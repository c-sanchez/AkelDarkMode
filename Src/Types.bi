Type MY_WNDPROCDATA
  nextItem As MY_WNDPROCDATA Ptr
  prevItem As MY_WNDPROCDATA Ptr
  CurProc As WNDPROC
  NextProc As WNDPROC
  PrevProc As WNDPROC
End Type

Enum WINDOWCOMPOSITIONATTRIB
  WCA_USEDARKMODECOLORS = 26
End Enum

Type WINDOWCOMPOSITIONATTRIBDATA
  Attrib As WINDOWCOMPOSITIONATTRIB
  pvData As PVOID
  cbData As SIZE_T
End Type

Type UAHMENU
  hMenu As HMENU
  hDC As HDC
  dwFlags As DWORD
End Type

Type UAHMENUITEM
  iPosition As Integer
  rgsizeBar(0 To 3) As DWORD
  rgcx(0 To 3) As DWORD
  fUpdateMaxWidths As DWORD
End Type

Type UAHDRAWMENUITEM
  dis As DRAWITEMSTRUCT
  um As UAHMENU
  umi As UAHMENUITEM
End Type

Type fnRtlGetNtVersionNumbers As Sub stdcall(ByVal major As LPDWORD, ByVal minor As LPDWORD, ByVal build As LPDWORD)
Type fnSetWindowCompositionAttribute As Function stdcall(ByVal hWnd As HWND, ByVal data As WINDOWCOMPOSITIONATTRIBDATA Ptr) As BOOL
Type fnAllowDarkModeForWindow As Function stdcall(ByVal hWnd As HWND, ByVal allow As WINBOOL) As WINBOOL
Type fnSetPreferredAppMode As Function stdcall(ByVal appMode As Integer) As Integer
Type fnFlushMenuThemes As Sub stdcall()
Type fnImageList_Draw As Function stdcall(ByVal himl As Any Ptr, ByVal i As Integer, ByVal hdcDst As HDC, ByVal x As Integer, ByVal y As Integer, ByVal fStyle As UINT) As BOOL
Type fnSetWindowTheme As Function stdcall(ByVal hWnd As HWND, ByVal pszSubAppName As LPCWSTR, ByVal pszSubIdList As LPCWSTR) As HRESULT