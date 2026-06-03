function Format-XwfHexInternal {
    param(
        [AllowNull()]
        [object]$Value
    )

    if ($null -eq $Value) {
        return ''
    }

    return ('0x{0:x}' -f [uint64]$Value)
}

function Read-XwfUInt16AtInternal {
    param(
        [Parameter(Mandatory)]
        [System.IO.BinaryReader]$Reader,

        [Parameter(Mandatory)]
        [long]$Offset
    )

    $Reader.BaseStream.Seek($Offset, [System.IO.SeekOrigin]::Begin) | Out-Null
    return $Reader.ReadUInt16()
}

function Read-XwfUInt32AtInternal {
    param(
        [Parameter(Mandatory)]
        [System.IO.BinaryReader]$Reader,

        [Parameter(Mandatory)]
        [long]$Offset
    )

    $Reader.BaseStream.Seek($Offset, [System.IO.SeekOrigin]::Begin) | Out-Null
    return $Reader.ReadUInt32()
}

function Read-XwfUInt64AtInternal {
    param(
        [Parameter(Mandatory)]
        [System.IO.BinaryReader]$Reader,

        [Parameter(Mandatory)]
        [long]$Offset
    )

    $Reader.BaseStream.Seek($Offset, [System.IO.SeekOrigin]::Begin) | Out-Null
    return $Reader.ReadUInt64()
}

function Read-XwfAsciiStringAtOffsetInternal {
    param(
        [Parameter(Mandatory)]
        [System.IO.BinaryReader]$Reader,

        [Parameter(Mandatory)]
        [long]$Offset,

        [int]$MaxLength = 4096
    )

    if ($Offset -lt 0 -or $Offset -ge $Reader.BaseStream.Length) {
        return ''
    }

    $Reader.BaseStream.Seek($Offset, [System.IO.SeekOrigin]::Begin) | Out-Null
    $bytes = New-Object System.Collections.Generic.List[byte]
    while ($Reader.BaseStream.Position -lt $Reader.BaseStream.Length -and $bytes.Count -lt $MaxLength) {
        $value = $Reader.ReadByte()
        if ($value -eq 0) {
            break
        }
        $bytes.Add([byte]$value)
    }

    return [System.Text.Encoding]::ASCII.GetString($bytes.ToArray())
}

function ConvertFrom-XwfRvaInternal {
    param(
        [Parameter(Mandatory)]
        [object]$PeInfo,

        [Parameter(Mandatory)]
        [uint32]$Rva
    )

    if ($Rva -eq 0) {
        return $null
    }

    foreach ($section in @($PeInfo.sections)) {
        $span = [Math]::Max([uint32]$section.virtual_size, [uint32]$section.raw_size)
        if ($span -eq 0) {
            continue
        }

        $start = [uint32]$section.virtual_address
        $end = [uint64]$start + [uint64]$span
        if ([uint64]$Rva -ge [uint64]$start -and [uint64]$Rva -lt $end) {
            return [long]$section.raw_pointer + ([long]$Rva - [long]$start)
        }
    }

    if ($Rva -lt [uint32]$PeInfo.size_of_headers) {
        return [long]$Rva
    }

    return $null
}

function ConvertFrom-XwfDelayImportValueInternal {
    param(
        [Parameter(Mandatory)]
        [object]$PeInfo,

        [Parameter(Mandatory)]
        [uint32]$Value,

        [Parameter(Mandatory)]
        [uint32]$Attributes
    )

    if ($Value -eq 0) {
        return [uint32]0
    }

    if (($Attributes -band 1) -ne 0) {
        return $Value
    }

    if ([uint64]$Value -ge [uint64]$PeInfo.image_base) {
        return [uint32]([uint64]$Value - [uint64]$PeInfo.image_base)
    }

    return $Value
}

function Read-XwfAsciiStringAtRvaInternal {
    param(
        [Parameter(Mandatory)]
        [System.IO.BinaryReader]$Reader,

        [Parameter(Mandatory)]
        [object]$PeInfo,

        [Parameter(Mandatory)]
        [uint32]$Rva
    )

    $offset = ConvertFrom-XwfRvaInternal -PeInfo $PeInfo -Rva $Rva
    if ($null -eq $offset) {
        return ''
    }

    return Read-XwfAsciiStringAtOffsetInternal -Reader $Reader -Offset $offset
}

