#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <wchar.h>
#include <wctype.h>

#define XWF_ITEM_INFO_ATTR 2
#define XWF_ITEM_INFO_FLAGS 3
#define XWF_ITEM_INFO_DELETION 4
#define XWF_ITEM_INFO_CLASSIFICATION 5
#define XWF_ITEM_INFO_CREATIONTIME 32
#define XWF_ITEM_INFO_MODIFICATIONTIME 33
#define XWF_ITEM_INFO_LASTACCESSTIME 34
#define XWF_ITEM_INFO_ENTRYMODIFICATIONTIME 35
#define XWF_ITEM_INFO_DELETIONTIME 36
#define XWF_ITEM_INFO_INTERNALCREATIONTIME 37

typedef DWORD(__stdcall *PFN_XWF_GetItemCount)(LPVOID pTarget);
typedef LPWSTR(__stdcall *PFN_XWF_GetItemName)(DWORD nItemID);
typedef LONG(__stdcall *PFN_XWF_GetItemParent)(LONG nItemID);
typedef INT64(__stdcall *PFN_XWF_GetItemSize)(LONG nItemID);
typedef INT64(__stdcall *PFN_XWF_GetItemInformation)(LONG nItemID, LONG nInfoType, LPBOOL lpSuccess);
typedef HANDLE(__stdcall *PFN_XWF_GetFirstEvObj)(LPVOID pReserved);
typedef HANDLE(__stdcall *PFN_XWF_GetNextEvObj)(HANDLE hPrevEvidence, LPVOID pReserved);
typedef HANDLE(__stdcall *PFN_XWF_OpenEvObj)(HANDLE hEvidence, DWORD nFlags);
typedef VOID(__stdcall *PFN_XWF_CloseEvObj)(HANDLE hEvidence);
typedef INT64(__stdcall *PFN_XWF_GetEvObjProp)(HANDLE hEvidence, DWORD nPropType, PVOID lpBuffer);
typedef LONG(__stdcall *PFN_XWF_SelectVolumeSnapshot)(HANDLE hVolume);
typedef VOID(__stdcall *PFN_XWF_OutputMessage)(LPWSTR lpMessage, DWORD nFlags);

static PFN_XWF_GetItemCount pXWF_GetItemCount = NULL;
static PFN_XWF_GetItemName pXWF_GetItemName = NULL;
static PFN_XWF_GetItemParent pXWF_GetItemParent = NULL;
static PFN_XWF_GetItemSize pXWF_GetItemSize = NULL;
static PFN_XWF_GetItemInformation pXWF_GetItemInformation = NULL;
static PFN_XWF_GetFirstEvObj pXWF_GetFirstEvObj = NULL;
static PFN_XWF_GetNextEvObj pXWF_GetNextEvObj = NULL;
static PFN_XWF_OpenEvObj pXWF_OpenEvObj = NULL;
static PFN_XWF_CloseEvObj pXWF_CloseEvObj = NULL;
static PFN_XWF_GetEvObjProp pXWF_GetEvObjProp = NULL;
static PFN_XWF_SelectVolumeSnapshot pXWF_SelectVolumeSnapshot = NULL;
static PFN_XWF_OutputMessage pXWF_OutputMessage = NULL;

static wchar_t g_output_path[MAX_PATH * 4] = L"";
static bool g_output_all = false;
static bool g_loaded = false;
static bool g_ran_case_enumeration = false;

static FARPROC resolve_symbol(HMODULE host, const char *name) {
    return host ? GetProcAddress(host, name) : NULL;
}

