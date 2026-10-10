Function EditSubclassProc(ByVal hWnd As HWND, ByVal uMsg As UINT, ByVal wParam As WPARAM, ByVal lParam As LPARAM, ByVal uIdSubclass As UINT_PTR, ByVal dwRefData As DWORD_PTR) As LRESULT
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

          Dim As LONG exStyle = GetWindowLongW(hWnd, GWL_EXSTYLE)
          Dim As LONG style = GetWindowLongW(hWnd, GWL_STYLE)
          Dim As Integer cx = 0, cy = 0
          If (exStyle And WS_EX_CLIENTEDGE) Then
            cx = GetSystemMetrics(SM_CXEDGE)
            cy = GetSystemMetrics(SM_CYEDGE)
          ElseIf (style And WS_BORDER) Then
            cx = GetSystemMetrics(SM_CXBORDER)
            cy = GetSystemMetrics(SM_CYBORDER)
          End If

          If cx > 0 AndAlso cy > 0 Then
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
          End If
          ReleaseDC(hWnd, hdc)
        End If
        Return lRes

      Case WM_NCDESTROY
        RemoveWindowSubclass(hWnd, @EditSubclassProc, uIdSubclass)
    End Select
  End If
  Return DefSubclassProc(hWnd, uMsg, wParam, lParam)
End Function