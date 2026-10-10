Function ListViewSubclassProc(ByVal hWnd As HWND, ByVal uMsg As UINT, ByVal wParam As WPARAM, ByVal lParam As LPARAM, ByVal uIdSubclass As UINT_PTR, ByVal dwRefData As DWORD_PTR) As LRESULT
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

      Case LVM_SETBKCOLOR, LVM_SETTEXTBKCOLOR
        Return DefSubclassProc(hWnd, uMsg, wParam, Cast(LPARAM, &h202020))
        
      Case LVM_SETTEXTCOLOR
        Return DefSubclassProc(hWnd, uMsg, wParam, Cast(LPARAM, &hFFFFFF))
        
      Case WM_ERASEBKGND
        Dim As HDC hDC = Cast(HDC, wParam)
        Dim As RECT rc
        GetClientRect(hWnd, @rc)
        Dim As HBRUSH hbr = CreateSolidBrush(&h202020)
        FillRect(hDC, @rc, hbr)
        DeleteObject(hbr)
        Return 1

      Case WM_NOTIFY
        Dim As NMHDR Ptr pnm = Cast(NMHDR Ptr, lParam)
        Dim As HWND hwndHdr = Cast(HWND, SendMessageW(hWnd, LVM_GETHEADER, 0, 0))
        If pnm->hwndFrom = hwndHdr Then
          Dim As LRESULT lRes = DefSubclassProc(hWnd, uMsg, wParam, lParam)
          RedrawWindow(hWnd, NULL, NULL, RDW_INVALIDATE Or RDW_ERASE Or RDW_UPDATENOW Or RDW_ALLCHILDREN)
          Return lRes
        End If

      Case WM_HSCROLL, WM_VSCROLL, WM_MOUSEWHEEL, WM_KEYDOWN
        InvalidateRect(hWnd, NULL, FALSE)

      Case WM_NCDESTROY
        RemoveWindowSubclass(hWnd, @ListViewSubclassProc, uIdSubclass)
    End Select
  End If
  Return DefSubclassProc(hWnd, uMsg, wParam, lParam)
End Function