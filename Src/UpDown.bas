Function UpDownSubclassProc(ByVal hWnd As HWND, ByVal uMsg As UINT, ByVal wParam As WPARAM, ByVal lParam As LPARAM, ByVal uIdSubclass As UINT_PTR, ByVal dwRefData As DWORD_PTR) As LRESULT
  If bDarkModeActive Then
    Dim As LONG style = GetWindowLongW(hWnd, GWL_STYLE)
    Dim As Boolean isHorz = ((style And UDS_HORZ) <> 0)

    Select Case uMsg
      Case WM_ERASEBKGND
        Return 1

      Case WM_PAINT
        Dim As PAINTSTRUCT ps
        Dim As HDC hDC = BeginPaint(hWnd, @ps)
        Dim As RECT rc
        GetClientRect(hWnd, @rc)

        Dim As HDC hdcMem = CreateCompatibleDC(hDC)
        Dim As HBITMAP hbm = CreateCompatibleBitmap(hDC, rc.right, rc.bottom)
        Dim As HBITMAP ohbm = Cast(HBITMAP, SelectObject(hdcMem, hbm))

        Dim As RECT rcUp = rc, rcDown = rc
        If isHorz Then
          rcUp.right = rc.left + (rc.right - rc.left) \ 2
          rcDown.left = rcUp.right
        Else
          rcUp.bottom = rc.top + (rc.bottom - rc.top) \ 2
          rcDown.top = rcUp.bottom
        End If

        Dim As Integer btnHot = Cast(Integer, GetPropW(hWnd, WStr("BtnHot")))
        Dim As Integer btnDown = Cast(Integer, GetPropW(hWnd, WStr("BtnDown")))
        Dim As Boolean isEnabled = IsWindowEnabled(hWnd)

        Dim As COLORREF bgUp = &h333333, bgDown = &h333333
        If Not isEnabled Then
          bgUp = &h2B2B2B
          bgDown = &h2B2B2B
        Else
          If btnDown = 1 Then
            bgUp = &h4A4A4A
          ElseIf btnHot = 1 Then
            bgUp = &h3D3D3D
          End If
          If btnDown = 2 Then
            bgDown = &h4A4A4A
          ElseIf btnHot = 2 Then
            bgDown = &h3D3D3D
          End If
        End If

        Dim As HBRUSH hbrUp = CreateSolidBrush(bgUp)
        FillRect(hdcMem, @rcUp, hbrUp)
        DeleteObject(hbrUp)

        Dim As HBRUSH hbrDown = CreateSolidBrush(bgDown)
        FillRect(hdcMem, @rcDown, hbrDown)
        DeleteObject(hbrDown)

        Dim As HPEN hBorder = CreatePen(PS_SOLID, 1, &h4A4A4A)
        Dim As HPEN oldPen = Cast(HPEN, SelectObject(hdcMem, hBorder))
        Dim As HBRUSH oldBrush = Cast(HBRUSH, SelectObject(hdcMem, GetStockObject(NULL_BRUSH)))
        Rectangle(hdcMem, rc.left, rc.top, rc.right, rc.bottom)

        If isHorz Then
          MoveToEx(hdcMem, rcUp.right, rc.top, NULL)
          LineTo(hdcMem, rcUp.right, rc.bottom)
        Else
          MoveToEx(hdcMem, rc.left, rcUp.bottom, NULL)
          LineTo(hdcMem, rc.right, rcUp.bottom)
        End If

        Dim As COLORREF arrowColor = IIf(isEnabled, &hE0E0E0, &h777777)
        Dim As HPEN hArrow = CreatePen(PS_SOLID, 1, arrowColor)
        SelectObject(hdcMem, hArrow)

        Dim As Integer cx = rcUp.left + (rcUp.right - rcUp.left) \ 2
        Dim As Integer cy = rcUp.top + (rcUp.bottom - rcUp.top) \ 2
        If isHorz Then
          MoveToEx(hdcMem, cx + 2, cy - 3, NULL)
          LineTo(hdcMem, cx - 2, cy + 1)
          MoveToEx(hdcMem, cx - 2, cy + 1, NULL)
          LineTo(hdcMem, cx + 3, cy + 6)
        Else
          MoveToEx(hdcMem, cx - 3, cy + 2, NULL)
          LineTo(hdcMem, cx, cy - 1)
          MoveToEx(hdcMem, cx, cy - 1, NULL)
          LineTo(hdcMem, cx + 4, cy + 3)
        End If

        cx = rcDown.left + (rcDown.right - rcDown.left) \ 2
        cy = rcDown.top + (rcDown.bottom - rcDown.top) \ 2
        If isHorz Then
          MoveToEx(hdcMem, cx - 2, cy - 3, NULL)
          LineTo(hdcMem, cx + 2, cy + 1)
          MoveToEx(hdcMem, cx + 2, cy + 1, NULL)
          LineTo(hdcMem, cx - 3, cy + 6)
        Else
          MoveToEx(hdcMem, cx - 3, cy - 2, NULL)
          LineTo(hdcMem, cx, cy + 1)
          MoveToEx(hdcMem, cx, cy + 1, NULL)
          LineTo(hdcMem, cx + 4, cy - 3)
        End If

        SelectObject(hdcMem, oldPen)
        SelectObject(hdcMem, oldBrush)
        DeleteObject(hBorder)
        DeleteObject(hArrow)

        BitBlt(hDC, 0, 0, rc.right, rc.bottom, hdcMem, 0, 0, SRCCOPY)
        SelectObject(hdcMem, ohbm)
        DeleteObject(hbm)
        DeleteDC(hdcMem)
        EndPaint(hWnd, @ps)
        Return 0

      Case WM_MOUSEMOVE
        Dim As POINT pt
        pt.x = Cast(SHORT, LOWORD(lParam))
        pt.y = Cast(SHORT, HIWORD(lParam))
        Dim As RECT rc
        GetClientRect(hWnd, @rc)

        Dim As Integer hot = 0
        If isHorz Then
          If pt.x < (rc.right \ 2) Then hot = 1 Else hot = 2
        Else
          If pt.y < (rc.bottom \ 2) Then hot = 1 Else hot = 2
        End If

        Dim As Integer oldHot = Cast(Integer, GetPropW(hWnd, WStr("BtnHot")))
        If hot <> oldHot Then
          SetPropW(hWnd, WStr("BtnHot"), Cast(HANDLE, hot))
          InvalidateRect(hWnd, NULL, FALSE)
          If oldHot = 0 Then
            Dim As TRACKMOUSEEVENT tme
            tme.cbSize = SizeOf(TRACKMOUSEEVENT)
            tme.dwFlags = TME_LEAVE
            tme.hwndTrack = hWnd
            TrackMouseEvent(@tme)
          End If
        End If

      Case WM_MOUSELEAVE
        RemovePropW(hWnd, WStr("BtnHot"))
        InvalidateRect(hWnd, NULL, FALSE)

      Case WM_LBUTTONDOWN, WM_LBUTTONDBLCLK
        Dim As POINT pt
        pt.x = Cast(SHORT, LOWORD(lParam))
        pt.y = Cast(SHORT, HIWORD(lParam))
        Dim As RECT rc
        GetClientRect(hWnd, @rc)

        Dim As Integer down = 0
        If isHorz Then
          If pt.x < (rc.right \ 2) Then down = 1 Else down = 2
        Else
          If pt.y < (rc.bottom \ 2) Then down = 1 Else down = 2
        End If
        SetPropW(hWnd, WStr("BtnDown"), Cast(HANDLE, down))

      Case WM_LBUTTONUP
        RemovePropW(hWnd, WStr("BtnDown"))

      Case WM_NCDESTROY
        RemovePropW(hWnd, WStr("BtnHot"))
        RemovePropW(hWnd, WStr("BtnDown"))
        RemoveWindowSubclass(hWnd, @UpDownSubclassProc, 110)
        Return DefSubclassProc(hWnd, uMsg, wParam, lParam)
    End Select

    Select Case uMsg
      Case WM_LBUTTONDOWN, WM_LBUTTONUP, WM_LBUTTONDBLCLK, WM_MOUSEMOVE, WM_MOUSELEAVE, _
           WM_KEYDOWN, WM_KEYUP, WM_SETFOCUS, WM_KILLFOCUS, WM_ENABLE, _
           WM_CAPTURECHANGED, WM_CANCELMODE
        SendMessageW(hWnd, WM_SETREDRAW, FALSE, 0)
        Dim As LRESULT lRes = DefSubclassProc(hWnd, uMsg, wParam, lParam)
        SendMessageW(hWnd, WM_SETREDRAW, TRUE, 0)
        RedrawWindow(hWnd, NULL, NULL, RDW_INVALIDATE Or RDW_UPDATENOW)
        Return lRes
    End Select
  End If
  Return DefSubclassProc(hWnd, uMsg, wParam, lParam)
End Function