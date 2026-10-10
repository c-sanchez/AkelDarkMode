Extern "windows"
Declare Function DialogProcHook(ByVal hWnd As HWND, ByVal uMsg As UINT, ByVal wParam As WPARAM, ByVal lParam As LPARAM) As LRESULT
End Extern

Function CreateDarkCheckboxes(ByVal bgColor As COLORREF) As HIMAGELIST
  Dim As HIMAGELIST hIL = ImageList_Create(16, 16, ILC_COLOR32 Or ILC_MASK, 2, 0)
  Dim As HDC hDC = GetDC(NULL)
  Dim As HDC hdcMem = CreateCompatibleDC(hDC)

  Dim As BITMAPINFO bmi
  bmi.bmiHeader.biSize = SizeOf(BITMAPINFOHEADER)
  bmi.bmiHeader.biWidth = 32
  bmi.bmiHeader.biHeight = -16
  bmi.bmiHeader.biPlanes = 1
  bmi.bmiHeader.biBitCount = 32
  bmi.bmiHeader.biCompression = BI_RGB

  Dim As Any Ptr pBits
  Dim As HBITMAP hbm = CreateDIBSection(hDC, @bmi, DIB_RGB_COLORS, @pBits, NULL, 0)
  Dim As HBITMAP ohbm = Cast(HBITMAP, SelectObject(hdcMem, hbm))

  Dim As HBRUSH hBg = CreateSolidBrush(bgColor)
  Dim As RECT rcFull = Type(0, 0, 32, 16)
  FillRect(hdcMem, @rcFull, hBg)
  DeleteObject(hBg)

  Dim As GpGraphics Ptr g
  GdipCreateFromHDC(hdcMem, @g)
  GdipSetSmoothingMode(g, SmoothingModeAntiAlias)

  Dim As DWORD borderColor = &hFF6B6B6B
  Dim As DWORD bgFillColor = &hFF202020
  Dim As DWORD checkColor = &hFFFFFFFF

  Dim As GpPen Ptr borderPen
  Dim As GpSolidFill Ptr bgBrush
  Dim As GpPen Ptr checkPen

  GdipCreatePen1(borderColor, 1.0, UnitPixel, @borderPen)
  GdipCreateSolidFill(bgFillColor, @bgBrush)
  GdipCreatePen1(checkColor, 1.6, UnitPixel, @checkPen)
  GdipSetPenStartCap(checkPen, LineCapRound)
  GdipSetPenEndCap(checkPen, LineCapRound)

  GdipFillRectangle(g, Cast(GpBrush Ptr, bgBrush), 2, 2, 12, 12)
  GdipDrawRectangle(g, borderPen, 2, 2, 12, 12)

  GdipFillRectangle(g, Cast(GpBrush Ptr, bgBrush), 16 + 2, 2, 12, 12)
  GdipDrawRectangle(g, borderPen, 16 + 2, 2, 12, 12)
  GdipDrawLine(g, checkPen, 16 + 4, 8, 16 + 7, 11)
  GdipDrawLine(g, checkPen, 16 + 7, 11, 16 + 12, 5)

  GdipDeletePen(borderPen)
  GdipDeleteBrush(Cast(GpBrush Ptr, bgBrush))
  GdipDeletePen(checkPen)
  GdipDeleteGraphics(g)

  SelectObject(hdcMem, ohbm)
  ImageList_Add(hIL, hbm, NULL)

  DeleteObject(hbm)
  DeleteDC(hdcMem)
  ReleaseDC(NULL, hDC)

  Return hIL
End Function

Function EnumInvalidatePageProc stdcall(ByVal hWndChild As HWND, ByVal lParam As LPARAM) As WINBOOL
  Dim As WChar className(63)
  GetClassNameW(hWndChild, @className(0), 64)
  If lstrcmpiW(@className(0), WStr("#32770")) = 0 Then
    If IsWindowVisible(hWndChild) Then
      InvalidateRect(hWndChild, NULL, TRUE)
    End If
  End If
  Return TRUE
End Function