static bool load_xwf_functions(void) {
    if (g_loaded) {
        return true;
    }

    HMODULE host = GetModuleHandleW(NULL);
    pXWF_GetItemCount = (PFN_XWF_GetItemCount)resolve_symbol(host, "XWF_GetItemCount");
    pXWF_GetItemName = (PFN_XWF_GetItemName)resolve_symbol(host, "XWF_GetItemName");
    pXWF_GetItemParent = (PFN_XWF_GetItemParent)resolve_symbol(host, "XWF_GetItemParent");
    pXWF_GetItemSize = (PFN_XWF_GetItemSize)resolve_symbol(host, "XWF_GetItemSize");
    pXWF_GetItemInformation = (PFN_XWF_GetItemInformation)resolve_symbol(host, "XWF_GetItemInformation");
    pXWF_GetFirstEvObj = (PFN_XWF_GetFirstEvObj)resolve_symbol(host, "XWF_GetFirstEvObj");
    pXWF_GetNextEvObj = (PFN_XWF_GetNextEvObj)resolve_symbol(host, "XWF_GetNextEvObj");
    pXWF_OpenEvObj = (PFN_XWF_OpenEvObj)resolve_symbol(host, "XWF_OpenEvObj");
    pXWF_CloseEvObj = (PFN_XWF_CloseEvObj)resolve_symbol(host, "XWF_CloseEvObj");
    pXWF_GetEvObjProp = (PFN_XWF_GetEvObjProp)resolve_symbol(host, "XWF_GetEvObjProp");
    pXWF_SelectVolumeSnapshot = (PFN_XWF_SelectVolumeSnapshot)resolve_symbol(host, "XWF_SelectVolumeSnapshot");
    pXWF_OutputMessage = (PFN_XWF_OutputMessage)resolve_symbol(host, "XWF_OutputMessage");

    g_loaded = pXWF_GetItemCount && pXWF_GetItemName && pXWF_GetItemParent &&
               pXWF_GetItemSize && pXWF_GetItemInformation &&
               pXWF_GetFirstEvObj && pXWF_GetNextEvObj && pXWF_OpenEvObj &&
               pXWF_CloseEvObj && pXWF_GetEvObjProp && pXWF_SelectVolumeSnapshot;
    return g_loaded;
}

static void output_message(const wchar_t *message) {
    if (pXWF_OutputMessage && message) {
        pXWF_OutputMessage((LPWSTR)message, 0);
    }
}

static wchar_t *dup_wstr(const wchar_t *value) {
    if (!value) {
        value = L"";
    }
    size_t len = wcslen(value) + 1;
    wchar_t *copy = (wchar_t *)HeapAlloc(GetProcessHeap(), HEAP_ZERO_MEMORY, len * sizeof(wchar_t));
    if (!copy) {
        return NULL;
    }
    wcscpy_s(copy, len, value);
    return copy;
}

static bool contains_i(const wchar_t *haystack, const wchar_t *needle) {
    if (!haystack || !needle || !*needle) {
        return false;
    }

    size_t needle_len = wcslen(needle);
    for (const wchar_t *h = haystack; *h; ++h) {
        size_t i = 0;
        while (i < needle_len && h[i] &&
               towlower((wint_t)h[i]) == towlower((wint_t)needle[i])) {
            ++i;
        }
        if (i == needle_len) {
            return true;
        }
    }
    return false;
}

static bool parse_xtparam_value(const wchar_t *marker, wchar_t *buffer, size_t buffer_cch) {
    const wchar_t *cmd = GetCommandLineW();
    const wchar_t *found = wcsstr(cmd, marker);
    if (!found) {
        return false;
    }

    bool quoted_arg = (found > cmd && *(found - 1) == L'"');
    const wchar_t *value = found + wcslen(marker);
    size_t i = 0;
    while (*value && i + 1 < buffer_cch) {
        if (quoted_arg) {
            if (*value == L'"') {
                break;
            }
        } else if (*value == L'"' || iswspace((wint_t)*value)) {
            break;
        }
        buffer[i++] = *value++;
    }
    buffer[i] = L'\0';
    return i > 0;
}

static void initialize_options(void) {
    if (g_output_path[0]) {
        return;
    }

    DWORD env_len = GetEnvironmentVariableW(L"XWF_PATH_EXPORT_OUT", g_output_path, ARRAYSIZE(g_output_path));
    if (env_len == 0 || env_len >= ARRAYSIZE(g_output_path)) {
        parse_xtparam_value(L"XTParam:XWFPathExport:", g_output_path, ARRAYSIZE(g_output_path));
    }

    wchar_t mode[64] = L"";
    if (parse_xtparam_value(L"XTParam:XWFPathExportMode:", mode, ARRAYSIZE(mode))) {
        g_output_all = (_wcsicmp(mode, L"all") == 0);
    }

    if (!g_output_path[0]) {
        wchar_t temp_dir[MAX_PATH] = L"";
        GetTempPathW(ARRAYSIZE(temp_dir), temp_dir);
        swprintf_s(g_output_path, ARRAYSIZE(g_output_path), L"%sxwf-path-export.jsonl", temp_dir);
    }
}

