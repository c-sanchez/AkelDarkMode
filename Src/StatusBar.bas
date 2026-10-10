Function GetStatusHandle(ByVal hWndMain As HWND) As HWND
  Return FindWindowExW(hWndMain, NULL, WStr("msctls_statusbar32"), NULL)
End Function

Extern "windows"
Function NewStatusProc(ByVal hWnd As HWND, ByVal uMsg As UINT, ByVal wParam As WPARAM, ByVal lParam As LPARAM) As LRESULT
  If bDarkModeActive Then
    Select Case uMsg
      Case WM_ERASEBKGND
        Return 1

      Case WM_PAINT
        Dim As PAINTSTRUCT ps
        Dim As HDC hDC = BeginPaint(hWnd, @ps)
        Dim As RECT clientRc
        GetClientRect(hWnd, @clientRc)

        Dim As HDC hdcMem = CreateCompatibleDC(hDC)
        Dim As HBITMAP hbm = CreateCompatibleBitmap(hDC, clientRc.right - clientRc.left, clientRc.bottom - clientRc.top)
        Dim As HBITMAP ohbm = Cast(HBITMAP, SelectObject(hdcMem, hbm))

        Dim As HBRUSH hBrushBkgnd = CreateSolidBrush(&h202020)
        FillRect(hdcMem, @clientRc, hBrushBkgnd)
        DeleteObject(hBrushBkgnd)

        Dim As HPEN hPenBorder = CreatePen(PS_SOLID, 1, &h1A1A1A)
        Dim As HPEN oldPen = Cast(HPEN, SelectObject(hdcMem, hPenBorder))
        MoveToEx(hdcMem, clientRc.left, clientRc.top, NULL)
        LineTo(hdcMem, clientRc.right, clientRc.top)

        Dim As HPEN hPenSep = CreatePen(PS_SOLID, 1, &h444444)
        SelectObject(hdcMem, hPenSep)

        Dim As Integer numParts = SendMessageW(hWnd, SB_GETPARTS, 0, 0)
        If numParts <= 0 Then numParts = 1
        Dim As RECT rcPart
        Dim As WChar textBuf(1024)

        For i As Integer = 0 To numParts - 1
          SendMessageW(hWnd, SB_GETRECT, i, Cast(LPARAM, @rcPart))
          If i < numParts - 1 Then
            MoveToEx(hdcMem, rcPart.right - 1, rcPart.top + 2, NULL)
            LineTo(hdcMem, rcPart.right - 1, rcPart.bottom - 2)
          End If

          rcPart.left += 2
          rcPart.right -= 2
          SetTextColor(hdcMem, &hE0E0E0)
          SetBkMode(hdcMem, TRANSPARENT)

          Dim As HFONT hFont = Cast(HFONT, SendMessageW(hWnd, WM_GETFONT, 0, 0))
          Dim As HFONT oldFont = NULL
          If hFont Then oldFont = Cast(HFONT, SelectObject(hdcMem, hFont))

          textBuf(0) = 0
          SendMessageW(hWnd, SB_GETTEXTW, i, Cast(LPARAM, @textBuf(0)))
          DrawTextW(hdcMem, @textBuf(0), -1, @rcPart, DT_NOPREFIX Or DT_SINGLELINE Or DT_VCENTER)

          If oldFont Then SelectObject(hdcMem, oldFont)
        Next

        SelectObject(hdcMem, oldPen)
        DeleteObject(hPenBorder)
        DeleteObject(hPenSep)

        Dim As Long style = GetWindowLongPtrW(hWnd, GWL_STYLE)
        If (style And SBARS_SIZEGRIP) Then
          Dim As Integer gx = clientRc.right - 4
          Dim As Integer gy = clientRc.bottom - 4
          For row As Integer = 0 To 2
            For col As Integer = 0 To row
              Dim As Integer px = gx - (row * 3) + (col * 3)
              Dim As Integer py = gy - (col * 3)
              SetPixel(hdcMem, px, py, &h555555)
              SetPixel(hdcMem, px + 1, py, &h555555)
              SetPixel(hdcMem, px, py + 1, &h555555)
              SetPixel(hdcMem, px + 1, py + 1, &h555555)
            Next col
          Next row
        End If

        BitBlt(hDC, clientRc.left, clientRc.top, clientRc.right - clientRc.left, clientRc.bottom - clientRc.top, hdcMem, 0, 0, SRCCOPY)
        SelectObject(hdcMem, ohbm)
        DeleteObject(hbm)
        DeleteDC(hdcMem)
        EndPaint(hWnd, @ps)
        Return 0
    End Select
  End If

  If lpOldStatusProc <> NULL Then
    Return CallWindowProcW(lpOldStatusProc, hWnd, uMsg, wParam, lParam)
  End If
  Return DefWindowProcW(hWnd, uMsg, wParam, lParam)
End Function
End Extern

Sub HookStatusBar(ByVal hWndMain As HWND)
  If hWndMain = NULL Then
    Exit Sub
  End If
  Dim As HWND hStatus = GetStatusHandle(hWndMain)
  If hStatus <> NULL Then
    If hStatus <> hStatusGlobal OrElse lpOldStatusProc = NULL Then
      hStatusGlobal = hStatus
      lpOldStatusProc = Cast(WNDPROC, SetWindowLongPtrW(hStatus, GWLP_WNDPROC, Cast(LONG_PTR, @NewStatusProc)))
      InvalidateRect(hStatus, NULL, TRUE)
      UpdateWindow(hStatus)
    End If
  End If
End Sub

Sub UnhookStatusBar()
  If hStatusGlobal <> NULL AndAlso IsWindow(hStatusGlobal) AndAlso lpOldStatusProc <> NULL Then
    SetWindowLongPtrW(hStatusGlobal, GWLP_WNDPROC, Cast(LONG_PTR, lpOldStatusProc))
    InvalidateRect(hStatusGlobal, NULL, TRUE)
    UpdateWindow(hStatusGlobal)
  End If
  hStatusGlobal = NULL
  lpOldStatusProc = NULL
End Sub