function Get-XwfPeInfoInternal {
    param(
        [Parameter(Mandatory)]
        [string]$Path
    )

    $resolvedPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Path)
    if (-not (Test-Path -LiteralPath $resolvedPath -PathType Leaf)) {
        throw "PE file not found: $resolvedPath"
    }

    $stream = [System.IO.File]::Open($resolvedPath, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read, [System.IO.FileShare]::ReadWrite)
    $reader = New-Object System.IO.BinaryReader($stream)
    try {
        if ((Read-XwfUInt16AtInternal -Reader $reader -Offset 0) -ne 0x5a4d) {
            throw "Not a PE file, missing MZ header: $resolvedPath"
        }

        $peOffset = Read-XwfUInt32AtInternal -Reader $reader -Offset 0x3c
        if ((Read-XwfUInt32AtInternal -Reader $reader -Offset $peOffset) -ne 0x00004550) {
            throw "Not a PE file, missing PE signature: $resolvedPath"
        }

        $coffOffset = [long]$peOffset + 4
        $machine = Read-XwfUInt16AtInternal -Reader $reader -Offset $coffOffset
        $sectionCount = Read-XwfUInt16AtInternal -Reader $reader -Offset ($coffOffset + 2)
        $timeDateStamp = Read-XwfUInt32AtInternal -Reader $reader -Offset ($coffOffset + 4)
        $optionalHeaderSize = Read-XwfUInt16AtInternal -Reader $reader -Offset ($coffOffset + 16)
        $optionalOffset = $coffOffset + 20
        $magic = Read-XwfUInt16AtInternal -Reader $reader -Offset $optionalOffset

        if ($magic -eq 0x20b) {
            $architecture = 'x64'
            $imageBase = Read-XwfUInt64AtInternal -Reader $reader -Offset ($optionalOffset + 24)
            $numberOfRvaAndSizes = Read-XwfUInt32AtInternal -Reader $reader -Offset ($optionalOffset + 108)
            $dataDirectoryOffset = $optionalOffset + 112
            $sizeOfHeaders = Read-XwfUInt32AtInternal -Reader $reader -Offset ($optionalOffset + 60)
        }
        elseif ($magic -eq 0x10b) {
            $architecture = 'x86'
            $imageBase = [uint64](Read-XwfUInt32AtInternal -Reader $reader -Offset ($optionalOffset + 28))
            $numberOfRvaAndSizes = Read-XwfUInt32AtInternal -Reader $reader -Offset ($optionalOffset + 92)
            $dataDirectoryOffset = $optionalOffset + 96
            $sizeOfHeaders = Read-XwfUInt32AtInternal -Reader $reader -Offset ($optionalOffset + 60)
        }
        else {
            throw ("Unsupported PE optional header magic {0}: {1}" -f (Format-XwfHexInternal $magic), $resolvedPath)
        }

        $directories = @()
        $directoryCount = [Math]::Min([int]$numberOfRvaAndSizes, 16)
        for ($index = 0; $index -lt $directoryCount; $index++) {
            $entryOffset = $dataDirectoryOffset + ($index * 8)
            $directories += [pscustomobject]@{
                index = $index
                virtual_address = Read-XwfUInt32AtInternal -Reader $reader -Offset $entryOffset
                size = Read-XwfUInt32AtInternal -Reader $reader -Offset ($entryOffset + 4)
            }
        }

        $sectionOffset = $optionalOffset + $optionalHeaderSize
        $sections = @()
        for ($index = 0; $index -lt $sectionCount; $index++) {
            $current = $sectionOffset + ($index * 40)
            $reader.BaseStream.Seek($current, [System.IO.SeekOrigin]::Begin) | Out-Null
            $nameBytes = $reader.ReadBytes(8)
            $nameLength = 0
            while ($nameLength -lt $nameBytes.Length -and $nameBytes[$nameLength] -ne 0) {
                $nameLength++
            }
            $name = [System.Text.Encoding]::ASCII.GetString($nameBytes, 0, $nameLength)
            $sections += [pscustomobject]@{
                name = $name
                virtual_size = Read-XwfUInt32AtInternal -Reader $reader -Offset ($current + 8)
                virtual_address = Read-XwfUInt32AtInternal -Reader $reader -Offset ($current + 12)
                raw_size = Read-XwfUInt32AtInternal -Reader $reader -Offset ($current + 16)
                raw_pointer = Read-XwfUInt32AtInternal -Reader $reader -Offset ($current + 20)
            }
        }

        return [pscustomobject]@{
            path = $resolvedPath
            architecture = $architecture
            machine = (Format-XwfHexInternal $machine)
            optional_header_magic = (Format-XwfHexInternal $magic)
            image_base = $imageBase
            image_base_hex = (Format-XwfHexInternal $imageBase)
            size_of_headers = $sizeOfHeaders
            timestamp = $timeDateStamp
            data_directories = @($directories)
            sections = @($sections)
        }
    }
    finally {
        $reader.Close()
        $stream.Close()
    }
}

function Get-XwfReferenceDirectoryInternal {
    $repoRoot = Resolve-XwfRepoRoot
    return (Join-Path $repoRoot 'data\xwf-external-surface')
}

function Import-XwfReferenceNamesInternal {
    param(
        [Parameter(Mandatory)]
        [string]$ReferenceDirectory,

        [Parameter(Mandatory)]
        [string]$FileName,

        [string[]]$FallbackNames = @()
    )

    $path = Join-Path $ReferenceDirectory $FileName
    if (Test-Path -LiteralPath $path -PathType Leaf) {
        return @(Import-Csv -LiteralPath $path | ForEach-Object { [string]$_.name } | Where-Object { $_ } | Sort-Object -Unique)
    }

    return @($FallbackNames | Sort-Object -Unique)
}

function Get-XwfCandidateExecutableInternal {
    param(
        [Parameter(Mandatory)]
        [string]$XwfRoot
    )

    $executables = @(Get-XwfPortableExecutable -XwfRoot $XwfRoot -IncludeAll)
    if ($executables.Count -eq 0) {
        throw "No X-Ways executables were found under $XwfRoot"
    }

    $preferredNames = @(
        'xwforensics64.exe',
        'winhexb64.exe',
        'xwb64.exe',
        'winhex64.exe',
        'xwforensics.exe',
        'winhex.exe',
        'winhexb.exe',
        'xwb.exe'
    )

    foreach ($name in $preferredNames) {
        $match = $executables | Where-Object { $_.name -ieq $name } | Select-Object -First 1
        if ($match) {
            return $match
        }
    }

    return ($executables | Sort-Object -Property name | Select-Object -First 1)
}

function Get-XwfApiFilesInternal {
    param(
        [string[]]$Path = @(),

        [string]$XwfRoot = ''
    )

    $files = New-Object System.Collections.Generic.List[string]
    foreach ($item in @($Path)) {
        if (-not $item) {
            continue
        }
        $resolved = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($item)
        if (Test-Path -LiteralPath $resolved -PathType Leaf) {
            $files.Add((Resolve-Path -LiteralPath $resolved).Path)
        }
        elseif (Test-Path -LiteralPath $resolved -PathType Container) {
            Get-ChildItem -LiteralPath $resolved -Recurse -File -ErrorAction SilentlyContinue |
                Where-Object { $_.Extension -match '^\.(exe|dll)$' } |
                ForEach-Object { $files.Add($_.FullName) }
        }
    }

    if ($XwfRoot) {
        $resolvedRoot = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($XwfRoot)
        Get-ChildItem -LiteralPath $resolvedRoot -Recurse -File -ErrorAction SilentlyContinue |
            Where-Object { $_.Extension -match '^\.(exe|dll)$' } |
            ForEach-Object { $files.Add($_.FullName) }
    }

    return @($files | Sort-Object -Unique)
}

