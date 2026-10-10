#ifndef __AKELDLL_BI__
#define __AKELDLL_BI__

#include once "windows.bi"

#ifndef MAKE_IDENTIFIER
  #define MAKE_IDENTIFIER(a, b, c, d) cast(DWORD, MAKELONG(MAKEWORD(a, b), MAKEWORD(c, d)))
#endif

const AKELDLL = MAKE_IDENTIFIER(2, 2, 0, 4)

#define PDS_NOANSI &h00000002
#define PDS_GETSUPPORT &h10000000
#define UD_NONUNLOAD_ACTIVE 1

#define AKD_SETMAINPROC (WM_USER + 102)

#define AKDN_MAIN_ONSTART_PRESHOW (WM_USER + 2)

type PLUGINVERSION
  cb as DWORD
  hMainWnd as HWND
  dwAkelDllVersion as DWORD
  dwExeMinVersion3x as DWORD
  dwExeMinVersion4x as DWORD
  pPluginName as ZString ptr
end type

type PLUGINDATA
  cb as DWORD
  pcs as any ptr
  dwSupport as DWORD
  pFunction as UBYTE ptr
  szFunction as ZString ptr
  wszFunction as WString ptr
  lParam as LPARAM
  hInstanceDLL as HINSTANCE
  lpPluginFunction as any ptr
  nUnload as Integer
  bInMemory as WINBOOL
  bOnStart as WINBOOL
  pAkelDir as UBYTE ptr
  szAkelDir as ZString ptr
  wszAkelDir as WString ptr
  hInstanceEXE as HINSTANCE
  hPluginsStack as any ptr
  nSaveSettings as Integer
  hMainWnd as HWND
end type

#endif