#define MKRGB(r, g, b) (Cast(COLORREF, (r)) Or (Cast(COLORREF, (g)) Shl 8) Or (Cast(COLORREF, (b)) Shl 16))

Dim Shared g_crBasic(47) As COLORREF
Dim Shared g_crCustom(15) As COLORREF
Dim Shared g_selBasic As Integer = 0
Dim Shared g_selCustom As Integer = 0

Sub InitColorTables()
  Static As Boolean bInit = False
  If bInit Then Exit Sub
  bInit = True

  g_crBasic(0)  = MKRGB(255, 128, 128)
  g_crBasic(1)  = MKRGB(255, 255, 128)
  g_crBasic(2)  = MKRGB(128, 255, 128)
  g_crBasic(3)  = MKRGB(0,   255, 128)
  g_crBasic(4)  = MKRGB(128, 255, 255)
  g_crBasic(5)  = MKRGB(0,   128, 255)
  g_crBasic(6)  = MKRGB(255, 128, 192)
  g_crBasic(7)  = MKRGB(255, 128, 255)

  g_crBasic(8)  = MKRGB(255, 0,   0)
  g_crBasic(9)  = MKRGB(255, 255, 0)
  g_crBasic(10) = MKRGB(128, 255, 0)
  g_crBasic(11) = MKRGB(0,   255, 64)
  g_crBasic(12) = MKRGB(0,   255, 255)
  g_crBasic(13) = MKRGB(0,   128, 192)
  g_crBasic(14) = MKRGB(128, 128, 192)
  g_crBasic(15) = MKRGB(255, 0,   255)

  g_crBasic(16) = MKRGB(128, 64,  64)
  g_crBasic(17) = MKRGB(255, 128, 64)
  g_crBasic(18) = MKRGB(0,   255, 0)
  g_crBasic(19) = MKRGB(0,   128, 128)
  g_crBasic(20) = MKRGB(0,   64,  128)
  g_crBasic(21) = MKRGB(128, 128, 255)
  g_crBasic(22) = MKRGB(128, 0,   64)
  g_crBasic(23) = MKRGB(255, 0,   128)

  g_crBasic(24) = MKRGB(128, 0,   0)
  g_crBasic(25) = MKRGB(255, 128, 0)
  g_crBasic(26) = MKRGB(0,   128, 0)
  g_crBasic(27) = MKRGB(0,   128, 64)
  g_crBasic(28) = MKRGB(0,   0,   255)
  g_crBasic(29) = MKRGB(0,   0,   128)
  g_crBasic(30) = MKRGB(128, 0,   128)
  g_crBasic(31) = MKRGB(128, 0,   255)

  g_crBasic(32) = MKRGB(64,  0,   0)
  g_crBasic(33) = MKRGB(128, 64,  0)
  g_crBasic(34) = MKRGB(0,   64,  0)
  g_crBasic(35) = MKRGB(0,   64,  64)
  g_crBasic(36) = MKRGB(0,   0,   128)
  g_crBasic(37) = MKRGB(0,   0,   64)
  g_crBasic(38) = MKRGB(64,  0,   64)
  g_crBasic(39) = MKRGB(64,  0,   128)

  g_crBasic(40) = MKRGB(0,   0,   0)
  g_crBasic(41) = MKRGB(128, 128, 0)
  g_crBasic(42) = MKRGB(128, 128, 64)
  g_crBasic(43) = MKRGB(128, 128, 128)
  g_crBasic(44) = MKRGB(64,  128, 128)
  g_crBasic(45) = MKRGB(192, 192, 192)
  g_crBasic(46) = MKRGB(64,  0,   64)
  g_crBasic(47) = MKRGB(255, 255, 255)

  For i As Integer = 0 To 15
    g_crCustom(i) = MKRGB(0, 0, 0)
  Next
End Sub

