Function HeaderSubclassProc(ByVal hWnd As HWND, ByVal uMsg As UINT, ByVal wParam As WPARAM, ByVal lParam As LPARAM, ByVal uIdSubclass As UINT_PTR, ByVal dwRefData As DWORD_PTR) As LRESULT
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

        Dim As HBRUSH hBrush = CreateSolidBrush(&h252525)
        FillRect(hdcMem, @clientRc, hBrush)
        DeleteObject(hBrush)

        Dim As HPEN hPenBorder = CreatePen(PS_SOLID, 1, &h404040)
        Dim As HPEN oldPen = Cast(HPEN, SelectObject(hdcMem, hPenBorder))

        Dim As Integer colCount = SendMessageW(hWnd, HDM_GETITEMCOUNT, 0, 0)
        Dim As RECT rcItem
        Dim As WChar textBuf(256)
        Dim As HDITEMW hdi
        hdi.mask = HDI_TEXT Or HDI_FORMAT
        hdi.pszText = @textBuf(0)
        hdi.cchTextMax = 256

        Dim As HFONT hFont = Cast(HFONT, SendMessageW(hWnd, WM_GETFONT, 0, 0))
        Dim As HFONT oldFont = NULL
        If hFont Then oldFont = Cast(HFONT, SelectObject(hdcMem, hFont))

        SetTextColor(hdcMem, &hFFFFFF)
        SetBkMode(hdcMem, TRANSPARENT)

        For i As Integer = 0 To colCount - 1
          SendMessageW(hWnd, HDM_GETITEMRECT, i, Cast(LPARAM, @rcItem))
          SendMessageW(hWnd, HDM_GETITEMW, i, Cast(LPARAM, @hdi))

          MoveToEx(hdcMem, rcItem.right - 1, rcItem.top + 3, NULL)
          LineTo(hdcMem, rcItem.right - 1, rcItem.bottom - 3)

          Dim As RECT textRc = rcItem
          textRc.left += 6
          textRc.right -= 6
          DrawTextW(hdcMem, @textBuf(0), -1, @textRc, DT_SINGLELINE Or DT_VCENTER Or DT_LEFT)
        Next

        MoveToEx(hdcMem, clientRc.left, clientRc.bottom - 1, NULL)
        LineTo(hdcMem, clientRc.right, clientRc.bottom - 1)

        If oldFont Then SelectObject(hdcMem, oldFont)
        SelectObject(hdcMem, oldPen)
        DeleteObject(hPenBorder)

        BitBlt(hDC, clientRc.left, clientRc.top, clientRc.right, clientRc.bottom, hdcMem, 0, 0, SRCCOPY)
        SelectObject(hdcMem, ohbm)
        DeleteObject(hbm)
        DeleteDC(hdcMem)
        EndPaint(hWnd, @ps)
        Return 0

      Case WM_NCDESTROY
        RemoveWindowSubclass(hWnd, @HeaderSubclassProc, uIdSubclass)
    End Select
  End If

  Return DefSubclassProc(hWnd, uMsg, wParam, lParam)
End Function