function Get-XwfStringRunHitsInternal {
    param(
        [Parameter(Mandatory)]
        [byte[]]$Bytes,

        [Parameter(Mandatory)]
        [string]$EncodingName,

        [Parameter(Mandatory)]
        [string]$Pattern,

        [int]$MinLength = 4
    )

    $hits = New-Object System.Collections.Generic.List[object]
    $regex = [regex]$Pattern
    $builder = New-Object System.Text.StringBuilder
    $start = -1

    if ($EncodingName -eq 'ascii') {
        for ($index = 0; $index -lt $Bytes.Length; $index++) {
            $byte = $Bytes[$index]
            $isPrintable = ($byte -ge 0x20 -and $byte -le 0x7e)
            if ($isPrintable) {
                if ($start -lt 0) {
                    $start = $index
                }
                [void]$builder.Append([char]$byte)
                continue
            }

            if ($builder.Length -ge $MinLength) {
                $text = $builder.ToString()
                $matches = @($regex.Matches($text) | ForEach-Object { $_.Value } | Sort-Object -Unique)
                if ($matches.Count -gt 0) {
                    $hits.Add([pscustomobject]@{
                        offset = $start
                        encoding = 'ascii'
                        api_names = ($matches -join ';')
                        string = $text
                    })
                }
            }
            $builder.Clear() | Out-Null
            $start = -1
        }
    }
    elseif ($EncodingName -eq 'utf16le') {
        for ($index = 0; $index -lt ($Bytes.Length - 1); $index += 2) {
            $byte = $Bytes[$index]
            $zero = $Bytes[$index + 1]
            $isPrintable = ($zero -eq 0 -and $byte -ge 0x20 -and $byte -le 0x7e)
            if ($isPrintable) {
                if ($start -lt 0) {
                    $start = $index
                }
                [void]$builder.Append([char]$byte)
                continue
            }

            if ($builder.Length -ge $MinLength) {
                $text = $builder.ToString()
                $matches = @($regex.Matches($text) | ForEach-Object { $_.Value } | Sort-Object -Unique)
                if ($matches.Count -gt 0) {
                    $hits.Add([pscustomobject]@{
                        offset = $start
                        encoding = 'utf16le'
                        api_names = ($matches -join ';')
                        string = $text
                    })
                }
            }
            $builder.Clear() | Out-Null
            $start = -1
        }
    }

    if ($builder.Length -ge $MinLength) {
        $text = $builder.ToString()
        $matches = @($regex.Matches($text) | ForEach-Object { $_.Value } | Sort-Object -Unique)
        if ($matches.Count -gt 0) {
            $hits.Add([pscustomobject]@{
                offset = $start
                encoding = $EncodingName
                api_names = ($matches -join ';')
                string = $text
            })
        }
    }

    return $hits.ToArray()
}

function Get-XwfPortableExecutable {
    <#
    .SYNOPSIS
    Finds X-Ways-family portable executables and records identity metadata.

    .DESCRIPTION
    Searches one or more X-Ways roots for known executable names such as
    winhexb64.exe, xwb64.exe, xwforensics64.exe, and XWFIM.exe. The cmdlet reads
    file version metadata, SHA-256, and PE architecture without executing the
    file. Use -IncludeAll when investigating companion executables in the same
    folder.

    .PARAMETER XwfRoot
    One or more installation or portable roots to search recursively.

    .PARAMETER IncludeAll
    Return every .exe under the roots instead of only known X-Ways executable
    names.

    .EXAMPLE
    Get-XwfPortableExecutable -XwfRoot 'C:\Tools\xwfportable'
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string[]]$XwfRoot,

        [switch]$IncludeAll
    )

    $knownNames = @(
        'xwforensics.exe',
        'xwforensics64.exe',
        'winhex.exe',
        'winhex64.exe',
        'winhexb.exe',
        'winhexb64.exe',
        'xwb.exe',
        'xwb64.exe',
        'xwimager.exe',
        'xwimager64.exe',
        'XWFIM.exe'
    )

    foreach ($root in @($XwfRoot)) {
        $resolvedRoot = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($root)
        if (-not (Test-Path -LiteralPath $resolvedRoot -PathType Container)) {
            throw "X-Ways root not found: $resolvedRoot"
        }

        $candidateFiles = Get-ChildItem -LiteralPath $resolvedRoot -Recurse -File -ErrorAction SilentlyContinue |
            Where-Object {
                if ($IncludeAll) {
                    $_.Extension -ieq '.exe'
                }
                else {
                    $knownNames -icontains $_.Name
                }
            }

        foreach ($file in $candidateFiles) {
            $version = $file.VersionInfo
            $architecture = ''
            try {
                $architecture = (Get-XwfPeInfoInternal -Path $file.FullName).architecture
            }
            catch {
                $architecture = 'unknown'
            }

            [pscustomobject]@{
                path = $file.FullName
                name = $file.Name
                length = $file.Length
                sha256 = (Get-FileHash -LiteralPath $file.FullName -Algorithm SHA256).Hash.ToLowerInvariant()
                architecture = $architecture
                product_name = [string]$version.ProductName
                file_description = [string]$version.FileDescription
                file_version = [string]$version.FileVersion
                product_version = [string]$version.ProductVersion
                company_name = [string]$version.CompanyName
                original_filename = [string]$version.OriginalFilename
                is_known_xways_executable = ($knownNames -icontains $file.Name)
            }
        }
    }
}