Function SampleBoxSubclassProc(ByVal hWnd As HWND, ByVal uMsg As UINT, ByVal wParam As WPARAM, ByVal lParam As LPARAM, ByVal uIdSubclass As UINT_PTR, ByVal dwRefData As DWORD_PTR) As LRESULT
  If bDarkModeActive Then
    Select Case uMsg
      Case WM_ERASEBKGND
        Return 1
        
      Case WM_PAINT
        Dim As PAINTSTRUCT ps
        Dim As HDC hDC = BeginPaint(hWnd, @ps)
        Dim As RECT rc
        GetClientRect(hWnd, @rc)

        FillRect(hDC, @rc, g_hbrDark)

        Dim As HFONT hFont = Cast(HFONT, SendMessageW(hWnd, WM_GETFONT, 0, 0))
        Dim As HFONT oldFont = NULL
        If hFont Then oldFont = Cast(HFONT, SelectObject(hDC, hFont))

        Dim As Integer textLen = GetWindowTextLengthW(hWnd)
        If textLen > 0 AndAlso textLen < 1024 Then
          Dim As WChar textBuf(1024)
          GetWindowTextW(hWnd, @textBuf(0), 1024)

          SetBkMode(hDC, TRANSPARENT)
          SetTextColor(hDC, &hE0E0E0)
          
          Dim As DWORD format = DT_WORDBREAK
          Dim As LONG style = GetWindowLongW(hWnd, GWL_STYLE)
          Dim As LONG typeMask = style And SS_TYPEMASK
          
          If typeMask = SS_CENTER Then
            format Or= DT_CENTER
          ElseIf typeMask = SS_RIGHT Then
            format Or= DT_RIGHT
          Else
            format Or= DT_LEFT
          End If
          
          If typeMask = SS_LEFTNOWORDWRAP OrElse typeMask = SS_SIMPLE Then
            format And= Not DT_WORDBREAK
            format Or= DT_SINGLELINE
          End If
          
          If (style And SS_CENTERIMAGE) = SS_CENTERIMAGE Then
            format Or= DT_VCENTER Or DT_SINGLELINE
          End If
          
          DrawTextW(hDC, @textBuf(0), -1, @rc, format)
        End If

        If oldFont Then SelectObject(hDC, oldFont)
        EndPaint(hWnd, @ps)
        Return 0
        
      Case WM_NCDESTROY
        RemoveWindowSubclass(hWnd, @SampleBoxSubclassProc, uIdSubclass)
    End Select
  End If
  Return DefSubclassProc(hWnd, uMsg, wParam, lParam)
End Function

Function StaticSubclassProc(ByVal hWnd As HWND, ByVal uMsg As UINT, ByVal wParam As WPARAM, ByVal lParam As LPARAM, ByVal uIdSubclass As UINT_PTR, ByVal dwRefData As DWORD_PTR) As LRESULT
  If bDarkModeActive Then
    Select Case uMsg
      Case WM_ERASEBKGND
        Return 1

      Case WM_PAINT
        Dim As PAINTSTRUCT ps
        Dim As HDC hDC = BeginPaint(hWnd, @ps)
        Dim As RECT rc
        GetClientRect(hWnd, @rc)
        
        FillRect(hDC, @rc, g_hbrDark)
        
        Dim As HPEN hPen = CreatePen(PS_SOLID, 1, &h4A4A4A)
        Dim As HPEN oldPen = Cast(HPEN, SelectObject(hDC, hPen))
        MoveToEx(hDC, rc.left, rc.top, NULL)
        LineTo(hDC, rc.right, rc.top)
        SelectObject(hDC, oldPen)
        DeleteObject(hPen)
        
        EndPaint(hWnd, @ps)
        Return 0
        
      Case WM_NCDESTROY
        RemoveWindowSubclass(hWnd, @StaticSubclassProc, uIdSubclass)
    End Select
  End If
  Return DefSubclassProc(hWnd, uMsg, wParam, lParam)
End Function