static FILE *open_output(void) {
    initialize_options();
    return _wfopen(g_output_path, L"ab");
}

static void write_json_wstr(FILE *out, const wchar_t *value) {
    fputc('"', out);
    if (value) {
        int needed = WideCharToMultiByte(CP_UTF8, 0, value, -1, NULL, 0, NULL, NULL);
        if (needed > 0) {
            char *utf8 = (char *)HeapAlloc(GetProcessHeap(), 0, (SIZE_T)needed);
            if (utf8 && WideCharToMultiByte(CP_UTF8, 0, value, -1, utf8, needed, NULL, NULL) > 0) {
                for (char *p = utf8; *p; ++p) {
                    unsigned char ch = (unsigned char)*p;
                    switch (ch) {
                    case '\\':
                        fputs("\\\\", out);
                        break;
                    case '"':
                        fputs("\\\"", out);
                        break;
                    case '\b':
                        fputs("\\b", out);
                        break;
                    case '\f':
                        fputs("\\f", out);
                        break;
                    case '\n':
                        fputs("\\n", out);
                        break;
                    case '\r':
                        fputs("\\r", out);
                        break;
                    case '\t':
                        fputs("\\t", out);
                        break;
                    default:
                        if (ch < 0x20) {
                            fprintf(out, "\\u%04x", ch);
                        } else {
                            fputc(ch, out);
                        }
                        break;
                    }
                }
            }
            if (utf8) {
                HeapFree(GetProcessHeap(), 0, utf8);
            }
        }
    }
    fputc('"', out);
}

static INT64 item_info(LONG item_id, LONG info_type, bool *ok) {
    BOOL success = FALSE;
    INT64 value = pXWF_GetItemInformation(item_id, info_type, &success);
    if (ok) {
        *ok = !!success;
    }
    return value;
}

static void write_nullable_i64(FILE *out, bool ok, INT64 value) {
    if (ok) {
        fprintf(out, "%lld", (long long)value);
    } else {
        fputs("null", out);
    }
}

static wchar_t *build_item_path(LONG item_id) {
    wchar_t *segments[1024];
    ZeroMemory(segments, sizeof(segments));
    int segment_count = 0;
    LONG current = item_id;

    for (int guard = 0; current >= 0 && guard < (int)ARRAYSIZE(segments); ++guard) {
        LPWSTR name = pXWF_GetItemName((DWORD)current);
        segments[segment_count] = dup_wstr(name ? name : L"");
        if (!segments[segment_count]) {
            break;
        }
        ++segment_count;
        LONG parent = pXWF_GetItemParent(current);
        if (parent < 0) {
            break;
        }
        current = parent;
    }

    size_t total = 1;
    for (int i = 0; i < segment_count; ++i) {
        total += wcslen(segments[i]) + 1;
    }

    wchar_t *path = (wchar_t *)HeapAlloc(GetProcessHeap(), HEAP_ZERO_MEMORY, total * sizeof(wchar_t));
    if (!path) {
        for (int i = 0; i < segment_count; ++i) {
            HeapFree(GetProcessHeap(), 0, segments[i]);
        }
        return NULL;
    }

    for (int i = segment_count - 1; i >= 0; --i) {
        if (!segments[i] || !segments[i][0]) {
            continue;
        }
        if (path[0]) {
            wcscat_s(path, total, L"\\");
        }
        wcscat_s(path, total, segments[i]);
    }

    for (int i = 0; i < segment_count; ++i) {
        HeapFree(GetProcessHeap(), 0, segments[i]);
    }
    return path;
}