Function EnumDlgChildProc stdcall(ByVal hWndChild As HWND, ByVal lParam As LPARAM) As WINBOOL
  Dim As WChar className(63)
  GetClassNameW(hWndChild, @className(0), 64)

  If lstrcmpiW(@className(0), WStr("#32770")) = 0 Then
    If GetPropW(hWndChild, WStr("OldDlgProc")) = NULL Then
      Dim As WNDPROC oldProc = Cast(WNDPROC, SetWindowLongPtrW(hWndChild, GWLP_WNDPROC, Cast(LONG_PTR, @DialogProcHook)))
      If oldProc <> NULL Then
        SetPropW(hWndChild, WStr("OldDlgProc"), Cast(HANDLE, oldProc))
      End If
    End If
  End If

  Dim As Integer ctrlId = GetDlgCtrlID(hWndChild)

  If lstrcmpiW(@className(0), WStr("Static")) = 0 Then
    Dim As LONG style = GetWindowLongW(hWndChild, GWL_STYLE)
    Dim As LONG typeMask = style And SS_TYPEMASK
    If typeMask = SS_ETCHEDHORZ Then
      SetWindowSubclass(hWndChild, @StaticSubclassProc, 106, 0)
    ElseIf ctrlId = 1092 OrElse ctrlId = 1093 Then
      SetWindowSubclass(hWndChild, @SampleBoxSubclassProc, 111, 0)
    ElseIf ctrlId = 720 OrElse ctrlId = 721 Then
      SetWindowSubclass(hWndChild, @ColorSwatchSubclassProc, 113, 0)
    End If
  End If

  If lstrcmpiW(@className(0), WStr("Button")) = 0 Then
    Dim As LONG btnStyle = GetWindowLongW(hWndChild, GWL_STYLE) And &h0F
    If btnStyle <> BS_OWNERDRAW Then
      If _SetWindowTheme Then
        _SetWindowTheme(hWndChild, WStr(""), WStr(""))
      End If
      SetWindowSubclass(hWndChild, @ButtonSubclassProc, 105, 0)
    End If
  End If

  If lstrcmpiW(@className(0), WStr("Edit")) = 0 Then
    If _SetWindowTheme Then
      _SetWindowTheme(hWndChild, WStr("DarkMode_Explorer"), NULL)
    End If
    If _AllowDarkModeForWindow Then
      _AllowDarkModeForWindow(hWndChild, TRUE)
    End If
    SetWindowSubclass(hWndChild, @EditSubclassProc, 107, 0)
  End If

  If lstrcmpiW(@className(0), WStr("ComboBox")) = 0 Then
    If _SetWindowTheme Then
      _SetWindowTheme(hWndChild, WStr("DarkMode_Explorer"), NULL)
    End If
    If _AllowDarkModeForWindow Then
      _AllowDarkModeForWindow(hWndChild, TRUE)
    End If
    SetWindowSubclass(hWndChild, @ComboBoxSubclassProc, 108, 0)
  End If

  If lstrcmpiW(@className(0), WStr("ListBox")) = 0 OrElse lstrcmpiW(@className(0), WStr("ComboLBox")) = 0 Then
    If _SetWindowTheme Then
      _SetWindowTheme(hWndChild, WStr("DarkMode_Explorer"), NULL)
    End If
    If _AllowDarkModeForWindow Then
      _AllowDarkModeForWindow(hWndChild, TRUE)
    End If
    SetWindowSubclass(hWndChild, @ListBoxSubclassProc, 112, 0)
  End If

  If lstrcmpiW(@className(0), WStr("msctls_updown32")) = 0 Then
    If _SetWindowTheme Then
      _SetWindowTheme(hWndChild, WStr(""), WStr(""))
    End If
    SetWindowSubclass(hWndChild, @UpDownSubclassProc, 110, 0)
  End If

  If lstrcmpiW(@className(0), WStr("SysTabControl32")) = 0 Then
    SetWindowSubclass(hWndChild, @DialogTabSubclassProc, 109, 0)
  End If

  If lstrcmpiW(@className(0), WStr("SysListView32")) = 0 Then
    If _SetWindowTheme Then
      _SetWindowTheme(hWndChild, WStr("DarkMode_Explorer"), NULL)
    End If
    If _AllowDarkModeForWindow Then
      _AllowDarkModeForWindow(hWndChild, TRUE)
    End If

    Dim As DWORD exStyle = SendMessageW(hWndChild, LVM_GETEXTENDEDLISTVIEWSTYLE, 0, 0)
    exStyle Or= LVS_EX_DOUBLEBUFFER
    exStyle And= Not LVS_EX_GRIDLINES
    SendMessageW(hWndChild, LVM_SETEXTENDEDLISTVIEWSTYLE, 0, exStyle)

    SetWindowSubclass(hWndChild, @ListViewSubclassProc, 103, 0)

    SendMessageW(hWndChild, LVM_SETBKCOLOR, 0, Cast(LPARAM, &h202020))
    SendMessageW(hWndChild, LVM_SETTEXTCOLOR, 0, Cast(LPARAM, &hFFFFFF))
    SendMessageW(hWndChild, LVM_SETTEXTBKCOLOR, 0, Cast(LPARAM, &h202020))

    Dim As HWND hHeader = Cast(HWND, SendMessageW(hWndChild, LVM_GETHEADER, 0, 0))
    If hHeader <> NULL Then
      SetWindowSubclass(hHeader, @HeaderSubclassProc, 102, 0)
    End If

    Dim As HIMAGELIST hOldIL = Cast(HIMAGELIST, SendMessageW(hWndChild, LVM_GETIMAGELIST, LVSIL_STATE, 0))
    If (exStyle And LVS_EX_CHECKBOXES) <> 0 OrElse hOldIL <> NULL Then
      Dim As HIMAGELIST hNewIL = CreateDarkCheckboxes(&h202020)
      SendMessageW(hWndChild, LVM_SETIMAGELIST, LVSIL_STATE, Cast(LPARAM, hNewIL))
      If hOldIL <> NULL AndAlso hOldIL <> hNewIL Then ImageList_Destroy(hOldIL)
    End If
  End If

  Return TRUE
