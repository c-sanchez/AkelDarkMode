#cmdline "-dll -gen gcc"
#include once "windows.bi"
#include once "win/commctrl.bi"
#include once "Inc\AkelDLL.bi"

#include once "Src\Constants.bi"
#include once "Src\Types.bi"
#include once "Src\Globals.bas"
#include once "Src\SystemAPI.bas"
#include once "Src\TabControl.bas"
#include once "Src\StatusBar.bas"
#include once "Src\MainMenu.bas"
#include once "Src\Button.bas"
#include once "Src\ComboBox.bas"
#include once "Src\Edit.bas"
#include once "Src\Header.bas"
#include once "Src\ListView.bas"
#include once "Src\Static.bas"
#include once "Src\DialogTab.bas"
#include once "Src\UpDown.bas"
#include once "Src\Dialogs.bas"

Extern "C"
Sub DllAkelPadID Alias "DllAkelPadID" (ByVal pv As PLUGINVERSION Ptr) Export
  pv->dwAkelDllVersion = AKELDLL
  pv->dwExeMinVersion3x = MAKE_IDENTIFIER(-1, -1, -1, -1)
  pv->dwExeMinVersion4x = MAKE_IDENTIFIER(4, 9, 7, 0)
  pv->pPluginName = @"AkelDarkMode"
End Sub

Sub Main Alias "Main" (ByVal pd As PLUGINDATA Ptr) Export
  pd->dwSupport Or= PDS_NOANSI

  If (pd->dwSupport And PDS_GETSUPPORT) Then
    Exit Sub
  End If

  hMainWndGlobal = pd->hMainWnd

  InitDarkModeAPIs()

  If lpMainProcData <> NULL Then
    bDarkModeActive = FALSE
    UnhookDialogs()
    UnhookTabControl()
    UnhookStatusBar()
    RefreshTitleBarThemeColor(hMainWndGlobal, bDarkModeActive)
    RefreshAllEditWindowsTheme(hMainWndGlobal)
    SendMessageW(hMainWndGlobal, AKD_SETMAINPROC, 0, Cast(LPARAM, @lpMainProcData))
    lpMainProcData = NULL
    If g_hbrDark <> NULL Then
      DeleteObject(g_hbrDark)
      g_hbrDark = NULL
    End If
    If g_gdiplusToken <> 0 Then
      GdiplusShutdown(g_gdiplusToken)
      g_gdiplusToken = 0
    End If
    pd->nUnload = 0
  Else
    bDarkModeActive = TRUE
    If g_hbrDark = NULL Then
      g_hbrDark = CreateSolidBrush(&h2B2B2B)
    End If
    If g_gdiplusToken = 0 Then
      Dim As GdiplusStartupInput gdipInput
      gdipInput.GdiplusVersion = 1
      GdiplusStartup(@g_gdiplusToken, @gdipInput, NULL)
    End If
    lpMainProcData = NULL
    SendMessageW(hMainWndGlobal, AKD_SETMAINPROC, Cast(WPARAM, @NewMainProc), Cast(LPARAM, @lpMainProcData))
    HookDialogs()
    HookTabControl(hMainWndGlobal)
    HookStatusBar(hMainWndGlobal)
    RefreshTitleBarThemeColor(hMainWndGlobal, bDarkModeActive)
    RefreshAllEditWindowsTheme(hMainWndGlobal)
    pd->nUnload = UD_NONUNLOAD_ACTIVE
  End If
End Sub
End Extern