Function ColorSwatchSubclassProc(ByVal hWnd As HWND, ByVal uMsg As UINT, ByVal wParam As WPARAM, ByVal lParam As LPARAM, ByVal uIdSubclass As UINT_PTR, ByVal dwRefData As DWORD_PTR) As LRESULT
  If bDarkModeActive Then
    InitColorTables()
    
    Select Case uMsg
      Case WM_ERASEBKGND
        Return 1

      Case WM_NCPAINT, WM_NCACTIVATE
        Dim As HDC hdc = GetWindowDC(hWnd)
        If hdc Then
          Dim As RECT rc
          GetWindowRect(hWnd, @rc)
          Dim As Integer w = rc.right - rc.left
          Dim As Integer h = rc.bottom - rc.top
          
          Dim As HPEN hBgPen = CreatePen(PS_SOLID, 1, &h2B2B2B)
          Dim As HPEN hBorderPen = CreatePen(PS_SOLID, 1, &h4A4A4A)
          Dim As HPEN oldPen = Cast(HPEN, SelectObject(hdc, hBgPen))
          Dim As HBRUSH oldBrush = Cast(HBRUSH, SelectObject(hdc, GetStockObject(NULL_BRUSH)))
          
          Rectangle(hdc, 0, 0, w, h)
          
          SelectObject(hdc, hBorderPen)
          Rectangle(hdc, 1, 1, w - 1, h - 1)
          
          SelectObject(hdc, oldPen)
          SelectObject(hdc, oldBrush)
          DeleteObject(hBgPen)
          DeleteObject(hBorderPen)
          
          ReleaseDC(hWnd, hdc)
        End If
        Return 0
        
      Case WM_PAINT
        Dim As PAINTSTRUCT ps
        Dim As HDC hDC = BeginPaint(hWnd, @ps)
        Dim As RECT rc
        GetClientRect(hWnd, @rc)
        
        Dim As Integer w = rc.right - rc.left
        Dim As Integer h = rc.bottom - rc.top
        
        Dim As Integer ctrlId = GetDlgCtrlID(hWnd)
        Dim As Integer numRows = IIf(ctrlId = 721, 2, 6)
        Dim As Integer pitch_x = w \ 8
        Dim As Integer pitch_y = h \ numRows
        
        If pitch_x > 0 AndAlso pitch_y > 0 Then
          Static As Boolean bInitialMatched = False
          If Not bInitialMatched AndAlso ctrlId = 720 Then
            Dim As HWND hDlg = GetParent(hWnd)
            If hDlg Then
              Dim As Integer r = GetDlgItemInt(hDlg, 706, NULL, FALSE)
              Dim As Integer g = GetDlgItemInt(hDlg, 707, NULL, FALSE)
              Dim As Integer b = GetDlgItemInt(hDlg, 708, NULL, FALSE)
              Dim As COLORREF initClr = MKRGB(r, g, b)
              For i As Integer = 0 To 47
                If g_crBasic(i) = initClr Then
                  g_selBasic = i
                  Exit For
                End If
              Next
              bInitialMatched = True
            End If
          End If

          Dim As Integer bw = 19
          Dim As Integer bh = 17
          Dim As Integer margin_x = (pitch_x - bw) \ 2
          Dim As Integer margin_y = (pitch_y - bh) \ 2
          
          Dim As HDC hdcMem = CreateCompatibleDC(hDC)
          Dim As HBITMAP hbmMem = CreateCompatibleBitmap(hDC, w, h)
          Dim As HBITMAP hOldBmp = Cast(HBITMAP, SelectObject(hdcMem, hbmMem))
          
          Dim As RECT rcClient = Type(0, 0, w, h)
          FillRect(hdcMem, @rcClient, g_hbrDark)
          
          Dim As Integer selIdx = IIf(ctrlId = 720, g_selBasic, g_selCustom)
          
          For row As Integer = 0 To numRows - 1
            For col As Integer = 0 To 7
              Dim As Integer idx = row * 8 + col
              Dim As Integer bx = col * pitch_x + margin_x
              Dim As Integer by = row * pitch_y + margin_y
              
              Dim As COLORREF clr = IIf(ctrlId = 720, g_crBasic(idx), g_crCustom(idx))
              
              Dim As HPEN hPen = CreatePen(PS_SOLID, 1, &h4A4A4A)
              Dim As HBRUSH hBrush = CreateSolidBrush(clr)
              Dim As HPEN oldPen = Cast(HPEN, SelectObject(hdcMem, hPen))
              Dim As HBRUSH oldBrush = Cast(HBRUSH, SelectObject(hdcMem, hBrush))
              
              Rectangle(hdcMem, bx, by, bx + bw, by + bh)
              
              SelectObject(hdcMem, oldPen)
              SelectObject(hdcMem, oldBrush)
              DeleteObject(hPen)
              DeleteObject(hBrush)
              
              If idx = selIdx Then
                Dim As RECT rcFocus = Type(bx - 2, by - 2, bx + bw + 2, by + bh + 2)
                DrawFocusRect(hdcMem, @rcFocus)
              End If
            Next
          Next
          
          BitBlt(hDC, 0, 0, w, h, hdcMem, 0, 0, SRCCOPY)
          
          SelectObject(hdcMem, hOldBmp)
          DeleteObject(hbmMem)
          DeleteDC(hdcMem)
        End If
        
        EndPaint(hWnd, @ps)
        Return 0
        
      Case WM_LBUTTONDOWN
        Dim As RECT rc
        GetClientRect(hWnd, @rc)
        Dim As Integer ctrlId = GetDlgCtrlID(hWnd)
        Dim As Integer numRows = IIf(ctrlId = 721, 2, 6)
        Dim As Integer pitch_x = (rc.right - rc.left) \ 8
        Dim As Integer pitch_y = (rc.bottom - rc.top) \ numRows
        If pitch_x > 0 AndAlso pitch_y > 0 Then
          Dim As Integer col = Cast(SHORT, LOWORD(lParam)) \ pitch_x
          Dim As Integer row = Cast(SHORT, HIWORD(lParam)) \ pitch_y
          If col >= 0 AndAlso col < 8 AndAlso row >= 0 AndAlso row < numRows Then
            If ctrlId = 720 Then
              g_selBasic = row * 8 + col
            Else
              g_selCustom = row * 8 + col
            End If
          End If
        End If
        Dim As LRESULT lRes = DefSubclassProc(hWnd, uMsg, wParam, lParam)
        InvalidateRect(hWnd, NULL, FALSE)
        UpdateWindow(hWnd)
        Return lRes
        
      Case WM_KEYDOWN
        Dim As Integer ctrlId = GetDlgCtrlID(hWnd)
        Dim As Integer numRows = IIf(ctrlId = 721, 2, 6)
        Dim As Integer curSel = IIf(ctrlId = 720, g_selBasic, g_selCustom)
        Select Case wParam
          Case VK_LEFT
            If (curSel Mod 8) > 0 Then curSel -= 1
          Case VK_RIGHT
            If (curSel Mod 8) < 7 Then curSel += 1
          Case VK_UP
            If curSel >= 8 Then curSel -= 8
          Case VK_DOWN
            If curSel + 8 < (numRows * 8) Then curSel += 8
        End Select
        If ctrlId = 720 Then g_selBasic = curSel Else g_selCustom = curSel
        Dim As LRESULT lRes = DefSubclassProc(hWnd, uMsg, wParam, lParam)
        InvalidateRect(hWnd, NULL, FALSE)
        UpdateWindow(hWnd)
        Return lRes

      Case WM_LBUTTONUP, WM_LBUTTONDBLCLK, WM_KEYUP, WM_SETFOCUS, WM_KILLFOCUS
        Dim As LRESULT lRes = DefSubclassProc(hWnd, uMsg, wParam, lParam)
        InvalidateRect(hWnd, NULL, FALSE)
        UpdateWindow(hWnd)
        Return lRes
        
      Case WM_MOUSEMOVE
        Dim As LRESULT lRes = DefSubclassProc(hWnd, uMsg, wParam, lParam)
        If (wParam And 1) <> 0 Then
          Dim As RECT rc
          GetClientRect(hWnd, @rc)
          Dim As Integer ctrlId = GetDlgCtrlID(hWnd)
          Dim As Integer numRows = IIf(ctrlId = 721, 2, 6)
          Dim As Integer pitch_x = (rc.right - rc.left) \ 8
          Dim As Integer pitch_y = (rc.bottom - rc.top) \ numRows
          If pitch_x > 0 AndAlso pitch_y > 0 Then
            Dim As Integer col = Cast(SHORT, LOWORD(lParam)) \ pitch_x
            Dim As Integer row = Cast(SHORT, HIWORD(lParam)) \ pitch_y
            If col >= 0 AndAlso col < 8 AndAlso row >= 0 AndAlso row < numRows Then
              If ctrlId = 720 Then
                g_selBasic = row * 8 + col
              Else
                g_selCustom = row * 8 + col
              End If
              InvalidateRect(hWnd, NULL, FALSE)
              UpdateWindow(hWnd)
            End If
          End If
        End If
        Return lRes
        
      Case WM_NCDESTROY
        RemoveWindowSubclass(hWnd, @ColorSwatchSubclassProc, uIdSubclass)
    End Select
  End If
  Return DefSubclassProc(hWnd, uMsg, wParam, lParam)
End Function