End Function

Extern "windows"
Function DialogProcHook(ByVal hWnd As HWND, ByVal uMsg As UINT, ByVal wParam As WPARAM, ByVal lParam As LPARAM) As LRESULT
  Dim As WNDPROC oldProc = Cast(WNDPROC, GetPropW(hWnd, WStr("OldDlgProc")))
  If oldProc = NULL Then Return DefWindowProcW(hWnd, uMsg, wParam, lParam)

  If bDarkModeActive Then
    Select Case uMsg
      Case WM_TIMER
        If wParam = 1001 Then
          KillTimer(hWnd, 1001)
          EnumChildWindows(hWnd, Cast(WNDENUMPROC, @EnumDlgChildProc), 0)
          InvalidateRect(hWnd, NULL, TRUE)
          Return 0
        End If

      Case WM_ERASEBKGND
        Dim As RECT rc
        GetClientRect(hWnd, @rc)
        FillRect(Cast(HDC, wParam), @rc, g_hbrDark)
        Return 1

      Case WM_PAINT
        Dim As LRESULT lRes = CallWindowProcW(oldProc, hWnd, uMsg, wParam, lParam)

        Dim As HWND hBox1 = GetDlgItem(hWnd, 720)
        Dim As HWND hBox2 = GetDlgItem(hWnd, 721)
        If hBox1 <> NULL Then
          InvalidateRect(hBox1, NULL, FALSE)
          UpdateWindow(hBox1)
        End If
        If hBox2 <> NULL Then
          InvalidateRect(hBox2, NULL, FALSE)
          UpdateWindow(hBox2)
        End If

        Dim As HWND hGroup = GetDlgItem(hWnd, 1073)
        Dim As HWND hFontBox = GetDlgItem(hWnd, 1136)
        If hGroup <> NULL AndAlso hFontBox <> NULL Then
          Dim As HDC hDC = GetDC(hWnd)
          If hDC <> NULL Then
            Dim As RECT rcGroup
            GetWindowRect(hGroup, @rcGroup)
            Dim As POINT pt1 = Type(rcGroup.left, rcGroup.top)
            ScreenToClient(hWnd, @pt1)
            Dim As POINT pt2 = Type(rcGroup.right, rcGroup.bottom)
            ScreenToClient(hWnd, @pt2)

            Dim As RECT rcSample
            Dim As HWND hRct = GetDlgItem(hWnd, 1092)
            If hRct <> NULL Then
              GetWindowRect(hRct, @rcSample)
              Dim As POINT p1 = Type(rcSample.left, rcSample.top)
              ScreenToClient(hWnd, @p1)
              Dim As POINT p2 = Type(rcSample.right, rcSample.bottom)
              ScreenToClient(hWnd, @p2)
              rcSample.left = p1.x
              rcSample.top = p1.y
              rcSample.right = p2.x
              rcSample.bottom = p2.y
            Else
              rcSample.left = pt1.x + 8
              rcSample.top = pt1.y + 18
              rcSample.right = pt2.x - 8
              rcSample.bottom = pt2.y - 8
            End If

            FillRect(hDC, @rcSample, g_hbrDark)

            Dim As HPEN hPen = CreatePen(PS_SOLID, 1, &h4A4A4A)
            Dim As HPEN oldPen = Cast(HPEN, SelectObject(hDC, hPen))
            Dim As HBRUSH oldBrush = Cast(HBRUSH, SelectObject(hDC, GetStockObject(NULL_BRUSH)))
            Rectangle(hDC, rcSample.left, rcSample.top, rcSample.right, rcSample.bottom)
            SelectObject(hDC, oldPen)
            SelectObject(hDC, oldBrush)
            DeleteObject(hPen)

            Dim As HWND hFontHolder = GetDlgItem(hWnd, 1093)
            If hFontHolder = NULL Then hFontHolder = hGroup

            Dim As HFONT hFont = Cast(HFONT, SendMessageW(hFontHolder, WM_GETFONT, 0, 0))
            Dim As HFONT oldFont = NULL
            If hFont Then oldFont = Cast(HFONT, SelectObject(hDC, hFont))

            Dim As WChar textBuf(255)
            textBuf(0) = 0
            If hFontHolder <> hGroup Then
              GetWindowTextW(hFontHolder, @textBuf(0), 255)
            End If
            If textBuf(0) = 0 Then
              lstrcpyW(@textBuf(0), WStr("AaBbYyZz"))
            End If

            SetBkMode(hDC, TRANSPARENT)
            SetTextColor(hDC, &hE0E0E0)
            DrawTextW(hDC, @textBuf(0), -1, @rcSample, DT_CENTER Or DT_VCENTER Or DT_SINGLELINE)

            If oldFont Then SelectObject(hDC, oldFont)
            ReleaseDC(hWnd, hDC)
          End If
        End If

        Dim As HWND hLum = GetDlgItem(hWnd, 702)
        If hLum <> NULL Then
          Dim As HDC hDC = GetDC(hWnd)
          If hDC <> NULL Then
            Dim As HPEN hBorderPen = CreatePen(PS_SOLID, 1, &h4A4A4A)
            Dim As HPEN oldPen = Cast(HPEN, SelectObject(hDC, hBorderPen))
            Dim As HBRUSH oldBrush = Cast(HBRUSH, SelectObject(hDC, GetStockObject(NULL_BRUSH)))

            Dim As Integer boxIds(0 To 3) = {702, 709, 713, 714}
            For i As Integer = 0 To 3
              Dim As HWND hBox = GetDlgItem(hWnd, boxIds(i))
              If hBox <> NULL Then
                Dim As RECT rcBox
                GetWindowRect(hBox, @rcBox)
                Dim As POINT p1 = Type(rcBox.left, rcBox.top)
                ScreenToClient(hWnd, @p1)
                Dim As POINT p2 = Type(rcBox.right, rcBox.bottom)
                ScreenToClient(hWnd, @p2)
                Rectangle(hDC, p1.x - 1, p1.y - 1, p2.x + 1, p2.y + 1)
              End If
            Next i

            SelectObject(hDC, oldPen)
            SelectObject(hDC, oldBrush)
            DeleteObject(hBorderPen)
            ReleaseDC(hWnd, hDC)
          End If
        End If

        Dim As LONG style = GetWindowLongW(hWnd, GWL_STYLE)
        If (style And WS_THICKFRAME) <> 0 Then
          Dim As HDC hDC = GetDC(hWnd)
          If hDC <> NULL Then
            Dim As RECT rcGrip
            GetClientRect(hWnd, @rcGrip)
            rcGrip.left = rcGrip.right - GetSystemMetrics(SM_CXVSCROLL)
            rcGrip.top = rcGrip.bottom - GetSystemMetrics(SM_CYVSCROLL)

            FillRect(hDC, @rcGrip, g_hbrDark)

            Dim As Integer gx = rcGrip.right - 4
            Dim As Integer gy = rcGrip.bottom - 4
            For row As Integer = 0 To 2
              For col As Integer = 0 To row
                Dim As Integer px = gx - (row * 3) + (col * 3)
                Dim As Integer py = gy - (col * 3)
                SetPixel(hDC, px, py, &h555555)
                SetPixel(hDC, px + 1, py, &h555555)
                SetPixel(hDC, px, py + 1, &h555555)
                SetPixel(hDC, px + 1, py + 1, &h555555)
              Next col
            Next row

            ReleaseDC(hWnd, hDC)
          End If
        End If
        Return lRes

      Case WM_LBUTTONDOWN, WM_LBUTTONUP
        If uMsg = WM_LBUTTONDOWN Then
          Dim As POINT pt = Type(Cast(SHORT, LOWORD(lParam)), Cast(SHORT, HIWORD(lParam)))

          Dim As HWND hBox1 = GetDlgItem(hWnd, 720)
          If hBox1 <> NULL Then
            Dim As RECT rc1
            GetWindowRect(hBox1, @rc1)
            MapWindowPoints(NULL, hWnd, Cast(POINT Ptr, @rc1), 2)
            If PtInRect(@rc1, pt) Then
              Dim As Integer w = rc1.right - rc1.left
              Dim As Integer h = rc1.bottom - rc1.top
              Dim As Integer pitch_x = w \ 8
              Dim As Integer pitch_y = h \ 6
              If pitch_x > 0 AndAlso pitch_y > 0 Then
                Dim As Integer col = (pt.x - rc1.left) \ pitch_x
                Dim As Integer row = (pt.y - rc1.top) \ pitch_y
                If col >= 0 AndAlso col < 8 AndAlso row >= 0 AndAlso row < 6 Then
                  g_selBasic = row * 8 + col
                End If
              End If
            End If
          End If

          Dim As HWND hBox2 = GetDlgItem(hWnd, 721)
          If hBox2 <> NULL Then
            Dim As RECT rc2
            GetWindowRect(hBox2, @rc2)
            MapWindowPoints(NULL, hWnd, Cast(POINT Ptr, @rc2), 2)
            If PtInRect(@rc2, pt) Then
              Dim As Integer w = rc2.right - rc2.left
              Dim As Integer h = rc2.bottom - rc2.top
              Dim As Integer pitch_x = w \ 8
              Dim As Integer pitch_y = h \ 2
              If pitch_x > 0 AndAlso pitch_y > 0 Then
                Dim As Integer col = (pt.x - rc2.left) \ pitch_x
                Dim As Integer row = (pt.y - rc2.top) \ pitch_y
                If col >= 0 AndAlso col < 8 AndAlso row >= 0 AndAlso row < 2 Then
                  g_selCustom = row * 8 + col
                End If
              End If
            End If
          End If
        End If

        Dim As LRESULT lRes = CallWindowProcW(oldProc, hWnd, uMsg, wParam, lParam)
        Dim As HWND hB1 = GetDlgItem(hWnd, 720)
        Dim As HWND hB2 = GetDlgItem(hWnd, 721)
        If hB1 <> NULL Then
          InvalidateRect(hB1, NULL, FALSE)
          UpdateWindow(hB1)
        End If
        If hB2 <> NULL Then
          InvalidateRect(hB2, NULL, FALSE)
          UpdateWindow(hB2)
        End If
        Return lRes

      Case WM_COMMAND
        Dim As LRESULT lRes = CallWindowProcW(oldProc, hWnd, uMsg, wParam, lParam)
        Dim As WORD notifyCode = HIWORD(wParam)
        Dim As WORD ctrlId = LOWORD(wParam)
        If notifyCode = CBN_SELCHANGE OrElse notifyCode = LBN_SELCHANGE OrElse notifyCode = EN_CHANGE Then
          Dim As HWND hGroup = GetDlgItem(hWnd, 1073)
          If hGroup <> NULL Then
            InvalidateRect(hWnd, NULL, FALSE)
          End If
        End If
        If ctrlId = 712 Then
          Dim As Integer r = GetDlgItemInt(hWnd, 706, NULL, FALSE)
          Dim As Integer g = GetDlgItemInt(hWnd, 707, NULL, FALSE)
          Dim As Integer b = GetDlgItemInt(hWnd, 708, NULL, FALSE)
          If g_selCustom >= 0 AndAlso g_selCustom < 16 Then
            g_crCustom(g_selCustom) = MKRGB(r, g, b)
          End If
          Dim As HWND hCust = GetDlgItem(hWnd, 721)
          If hCust <> NULL Then
            InvalidateRect(hCust, NULL, FALSE)
            UpdateWindow(hCust)
          End If
        End If
        If ctrlId = 720 OrElse ctrlId = 721 Then
          Dim As HWND hTarget = GetDlgItem(hWnd, ctrlId)
          If hTarget <> NULL Then
            InvalidateRect(hTarget, NULL, FALSE)
            UpdateWindow(hTarget)
          End If
        End If
        Return lRes

      Case WM_CTLCOLORDLG, WM_CTLCOLORSTATIC, WM_CTLCOLORBTN, WM_CTLCOLORLISTBOX, WM_CTLCOLOREDIT
        If uMsg = WM_CTLCOLORLISTBOX OrElse uMsg = WM_CTLCOLOREDIT Then
          Dim As HWND hCtrl = Cast(HWND, lParam)
          If hCtrl <> NULL AndAlso GetPropW(hCtrl, WStr("DarkThemeApplied")) = NULL Then
            If _AllowDarkModeForWindow Then _AllowDarkModeForWindow(hCtrl, TRUE)
            If _SetWindowTheme Then _SetWindowTheme(hCtrl, WStr("DarkMode_Explorer"), NULL)
            SetPropW(hCtrl, WStr("DarkThemeApplied"), Cast(HANDLE, 1))
          End If
        End If
        SetTextColor(Cast(HDC, wParam), &hE0E0E0)
        SetBkColor(Cast(HDC, wParam), &h2B2B2B)
        Return Cast(LRESULT, g_hbrDark)

      Case WM_DRAWITEM
        Dim As DRAWITEMSTRUCT Ptr pdis = Cast(DRAWITEMSTRUCT Ptr, lParam)
        If pdis->CtlType = ODT_BUTTON Then
          Dim As LRESULT lRes = CallWindowProcW(oldProc, hWnd, uMsg, wParam, lParam)

          Dim As Integer cx = (pdis->rcItem.left + pdis->rcItem.right) \ 2
          Dim As Integer cy = (pdis->rcItem.top + pdis->rcItem.bottom) \ 2
          Dim As COLORREF boxColor = GetPixel(pdis->hDC, cx, cy)

          Dim As RECT rc = pdis->rcItem

          Dim As HBRUSH hbrColor = CreateSolidBrush(boxColor)
          FillRect(pdis->hDC, @rc, hbrColor)
          DeleteObject(hbrColor)

          Dim As HPEN hBorderPen = CreatePen(PS_SOLID, 1, &h4A4A4A)
          Dim As HPEN oldPen = Cast(HPEN, SelectObject(pdis->hDC, hBorderPen))
          Dim As HBRUSH oldBrush = Cast(HBRUSH, SelectObject(pdis->hDC, GetStockObject(NULL_BRUSH)))
          Rectangle(pdis->hDC, rc.left, rc.top, rc.right, rc.bottom)

          Dim As Boolean isFocused = ((pdis->itemState And ODS_FOCUS) <> 0)
          Dim As Boolean isSelected = ((pdis->itemState And ODS_SELECTED) <> 0)

          If isFocused OrElse isSelected Then
            Dim As HPEN hSelPen = CreatePen(PS_SOLID, 1, &hFFFFFF)
            SelectObject(pdis->hDC, hSelPen)
            Rectangle(pdis->hDC, rc.left + 1, rc.top + 1, rc.right - 1, rc.bottom - 1)
            SelectObject(pdis->hDC, oldPen)
            DeleteObject(hSelPen)

            If isFocused Then
              Dim As RECT rcFocus = rc
              InflateRect(@rcFocus, -2, -2)
              DrawFocusRect(pdis->hDC, @rcFocus)
            End If
          End If

          SelectObject(pdis->hDC, oldPen)
          SelectObject(pdis->hDC, oldBrush)
          DeleteObject(hBorderPen)
          Return lRes
        End If

        If pdis->CtlType = ODT_COMBOBOX OrElse pdis->CtlType = ODT_LISTBOX Then
          Dim As Boolean isSel = ((pdis->itemState And ODS_SELECTED) <> 0)
          Dim As COLORREF bgColor = IIf(isSel, &h454545, &h2B2B2B)
          Dim As HBRUSH hbr = CreateSolidBrush(bgColor)
          FillRect(pdis->hDC, @pdis->rcItem, hbr)
          DeleteObject(hbr)

          If pdis->itemID <> -1 Then
            Dim As LONG ctlStyle = GetWindowLongW(pdis->hwndItem, GWL_STYLE)
            Dim As Boolean hasStrings = False
            If pdis->CtlType = ODT_COMBOBOX Then
              If (ctlStyle And CBS_HASSTRINGS) <> 0 Then hasStrings = True
            Else
              If (ctlStyle And LBS_HASSTRINGS) <> 0 Then hasStrings = True
            End If

            If hasStrings Then
              Dim As WChar textBuf(512)
              textBuf(0) = 0
              If pdis->CtlType = ODT_COMBOBOX Then
                SendMessageW(pdis->hwndItem, CB_GETLBTEXT, pdis->itemID, Cast(LPARAM, @textBuf(0)))
              Else
                SendMessageW(pdis->hwndItem, LB_GETTEXT, pdis->itemID, Cast(LPARAM, @textBuf(0)))
              End If

              If lstrlenW(@textBuf(0)) > 0 Then
                SetBkMode(pdis->hDC, TRANSPARENT)
                SetTextColor(pdis->hDC, IIf(isSel, &hFFFFFF, &hE0E0E0))
                Dim As RECT rcText = pdis->rcItem
                rcText.left += 4
                DrawTextW(pdis->hDC, @textBuf(0), -1, @rcText, DT_LEFT Or DT_VCENTER Or DT_SINGLELINE)
              End If
            Else
              Return CallWindowProcW(oldProc, hWnd, uMsg, wParam, lParam)
            End If
          End If
          Return TRUE
        End If

      Case WM_NOTIFY
        Dim As NMHDR Ptr pnmh = Cast(NMHDR Ptr, lParam)
        Dim As WChar className(63)
        GetClassNameW(pnmh->hwndFrom, @className(0), 64)

        If lstrcmpiW(@className(0), WStr("SysListView32")) = 0 Then
          If pnmh->code = LVN_ITEMCHANGED Then
            RedrawWindow(pnmh->hwndFrom, NULL, NULL, RDW_INVALIDATE Or RDW_ERASE Or RDW_UPDATENOW)
          ElseIf pnmh->code = NM_CUSTOMDRAW Then
            Dim As LPNMLVCUSTOMDRAW plvcd = Cast(LPNMLVCUSTOMDRAW, lParam)

            If plvcd->nmcd.dwDrawStage = CDDS_POSTPAINT Then
              Dim As HDC hDC = plvcd->nmcd.hdc
              Dim As RECT rcClient
              GetClientRect(pnmh->hwndFrom, @rcClient)
              Dim As HPEN hPenGrid = CreatePen(PS_SOLID, 1, &h383838)
              Dim As HPEN oldPen = Cast(HPEN, SelectObject(hDC, hPenGrid))

              Dim As HWND hwndHdr = Cast(HWND, SendMessageW(pnmh->hwndFrom, LVM_GETHEADER, 0, 0))
              If hwndHdr Then
                Dim As Integer colCount = SendMessageW(hwndHdr, HDM_GETITEMCOUNT, 0, 0)
                For i As Integer = 0 To colCount - 1
                  Dim As RECT rcCol
                  SendMessageW(hwndHdr, HDM_GETITEMRECT, i, Cast(LPARAM, @rcCol))
                  MoveToEx(hDC, rcCol.right - 1, 0, NULL)
                  LineTo(hDC, rcCol.right - 1, rcClient.bottom)
                Next
              End If

              Dim As Integer rowCount = SendMessageW(pnmh->hwndFrom, LVM_GETITEMCOUNT, 0, 0)
              Dim As Integer itemHeight = 0

              If rowCount > 0 Then
                Dim As RECT rcItem
                rcItem.left = LVIR_BOUNDS
                SendMessageW(pnmh->hwndFrom, LVM_GETITEMRECT, 0, Cast(LPARAM, @rcItem))
                itemHeight = rcItem.bottom - rcItem.top

                For i As Integer = 0 To rowCount - 1
                  rcItem.left = LVIR_BOUNDS
                  If SendMessageW(pnmh->hwndFrom, LVM_GETITEMRECT, i, Cast(LPARAM, @rcItem)) Then
                    MoveToEx(hDC, rcClient.left, rcItem.bottom - 1, NULL)
                    LineTo(hDC, rcClient.right, rcItem.bottom - 1)
                  End If
                Next

                If itemHeight > 0 Then
                  Dim As Integer y = rcItem.bottom - 1 + itemHeight
                  While y < rcClient.bottom
                    MoveToEx(hDC, rcClient.left, y, NULL)
                    LineTo(hDC, rcClient.right, y)
                    y += itemHeight
                  Wend
                End If
              End If

              SelectObject(hDC, oldPen)
              DeleteObject(hPenGrid)
              Return CDRF_DODEFAULT
            End If

            If plvcd->nmcd.dwDrawStage = CDDS_PREPAINT Then
              CallWindowProcW(oldProc, hWnd, uMsg, wParam, lParam)
              Return CDRF_NOTIFYITEMDRAW Or CDRF_NOTIFYPOSTPAINT
            End If

            If plvcd->nmcd.dwDrawStage = CDDS_ITEMPREPAINT Then
              CallWindowProcW(oldProc, hWnd, uMsg, wParam, lParam)
              Return CDRF_NOTIFYSUBITEMDRAW
            End If

            If plvcd->nmcd.dwDrawStage = (CDDS_ITEMPREPAINT Or CDDS_SUBITEM) Then
              SetWindowLongPtrW(hWnd, DWLP_MSGRESULT, 0)
              Dim As LRESULT dlgResult = CallWindowProcW(oldProc, hWnd, uMsg, wParam, lParam)
              Dim As LRESULT msgResult = GetWindowLongPtrW(hWnd, DWLP_MSGRESULT)

              If plvcd->iSubItem > 0 Then
                If msgResult <> 0 Then Return msgResult
                If dlgResult <> 0 Then Return dlgResult
                Return CDRF_DODEFAULT
              End If

              Dim As WINBOOL isSelected = ((plvcd->nmcd.uItemState And CDIS_SELECTED) <> 0)
              If isSelected Then
                plvcd->clrTextBk = CLR_NONE
              Else
                plvcd->clrTextBk = &h202020
              End If
              plvcd->clrText = &hFFFFFF
              Return CDRF_NEWFONT
            End If
          End If
        End If

        Dim As LRESULT lRes = CallWindowProcW(oldProc, hWnd, uMsg, wParam, lParam)

        If pnmh->code = TCN_SELCHANGE Then
          EnumChildWindows(hWnd, Cast(WNDENUMPROC, @EnumDlgChildProc), 0)
          EnumChildWindows(hWnd, Cast(WNDENUMPROC, @EnumInvalidatePageProc), 0)
        End If

        Return lRes

      Case WM_DESTROY
        SetWindowLongPtrW(hWnd, GWLP_WNDPROC, Cast(LONG_PTR, oldProc))
        RemovePropW(hWnd, WStr("OldDlgProc"))
        Return CallWindowProcW(oldProc, hWnd, uMsg, wParam, lParam)
    End Select
  End If

  Return CallWindowProcW(oldProc, hWnd, uMsg, wParam, lParam)
