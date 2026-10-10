Function ListBoxSubclassProc(ByVal hWnd As HWND, ByVal uMsg As UINT, ByVal wParam As WPARAM, ByVal lParam As LPARAM, ByVal uIdSubclass As UINT_PTR, ByVal dwRefData As DWORD_PTR) As LRESULT
  If bDarkModeActive Then
    Select Case uMsg
      Case WM_NCPAINT, WM_NCACTIVATE
        Dim As LRESULT lRes = DefSubclassProc(hWnd, uMsg, wParam, lParam)
        Dim As HDC hdc = GetWindowDC(hWnd)
        If hdc Then
          Dim As RECT rc
          GetWindowRect(hWnd, @rc)
          Dim As Integer w = rc.right - rc.left
          Dim As Integer h = rc.bottom - rc.top

          Dim As Integer cx = 1
          Dim As Integer cy = 1
          Dim As LONG exStyle = GetWindowLongW(hWnd, GWL_EXSTYLE)
          If (exStyle And WS_EX_CLIENTEDGE) Then
            cx = GetSystemMetrics(SM_CXEDGE)
            cy = GetSystemMetrics(SM_CYEDGE)
          End If

          Dim As HBRUSH hbrBg = CreateSolidBrush(&h2B2B2B)
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

          ReleaseDC(hWnd, hdc)
        End If
        Return lRes

      Case WM_NCDESTROY
        RemoveWindowSubclass(hWnd, @ListBoxSubclassProc, uIdSubclass)
    End Select
  End If
  Return DefSubclassProc(hWnd, uMsg, wParam, lParam)
End Function