function Get-XwfPeExternalFunction {
    <#
    .SYNOPSIS
    Lists imported and delay-imported external functions from a PE file.

    .DESCRIPTION
    Parses the PE import table and delay-load import table directly from disk
    using read-only byte access. The cmdlet does not load, execute, or call the
    target binary. Results include the DLL name, function name or ordinal, thunk
    RVA, IAT RVA, and whether the entry came from a normal import or delay
    import table.

    This is intended for tool-surface auditing of X-Ways executables or
    container-derived binaries. Do not run it directly against original evidence
    when the repo's container-first policy requires a derived source.

    .PARAMETER Path
    Path to a PE executable or DLL.

    .EXAMPLE
    Get-XwfPeExternalFunction -Path 'C:\Tools\xwfportable\winhexb64.exe' |
      Group-Object dll
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Alias('FullName')]
        [string]$Path
    )

    process {
        $peInfo = Get-XwfPeInfoInternal -Path $Path
        $importDirectory = @($peInfo.data_directories) | Where-Object { $_.index -eq 1 } | Select-Object -First 1
        $delayImportDirectory = @($peInfo.data_directories) | Where-Object { $_.index -eq 13 } | Select-Object -First 1
        $hasImportDirectory = ($importDirectory -and $importDirectory.virtual_address -ne 0)
        $hasDelayImportDirectory = ($delayImportDirectory -and $delayImportDirectory.virtual_address -ne 0)
        if (-not $hasImportDirectory -and -not $hasDelayImportDirectory) {
            return
        }

        $descriptorOffset = $null
        if ($hasImportDirectory) {
            $descriptorOffset = ConvertFrom-XwfRvaInternal -PeInfo $peInfo -Rva ([uint32]$importDirectory.virtual_address)
        }

        $stream = [System.IO.File]::Open($peInfo.path, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read, [System.IO.FileShare]::ReadWrite)
        $reader = New-Object System.IO.BinaryReader($stream)
        try {
            $ordinalFlag64 = [uint64]::Parse('8000000000000000', [System.Globalization.NumberStyles]::HexNumber)
            $ordinalMask64 = [uint64]::Parse('7fffffffffffffff', [System.Globalization.NumberStyles]::HexNumber)
            $ordinalFlag32 = [uint32]::Parse('80000000', [System.Globalization.NumberStyles]::HexNumber)
            $ordinalMask32 = [uint32]::Parse('7fffffff', [System.Globalization.NumberStyles]::HexNumber)
            $descriptorIndex = 0
            while ($null -ne $descriptorOffset -and $descriptorIndex -lt 4096) {
                $current = $descriptorOffset + ($descriptorIndex * 20)
                $originalFirstThunk = Read-XwfUInt32AtInternal -Reader $reader -Offset $current
                $timeDateStamp = Read-XwfUInt32AtInternal -Reader $reader -Offset ($current + 4)
                $forwarderChain = Read-XwfUInt32AtInternal -Reader $reader -Offset ($current + 8)
                $nameRva = Read-XwfUInt32AtInternal -Reader $reader -Offset ($current + 12)
                $firstThunk = Read-XwfUInt32AtInternal -Reader $reader -Offset ($current + 16)

                if ($originalFirstThunk -eq 0 -and $timeDateStamp -eq 0 -and $forwarderChain -eq 0 -and $nameRva -eq 0 -and $firstThunk -eq 0) {
                    break
                }

                $dllName = Read-XwfAsciiStringAtRvaInternal -Reader $reader -PeInfo $peInfo -Rva $nameRva
                $thunkRva = $originalFirstThunk
                if ($thunkRva -eq 0) {
                    $thunkRva = $firstThunk
                }

                $thunkOffset = ConvertFrom-XwfRvaInternal -PeInfo $peInfo -Rva ([uint32]$thunkRva)
                if ($null -ne $thunkOffset) {
                    $thunkSize = 4
                    if ($peInfo.architecture -eq 'x64') {
                        $thunkSize = 8
                    }

                    $thunkIndex = 0
                    while ($thunkIndex -lt 65536) {
                        $entryOffset = $thunkOffset + ($thunkIndex * $thunkSize)
                        if ($entryOffset -ge $reader.BaseStream.Length) {
                            break
                        }

                        if ($peInfo.architecture -eq 'x64') {
                            $value = Read-XwfUInt64AtInternal -Reader $reader -Offset $entryOffset
                            $isOrdinal = (($value -band $ordinalFlag64) -ne 0)
                            $namePointer = [uint32]($value -band $ordinalMask64)
                        }
                        else {
                            $value = Read-XwfUInt32AtInternal -Reader $reader -Offset $entryOffset
                            $isOrdinal = (($value -band $ordinalFlag32) -ne 0)
                            $namePointer = [uint32]($value -band $ordinalMask32)
                        }

                        if ($value -eq 0) {
                            break
                        }

                        $functionName = ''
                        $ordinal = $null
                        $hint = $null
                        if ($isOrdinal) {
                            $ordinal = [int]($value -band 0xffff)
                        }
                        else {
                            $nameOffset = ConvertFrom-XwfRvaInternal -PeInfo $peInfo -Rva $namePointer
                            if ($null -ne $nameOffset) {
                                $hint = Read-XwfUInt16AtInternal -Reader $reader -Offset $nameOffset
                                $functionName = Read-XwfAsciiStringAtOffsetInternal -Reader $reader -Offset ($nameOffset + 2)
                            }
                        }

                        [pscustomobject]@{
                            file = $peInfo.path
                            kind = 'import'
                            dll = $dllName
                            function = $functionName
                            ordinal = $ordinal
                            hint = $hint
                            thunk_rva = (Format-XwfHexInternal ([uint64]$thunkRva + [uint64]($thunkIndex * $thunkSize)))
                            iat_rva = (Format-XwfHexInternal ([uint64]$firstThunk + [uint64]($thunkIndex * $thunkSize)))
                        }

                        $thunkIndex++
                    }
                }

                $descriptorIndex++
            }

            if ($hasDelayImportDirectory) {
                $delayDescriptorOffset = ConvertFrom-XwfRvaInternal -PeInfo $peInfo -Rva ([uint32]$delayImportDirectory.virtual_address)
                $delayIndex = 0
                while ($null -ne $delayDescriptorOffset -and $delayIndex -lt 4096) {
                    $current = $delayDescriptorOffset + ($delayIndex * 32)
                    $attributes = Read-XwfUInt32AtInternal -Reader $reader -Offset $current
                    $nameValue = Read-XwfUInt32AtInternal -Reader $reader -Offset ($current + 4)
                    $moduleHandleValue = Read-XwfUInt32AtInternal -Reader $reader -Offset ($current + 8)
                    $iatValue = Read-XwfUInt32AtInternal -Reader $reader -Offset ($current + 12)
                    $intValue = Read-XwfUInt32AtInternal -Reader $reader -Offset ($current + 16)
                    $boundIatValue = Read-XwfUInt32AtInternal -Reader $reader -Offset ($current + 20)
                    $unloadIatValue = Read-XwfUInt32AtInternal -Reader $reader -Offset ($current + 24)
                    $timestampValue = Read-XwfUInt32AtInternal -Reader $reader -Offset ($current + 28)

                    if ($attributes -eq 0 -and $nameValue -eq 0 -and $moduleHandleValue -eq 0 -and $iatValue -eq 0 -and $intValue -eq 0 -and $boundIatValue -eq 0 -and $unloadIatValue -eq 0 -and $timestampValue -eq 0) {
                        break
                    }

                    $nameRva = ConvertFrom-XwfDelayImportValueInternal -PeInfo $peInfo -Value $nameValue -Attributes $attributes
                    $iatRva = ConvertFrom-XwfDelayImportValueInternal -PeInfo $peInfo -Value $iatValue -Attributes $attributes
                    $intRva = ConvertFrom-XwfDelayImportValueInternal -PeInfo $peInfo -Value $intValue -Attributes $attributes
                    if ($intRva -eq 0) {
                        $intRva = $iatRva
                    }

                    $dllName = Read-XwfAsciiStringAtRvaInternal -Reader $reader -PeInfo $peInfo -Rva $nameRva
                    $thunkOffset = ConvertFrom-XwfRvaInternal -PeInfo $peInfo -Rva $intRva
                    if ($null -ne $thunkOffset) {
                        $thunkSize = 4
                        if ($peInfo.architecture -eq 'x64') {
                            $thunkSize = 8
                        }

                        $thunkIndex = 0
                        while ($thunkIndex -lt 65536) {
                            $entryOffset = $thunkOffset + ($thunkIndex * $thunkSize)
                            if ($entryOffset -ge $reader.BaseStream.Length) {
                                break
                            }

                            if ($peInfo.architecture -eq 'x64') {
                                $value = Read-XwfUInt64AtInternal -Reader $reader -Offset $entryOffset
                                $isOrdinal = (($value -band $ordinalFlag64) -ne 0)
                                $namePointer = [uint32]($value -band $ordinalMask64)
                            }
                            else {
                                $value = Read-XwfUInt32AtInternal -Reader $reader -Offset $entryOffset
                                $isOrdinal = (($value -band $ordinalFlag32) -ne 0)
                                $namePointer = [uint32]($value -band $ordinalMask32)
                            }

                            if ($value -eq 0) {
                                break
                            }

                            $functionName = ''
                            $ordinal = $null
                            $hint = $null
                            if ($isOrdinal) {
                                $ordinal = [int]($value -band 0xffff)
                            }
                            else {
                                $nameOffset = ConvertFrom-XwfRvaInternal -PeInfo $peInfo -Rva $namePointer
                                if ($null -ne $nameOffset) {
                                    $hint = Read-XwfUInt16AtInternal -Reader $reader -Offset $nameOffset
                                    $functionName = Read-XwfAsciiStringAtOffsetInternal -Reader $reader -Offset ($nameOffset + 2)
                                }
                            }

                            [pscustomobject]@{
                                file = $peInfo.path
                                kind = 'delay_import'
                                dll = $dllName
                                function = $functionName
                                ordinal = $ordinal
                                hint = $hint
                                thunk_rva = (Format-XwfHexInternal ([uint64]$intRva + [uint64]($thunkIndex * $thunkSize)))
                                iat_rva = (Format-XwfHexInternal ([uint64]$iatRva + [uint64]($thunkIndex * $thunkSize)))
                            }

                            $thunkIndex++
                        }
                    }

                    $delayIndex++
                }
            }
        }
        finally {
            $reader.Close()
            $stream.Close()
        }
    }
}