static bool is_usage_relevant(const wchar_t *path, const wchar_t *name, INT64 deletion, INT64 classification) {
    if (g_output_all) {
        return true;
    }
    if (deletion == 5 || classification == 5) {
        return true;
    }
    if (!path) {
        return false;
    }

    static const wchar_t *patterns[] = {
        L"\\users\\",
        L"\\documents and settings\\",
        L"\\windows\\prefetch\\",
        L"\\windows\\appcompat\\programs\\",
        L"\\windows\\system32\\config\\",
        L"\\windows\\system32\\winevt\\logs\\",
        L"\\appdata\\roaming\\microsoft\\windows\\recent\\",
        L"\\automaticdestinations\\",
        L"\\customdestinations\\",
        L"\\appdata\\local\\google\\chrome\\user data\\",
        L"\\appdata\\local\\microsoft\\edge\\user data\\",
        L"\\appdata\\roaming\\mozilla\\firefox\\profiles\\",
        L"\\appdata\\local\\microsoft\\windows\\webcache\\",
        L"\\appdata\\roaming\\microsoft\\teams\\",
        L"\\appdata\\local\\microsoft\\teams\\",
        L"\\appdata\\roaming\\slack\\",
        L"\\appdata\\roaming\\zoom\\",
        L"\\appdata\\roaming\\discord\\",
        L"\\thunderbird\\profiles\\",
        L"\\$recycle.bin\\",
        L"\\onedrive\\",
        L"\\dropbox\\",
        L"\\google drive\\",
        L"\\icloud",
        L"\\recovered",
        L"\\carved",
        L"\\free space"
    };

    for (size_t i = 0; i < ARRAYSIZE(patterns); ++i) {
        if (contains_i(path, patterns[i])) {
            return true;
        }
    }

    if (name) {
        static const wchar_t *names[] = {
            L"ntuser.dat",
            L"usrclass.dat",
            L"amcache.hve",
            L"shimcache",
            L"activitiescache.db",
            L"history",
            L"places.sqlite",
            L"downloads.sqlite",
            L"cookies.sqlite",
            L"webcachev01.dat"
        };
        for (size_t i = 0; i < ARRAYSIZE(names); ++i) {
            if (_wcsicmp(name, names[i]) == 0) {
                return true;
            }
        }
        if (contains_i(name, L".lnk") || contains_i(name, L".automaticdestinations-ms") ||
            contains_i(name, L".customdestinations-ms") || contains_i(name, L".evtx") ||
            contains_i(name, L".pf") || contains_i(name, L".ost") || contains_i(name, L".pst")) {
            return true;
        }
    }

    return false;
}

static const wchar_t *evprop_wstr_return(HANDLE hEvidence, DWORD prop) {
    INT64 raw = pXWF_GetEvObjProp(hEvidence, prop, NULL);
    if (raw <= 0) {
        return L"";
    }
    return (const wchar_t *)(uintptr_t)raw;
}