Function ComboBoxSubclassProc(ByVal hWnd As HWND, ByVal uMsg As UINT, ByVal wParam As WPARAM, ByVal lParam As LPARAM, ByVal uIdSubclass As UINT_PTR, ByVal dwRefData As DWORD_PTR) As LRESULT
  If bDarkModeActive Then
    Select Case uMsg
      Case WM_CTLCOLOREDIT, WM_CTLCOLORLISTBOX
        Dim As HWND hCtrl = Cast(HWND, lParam)
        If hCtrl <> NULL AndAlso GetPropW(hCtrl, WStr("DarkThemeApplied")) = NULL Then
          If _AllowDarkModeForWindow Then _AllowDarkModeForWindow(hCtrl, TRUE)
          If _SetWindowTheme Then _SetWindowTheme(hCtrl, WStr("DarkMode_Explorer"), NULL)
          If uMsg = WM_CTLCOLORLISTBOX Then
            SetWindowSubclass(hCtrl, @ListBoxSubclassProc, 112, 0)
          End If
          SetPropW(hCtrl, WStr("DarkThemeApplied"), Cast(HANDLE, 1))
        End If
        SetTextColor(Cast(HDC, wParam), &hE0E0E0)
        SetBkColor(Cast(HDC, wParam), &h2B2B2B)
        Return Cast(LRESULT, g_hbrDark)

      Case WM_CTLCOLORSTATIC
        SetTextColor(Cast(HDC, wParam), &hE0E0E0)
        SetBkColor(Cast(HDC, wParam), &h2B2B2B)
        Return Cast(LRESULT, g_hbrDark)

      Case WM_ERASEBKGND
        Dim As RECT rcErase
        GetClientRect(hWnd, @rcErase)
        FillRect(Cast(HDC, wParam), @rcErase, g_hbrDark)
        Return 1

      Case WM_NCPAINT, WM_NCACTIVATE
        Dim As LRESULT lRes = DefSubclassProc(hWnd, uMsg, wParam, lParam)
        Dim As HDC hdc = GetWindowDC(hWnd)
        If hdc Then
          Dim As RECT rc
          GetWindowRect(hWnd, @rc)
          Dim As Integer w = rc.right - rc.left
          Dim As Integer h = rc.bottom - rc.top

          Dim As Integer cx = 2
          Dim As Integer cy = 2

          Dim As HBRUSH hbrBg = CreateSolidBrush(&h2B2B2B)
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
          ReleaseDC(hWnd, hdc)
        End If
        Return lRes

      Case WM_PAINT
        Dim As LRESULT lRes = DefSubclassProc(hWnd, uMsg, wParam, lParam)
        Dim As HDC hDC = GetDC(hWnd)
        If hDC Then
          Dim As RECT rcClient
          GetClientRect(hWnd, @rcClient)

          Dim As COMBOBOXINFO cbi
          cbi.cbSize = SizeOf(COMBOBOXINFO)
          If GetComboBoxInfo(hWnd, @cbi) Then
            If cbi.hwndList <> NULL AndAlso GetPropW(cbi.hwndList, WStr("DarkThemeApplied")) = NULL Then
              If _AllowDarkModeForWindow Then _AllowDarkModeForWindow(cbi.hwndList, TRUE)
              If _SetWindowTheme Then _SetWindowTheme(cbi.hwndList, WStr("DarkMode_Explorer"), NULL)
              SetWindowSubclass(cbi.hwndList, @ListBoxSubclassProc, 112, 0)
              SetPropW(cbi.hwndList, WStr("DarkThemeApplied"), Cast(HANDLE, 1))
            End If
            If cbi.hwndItem <> NULL AndAlso GetPropW(cbi.hwndItem, WStr("DarkThemeApplied")) = NULL Then
              If _AllowDarkModeForWindow Then _AllowDarkModeForWindow(cbi.hwndItem, TRUE)
              If _SetWindowTheme Then _SetWindowTheme(cbi.hwndItem, WStr("DarkMode_Explorer"), NULL)
              SetPropW(cbi.hwndItem, WStr("DarkThemeApplied"), Cast(HANDLE, 1))
            End If

            Dim As HRGN hRgn = CreateRectRgnIndirect(@rcClient)
            Dim As HRGN hRgnBtn = CreateRectRgnIndirect(@cbi.rcButton)
            CombineRgn(hRgn, hRgn, hRgnBtn, RGN_DIFF)

            If cbi.hwndItem <> NULL AndAlso cbi.hwndItem <> hWnd Then
              Dim As RECT rcEdit
              GetWindowRect(cbi.hwndItem, @rcEdit)
              Dim As POINT pt1 = Type(rcEdit.left, rcEdit.top)
              ScreenToClient(hWnd, @pt1)
              Dim As POINT pt2 = Type(rcEdit.right, rcEdit.bottom)
              ScreenToClient(hWnd, @pt2)
              rcEdit.left = pt1.x
              rcEdit.top = pt1.y
              rcEdit.right = pt2.x
              rcEdit.bottom = pt2.y
              Dim As HRGN hRgnEdit = CreateRectRgnIndirect(@rcEdit)
              CombineRgn(hRgn, hRgn, hRgnEdit, RGN_DIFF)
              DeleteObject(hRgnEdit)
            Else
              Dim As HRGN hRgnItem = CreateRectRgnIndirect(@cbi.rcItem)
              CombineRgn(hRgn, hRgn, hRgnItem, RGN_DIFF)
              DeleteObject(hRgnItem)
            End If
            
            FillRgn(hDC, hRgn, g_hbrDark)
            DeleteObject(hRgn)
            DeleteObject(hRgnBtn)

            Dim As HBRUSH hbrBorder = CreateSolidBrush(&h4A4A4A)
            Dim As RECT rL = Type(rcClient.left, rcClient.top, rcClient.left + 1, rcClient.bottom)
            Dim As RECT rT = Type(rcClient.left, rcClient.top, rcClient.right, rcClient.top + 1)
            Dim As RECT rR = Type(rcClient.right - 1, rcClient.top, rcClient.right, rcClient.bottom)
            Dim As RECT rB = Type(rcClient.left, rcClient.bottom - 1, rcClient.right, rcClient.bottom)

            FillRect(hDC, @rL, hbrBorder)
            FillRect(hDC, @rT, hbrBorder)
            FillRect(hDC, @rR, hbrBorder)
            FillRect(hDC, @rB, hbrBorder)
            DeleteObject(hbrBorder)

            Dim As RECT rcBtn = cbi.rcButton
            If rcBtn.right > rcBtn.left Then
              rcBtn.right = rcClient.right - 1
              rcBtn.top = rcClient.top + 1
              rcBtn.bottom = rcClient.bottom - 1

              Dim As Boolean isPressed = ((cbi.stateButton And STATE_SYSTEM_PRESSED) <> 0)
              Dim As Boolean isHovered = (GetPropW(hWnd, WStr("ComboBtnHover")) <> NULL)
              Dim As COLORREF btnBg = &h333333
              If isPressed Then
                btnBg = &h4A4A4A
              ElseIf isHovered Then
                btnBg = &h3D3D3D
              End If

              Dim As HBRUSH hbrBtn = CreateSolidBrush(btnBg)
              FillRect(hDC, @rcBtn, hbrBtn)
              DeleteObject(hbrBtn)

              Dim As HPEN hPenSep = CreatePen(PS_SOLID, 1, &h4A4A4A)
              Dim As HPEN oldPen = Cast(HPEN, SelectObject(hDC, hPenSep))
              MoveToEx(hDC, rcBtn.left, rcBtn.top, NULL)
              LineTo(hDC, rcBtn.left, rcBtn.bottom)

              Dim As Integer cx = (rcBtn.left + rcBtn.right) \ 2
              Dim As Integer cy = (rcBtn.top + rcBtn.bottom) \ 2
              Dim As COLORREF arrowColor = IIf(IsWindowEnabled(hWnd), &hE0E0E0, &h777777)
              Dim As HPEN hPenArrow = CreatePen(PS_SOLID, 1, arrowColor)
              SelectObject(hDC, hPenArrow)

              MoveToEx(hDC, cx - 3, cy - 1, NULL)
              LineTo(hDC, cx + 4, cy - 1)
              MoveToEx(hDC, cx - 2, cy, NULL)
              LineTo(hDC, cx + 3, cy)
              MoveToEx(hDC, cx - 1, cy + 1, NULL)
              LineTo(hDC, cx + 2, cy + 1)
              SetPixel(hDC, cx, cy + 2, arrowColor)

              SelectObject(hDC, oldPen)
              DeleteObject(hPenSep)
              DeleteObject(hPenArrow)
            End If
          End If
          ReleaseDC(hWnd, hDC)
        End If
        Return lRes

      Case WM_MOUSEMOVE
        Dim As COMBOBOXINFO cbi
        cbi.cbSize = SizeOf(COMBOBOXINFO)
        If GetComboBoxInfo(hWnd, @cbi) Then
          Dim As POINT pt = Type(Cast(SHORT, LOWORD(lParam)), Cast(SHORT, HIWORD(lParam)))
          Dim As Boolean inBtn = PtInRect(@cbi.rcButton, pt)
          Dim As Boolean wasHovered = (GetPropW(hWnd, WStr("ComboBtnHover")) <> NULL)
          If inBtn <> wasHovered Then
            If inBtn Then
              SetPropW(hWnd, WStr("ComboBtnHover"), Cast(HANDLE, 1))
              Dim As TRACKMOUSEEVENT tme
              tme.cbSize = SizeOf(tme)
              tme.dwFlags = TME_LEAVE
              tme.hwndTrack = hWnd
              TrackMouseEvent(@tme)
            Else
              RemovePropW(hWnd, WStr("ComboBtnHover"))
            End If
            InvalidateRect(hWnd, @cbi.rcButton, FALSE)
          End If
        End If

      Case WM_MOUSELEAVE
        RemovePropW(hWnd, WStr("ComboBtnHover"))
        InvalidateRect(hWnd, NULL, FALSE)

      Case WM_NCDESTROY
        RemovePropW(hWnd, WStr("ComboBtnHover"))
        RemoveWindowSubclass(hWnd, @ComboBoxSubclassProc, uIdSubclass)
    End Select
  End If
  Return DefSubclassProc(hWnd, uMsg, wParam, lParam)
End Function