function Get-XwfPeExport {
    <#
    .SYNOPSIS
    Lists PE export-table entries from an executable or DLL.

    .DESCRIPTION
    Parses the PE export directory and returns export names, ordinals, and RVAs.
    For X-Ways Forensics and WinHex binaries this identifies callable exported
    X-Tensions API functions such as XWF_GetItemName or XWF_Read. The cmdlet is
    read-only and never loads the target binary.

    .PARAMETER Path
    Path to a PE executable or DLL.

    .EXAMPLE
    Get-XwfPeExport -Path 'C:\Tools\xwfportable\winhexb64.exe' |
      Where-Object name -like 'XWF_*'
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Alias('FullName')]
        [string]$Path
    )

    process {
        $peInfo = Get-XwfPeInfoInternal -Path $Path
        $exportDirectory = @($peInfo.data_directories) | Where-Object { $_.index -eq 0 } | Select-Object -First 1
        if (-not $exportDirectory -or $exportDirectory.virtual_address -eq 0) {
            return
        }

        $exportOffset = ConvertFrom-XwfRvaInternal -PeInfo $peInfo -Rva ([uint32]$exportDirectory.virtual_address)
        if ($null -eq $exportOffset) {
            return
        }

        $stream = [System.IO.File]::Open($peInfo.path, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read, [System.IO.FileShare]::ReadWrite)
        $reader = New-Object System.IO.BinaryReader($stream)
        try {
            $baseOrdinal = Read-XwfUInt32AtInternal -Reader $reader -Offset ($exportOffset + 16)
            $numberOfFunctions = Read-XwfUInt32AtInternal -Reader $reader -Offset ($exportOffset + 20)
            $numberOfNames = Read-XwfUInt32AtInternal -Reader $reader -Offset ($exportOffset + 24)
            $addressOfFunctions = Read-XwfUInt32AtInternal -Reader $reader -Offset ($exportOffset + 28)
            $addressOfNames = Read-XwfUInt32AtInternal -Reader $reader -Offset ($exportOffset + 32)
            $addressOfNameOrdinals = Read-XwfUInt32AtInternal -Reader $reader -Offset ($exportOffset + 36)

            $functionTableOffset = ConvertFrom-XwfRvaInternal -PeInfo $peInfo -Rva $addressOfFunctions
            $nameTableOffset = ConvertFrom-XwfRvaInternal -PeInfo $peInfo -Rva $addressOfNames
            $ordinalTableOffset = ConvertFrom-XwfRvaInternal -PeInfo $peInfo -Rva $addressOfNameOrdinals
            if ($null -eq $functionTableOffset) {
                return
            }

            $nameByOrdinalIndex = @{}
            if ($null -ne $nameTableOffset -and $null -ne $ordinalTableOffset) {
                for ($index = 0; $index -lt $numberOfNames; $index++) {
                    $nameRva = Read-XwfUInt32AtInternal -Reader $reader -Offset ($nameTableOffset + ($index * 4))
                    $ordinalIndex = Read-XwfUInt16AtInternal -Reader $reader -Offset ($ordinalTableOffset + ($index * 2))
                    $nameByOrdinalIndex[[int]$ordinalIndex] = Read-XwfAsciiStringAtRvaInternal -Reader $reader -PeInfo $peInfo -Rva $nameRva
                }
            }

            for ($index = 0; $index -lt $numberOfFunctions; $index++) {
                $rva = Read-XwfUInt32AtInternal -Reader $reader -Offset ($functionTableOffset + ($index * 4))
                if ($rva -eq 0) {
                    continue
                }

                $name = ''
                if ($nameByOrdinalIndex.ContainsKey($index)) {
                    $name = [string]$nameByOrdinalIndex[$index]
                }

                [pscustomobject]@{
                    file = $peInfo.path
                    name = $name
                    ordinal = [int]([uint32]$baseOrdinal + [uint32]$index)
                    rva = (Format-XwfHexInternal $rva)
                }
            }
        }
        finally {
            $reader.Close()
            $stream.Close()
        }
    }
}

