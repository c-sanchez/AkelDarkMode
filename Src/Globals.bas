#include once "win/gdiplus.bi"

Using Gdiplus

Dim Shared hMainWndGlobal As HWND = NULL
Dim Shared lpMainProcData As MY_WNDPROCDATA Ptr = NULL
Dim Shared bDarkModeActive As WINBOOL = FALSE

Dim Shared _SetWindowCompositionAttribute As fnSetWindowCompositionAttribute
Dim Shared _AllowDarkModeForWindow As fnAllowDarkModeForWindow
Dim Shared _SetPreferredAppMode As fnSetPreferredAppMode
Dim Shared _FlushMenuThemes As fnFlushMenuThemes
Dim Shared _ImageList_Draw As fnImageList_Draw
Dim Shared _SetWindowTheme As fnSetWindowTheme
Dim Shared g_buildNumber As DWORD = 0
Dim Shared g_darkModeSupported As WINBOOL = FALSE
Dim Shared g_hbrDark As HBRUSH = NULL
Dim Shared g_gdiplusToken As ULONG_PTR = 0

Dim Shared hTabGlobal As HWND = NULL
Dim Shared lpOldTabProc As WNDPROC = NULL
Dim Shared g_hoverTab As Integer = -1

Dim Shared hStatusGlobal As HWND = NULL
Dim Shared lpOldStatusProc As WNDPROC = NULL

Dim Shared hHookCBT As HHOOK = NULL