static void export_item(FILE *out, HANDLE hEvidence, int ev_index, DWORD selected_count, LONG item_id) {
    LPWSTR name = pXWF_GetItemName((DWORD)item_id);
    LONG parent_id = pXWF_GetItemParent(item_id);
    INT64 size = pXWF_GetItemSize(item_id);

    bool ok_attr = false, ok_flags = false, ok_deletion = false, ok_classification = false;
    bool ok_ctime = false, ok_mtime = false, ok_atime = false, ok_etime = false, ok_dtime = false, ok_itime = false;
    INT64 attr = item_info(item_id, XWF_ITEM_INFO_ATTR, &ok_attr);
    INT64 flags = item_info(item_id, XWF_ITEM_INFO_FLAGS, &ok_flags);
    INT64 deletion = item_info(item_id, XWF_ITEM_INFO_DELETION, &ok_deletion);
    INT64 classification = item_info(item_id, XWF_ITEM_INFO_CLASSIFICATION, &ok_classification);
    INT64 ctime = item_info(item_id, XWF_ITEM_INFO_CREATIONTIME, &ok_ctime);
    INT64 mtime = item_info(item_id, XWF_ITEM_INFO_MODIFICATIONTIME, &ok_mtime);
    INT64 atime = item_info(item_id, XWF_ITEM_INFO_LASTACCESSTIME, &ok_atime);
    INT64 etime = item_info(item_id, XWF_ITEM_INFO_ENTRYMODIFICATIONTIME, &ok_etime);
    INT64 dtime = item_info(item_id, XWF_ITEM_INFO_DELETIONTIME, &ok_dtime);
    INT64 itime = item_info(item_id, XWF_ITEM_INFO_INTERNALCREATIONTIME, &ok_itime);

    wchar_t *path = build_item_path(item_id);
    if (!is_usage_relevant(path, name, ok_deletion ? deletion : 0, ok_classification ? classification : 0)) {
        if (path) {
            HeapFree(GetProcessHeap(), 0, path);
        }
        return;
    }

    wchar_t ext_title[MAX_PATH] = L"";
    wchar_t abbrev_title[MAX_PATH] = L"";
    pXWF_GetEvObjProp(hEvidence, 7, ext_title);
    pXWF_GetEvObjProp(hEvidence, 8, abbrev_title);

    INT64 ev_number = pXWF_GetEvObjProp(hEvidence, 0, NULL);
    INT64 ev_id = pXWF_GetEvObjProp(hEvidence, 1, NULL);
    INT64 ev_parent_id = pXWF_GetEvObjProp(hEvidence, 2, NULL);
    INT64 ev_short_id = pXWF_GetEvObjProp(hEvidence, 3, NULL);
    INT64 vs_id = pXWF_GetEvObjProp(hEvidence, 4, NULL);
    const wchar_t *ev_title = evprop_wstr_return(hEvidence, 6);
    const wchar_t *ev_internal = evprop_wstr_return(hEvidence, 9);

    fputs("{", out);
    fprintf(out, "\"schema\":\"xwf-path-export-v1\",");
    fprintf(out, "\"evidence_index\":%d,", ev_index);
    fprintf(out, "\"evidence_object_number\":%lld,", (long long)ev_number);
    fprintf(out, "\"evidence_object_id\":%lld,", (long long)ev_id);
    fprintf(out, "\"parent_evidence_object_id\":%lld,", (long long)ev_parent_id);
    fprintf(out, "\"short_evidence_object_id\":%lld,", (long long)ev_short_id);
    fprintf(out, "\"volume_snapshot_id\":%lld,", (long long)vs_id);
    fprintf(out, "\"volume_item_count\":%lu,", (unsigned long)selected_count);
    fputs("\"evidence_title\":", out);
    write_json_wstr(out, ev_title);
    fputs(",\"evidence_extended_title\":", out);
    write_json_wstr(out, ext_title);
    fputs(",\"evidence_abbreviated_title\":", out);
    write_json_wstr(out, abbrev_title);
    fputs(",\"evidence_internal_designation\":", out);
    write_json_wstr(out, ev_internal);
    fprintf(out, ",\"item_id\":%ld,\"parent_id\":%ld,\"size\":%lld,", item_id, parent_id, (long long)size);
    fputs("\"name\":", out);
    write_json_wstr(out, name ? name : L"");
    fputs(",\"path\":", out);
    write_json_wstr(out, path ? path : L"");
    fputs(",\"attr\":", out);
    write_nullable_i64(out, ok_attr, attr);
    fputs(",\"flags\":", out);
    write_nullable_i64(out, ok_flags, flags);
    fputs(",\"deletion\":", out);
    write_nullable_i64(out, ok_deletion, deletion);
    fputs(",\"classification\":", out);
    write_nullable_i64(out, ok_classification, classification);
    fputs(",\"creation_filetime\":", out);
    write_nullable_i64(out, ok_ctime, ctime);
    fputs(",\"modification_filetime\":", out);
    write_nullable_i64(out, ok_mtime, mtime);
    fputs(",\"last_access_filetime\":", out);
    write_nullable_i64(out, ok_atime, atime);
    fputs(",\"entry_modification_filetime\":", out);
    write_nullable_i64(out, ok_etime, etime);
    fputs(",\"deletion_filetime\":", out);
    write_nullable_i64(out, ok_dtime, dtime);
    fputs(",\"internal_creation_filetime\":", out);
    write_nullable_i64(out, ok_itime, itime);
    fputs("}\n", out);

    if (path) {
        HeapFree(GetProcessHeap(), 0, path);
    }
}

static LONG export_volume(FILE *out, HANDLE hVolume, HANDLE hEvidence, int ev_index) {
    if (!hVolume || !hEvidence) {
        return -1;
    }

    LONG selected = pXWF_SelectVolumeSnapshot(hVolume);
    DWORD count = selected > 0 ? (DWORD)selected : pXWF_GetItemCount(NULL);
    if (count == 0 || count == (DWORD)-1) {
        return -2;
    }

    for (DWORD item_id = 0; item_id < count; ++item_id) {
        export_item(out, hEvidence, ev_index, count, (LONG)item_id);
    }
    return 0;
}

