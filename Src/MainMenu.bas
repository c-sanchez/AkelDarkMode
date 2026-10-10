Extern "windows"
Function NewMainProc(ByVal hWnd As HWND, ByVal uMsg As UINT, ByVal wParam As WPARAM, ByVal lParam As LPARAM) As LRESULT
  If uMsg = AKDN_MAIN_ONSTART_PRESHOW Then
    RefreshTitleBarThemeColor(hWnd, bDarkModeActive)
    HookTabControl(hWnd)
    HookStatusBar(hWnd)
    RefreshAllEditWindowsTheme(hWnd)
  End If

  If bDarkModeActive Then
    If uMsg = AKDN_EDIT_ONSTART Then
      ApplyThemeToEditWindow(Cast(HWND, wParam), TRUE)
    End If

    If uMsg = WM_SIZE OrElse uMsg = WM_WINDOWPOSCHANGED Then
      If hTabGlobal = NULL OrElse IsWindow(hTabGlobal) = FALSE Then
        HookTabControl(hWnd)
      End If
      If hStatusGlobal = NULL OrElse IsWindow(hStatusGlobal) = FALSE Then
        HookStatusBar(hWnd)
      End If
    End If

    If uMsg = WM_NCPAINT OrElse uMsg = WM_NCACTIVATE Then
      Dim As LRESULT lRes = 0
      If lpMainProcData <> NULL AndAlso lpMainProcData->NextProc <> NULL Then
        lRes = lpMainProcData->NextProc(hWnd, uMsg, wParam, lParam)
      Else
        lRes = DefWindowProcW(hWnd, uMsg, wParam, lParam)
      End If
      PaintMenuSeparatorLine(hWnd, TRUE)
      Return lRes
    End If

    Select Case uMsg
      Case &h0091
        Dim As UAHMENU Ptr pUM = Cast(UAHMENU Ptr, lParam)
        Dim As MENUBARINFO mbi
        mbi.cbSize = SizeOf(MENUBARINFO)
        GetMenuBarInfo(hWnd, OBJID_MENU, 0, @mbi)
        Dim As RECT rcWindow
        GetWindowRect(hWnd, @rcWindow)
        Dim As POINT ptClient = Type(0, 0)
        ClientToScreen(hWnd, @ptClient)

        Dim As RECT rcBar = mbi.rcBar
        OffsetRect(@rcBar, -rcWindow.left, -rcWindow.top)
        rcBar.left = 0
        rcBar.right = rcWindow.right - rcWindow.left
        Dim As Integer clientTop = ptClient.y - rcWindow.top
        If clientTop > rcBar.bottom Then
          rcBar.bottom = clientTop
        Else
          rcBar.bottom += 2
        End If
        FillRect(pUM->hDC, @rcBar, g_hbrDark)
        Return TRUE

      Case &h0092
        Dim As UAHDRAWMENUITEM Ptr pUDMI = Cast(UAHDRAWMENUITEM Ptr, lParam)
        Dim As WChar textBuf(255)
        textBuf(0) = 0
        Dim As MENUITEMINFOW mii
        mii.cbSize = SizeOf(MENUITEMINFOW)
        mii.fMask = MIIM_STRING
        mii.dwTypeData = @textBuf(0)
        mii.cch = 256
        GetMenuItemInfoW(pUDMI->um.hMenu, pUDMI->umi.iPosition, TRUE, @mii)

        Dim As UINT cmd = (pUDMI->dis.itemID And &hFFF0)
        If cmd = 0 Then
          cmd = (GetMenuItemID(pUDMI->um.hMenu, pUDMI->umi.iPosition) And &hFFF0)
        End If

        If cmd = SC_CLOSE OrElse cmd = SC_RESTORE OrElse cmd = SC_MINIMIZE Then
          Dim As Boolean isHovered = ((pUDMI->dis.itemState And ODS_HOTLIGHT) <> 0) OrElse ((pUDMI->dis.itemState And ODS_SELECTED) <> 0)
          Dim As HBRUSH hBrush
          Dim As COLORREF textColor

          If cmd = SC_CLOSE Then
            If isHovered Then
              hBrush = CreateSolidBrush(&h2311E8)
              textColor = &hFFFFFF
            Else
              hBrush = CreateSolidBrush(&h2B2B2B)
              textColor = &hE0E0E0
            End If
          Else
            If isHovered Then
              hBrush = CreateSolidBrush(&h454545)
              textColor = &hFFFFFF
            Else
              hBrush = CreateSolidBrush(&h2B2B2B)
              textColor = &hE0E0E0
            End If
          End If

          FillRect(pUDMI->um.hDC, @pUDMI->dis.rcItem, hBrush)
          DeleteObject(hBrush)

          Dim As Integer cx = (pUDMI->dis.rcItem.left + pUDMI->dis.rcItem.right) \ 2
          Dim As Integer cy = (pUDMI->dis.rcItem.top + pUDMI->dis.rcItem.bottom) \ 2

          Dim As HPEN hPen = CreatePen(PS_SOLID, 1, textColor)
          Dim As HPEN oldPen = SelectObject(pUDMI->um.hDC, hPen)
          Dim As HBRUSH oldBrush = SelectObject(pUDMI->um.hDC, GetStockObject(NULL_BRUSH))

          If cmd = SC_CLOSE Then
            MoveToEx(pUDMI->um.hDC, cx - 4, cy - 4, NULL)
            LineTo(pUDMI->um.hDC, cx + 5, cy + 5)
            MoveToEx(pUDMI->um.hDC, cx - 4, cy + 4, NULL)
            LineTo(pUDMI->um.hDC, cx + 5, cy - 5)
          ElseIf cmd = SC_RESTORE Then
            Rectangle(pUDMI->um.hDC, cx - 5, cy - 2, cx + 3, cy + 6)
            MoveToEx(pUDMI->um.hDC, cx - 2, cy - 2, NULL)
            LineTo(pUDMI->um.hDC, cx - 2, cy - 5)
            LineTo(pUDMI->um.hDC, cx + 6, cy - 5)
            LineTo(pUDMI->um.hDC, cx + 6, cy + 3)
            LineTo(pUDMI->um.hDC, cx + 2, cy + 3)
          ElseIf cmd = SC_MINIMIZE Then
            MoveToEx(pUDMI->um.hDC, cx - 5, cy + 4, NULL)
            LineTo(pUDMI->um.hDC, cx + 5, cy + 4)
          End If

          SelectObject(pUDMI->um.hDC, oldBrush)
          SelectObject(pUDMI->um.hDC, oldPen)
          DeleteObject(hPen)
          Return TRUE
        End If

        If textBuf(0) = 0 Then
          Dim As HDC hOrigDC = pUDMI->um.hDC
          Dim As RECT rcOrig = pUDMI->dis.rcItem
          Dim As Integer w = rcOrig.right - rcOrig.left
          Dim As Integer h = rcOrig.bottom - rcOrig.top

          If w > 0 AndAlso h > 0 AndAlso w <= 64 AndAlso h <= 64 Then
            Dim As HDC hMemDC = CreateCompatibleDC(hOrigDC)
            Dim As HBITMAP hBmp = CreateCompatibleBitmap(hOrigDC, w, h)
            Dim As HBITMAP hOldBmp = Cast(HBITMAP, SelectObject(hMemDC, hBmp))

            Dim As RECT rcMem = Type(0, 0, w, h)
            FillRect(hMemDC, @rcMem, GetSysColorBrush(COLOR_MENUBAR))

            pUDMI->um.hDC = hMemDC
            pUDMI->dis.hDC = hMemDC
            pUDMI->dis.rcItem = rcMem

            If lpMainProcData <> NULL AndAlso lpMainProcData->NextProc <> NULL Then
              lpMainProcData->NextProc(hWnd, uMsg, wParam, lParam)
            Else
              DefWindowProcW(hWnd, uMsg, wParam, lParam)
            End If

            pUDMI->um.hDC = hOrigDC
            pUDMI->dis.hDC = hOrigDC
            pUDMI->dis.rcItem = rcOrig

            Dim As COLORREF clrBg = GetPixel(hMemDC, 0, 0)
            Dim As Boolean isHovered = ((pUDMI->dis.itemState And ODS_HOTLIGHT) <> 0) OrElse ((pUDMI->dis.itemState And ODS_SELECTED) <> 0)
            Dim As COLORREF clrDark = IIf(isHovered, &h454545, &h2B2B2B)

            If clrBg <> clrDark Then
              Dim As Integer qHead = 0, qTail = 0
              Dim As Integer qX(4095), qY(4095)

              For x As Integer = 0 To w - 1
                If GetPixel(hMemDC, x, 0) = clrBg Then
                  SetPixel(hMemDC, x, 0, clrDark)
                  qX(qTail) = x
                  qY(qTail) = 0
                  qTail += 1
                End If
                If h > 1 AndAlso GetPixel(hMemDC, x, h - 1) = clrBg Then
                  SetPixel(hMemDC, x, h - 1, clrDark)
                  qX(qTail) = x
                  qY(qTail) = h - 1
                  qTail += 1
                End If
              Next x

              For y As Integer = 1 To h - 2
                If GetPixel(hMemDC, 0, y) = clrBg Then
                  SetPixel(hMemDC, 0, y, clrDark)
                  qX(qTail) = 0
                  qY(qTail) = y
                  qTail += 1
                End If
                If w > 1 AndAlso GetPixel(hMemDC, w - 1, y) = clrBg Then
                  SetPixel(hMemDC, w - 1, y, clrDark)
                  qX(qTail) = w - 1
                  qY(qTail) = y
                  qTail += 1
                End If
              Next y

              While qHead < qTail
                Dim As Integer cx = qX(qHead)
                Dim As Integer cy = qY(qHead)
                qHead += 1

                If cx > 0 Then
                  If GetPixel(hMemDC, cx - 1, cy) = clrBg Then
                    SetPixel(hMemDC, cx - 1, cy, clrDark)
                    qX(qTail) = cx - 1
                    qY(qTail) = cy
                    qTail += 1
                  End If
                End If
                If cx < w - 1 Then
                  If GetPixel(hMemDC, cx + 1, cy) = clrBg Then
                    SetPixel(hMemDC, cx + 1, cy, clrDark)
                    qX(qTail) = cx + 1
                    qY(qTail) = cy
                    qTail += 1
                  End If
                End If
                If cy > 0 Then
                  If GetPixel(hMemDC, cx, cy - 1) = clrBg Then
                    SetPixel(hMemDC, cx, cy - 1, clrDark)
                    qX(qTail) = cx
                    qY(qTail) = cy - 1
                    qTail += 1
                  End If
                End If
                If cy < h - 1 Then
                  If GetPixel(hMemDC, cx, cy + 1) = clrBg Then
                    SetPixel(hMemDC, cx, cy + 1, clrDark)
                    qX(qTail) = cx
                    qY(qTail) = cy + 1
                    qTail += 1
                  End If
                End If
              Wend
            End If

            BitBlt(hOrigDC, rcOrig.left, rcOrig.top, w, h, hMemDC, 0, 0, SRCCOPY)
            SelectObject(hMemDC, hOldBmp)
            DeleteObject(hBmp)
            DeleteDC(hMemDC)
            Return TRUE
          End If
        End If

        Dim As HBRUSH hBrush
        Dim As COLORREF textColor
        If ((pUDMI->dis.itemState And ODS_SELECTED) <> 0) OrElse ((pUDMI->dis.itemState And ODS_HOTLIGHT) <> 0) Then
          hBrush = CreateSolidBrush(&h454545)
          textColor = &hFFFFFF
        Else
          hBrush = CreateSolidBrush(&h2B2B2B)
          textColor = &hE0E0E0
        End If

        FillRect(pUDMI->um.hDC, @pUDMI->dis.rcItem, hBrush)
        DeleteObject(hBrush)

        SetTextColor(pUDMI->um.hDC, textColor)
        SetBkMode(pUDMI->um.hDC, TRANSPARENT)

        Dim As DWORD dtFlags = DT_CENTER Or DT_SINGLELINE Or DT_VCENTER
        Dim As Boolean bHideAccel = ((pUDMI->dis.itemState And ODS_NOACCEL) <> 0)
        If bHideAccel = FALSE Then
          If (SendMessageW(hWnd, WM_QUERYUISTATE, 0, 0) And UISF_HIDEACCEL) <> 0 Then
            bHideAccel = TRUE
          End If
        End If
        If bHideAccel Then
          dtFlags Or= DT_HIDEPREFIX
        End If

        DrawTextW(pUDMI->um.hDC, @textBuf(0), -1, @pUDMI->dis.rcItem, dtFlags)

        Return TRUE
    End Select
  End If

  If lpMainProcData <> NULL AndAlso lpMainProcData->NextProc <> NULL Then
    Return lpMainProcData->NextProc(hWnd, uMsg, wParam, lParam)
  End If

  Return DefWindowProcW(hWnd, uMsg, wParam, lParam)
End Function
End Extern