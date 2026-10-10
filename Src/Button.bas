Sub DarkenImageBg(ByVal hdcMem As HDC, ByVal startX As Integer, ByVal startY As Integer, ByVal imgW As Integer, ByVal imgH As Integer, ByVal bgBase As Integer)
  For y As Integer = startY To startY + imgH - 1
    For x As Integer = startX To startX + imgW - 1
      Dim As COLORREF px = GetPixel(hdcMem, x, y)
      Dim As Integer r = px And 255
      Dim As Integer g = (px Shr 8) And 255
      Dim As Integer b = (px Shr 16) And 255
      If r < bgBase AndAlso g < bgBase AndAlso b < bgBase Then
        Dim As Integer newR = bgBase + ((bgBase - r) * (224 - bgBase)) \ bgBase
        Dim As Integer newG = bgBase + ((bgBase - g) * (224 - bgBase)) \ bgBase
        Dim As Integer newB = bgBase + ((bgBase - b) * (224 - bgBase)) \ bgBase
        SetPixel(hdcMem, x, y, RGB(newR, newG, newB))
      End If
    Next
  Next
End Sub

Function ButtonSubclassProc(ByVal hWnd As HWND, ByVal uMsg As UINT, ByVal wParam As WPARAM, ByVal lParam As LPARAM, ByVal uIdSubclass As UINT_PTR, ByVal dwRefData As DWORD_PTR) As LRESULT
  If bDarkModeActive Then
    Dim As Long fullStyle = GetWindowLongPtrW(hWnd, GWL_STYLE)
    Dim As Long style = fullStyle And &h0F
    Dim As Boolean isCheckOrRadio = (style = BS_AUTOCHECKBOX) OrElse (style = BS_CHECKBOX) OrElse (style = BS_AUTORADIOBUTTON) OrElse (style = BS_RADIOBUTTON) OrElse (style = BS_3STATE) OrElse (style = BS_AUTO3STATE)
    Dim As Boolean isGroupBox = (style = BS_GROUPBOX)
    Dim As Boolean isOwnerDraw = (style = BS_OWNERDRAW)

    If isOwnerDraw Then
      Return DefSubclassProc(hWnd, uMsg, wParam, lParam)
    End If

    If isGroupBox Then
      Select Case uMsg
        Case WM_ERASEBKGND
          Return 1

        Case WM_PAINT
          Dim As PAINTSTRUCT ps
          Dim As HDC hDC = BeginPaint(hWnd, @ps)
          Dim As RECT rc
          GetClientRect(hWnd, @rc)

          Dim As HFONT hFont = Cast(HFONT, SendMessageW(hWnd, WM_GETFONT, 0, 0))
          Dim As HFONT oldFont = NULL
          If hFont Then oldFont = Cast(HFONT, SelectObject(hDC, hFont))

          Dim As WChar textBuf(255)
          GetWindowTextW(hWnd, @textBuf(0), 255)
          Dim As Integer textLen = lstrlenW(@textBuf(0))

          Dim As SIZE textSize
          If textLen > 0 Then
            GetTextExtentPoint32W(hDC, @textBuf(0), textLen, @textSize)
          Else
            textSize.cx = 0
            textSize.cy = 14
          End If

          Dim As RECT boxRc = rc
          boxRc.top += (textSize.cy \ 2)
          boxRc.right -= 1
          boxRc.bottom -= 1

          Dim As HPEN hBorderPen = CreatePen(PS_SOLID, 1, &h4A4A4A)
          Dim As HPEN oldPen = Cast(HPEN, SelectObject(hDC, hBorderPen))
          Dim As HBRUSH oldBrush = Cast(HBRUSH, SelectObject(hDC, GetStockObject(NULL_BRUSH)))

          Rectangle(hDC, boxRc.left, boxRc.top, boxRc.right, boxRc.bottom)

          If textLen > 0 Then
            Dim As RECT textRc
            textRc.left = rc.left + 9
            textRc.top = rc.top
            textRc.right = textRc.left + textSize.cx + 6
            textRc.bottom = rc.top + textSize.cy
            FillRect(hDC, @textRc, g_hbrDark)

            SetBkMode(hDC, TRANSPARENT)
            SetTextColor(hDC, &hE0E0E0)
            textRc.left += 3
            DrawTextW(hDC, @textBuf(0), -1, @textRc, DT_SINGLELINE Or DT_VCENTER)
          End If

          SelectObject(hDC, oldPen)
          SelectObject(hDC, oldBrush)
          DeleteObject(hBorderPen)
          If oldFont Then SelectObject(hDC, oldFont)
          EndPaint(hWnd, @ps)
          Return 0

        Case WM_NCDESTROY
          RemoveWindowSubclass(hWnd, @ButtonSubclassProc, uIdSubclass)
      End Select
      Return DefSubclassProc(hWnd, uMsg, wParam, lParam)
    End If

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

        Dim As Long checked = SendMessageW(hWnd, BM_GETCHECK, 0, 0)
        Dim As Long btnState = SendMessageW(hWnd, BM_GETSTATE, 0, 0)
        Dim As Boolean isPressed = ((btnState And BST_PUSHED) <> 0)
        Dim As Boolean isEnabled = IsWindowEnabled(hWnd)

        Dim As Integer boxSize = 12
        Dim As Integer boxX = 0
        Dim As Integer boxY = (rc.bottom - rc.top - boxSize) \ 2

        If isCheckOrRadio Then
          Dim As GpGraphics Ptr g
          GdipCreateFromHDC(hdcMem, @g)
          GdipSetSmoothingMode(g, SmoothingModeAntiAlias)

          Dim As DWORD borderColorGdip = IIf(isEnabled, &hFF6B6B6B, &hFF444444)
          Dim As DWORD bgFillColorGdip
          If Not isEnabled Then
            bgFillColorGdip = &hFF2A2A2A
          ElseIf isPressed Then
            bgFillColorGdip = &hFF1A1A1A
          ElseIf GetPropW(hWnd, WStr("BtnHover")) <> NULL Then
            bgFillColorGdip = &hFF262626
          Else
            bgFillColorGdip = &hFF202020
          End If
          Dim As DWORD checkColorGdip = IIf(isEnabled, &hFFFFFFFF, &hFF777777)

          Dim As GpPen Ptr borderPen
          Dim As GpSolidFill Ptr bgBrush
          GdipCreatePen1(borderColorGdip, 1.0, UnitPixel, @borderPen)
          GdipCreateSolidFill(bgFillColorGdip, @bgBrush)

          If style = BS_AUTOCHECKBOX OrElse style = BS_CHECKBOX OrElse style = BS_3STATE OrElse style = BS_AUTO3STATE Then
            GdipFillRectangle(g, Cast(GpBrush Ptr, bgBrush), boxX, boxY, boxSize, boxSize)
            GdipDrawRectangle(g, borderPen, boxX, boxY, boxSize, boxSize)
            If checked = BST_CHECKED Then
              Dim As GpPen Ptr checkPen
              GdipCreatePen1(checkColorGdip, 1.6, UnitPixel, @checkPen)
              GdipSetPenStartCap(checkPen, LineCapRound)
              GdipSetPenEndCap(checkPen, LineCapRound)
              GdipDrawLine(g, checkPen, boxX + 2, boxY + 6, boxX + 5, boxY + 9)
              GdipDrawLine(g, checkPen, boxX + 5, boxY + 9, boxX + 10, boxY + 3)
              GdipDeletePen(checkPen)
            ElseIf checked = BST_INDETERMINATE Then
              Dim As GpSolidFill Ptr indetBrush
              GdipCreateSolidFill(checkColorGdip, @indetBrush)
              GdipFillRectangle(g, Cast(GpBrush Ptr, indetBrush), boxX + 3, boxY + 3, boxSize - 6, boxSize - 6)
              GdipDeleteBrush(Cast(GpBrush Ptr, indetBrush))
            End If
          ElseIf style = BS_AUTORADIOBUTTON OrElse style = BS_RADIOBUTTON Then
            GdipFillEllipse(g, Cast(GpBrush Ptr, bgBrush), boxX, boxY, boxSize, boxSize)
            GdipDrawEllipse(g, borderPen, boxX, boxY, boxSize, boxSize)
            If checked = BST_CHECKED Then
              Dim As GpSolidFill Ptr dotBrush
              GdipCreateSolidFill(checkColorGdip, @dotBrush)
              GdipFillEllipse(g, Cast(GpBrush Ptr, dotBrush), boxX + 3, boxY + 3, boxSize - 6, boxSize - 6)
              GdipDeleteBrush(Cast(GpBrush Ptr, dotBrush))
            End If
          End If

          GdipDeletePen(borderPen)
          GdipDeleteBrush(Cast(GpBrush Ptr, bgBrush))
          GdipDeleteGraphics(g)
        Else
          Dim As COLORREF btnBg = &h333333
          Dim As COLORREF btnBorder = &h555555

          If Not isEnabled Then
            btnBg = &h2B2B2B
            btnBorder = &h444444
          ElseIf isPressed Then
            btnBg = &h4A4A4A
          ElseIf GetPropW(hWnd, WStr("BtnHover")) <> NULL Then
            btnBg = &h3D3D3D
          ElseIf (style = BS_DEFPUSHBUTTON) Then
            btnBorder = &hB5711A
          End If

          Dim As HBRUSH hBtnBrush = CreateSolidBrush(btnBg)
          FillRect(hdcMem, @rc, hBtnBrush)
          DeleteObject(hBtnBrush)

          Dim As HPEN hPen = CreatePen(PS_SOLID, 1, btnBorder)
          Dim As HPEN oldPen = Cast(HPEN, SelectObject(hdcMem, hPen))
          Dim As HBRUSH oldBrush = Cast(HBRUSH, SelectObject(hdcMem, GetStockObject(NULL_BRUSH)))
          Rectangle(hdcMem, rc.left, rc.top, rc.right, rc.bottom)
          SelectObject(hdcMem, oldPen)
          SelectObject(hdcMem, oldBrush)
          DeleteObject(hPen)

          Dim As Boolean hasIcon = ((fullStyle And BS_ICON) = BS_ICON)
          Dim As Boolean hasBitmap = ((fullStyle And BS_BITMAP) = BS_BITMAP)

          If hasIcon Then
            Dim As HICON hIcon = Cast(HICON, SendMessageW(hWnd, BM_GETIMAGE, IMAGE_ICON, 0))
            If hIcon <> NULL Then
              Dim As ICONINFO ii
              Dim As Integer iconW = 16, iconH = 16
              If GetIconInfo(hIcon, @ii) Then
                Dim As BITMAP bmp
                If ii.hbmColor <> NULL Then
                  GetObject(ii.hbmColor, SizeOf(BITMAP), @bmp)
                  iconW = bmp.bmWidth
                  iconH = bmp.bmHeight
                ElseIf ii.hbmMask <> NULL Then
                  GetObject(ii.hbmMask, SizeOf(BITMAP), @bmp)
                  iconW = bmp.bmWidth
                  iconH = bmp.bmHeight \ 2
                End If
                If ii.hbmColor Then DeleteObject(ii.hbmColor)
                If ii.hbmMask Then DeleteObject(ii.hbmMask)
              End If

              Dim As Integer ix = rc.left + (rc.right - rc.left - iconW) \ 2
              Dim As Integer iy = rc.top + (rc.bottom - rc.top - iconH) \ 2
              DrawIconEx(hdcMem, ix, iy, hIcon, iconW, iconH, 0, NULL, DI_NORMAL)

              DarkenImageBg(hdcMem, ix, iy, iconW, iconH, btnBg And 255)
            End If
          ElseIf hasBitmap Then
            Dim As HBITMAP hBmp = Cast(HBITMAP, SendMessageW(hWnd, BM_GETIMAGE, IMAGE_BITMAP, 0))
            If hBmp <> NULL Then
              Dim As HDC hBmpDC = CreateCompatibleDC(hDC)
              Dim As HBITMAP hOldBmp = Cast(HBITMAP, SelectObject(hBmpDC, hBmp))
              Dim As BITMAP bmp
              GetObject(hBmp, SizeOf(BITMAP), @bmp)
              Dim As Integer bx = rc.left + (rc.right - rc.left - bmp.bmWidth) \ 2
              Dim As Integer by = rc.top + (rc.bottom - rc.top - bmp.bmHeight) \ 2
              BitBlt(hdcMem, bx, by, bmp.bmWidth, bmp.bmHeight, hBmpDC, 0, 0, SRCCOPY)

              DarkenImageBg(hdcMem, bx, by, bmp.bmWidth, bmp.bmHeight, btnBg And 255)

              SelectObject(hBmpDC, hOldBmp)
              DeleteDC(hBmpDC)
            End If
          End If
        End If

        Dim As WChar textBuf(255)
        GetWindowTextW(hWnd, @textBuf(0), 255)

        If lstrlenW(@textBuf(0)) > 0 Then
          SetBkMode(hdcMem, TRANSPARENT)
          SetTextColor(hdcMem, IIf(isEnabled, &hE0E0E0, &h777777))

          Dim As RECT textRc = rc
          If isCheckOrRadio Then
            textRc.left += (boxSize + 6)
          End If

          Dim As HFONT hFont = Cast(HFONT, SendMessageW(hWnd, WM_GETFONT, 0, 0))
          Dim As HFONT oldFont = NULL
          If hFont Then oldFont = Cast(HFONT, SelectObject(hdcMem, hFont))

          If isCheckOrRadio Then
            DrawTextW(hdcMem, @textBuf(0), -1, @textRc, DT_SINGLELINE Or DT_VCENTER Or DT_LEFT)
          Else
            DrawTextW(hdcMem, @textBuf(0), -1, @textRc, DT_SINGLELINE Or DT_CENTER Or DT_VCENTER)
          End If

          If oldFont Then SelectObject(hdcMem, oldFont)
        End If

        BitBlt(hDC, rc.left, rc.top, rc.right, rc.bottom, hdcMem, 0, 0, SRCCOPY)
        SelectObject(hdcMem, ohbm)
        DeleteObject(hbm)
        DeleteDC(hdcMem)

        EndPaint(hWnd, @ps)
        Return 0

      Case WM_MOUSEMOVE
        If GetPropW(hWnd, WStr("BtnHover")) = NULL Then
          SetPropW(hWnd, WStr("BtnHover"), Cast(HANDLE, 1))
          Dim As TRACKMOUSEEVENT tme
          tme.cbSize = SizeOf(tme)
          tme.dwFlags = TME_LEAVE
          tme.hwndTrack = hWnd
          TrackMouseEvent(@tme)
        End If

      Case WM_MOUSELEAVE
        RemovePropW(hWnd, WStr("BtnHover"))

      Case WM_NCDESTROY
        RemovePropW(hWnd, WStr("BtnHover"))
        RemoveWindowSubclass(hWnd, @ButtonSubclassProc, uIdSubclass)
        Return DefSubclassProc(hWnd, uMsg, wParam, lParam)
    End Select

    Select Case uMsg
      Case WM_LBUTTONDOWN, WM_LBUTTONUP, WM_LBUTTONDBLCLK, WM_MOUSEMOVE, WM_MOUSELEAVE, _
           WM_KEYDOWN, WM_KEYUP, WM_SETFOCUS, WM_KILLFOCUS, WM_ENABLE, _
           BM_SETCHECK, BM_SETSTATE, WM_CAPTURECHANGED, WM_CANCELMODE
        SendMessageW(hWnd, WM_SETREDRAW, FALSE, 0)
        Dim As LRESULT lRes = DefSubclassProc(hWnd, uMsg, wParam, lParam)
        SendMessageW(hWnd, WM_SETREDRAW, TRUE, 0)
        RedrawWindow(hWnd, NULL, NULL, RDW_INVALIDATE Or RDW_UPDATENOW)
        Return lRes
    End Select
  End If

  Return DefSubclassProc(hWnd, uMsg, wParam, lParam)
End Function