static void export_evidence_summary(FILE *out, HANDLE hEvidence, int ev_index, LONG open_result, DWORD item_count) {
    wchar_t ext_title[MAX_PATH] = L"";
    wchar_t abbrev_title[MAX_PATH] = L"";
    pXWF_GetEvObjProp(hEvidence, 7, ext_title);
    pXWF_GetEvObjProp(hEvidence, 8, abbrev_title);

    INT64 ev_number = pXWF_GetEvObjProp(hEvidence, 0, NULL);
    INT64 ev_id = pXWF_GetEvObjProp(hEvidence, 1, NULL);
    INT64 ev_parent_id = pXWF_GetEvObjProp(hEvidence, 2, NULL);
    INT64 ev_short_id = pXWF_GetEvObjProp(hEvidence, 3, NULL);
    INT64 vs_id = pXWF_GetEvObjProp(hEvidence, 4, NULL);
    const wchar_t *ev_title = evprop_wstr_return(hEvidence, 6);
    const wchar_t *ev_internal = evprop_wstr_return(hEvidence, 9);

    fputs("{", out);
    fprintf(out, "\"schema\":\"xwf-path-export-evidence-v1\",");
    fprintf(out, "\"evidence_index\":%d,", ev_index);
    fprintf(out, "\"evidence_object_number\":%lld,", (long long)ev_number);
    fprintf(out, "\"evidence_object_id\":%lld,", (long long)ev_id);
    fprintf(out, "\"parent_evidence_object_id\":%lld,", (long long)ev_parent_id);
    fprintf(out, "\"short_evidence_object_id\":%lld,", (long long)ev_short_id);
    fprintf(out, "\"volume_snapshot_id\":%lld,", (long long)vs_id);
    fprintf(out, "\"open_result\":%ld,", open_result);
    fprintf(out, "\"volume_item_count\":%lu,", (unsigned long)item_count);
    fputs("\"evidence_title\":", out);
    write_json_wstr(out, ev_title);
    fputs(",\"evidence_extended_title\":", out);
    write_json_wstr(out, ext_title);
    fputs(",\"evidence_abbreviated_title\":", out);
    write_json_wstr(out, abbrev_title);
    fputs(",\"evidence_internal_designation\":", out);
    write_json_wstr(out, ev_internal);
    fputs("}\n", out);
}

static LONG export_case(void) {
    FILE *out = open_output();
    if (!out) {
        output_message(L"XwfPathExport: could not open local metadata output.");
        return -1;
    }

    int ev_index = 0;
    HANDLE hEvidence = pXWF_GetFirstEvObj(NULL);
    while (hEvidence) {
        ++ev_index;
        HANDLE hNextEvidence = pXWF_GetNextEvObj(hEvidence, NULL);
        HANDLE hVolume = pXWF_OpenEvObj(hEvidence, 0x03);
        if (hVolume) {
            LONG selected = pXWF_SelectVolumeSnapshot(hVolume);
            DWORD count = selected > 0 ? (DWORD)selected : pXWF_GetItemCount(NULL);
            export_evidence_summary(out, hEvidence, ev_index, selected, count);
            export_volume(out, hVolume, hEvidence, ev_index);
            pXWF_CloseEvObj(hEvidence);
        } else {
            export_evidence_summary(out, hEvidence, ev_index, -1, 0);
        }
        hEvidence = hNextEvidence;
    }

    fclose(out);
    output_message(L"XwfPathExport: metadata export completed locally.");
    return 0;
}

__declspec(dllexport) LONG __stdcall XT_Init(DWORD nVersion, DWORD nFlags, HANDLE hMainWnd, void *pLicInfo) {
    initialize_options();
    if (!load_xwf_functions()) {
        return -1;
    }
    return 0x01;
}

__declspec(dllexport) LONG __stdcall XT_Prepare(HANDLE hVolume, HANDLE hEvidence, DWORD nOpType, PVOID lpReserved) {
    initialize_options();
    if (!load_xwf_functions()) {
        return -3;
    }
    return 0;
}

__declspec(dllexport) LONG __stdcall XT_Finalize(HANDLE hVolume, HANDLE hEvidence, DWORD nOpType, PVOID lpReserved) {
    initialize_options();
    if (!load_xwf_functions()) {
        return -1;
    }

    if (hVolume && hEvidence) {
        FILE *out = open_output();
        if (!out) {
            return -1;
        }
        LONG result = export_volume(out, hVolume, hEvidence, 1);
        fclose(out);
        return result;
    }

    if (g_ran_case_enumeration) {
        return 0;
    }
    g_ran_case_enumeration = true;
    return export_case();
}
