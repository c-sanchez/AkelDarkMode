Function EnumFindTabProc stdcall(ByVal hWndChild As HWND, ByVal lParam As LPARAM) As WINBOOL
  Dim As WChar className(63)
  GetClassNameW(hWndChild, @className(0), 64)
  If lstrcmpiW(@className(0), WStr("SysTabControl32")) = 0 Then
    *Cast(HWND Ptr, lParam) = hWndChild
    Return FALSE
  End If
  Return TRUE
End Function

Function GetTabHandle(ByVal hWndMain As HWND) As HWND
  Dim As HWND hFound = NULL
  EnumChildWindows(hWndMain, Cast(WNDENUMPROC, @EnumFindTabProc), Cast(LPARAM, @hFound))
  Return hFound
End Function

Extern "windows"
Function NewTabProc(ByVal hWnd As HWND, ByVal uMsg As UINT, ByVal wParam As WPARAM, ByVal lParam As LPARAM) As LRESULT
  If bDarkModeActive Then
    Select Case uMsg
      Case WM_ERASEBKGND
        Return 1

      Case WM_NCPAINT
        Return 0

      Case WM_MOUSEMOVE
        Dim As TCHITTESTINFO hti
        hti.pt.x = Cast(SHORT, LOWORD(lParam))
        hti.pt.y = Cast(SHORT, HIWORD(lParam))
        Dim As Integer newHover = SendMessageW(hWnd, TCM_HITTEST, 0, Cast(LPARAM, @hti))
        If newHover <> g_hoverTab Then
          g_hoverTab = newHover
          InvalidateRect(hWnd, NULL, FALSE)
          Dim As TRACKMOUSEEVENT tme
          tme.cbSize = SizeOf(TRACKMOUSEEVENT)
          tme.dwFlags = TME_LEAVE
          tme.hwndTrack = hWnd
          TrackMouseEvent(@tme)
        End If

      Case WM_MOUSELEAVE
        If g_hoverTab <> -1 Then
          g_hoverTab = -1
          InvalidateRect(hWnd, NULL, FALSE)
        End If

      Case WM_PAINT
        Dim As PAINTSTRUCT ps
        Dim As HDC hDC = BeginPaint(hWnd, @ps)
        Dim As RECT rcClient
        GetClientRect(hWnd, @rcClient)

        Dim As HDC hMemDC = CreateCompatibleDC(hDC)
        Dim As HBITMAP hBmp = CreateCompatibleBitmap(hDC, rcClient.right, rcClient.bottom)
        Dim As HBITMAP hOldBmp = Cast(HBITMAP, SelectObject(hMemDC, hBmp))

        Dim As HBRUSH hbrBg = CreateSolidBrush(&h202020)
        FillRect(hMemDC, @rcClient, hbrBg)
        DeleteObject(hbrBg)

        Dim As Integer tabCount = SendMessageW(hWnd, TCM_GETITEMCOUNT, 0, 0)
        Dim As Integer curSel = SendMessageW(hWnd, TCM_GETCURSEL, 0, 0)
        Dim As Any Ptr hIL = Cast(Any Ptr, SendMessageW(hWnd, TCM_GETIMAGELIST, 0, 0))

        Dim As HFONT hFont = Cast(HFONT, SendMessageW(hWnd, WM_GETFONT, 0, 0))
        Dim As HFONT oldFont = NULL
        If hFont Then oldFont = Cast(HFONT, SelectObject(hMemDC, hFont))
        SetBkMode(hMemDC, TRANSPARENT)

        For i As Integer = 0 To tabCount - 1
          Dim As RECT rcItem
          SendMessageW(hWnd, TCM_GETITEMRECT, i, Cast(LPARAM, @rcItem))

          Dim As Boolean isSel = (i = curSel)
          Dim As Boolean isHover = (i = g_hoverTab)

          Dim As COLORREF clrTabBg
          Dim As COLORREF clrText

          If isSel Then
            clrTabBg = &h333333
            clrText = &hFFFFFF
          ElseIf isHover Then
            clrTabBg = &h2B2B2B
            clrText = &hE0E0E0
          Else
            clrTabBg = &h222222
            clrText = &h999999
          End If

          Dim As HBRUSH hbrTab = CreateSolidBrush(clrTabBg)
          FillRect(hMemDC, @rcItem, hbrTab)
          DeleteObject(hbrTab)

          If isSel Then
            Dim As RECT rcTop = rcItem
            rcTop.bottom = rcTop.top + 2
            Dim As HBRUSH hbrAccent = CreateSolidBrush(&hD08000)
            FillRect(hMemDC, @rcTop, hbrAccent)
            DeleteObject(hbrAccent)
          End If

          Dim As HPEN hPenSep = CreatePen(PS_SOLID, 1, &h1A1A1A)
          Dim As HPEN oldPen = Cast(HPEN, SelectObject(hMemDC, hPenSep))
          MoveToEx(hMemDC, rcItem.right - 1, rcItem.top, NULL)
          LineTo(hMemDC, rcItem.right - 1, rcItem.bottom)
          SelectObject(hMemDC, oldPen)
          DeleteObject(hPenSep)

          Dim As WChar textBuf(255)
          textBuf(0) = 0
          Dim As TCITEMW tci
          tci.mask = TCIF_TEXT Or TCIF_IMAGE
          tci.pszText = @textBuf(0)
          tci.cchTextMax = 256
          SendMessageW(hWnd, TCM_GETITEMW, i, Cast(LPARAM, @tci))

          Dim As Boolean hasIcon = ((tci.mask And TCIF_IMAGE) <> 0 AndAlso tci.iImage >= 0 AndAlso hIL <> NULL)
          Dim As Boolean hasText = (textBuf(0) <> 0)

          If hasIcon Then
            Dim As Integer iconX
            If hasText Then
              iconX = rcItem.left + 6
            Else
              iconX = rcItem.left + (rcItem.right - rcItem.left - 16) \ 2
            End If
            Dim As Integer iconY = rcItem.top + (rcItem.bottom - rcItem.top - 16) \ 2
            If _ImageList_Draw <> NULL Then
              _ImageList_Draw(hIL, tci.iImage, hMemDC, iconX, iconY, ILD_TRANSPARENT)
            End If
          End If

          If hasText Then
            Dim As RECT rcText = rcItem
            If hasIcon Then
              rcText.left += 26
            Else
              rcText.left += 6
            End If
            rcText.right -= 6
            SetTextColor(hMemDC, clrText)
            DrawTextW(hMemDC, @textBuf(0), -1, @rcText, DT_SINGLELINE Or DT_VCENTER Or DT_CENTER Or DT_END_ELLIPSIS)
          End If
        Next i

        Dim As HPEN hPenBorder = CreatePen(PS_SOLID, 1, &h2B2B2B)
        Dim As HPEN oldPen2 = Cast(HPEN, SelectObject(hMemDC, hPenBorder))
        MoveToEx(hMemDC, rcClient.left, rcClient.bottom - 1, NULL)
        LineTo(hMemDC, rcClient.right, rcClient.bottom - 1)
        SelectObject(hMemDC, oldPen2)
        DeleteObject(hPenBorder)

        If oldFont Then SelectObject(hMemDC, oldFont)
        BitBlt(hDC, 0, 0, rcClient.right, rcClient.bottom, hMemDC, 0, 0, SRCCOPY)
        SelectObject(hMemDC, hOldBmp)
        DeleteObject(hBmp)
        DeleteDC(hMemDC)
        EndPaint(hWnd, @ps)
        Return 0
    End Select
  End If

  If lpOldTabProc <> NULL Then
    Return CallWindowProcW(lpOldTabProc, hWnd, uMsg, wParam, lParam)
  End If
  Return DefWindowProcW(hWnd, uMsg, wParam, lParam)
End Function
End Extern

Sub HookTabControl(ByVal hWndMain As HWND)
  If hWndMain = NULL Then
    Exit Sub
  End If
  Dim As HWND hTab = GetTabHandle(hWndMain)
  If hTab <> NULL Then
    If hTab <> hTabGlobal OrElse lpOldTabProc = NULL Then
      hTabGlobal = hTab
      lpOldTabProc = Cast(WNDPROC, SetWindowLongPtrW(hTab, GWLP_WNDPROC, Cast(LONG_PTR, @NewTabProc)))
      InvalidateRect(hTab, NULL, TRUE)
      UpdateWindow(hTab)
    End If
  End If
End Sub

Sub UnhookTabControl()
  If hTabGlobal <> NULL AndAlso IsWindow(hTabGlobal) AndAlso lpOldTabProc <> NULL Then
    SetWindowLongPtrW(hTabGlobal, GWLP_WNDPROC, Cast(LONG_PTR, lpOldTabProc))
    InvalidateRect(hTabGlobal, NULL, TRUE)
    UpdateWindow(hTabGlobal)
  End If
  hTabGlobal = NULL
  lpOldTabProc = NULL
  g_hoverTab = -1
End Sub