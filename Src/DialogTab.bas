Function DialogTabSubclassProc(ByVal hWnd As HWND, ByVal uMsg As UINT, ByVal wParam As WPARAM, ByVal lParam As LPARAM, ByVal uIdSubclass As UINT_PTR, ByVal dwRefData As DWORD_PTR) As LRESULT
  If bDarkModeActive Then
    Select Case uMsg
      Case WM_ERASEBKGND
        Return 1

      Case WM_PAINT
        Dim As PAINTSTRUCT ps
        Dim As HDC hDC = BeginPaint(hWnd, @ps)
        Dim As RECT rc
        GetClientRect(hWnd, @rc)

        Dim As HDC hdcMem = CreateCompatibleDC(hDC)
        Dim As HBITMAP hbm = CreateCompatibleBitmap(hDC, rc.right - rc.left, rc.bottom - rc.top)
        Dim As HBITMAP ohbm = Cast(HBITMAP, SelectObject(hdcMem, hbm))

        FillRect(hdcMem, @rc, g_hbrDark)

        Dim As Integer tabCount = SendMessageW(hWnd, TCM_GETITEMCOUNT, 0, 0)
        Dim As Integer maxBottom = 0
        For i As Integer = 0 To tabCount - 1
          Dim As RECT rct
          SendMessageW(hWnd, TCM_GETITEMRECT, i, Cast(LPARAM, @rct))
          If rct.bottom > maxBottom Then maxBottom = rct.bottom
        Next

        Dim As RECT rcBody = rc
        rcBody.top = maxBottom

        FillRect(hdcMem, @rcBody, g_hbrDark)

        Dim As HPEN hBorderPen = CreatePen(PS_SOLID, 1, &h4A4A4A)
        Dim As HPEN oldPen = Cast(HPEN, SelectObject(hdcMem, hBorderPen))
        Dim As HBRUSH oldBrush = Cast(HBRUSH, SelectObject(hdcMem, GetStockObject(NULL_BRUSH)))
        Rectangle(hdcMem, rcBody.left, rcBody.top, rcBody.right, rcBody.bottom)

        Dim As Integer curSel = SendMessageW(hWnd, TCM_GETCURSEL, 0, 0)
        Dim As HFONT hFont = Cast(HFONT, SendMessageW(hWnd, WM_GETFONT, 0, 0))
        Dim As HFONT oldFont = NULL
        If hFont Then oldFont = Cast(HFONT, SelectObject(hdcMem, hFont))
        SetBkMode(hdcMem, TRANSPARENT)

        Dim As WChar textBuf(256)
        Dim As TCITEMW tci
        tci.mask = TCIF_TEXT
        tci.pszText = @textBuf(0)
        tci.cchTextMax = 256

        For i As Integer = 0 To tabCount - 1
          Dim As RECT rcTab
          SendMessageW(hWnd, TCM_GETITEMRECT, i, Cast(LPARAM, @rcTab))

          If i <> curSel Then
            Dim As HBRUSH hInact = CreateSolidBrush(&h202020)
            FillRect(hdcMem, @rcTab, hInact)
            DeleteObject(hInact)

            Dim As HPEN hTabBorder = CreatePen(PS_SOLID, 1, &h4A4A4A)
            SelectObject(hdcMem, hTabBorder)
            MoveToEx(hdcMem, rcTab.left, rcTab.top, NULL)
            LineTo(hdcMem, rcTab.right - 1, rcTab.top)
            LineTo(hdcMem, rcTab.right - 1, rcBody.top)
            MoveToEx(hdcMem, rcTab.left, rcTab.top, NULL)
            LineTo(hdcMem, rcTab.left, rcBody.top)
            SelectObject(hdcMem, hBorderPen)
            DeleteObject(hTabBorder)

            SetTextColor(hdcMem, &h888888)
            SendMessageW(hWnd, TCM_GETITEMW, i, Cast(LPARAM, @tci))
            DrawTextW(hdcMem, @textBuf(0), -1, @rcTab, DT_CENTER Or DT_VCENTER Or DT_SINGLELINE)
          End If
        Next

        If curSel >= 0 AndAlso curSel < tabCount Then
          Dim As RECT rcTab
          SendMessageW(hWnd, TCM_GETITEMRECT, curSel, Cast(LPARAM, @rcTab))
          rcTab.top -= 2
          rcTab.bottom += 1

          FillRect(hdcMem, @rcTab, g_hbrDark)

          SelectObject(hdcMem, hBorderPen)
          MoveToEx(hdcMem, rcTab.left, rcBody.top, NULL)
          LineTo(hdcMem, rcTab.left, rcTab.top)
          LineTo(hdcMem, rcTab.right - 1, rcTab.top)
          LineTo(hdcMem, rcTab.right - 1, rcBody.top)

          Dim As HPEN hErase = CreatePen(PS_SOLID, 1, &h2B2B2B)
          SelectObject(hdcMem, hErase)
          MoveToEx(hdcMem, rcTab.left + 1, rcBody.top, NULL)
          LineTo(hdcMem, rcTab.right - 1, rcBody.top)
          SelectObject(hdcMem, hBorderPen)
          DeleteObject(hErase)

          SetTextColor(hdcMem, &hFFFFFF)
          SendMessageW(hWnd, TCM_GETITEMW, curSel, Cast(LPARAM, @tci))
          DrawTextW(hdcMem, @textBuf(0), -1, @rcTab, DT_CENTER Or DT_VCENTER Or DT_SINGLELINE)
        End If

        SelectObject(hdcMem, oldPen)
        SelectObject(hdcMem, oldBrush)
        DeleteObject(hBorderPen)
        If oldFont Then SelectObject(hdcMem, oldFont)

        BitBlt(hDC, rc.left, rc.top, rc.right - rc.left, rc.bottom - rc.top, hdcMem, 0, 0, SRCCOPY)
        SelectObject(hdcMem, ohbm)
        DeleteObject(hbm)
        DeleteDC(hdcMem)
        EndPaint(hWnd, @ps)
        Return 0

      Case WM_NCDESTROY
        RemoveWindowSubclass(hWnd, @DialogTabSubclassProc, uIdSubclass)
    End Select
  End If

  Return DefSubclassProc(hWnd, uMsg, wParam, lParam)
End Function