Sub PaintMenuSeparatorLine(ByVal hWnd As HWND, ByVal isDark As WINBOOL)
  Dim As MENUBARINFO mbi
  mbi.cbSize = SizeOf(MENUBARINFO)
  If GetMenuBarInfo(hWnd, OBJID_MENU, 0, @mbi) Then
    Dim As RECT rcWindow
    GetWindowRect(hWnd, @rcWindow)
    Dim As POINT ptClient = Type(0, 0)
    ClientToScreen(hWnd, @ptClient)

    Dim As HDC hDC = GetWindowDC(hWnd)
    If hDC Then
      Dim As RECT rcLine
      rcLine.left = 0
      rcLine.right = rcWindow.right - rcWindow.left
      rcLine.top = mbi.rcBar.bottom - rcWindow.top - 1
      rcLine.bottom = ptClient.y - rcWindow.top
      If rcLine.bottom <= rcLine.top Then
        rcLine.bottom = rcLine.top + 2
      End If
      Dim As HBRUSH hBrush = IIf(isDark, g_hbrDark, GetSysColorBrush(COLOR_BTNFACE))
      FillRect(hDC, @rcLine, hBrush)
      ReleaseDC(hWnd, hDC)
    End If
  End If
End Sub

Sub InitDarkModeAPIs()
  Dim hNtdll As HMODULE = GetModuleHandle("ntdll.dll")
  If hNtdll = NULL Then
    Exit Sub
  End If

  Dim RtlGetNtVersionNumbers As fnRtlGetNtVersionNumbers = Cast(fnRtlGetNtVersionNumbers, GetProcAddress(hNtdll, "RtlGetNtVersionNumbers"))
  If RtlGetNtVersionNumbers = NULL Then
    Exit Sub
  End If

  Dim As DWORD major, minor
  RtlGetNtVersionNumbers(@major, @minor, @g_buildNumber)
  g_buildNumber And= &h0FFFFFFF

  If major >= 10 And g_buildNumber >= 17763 Then
    Dim hUxtheme As HMODULE = LoadLibrary("uxtheme.dll")
    If hUxtheme Then
      _AllowDarkModeForWindow = Cast(fnAllowDarkModeForWindow, GetProcAddress(hUxtheme, Cast(LPCSTR, 133)))
      _SetPreferredAppMode = Cast(fnSetPreferredAppMode, GetProcAddress(hUxtheme, Cast(LPCSTR, 135)))
      _FlushMenuThemes = Cast(fnFlushMenuThemes, GetProcAddress(hUxtheme, Cast(LPCSTR, 136)))
      _SetWindowTheme = Cast(fnSetWindowTheme, GetProcAddress(hUxtheme, "SetWindowTheme"))
      _SetWindowCompositionAttribute = Cast(fnSetWindowCompositionAttribute, GetProcAddress(GetModuleHandle("user32.dll"), "SetWindowCompositionAttribute"))
      If (_AllowDarkModeForWindow <> 0) And (_SetPreferredAppMode <> 0) Then
        g_darkModeSupported = TRUE
      End If
    End If
  End If

  Dim hComctl As HMODULE = GetModuleHandle("comctl32.dll")
  If hComctl = NULL Then
    hComctl = LoadLibrary("comctl32.dll")
  End If
  If hComctl Then
    _ImageList_Draw = Cast(fnImageList_Draw, GetProcAddress(hComctl, "ImageList_Draw"))
  End If
End Sub

Sub RefreshTitleBarThemeColor(ByVal hWnd As HWND, ByVal isDark As WINBOOL)
  If g_darkModeSupported = FALSE Then
    Exit Sub
  End If

  If _AllowDarkModeForWindow Then
    _AllowDarkModeForWindow(hWnd, isDark)
  End If

  If _SetPreferredAppMode Then
    If isDark Then
      _SetPreferredAppMode(2)
    Else
      _SetPreferredAppMode(3)
    End If
  End If

  If _FlushMenuThemes Then
    _FlushMenuThemes()
  End If

  Dim dark As BOOL = isDark
  If g_buildNumber < 18362 Then
    SetPropW(hWnd, WStr("UseImmersiveDarkModeColors"), Cast(HANDLE, Cast(INT_PTR, dark)))
  ElseIf _SetWindowCompositionAttribute Then
    Dim wcData As WINDOWCOMPOSITIONATTRIBDATA
    wcData.Attrib = WCA_USEDARKMODECOLORS
    wcData.pvData = @dark
    wcData.cbData = SizeOf(dark)
    _SetWindowCompositionAttribute(hWnd, @wcData)
  End If

  Dim As RECT rc
  GetWindowRect(hWnd, @rc)
  SetWindowPos(hWnd, NULL, 0, 0, rc.right - rc.left, rc.bottom - rc.top + 1, SWP_NOMOVE Or SWP_NOZORDER Or SWP_NOACTIVATE)
  SetWindowPos(hWnd, NULL, 0, 0, rc.right - rc.left, rc.bottom - rc.top, SWP_NOMOVE Or SWP_NOZORDER Or SWP_NOACTIVATE Or SWP_FRAMECHANGED)

  SendMessageW(hWnd, WM_NCACTIVATE, False, 0)
  SendMessageW(hWnd, WM_NCACTIVATE, True, 0)
  DrawMenuBar(hWnd)

  PaintMenuSeparatorLine(hWnd, isDark)

  RedrawWindow(hWnd, NULL, NULL, RDW_FRAME Or RDW_INVALIDATE Or RDW_UPDATENOW Or RDW_ALLCHILDREN)
End Sub