End Function

Function CBTProc(ByVal nCode As Integer, ByVal wParam As WPARAM, ByVal lParam As LPARAM) As LRESULT
  If nCode = HCBT_ACTIVATE AndAlso bDarkModeActive Then
    Dim As HWND hWnd = Cast(HWND, wParam)
    Dim As WChar className(63)
    GetClassNameW(hWnd, @className(0), 64)
    If lstrcmpiW(@className(0), WStr("#32770")) = 0 Then
      If GetPropW(hWnd, WStr("OldDlgProc")) = NULL Then
        RefreshTitleBarThemeColor(hWnd, TRUE)
        Dim As WNDPROC oldProc = Cast(WNDPROC, SetWindowLongPtrW(hWnd, GWLP_WNDPROC, Cast(LONG_PTR, @DialogProcHook)))
        If oldProc <> NULL Then
          SetPropW(hWnd, WStr("OldDlgProc"), Cast(HANDLE, oldProc))
        End If
        EnumChildWindows(hWnd, Cast(WNDENUMPROC, @EnumDlgChildProc), 0)
        SetTimer(hWnd, 1001, 20, NULL)
      End If
    End If
  End If
  Return CallNextHookEx(hHookCBT, nCode, wParam, lParam)
End Function
End Extern

Sub HookDialogs()
  If hHookCBT = NULL Then
    hHookCBT = SetWindowsHookExW(WH_CBT, Cast(HOOKPROC, @CBTProc), NULL, GetCurrentThreadId())
  End If
End Sub

Sub UnhookDialogs()
  If hHookCBT <> NULL Then
    UnhookWindowsHookEx(hHookCBT)
    hHookCBT = NULL
  End If
End Sub