function Get-XwfApiString {
    <#
    .SYNOPSIS
    Finds XWF_* and XT_* API-like strings in PE files.

    .DESCRIPTION
    Scans ASCII and UTF-16LE printable strings in executables and DLLs for
    X-Ways API-looking names. This is useful for finding X-Tension callback
    names that are resolved dynamically and for flagging undocumented-looking
    string clues such as XWF_EDB. String presence alone does not prove that a
    name is callable.

    .PARAMETER Path
    One or more files or directories to scan. Directories are searched
    recursively for .exe and .dll files.

    .PARAMETER XwfRoot
    X-Ways root to scan recursively for .exe and .dll files.

    .PARAMETER Pattern
    Regex used to extract API-like names. The default matches XWF_* and XT_*.

    .PARAMETER MinLength
    Minimum printable string length to consider.

    .EXAMPLE
    Get-XwfApiString -Path 'C:\Tools\xwfportable\winhexb64.exe' |
      Where-Object api_names -match 'XWF_EDB|XT_'
    #>
    [CmdletBinding()]
    param(
        [string[]]$Path = @(),

        [string]$XwfRoot = '',

        [string]$Pattern = '\b(?:XWF|XT)_[A-Za-z0-9_]+\b',

        [int]$MinLength = 4
    )

    $files = Get-XwfApiFilesInternal -Path $Path -XwfRoot $XwfRoot
    foreach ($file in $files) {
        $bytes = [System.IO.File]::ReadAllBytes($file)
        $asciiHits = Get-XwfStringRunHitsInternal -Bytes $bytes -EncodingName 'ascii' -Pattern $Pattern -MinLength $MinLength
        $unicodeHits = Get-XwfStringRunHitsInternal -Bytes $bytes -EncodingName 'utf16le' -Pattern $Pattern -MinLength $MinLength

        foreach ($hit in @($asciiHits + $unicodeHits)) {
            [pscustomobject]@{
                file = $file
                offset = (Format-XwfHexInternal $hit.offset)
                encoding = $hit.encoding
                api_names = $hit.api_names
                string = $hit.string
            }
        }
    }
}