Extern "windows"
Function NewEditProc(ByVal hWnd As HWND, ByVal uMsg As UINT, ByVal wParam As WPARAM, ByVal lParam As LPARAM) As LRESULT
  Dim As WNDPROC oldProc = Cast(WNDPROC, GetPropW(hWnd, WStr("OldEditProc")))
  If oldProc = NULL Then Return DefWindowProcW(hWnd, uMsg, wParam, lParam)

  If bDarkModeActive Then
    Select Case uMsg
      Case WM_NCPAINT, WM_NCACTIVATE
        Dim As LRESULT lRes = CallWindowProcW(oldProc, hWnd, uMsg, wParam, lParam)
        Dim As HDC hdc = GetWindowDC(hWnd)
        If hdc Then
          Dim As RECT rc
          GetWindowRect(hWnd, @rc)
          Dim As Integer w = rc.right - rc.left
          Dim As Integer h = rc.bottom - rc.top
          
          Dim As LONG exStyle = GetWindowLongW(hWnd, GWL_EXSTYLE)
          Dim As Integer cx = 0, cy = 0
          If (exStyle And WS_EX_CLIENTEDGE) Then
            cx = GetSystemMetrics(SM_CXEDGE)
            cy = GetSystemMetrics(SM_CYEDGE)
          ElseIf (GetWindowLongW(hWnd, GWL_STYLE) And WS_BORDER) Then
            cx = GetSystemMetrics(SM_CXBORDER)
            cy = GetSystemMetrics(SM_CYBORDER)
          End If

          If cx > 0 AndAlso cy > 0 Then
            Dim As HBRUSH hbrBg = CreateSolidBrush(&h202020)
            Dim As RECT rLeft = Type(0, 0, cx, h)
            Dim As RECT rTop = Type(0, 0, w, cy)
            Dim As RECT rRight = Type(w - cx, 0, w, h)
            Dim As RECT rBottom = Type(0, h - cy, w, h)

            FillRect(hdc, @rLeft, hbrBg)
            FillRect(hdc, @rTop, hbrBg)
            FillRect(hdc, @rRight, hbrBg)
            FillRect(hdc, @rBottom, hbrBg)
            DeleteObject(hbrBg)

            Dim As HBRUSH hbrBorder = CreateSolidBrush(&h4A4A4A)
            Dim As RECT rBLeft = Type(0, 0, 1, h)
            Dim As RECT rBTop = Type(0, 0, w, 1)
            Dim As RECT rBRight = Type(w - 1, 0, w, h)
            Dim As RECT rBBottom = Type(0, h - 1, w, h)

            FillRect(hdc, @rBLeft, hbrBorder)
            FillRect(hdc, @rBTop, hbrBorder)
            FillRect(hdc, @rBRight, hbrBorder)
            FillRect(hdc, @rBBottom, hbrBorder)
            DeleteObject(hbrBorder)
          End If
          ReleaseDC(hWnd, hdc)
        End If
        Return lRes

      Case WM_DESTROY
        SetWindowLongPtrW(hWnd, GWLP_WNDPROC, Cast(LONG_PTR, oldProc))
        RemovePropW(hWnd, WStr("OldEditProc"))
        Return CallWindowProcW(oldProc, hWnd, uMsg, wParam, lParam)
    End Select
  End If

  Return CallWindowProcW(oldProc, hWnd, uMsg, wParam, lParam)
End Function
End Extern

Sub ApplyThemeToEditWindow(ByVal hWnd As HWND, ByVal isDark As WINBOOL)
  If _AllowDarkModeForWindow Then
    _AllowDarkModeForWindow(hWnd, isDark)
  End If
  If _SetWindowTheme Then
    If isDark Then
      _SetWindowTheme(hWnd, WStr("DarkMode_Explorer"), NULL)
    Else
      _SetWindowTheme(hWnd, NULL, NULL)
    End If
  End If

  If isDark Then
    If GetPropW(hWnd, WStr("OldEditProc")) = NULL Then
      Dim As WNDPROC oldProc = Cast(WNDPROC, SetWindowLongPtrW(hWnd, GWLP_WNDPROC, Cast(LONG_PTR, @NewEditProc)))
      If oldProc <> NULL Then
        SetPropW(hWnd, WStr("OldEditProc"), Cast(HANDLE, oldProc))
      End If
    End If
  Else
    Dim As WNDPROC oldProc = Cast(WNDPROC, GetPropW(hWnd, WStr("OldEditProc")))
    If oldProc <> NULL Then
      SetWindowLongPtrW(hWnd, GWLP_WNDPROC, Cast(LONG_PTR, oldProc))
      RemovePropW(hWnd, WStr("OldEditProc"))
    End If
  End If

  SetWindowPos(hWnd, NULL, 0, 0, 0, 0, SWP_NOMOVE Or SWP_NOSIZE Or SWP_NOZORDER Or SWP_FRAMECHANGED)
  RedrawWindow(hWnd, NULL, NULL, RDW_FRAME Or RDW_INVALIDATE Or RDW_UPDATENOW)
End Sub

Function EnumEditWindowsProc stdcall(ByVal hWndChild As HWND, ByVal lParam As LPARAM) As WINBOOL
  Dim As WChar className(63)
  GetClassNameW(hWndChild, @className(0), 64)
  If lstrcmpiW(@className(0), WStr("AkelEditW")) = 0 OrElse _
     lstrcmpiW(@className(0), WStr("AkelEditA")) = 0 OrElse _
     lstrcmpiW(@className(0), WStr("RichEdit20W")) = 0 OrElse _
     lstrcmpiW(@className(0), WStr("RichEdit20A")) = 0 Then
    ApplyThemeToEditWindow(hWndChild, bDarkModeActive)
  End If
  Return TRUE
End Function

Sub RefreshAllEditWindowsTheme(ByVal hWndMain As HWND)
  EnumChildWindows(hWndMain, Cast(WNDENUMPROC, @EnumEditWindowsProc), 0)
End Sub