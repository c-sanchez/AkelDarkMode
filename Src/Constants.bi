#ifndef SC_MINIMIZE
  Const SC_MINIMIZE = &hF020
#endif
#ifndef SC_RESTORE
  Const SC_RESTORE = &hF120
#endif
#ifndef SC_CLOSE
  Const SC_CLOSE = &hF060
#endif
#ifndef ODS_NOACCEL
  Const ODS_NOACCEL = &h0100
#endif
#ifndef DT_HIDEPREFIX
  Const DT_HIDEPREFIX = &h00100000
#endif
#ifndef WM_QUERYUISTATE
  Const WM_QUERYUISTATE = &h0129
#endif
#ifndef UISF_HIDEACCEL
  Const UISF_HIDEACCEL = &h0002
#endif
#ifndef AKD_GETMAININFO
  Const AKD_GETMAININFO = (WM_USER + 175)
#endif
#ifndef MI_WNDTAB
  Const MI_WNDTAB = 13
#endif
#ifndef MI_WNDSTATUS
  Const MI_WNDSTATUS = 11
#endif
#ifndef TCM_GETITEMCOUNT
  Const TCM_GETITEMCOUNT = &h1304
#endif
#ifndef TCM_GETITEMRECT
  Const TCM_GETITEMRECT = &h130A
#endif
#ifndef TCM_GETCURSEL
  Const TCM_GETCURSEL = &h130B
#endif
#ifndef TCM_GETITEMW
  Const TCM_GETITEMW = &h133C
#endif
#ifndef TCM_GETIMAGELIST
  Const TCM_GETIMAGELIST = &h1302
#endif
#ifndef TCM_HITTEST
  Const TCM_HITTEST = &h130D
#endif
#ifndef TCIF_TEXT
  Const TCIF_TEXT = 1
#endif
#ifndef TCIF_IMAGE
  Const TCIF_IMAGE = 2
#endif
#ifndef ILD_TRANSPARENT
  Const ILD_TRANSPARENT = 1
#endif
#ifndef SB_GETPARTS
  Const SB_GETPARTS = (WM_USER + 6)
#endif
#ifndef SB_GETRECT
  Const SB_GETRECT = (WM_USER + 10)
#endif
#ifndef SB_GETTEXTW
  Const SB_GETTEXTW = (WM_USER + 13)
#endif
#ifndef SBARS_SIZEGRIP
  Const SBARS_SIZEGRIP = &h0100
#endif
#ifndef AKDN_EDIT_ONSTART
  Const AKDN_EDIT_ONSTART = (WM_USER + 11)
#endif
#ifndef WH_CBT
  Const WH_CBT = 5
#endif
#ifndef HCBT_ACTIVATE
  Const HCBT_ACTIVATE = 5
#endif
#ifndef WM_CTLCOLORDLG
  Const WM_CTLCOLORDLG = &h0136
#endif
#ifndef WM_CTLCOLORSTATIC
  Const WM_CTLCOLORSTATIC = &h0138
#endif
#ifndef WM_CTLCOLORBTN
  Const WM_CTLCOLORBTN = &h0135
#endif
#ifndef WM_CTLCOLORLISTBOX
  Const WM_CTLCOLORLISTBOX = &h0134
#endif
#ifndef WM_CTLCOLOREDIT
  Const WM_CTLCOLOREDIT = &h0133
#endif
#ifndef LVM_GETEXTENDEDLISTVIEWSTYLE
  Const LVM_GETEXTENDEDLISTVIEWSTYLE = (LVM_FIRST + 55)
#endif
#ifndef LVM_SETEXTENDEDLISTVIEWSTYLE
  Const LVM_SETEXTENDEDLISTVIEWSTYLE = (LVM_FIRST + 54)
#endif
#ifndef LVS_EX_GRIDLINES
  Const LVS_EX_GRIDLINES = &h00000001
#endif
#ifndef LVS_EX_DOUBLEBUFFER
  Const LVS_EX_DOUBLEBUFFER = &h00010000
#endif
#ifndef CDDS_SUBITEM
  Const CDDS_SUBITEM = &h00020000
#endif
#ifndef LVIR_BOUNDS
  Const LVIR_BOUNDS = 0
#endif
#ifndef CLR_NONE
  Const CLR_NONE = &hFFFFFFFF
#endif
#ifndef WM_CTLCOLORSCROLLBAR
  Const WM_CTLCOLORSCROLLBAR = &h0137
#endif
#ifndef SBS_SIZEBOX
  Const SBS_SIZEBOX = &h0008
#endif
#ifndef SBS_SIZEGRIP
  Const SBS_SIZEGRIP = &h0010
#endif
#ifndef BS_PUSHBUTTON
  Const BS_PUSHBUTTON = 0
#endif
#ifndef BS_DEFPUSHBUTTON
  Const BS_DEFPUSHBUTTON = 1
#endif
#ifndef BS_CHECKBOX
  Const BS_CHECKBOX = 2
#endif
#ifndef BS_AUTOCHECKBOX
  Const BS_AUTOCHECKBOX = 3
#endif
#ifndef BS_RADIOBUTTON
  Const BS_RADIOBUTTON = 4
#endif
#ifndef BS_3STATE
  Const BS_3STATE = 5
#endif
#ifndef BS_AUTO3STATE
  Const BS_AUTO3STATE = 6
#endif
#ifndef BS_GROUPBOX
  Const BS_GROUPBOX = 7
#endif
#ifndef BS_AUTORADIOBUTTON
  Const BS_AUTORADIOBUTTON = 9
#endif
#ifndef BM_GETCHECK
  Const BM_GETCHECK = &h00F0
#endif
#ifndef BM_SETCHECK
  Const BM_SETCHECK = &h00F1
#endif
#ifndef BM_GETSTATE
  Const BM_GETSTATE = &h00F2
#endif
#ifndef BST_CHECKED
  Const BST_CHECKED = 1
#endif
#ifndef BST_INDETERMINATE
  Const BST_INDETERMINATE = 2
#endif
#ifndef BST_PUSHED
  Const BST_PUSHED = &h0004
#endif
#ifndef TME_LEAVE
  Const TME_LEAVE = 2
#endif
#ifndef WM_CAPTURECHANGED
  Const WM_CAPTURECHANGED = &h0215
#endif
#ifndef SS_TYPEMASK
  Const SS_TYPEMASK = &h0000001F
#endif
#ifndef SS_ETCHEDHORZ
  Const SS_ETCHEDHORZ = &h00000010
#endif
#ifndef STATE_SYSTEM_PRESSED
  Const STATE_SYSTEM_PRESSED = &h00000008
#endif
#ifndef BS_ICON
  Const BS_ICON = &h00000040
#endif
#ifndef BS_BITMAP
  Const BS_BITMAP = &h00000080
#endif
#ifndef BS_OWNERDRAW
  Const BS_OWNERDRAW = &h0000000B
#endif
#ifndef IMAGE_BITMAP
  Const IMAGE_BITMAP = 0
#endif
#ifndef IMAGE_ICON
  Const IMAGE_ICON = 1
#endif
#ifndef DI_NORMAL
  Const DI_NORMAL = &h0003
#endif
#ifndef BM_GETIMAGE
  Const BM_GETIMAGE = &h00F6
#endif
#ifndef TCN_FIRST
  Const TCN_FIRST = -550
#endif
#ifndef TCN_SELCHANGE
  Const TCN_SELCHANGE = (TCN_FIRST - 1)
#endif
#ifndef UDS_HORZ
  Const UDS_HORZ = &h0040
#endif