function Compare-XwfExternalSurface {
    <#
    .SYNOPSIS
    Compares a local X-Ways executable against the documented XWF/XT surface.

    .DESCRIPTION
    Discovers or accepts a target executable, parses imports, delay imports, PE
    exports, and API-like strings, then compares the result with the repo's
    documented XWF function and XT callback reference data. The returned object
    includes counts, exported XWF functions, documented functions absent from
    the export table, found XT callbacks, undocumented-looking string
    candidates, and the raw import/export/string objects.

    Pass -OutputDirectory to also write Markdown, JSON, and CSV artifacts that
    can be attached to an MCP/harness run without putting raw case facts in
    chat.

    .PARAMETER XwfRoot
    X-Ways root used for executable discovery.

    .PARAMETER ExecutablePath
    Optional explicit executable path. If omitted, the cmdlet prefers 64-bit
    X-Ways/WinHex executables found under XwfRoot.

    .PARAMETER ReferenceDirectory
    Optional directory containing documented-xwf-functions.csv and
    documented-xt-callbacks.csv.

    .PARAMETER OutputDirectory
    Optional output directory for report artifacts.

    .EXAMPLE
    Compare-XwfExternalSurface -XwfRoot 'C:\Tools\xwfportable' -OutputDirectory '.\reports\xwf-surface'
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$XwfRoot,

        [string]$ExecutablePath = '',

        [string]$ReferenceDirectory = '',

        [string]$OutputDirectory = ''
    )

    if (-not $ReferenceDirectory) {
        $ReferenceDirectory = Get-XwfReferenceDirectoryInternal
    }

    if ($ExecutablePath) {
        $resolvedExecutable = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($ExecutablePath)
        $executable = Get-XwfPortableExecutable -XwfRoot (Split-Path -Parent $resolvedExecutable) -IncludeAll |
            Where-Object { $_.path -ieq $resolvedExecutable } |
            Select-Object -First 1
        if (-not $executable) {
            throw "Executable was not found or is not parseable: $resolvedExecutable"
        }
    }
    else {
        $executable = Get-XwfCandidateExecutableInternal -XwfRoot $XwfRoot
    }

    $imports = @(Get-XwfPeExternalFunction -Path $executable.path)
    $exports = @(Get-XwfPeExport -Path $executable.path)
    $xwfExports = @($exports | Where-Object { $_.name -like 'XWF_*' } | Sort-Object -Property name)
    $apiStrings = @(Get-XwfApiString -Path $executable.path)

    $binaryNames = @(
        $apiStrings |
            ForEach-Object { ([string]$_.api_names) -split ';' } |
            Where-Object { $_ } |
            Sort-Object -Unique
    )

    $documentedXwfFallback = @(
        @($xwfExports | ForEach-Object { $_.name }) +
        @('XWF_AddSearchHit', 'XWF_DeleteEvObj', 'XWF_GetDriveInfo', 'XWF_GetSearchHit', 'XWF_SetItemDataRuns', 'XWF_SetItemName', 'XWF_SetSearchHit', 'XWF_Write')
    ) | Sort-Object -Unique
    $documentedXtFallback = @(
        'XT_Init', 'XT_Done', 'XT_About', 'XT_Prepare', 'XT_Finalize',
        'XT_ProcessItem', 'XT_ProcessItemEx', 'XT_PrepareSearch',
        'XT_ProcessSearchHit', 'XT_View', 'XT_ReleaseMem', 'XT_FileIO',
        'XT_SectorIOInit', 'XT_SectorIO', 'XT_SectorIODone'
    )

    $documentedXwf = Import-XwfReferenceNamesInternal -ReferenceDirectory $ReferenceDirectory -FileName 'documented-xwf-functions.csv' -FallbackNames $documentedXwfFallback
    $documentedXt = Import-XwfReferenceNamesInternal -ReferenceDirectory $ReferenceDirectory -FileName 'documented-xt-callbacks.csv' -FallbackNames $documentedXtFallback
    $documentedCallableNames = @($documentedXwf + $documentedXt | Sort-Object -Unique)

    $exportNameSet = @{}
    foreach ($name in @($xwfExports | ForEach-Object { $_.name })) {
        $exportNameSet[$name] = $true
    }

    $documentedMissingExports = @(
        $documentedXwf |
            Where-Object { -not $exportNameSet.ContainsKey($_) } |
            Sort-Object
    )

    $binaryNameSet = @{}
    foreach ($name in $binaryNames) {
        $binaryNameSet[$name] = $true
    }

    $xtCallbacksFound = @(
        $documentedXt |
            Where-Object { $binaryNameSet.ContainsKey($_) } |
            Sort-Object
    )

    $documentedNameSet = @{}
    foreach ($name in $documentedCallableNames) {
        $documentedNameSet[$name] = $true
    }

    $undocumentedCandidates = @(
        $binaryNames |
            Where-Object { -not $documentedNameSet.ContainsKey($_) } |
            Sort-Object |
            ForEach-Object {
                $name = $_
                $locations = @(
                    $apiStrings |
                        Where-Object { ((';{0};' -f $_.api_names) -like ('*;{0};*' -f $name)) } |
                        ForEach-Object { '{0}@{1}' -f (Split-Path -Leaf $_.file), $_.offset }
                )

                $assessment = 'Name appears in binary strings but is not in the documented callable XWF/XT reference set. Confirm callability with xrefs before use.'
                if ($name -eq 'XT_error') {
                    $assessment = 'Appears as part of XT_error.log; treat as a log filename unless xrefs prove otherwise.'
                }
                elseif ($name -eq 'XWF_EDB') {
                    $assessment = 'Bare string and not an exported XWF_* function in the 21.8 x64 baseline; plausible undocumented clue, not proven callable.'
                }

                [pscustomobject]@{
                    name = $name
                    locations = ($locations | Sort-Object -Unique)
                    assessment = $assessment
                }
            }
    )

    $importDlls = @{}
    foreach ($group in ($imports | Group-Object -Property dll | Sort-Object -Property Name)) {
        $importDlls[$group.Name] = $group.Count
    }

    $result = [pscustomobject]@{
        analyzed_at_utc = (Get-Date).ToUniversalTime().ToString('o')
        xwf_root = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($XwfRoot)
        executable = $executable
        import_count = $imports.Count
        xwf_export_count = $xwfExports.Count
        import_dlls = $importDlls
        documented_xwf_function_count = $documentedXwf.Count
        documented_xt_callback_count = $documentedXt.Count
        documented_xwf_missing_exports = @($documentedMissingExports)
        xt_callbacks_found = @($xtCallbacksFound)
        binary_api_names = @($binaryNames)
        undocumented_candidates = @($undocumentedCandidates)
        imports = @($imports)
        xwf_exports = @($xwfExports)
        api_strings = @($apiStrings)
    }

    if ($OutputDirectory) {
        Export-XwfExternalSurfaceReport -Comparison $result -OutputDirectory $OutputDirectory | Out-Null
    }

    return $result
}

function Export-XwfExternalSurfaceReport {
    <#
    .SYNOPSIS
    Writes external-surface comparison artifacts to disk.

    .DESCRIPTION
    Exports a Compare-XwfExternalSurface result to a Markdown summary, JSON
    summary, import CSV, XWF export CSV, and API string-hit CSV. The report
    records cautionary assessments for undocumented-looking strings and links
    the machine-readable artifacts produced by the run.

    .PARAMETER Comparison
    Existing comparison object from Compare-XwfExternalSurface. May be supplied
    by pipeline.

    .PARAMETER XwfRoot
    X-Ways root to analyze if -Comparison is not supplied.

    .PARAMETER ExecutablePath
    Optional explicit executable path when analyzing by -XwfRoot.

    .PARAMETER OutputDirectory
    Destination directory for report artifacts.

    .EXAMPLE
    Compare-XwfExternalSurface -XwfRoot 'C:\Tools\xwfportable' |
      Export-XwfExternalSurfaceReport -OutputDirectory '.\surface-report'
    #>
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline)]
        [object]$Comparison,

        [string]$XwfRoot = '',

        [string]$ExecutablePath = '',

        [Parameter(Mandatory)]
        [string]$OutputDirectory
    )

    process {
        if (-not $Comparison) {
            if (-not $XwfRoot) {
                throw 'Pass -Comparison or -XwfRoot.'
            }
            $Comparison = Compare-XwfExternalSurface -XwfRoot $XwfRoot -ExecutablePath $ExecutablePath
        }

        $resolvedOutput = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($OutputDirectory)
        New-Item -ItemType Directory -Path $resolvedOutput -Force | Out-Null

        $importsPath = Join-Path $resolvedOutput 'xwf-external-imports.csv'
        $exportsPath = Join-Path $resolvedOutput 'xwf-exports.csv'
        $stringsPath = Join-Path $resolvedOutput 'xwf-api-strings.csv'
        $summaryPath = Join-Path $resolvedOutput 'xwf-external-surface-summary.json'
        $reportPath = Join-Path $resolvedOutput 'xwf-external-surface-report.md'

        @($Comparison.imports) | Export-Csv -LiteralPath $importsPath -NoTypeInformation -Encoding UTF8
        @($Comparison.xwf_exports) | Export-Csv -LiteralPath $exportsPath -NoTypeInformation -Encoding UTF8
        @($Comparison.api_strings) | Export-Csv -LiteralPath $stringsPath -NoTypeInformation -Encoding UTF8

        $summary = [ordered]@{
            analyzed_at_utc = $Comparison.analyzed_at_utc
            executable = $Comparison.executable.path
            executable_name = $Comparison.executable.name
            sha256 = $Comparison.executable.sha256
            architecture = $Comparison.executable.architecture
            product_name = $Comparison.executable.product_name
            product_version = $Comparison.executable.product_version
            import_count = $Comparison.import_count
            xwf_export_count = $Comparison.xwf_export_count
            documented_xwf_function_count = $Comparison.documented_xwf_function_count
            documented_xt_callback_count = $Comparison.documented_xt_callback_count
            documented_xwf_missing_exports = @($Comparison.documented_xwf_missing_exports)
            xt_callbacks_found = @($Comparison.xt_callbacks_found)
            undocumented_candidates = @($Comparison.undocumented_candidates)
            import_dlls = $Comparison.import_dlls
        }
        $summary | ConvertTo-Json -Depth 12 | Set-Content -LiteralPath $summaryPath -Encoding UTF8

        $candidateLines = @($Comparison.undocumented_candidates | ForEach-Object {
            $locations = (@($_.locations) -join '; ')
            '- `{0}`: {1} Locations: {2}' -f $_.name, $_.assessment, $locations
        })
        if ($candidateLines.Count -eq 0) {
            $candidateLines = @('- None found.')
        }

        $missingLines = @($Comparison.documented_xwf_missing_exports | ForEach-Object { '- `{0}`' -f $_ })
        if ($missingLines.Count -eq 0) {
            $missingLines = @('- None.')
        }

        $callbackText = (@($Comparison.xt_callbacks_found) -join ', ')
        if (-not $callbackText) {
            $callbackText = 'None found.'
        }

        $markdown = @(
            '# X-Ways External Surface Report'
            ''
            "Analyzed UTC: $($Comparison.analyzed_at_utc)"
            ''
            ('Executable: `{0}`' -f $Comparison.executable.path)
            ('SHA-256: `{0}`' -f $Comparison.executable.sha256)
            ('Architecture: `{0}`' -f $Comparison.executable.architecture)
            ('Product: `{0} {1}`' -f $Comparison.executable.product_name, $Comparison.executable.product_version)
            ''
            '## Counts'
            ''
            "- Imported external functions: $($Comparison.import_count)"
            ('- Exported `XWF_*` functions: {0}' -f $Comparison.xwf_export_count)
            ('- Documented callable `XWF_*` reference names: {0}' -f $Comparison.documented_xwf_function_count)
            ('- Documented `XT_*` callbacks found in strings: {0}' -f @($Comparison.xt_callbacks_found).Count)
            ''
            '## Documented XWF Functions Missing From Export Table'
            ''
            ($missingLines -join "`r`n")
            ''
            '## XT Callback Names Found'
            ''
            $callbackText
            ''
            '## Undocumented-Looking Candidates'
            ''
            ($candidateLines -join "`r`n")
            ''
            '## Artifact Files'
            ''
            ('- Imports CSV: `{0}`' -f $importsPath)
            ('- XWF exports CSV: `{0}`' -f $exportsPath)
            ('- API string hits CSV: `{0}`' -f $stringsPath)
            ('- Summary JSON: `{0}`' -f $summaryPath)
        ) -join "`r`n"
        $markdown | Set-Content -LiteralPath $reportPath -Encoding UTF8

        return [pscustomobject]@{
            output_directory = $resolvedOutput
            report_markdown = $reportPath
            summary_json = $summaryPath
            imports_csv = $importsPath
            xwf_exports_csv = $exportsPath
            api_strings_csv = $stringsPath
        }
    }
}
