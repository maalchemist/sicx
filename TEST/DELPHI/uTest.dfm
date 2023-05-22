object mForm: TmForm
  Left = 298
  Top = 157
  ActiveControl = CB_Expression
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'SIC TEST'
  ClientHeight = 654
  ClientWidth = 630
  Color = clBtnFace
  Font.Charset = RUSSIAN_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Menu = MainMenu
  Position = poScreenCenter
  ShowHint = True
  OnClick = FormClick
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnMouseWheel = FormMouseWheel
  OnMouseWheelDown = FormMouseWheelDown
  OnMouseWheelUp = FormMouseWheelUp
  TextHeight = 13
  object L_VarA: TLabel
    Left = 8
    Top = 233
    Width = 8
    Height = 13
    Hint = '"A" variable'
    Caption = 'A'
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object L_VarB: TLabel
    Left = 8
    Top = 257
    Width = 7
    Height = 13
    Hint = '"B" variable'
    Caption = 'B'
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object L_VarC: TLabel
    Left = 8
    Top = 281
    Width = 7
    Height = 13
    Hint = '"C" variable'
    Caption = 'C'
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object L_Result: TLabel
    Left = 328
    Top = 107
    Width = 8
    Height = 13
    Hint = 'Result'
    Caption = 'R'
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object L_mcsTime: TLabel
    Left = 328
    Top = 187
    Width = 7
    Height = 13
    Hint = 'Time (microseconds per cycle)'
    Caption = 'T'
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object L_CodeSize: TLabel
    Left = 328
    Top = 243
    Width = 7
    Height = 13
    Hint = 'Code Size'
    Caption = 'S'
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object L_VarX: TLabel
    Left = 168
    Top = 233
    Width = 7
    Height = 13
    Hint = '"X" variable'
    Caption = 'X'
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object L_VarY: TLabel
    Left = 168
    Top = 257
    Width = 7
    Height = 13
    Hint = '"Y" variable'
    Caption = 'Y'
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object L_VarZ: TLabel
    Left = 168
    Top = 281
    Width = 7
    Height = 13
    Hint = '"Z" variable'
    Caption = 'Z'
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object L_Error: TLabel
    Left = 580
    Top = 40
    Width = 38
    Height = 13
    Hint = 'Error'
    Caption = 'ERROR'
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clRed
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object L_ZE: TLabel
    Left = 580
    Top = 72
    Width = 16
    Height = 13
    Hint = 'ZE - Zero Divide'
    Alignment = taRightJustify
    AutoSize = False
    Caption = 'ZE'
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clRed
    Font.Height = -13
    Font.Name = 'Consolas'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object L_ZE_F: TLabel
    Left = 604
    Top = 72
    Width = 7
    Height = 15
    Hint = 'ZE - Zero Divide'
    Caption = '0'
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clBlack
    Font.Height = -13
    Font.Name = 'Consolas'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object L_OE: TLabel
    Left = 580
    Top = 56
    Width = 16
    Height = 13
    Hint = 'OE - Overflow'
    Alignment = taRightJustify
    AutoSize = False
    Caption = 'OE'
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clRed
    Font.Height = -13
    Font.Name = 'Consolas'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object L_OE_F: TLabel
    Left = 604
    Top = 56
    Width = 7
    Height = 15
    Hint = 'OE - Overflow'
    Caption = '0'
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clBlack
    Font.Height = -13
    Font.Name = 'Consolas'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object L_IE: TLabel
    Left = 580
    Top = 88
    Width = 16
    Height = 13
    Hint = 'IE - Invalid Operation'
    Alignment = taRightJustify
    AutoSize = False
    Caption = 'IE'
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clRed
    Font.Height = -13
    Font.Name = 'Consolas'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object L_IE_F: TLabel
    Left = 604
    Top = 88
    Width = 7
    Height = 15
    Hint = 'IE - Invalid Operation'
    Caption = '0'
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clBlack
    Font.Height = -13
    Font.Name = 'Consolas'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object L_VarU: TLabel
    Left = 8
    Top = 331
    Width = 8
    Height = 13
    Hint = '"U" array variable'
    Caption = 'U'
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object L_secTime: TLabel
    Left = 328
    Top = 211
    Width = 7
    Height = 13
    Hint = 'Time (seconds)'
    Caption = 'T'
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object L_Cycles: TLabel
    Left = 488
    Top = 40
    Width = 31
    Height = 13
    Caption = 'Cycles'
  end
  object L_0x: TLabel
    Left = 328
    Top = 155
    Width = 14
    Height = 14
    Hint = 'Trunc (Result) in hex format'
    Caption = '0x'
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Consolas'
    Font.Style = []
    ParentFont = False
  end
  object L_VarD: TLabel
    Left = 8
    Top = 305
    Width = 8
    Height = 13
    Hint = '"D" variable'
    Caption = 'D'
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object L_VarT: TLabel
    Left = 168
    Top = 305
    Width = 7
    Height = 13
    Hint = '"T" variable'
    Caption = 'T'
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object BT_ExpressionClipboard: TSpeedButton
    Left = 318
    Top = 8
    Width = 22
    Height = 21
    Hint = 'Clipboard As Expression'
    Caption = '~'
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Courier New'
    Font.Style = []
    ParentFont = False
    OnClick = BT_ExpressionClipboardClick
  end
  object BT_ExpressionClear: TSpeedButton
    Left = 318
    Top = 56
    Width = 22
    Height = 21
    Hint = 'Clear Expression'
    Caption = 'X'
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Courier New'
    Font.Style = []
    ParentFont = False
    OnClick = BT_ExpressionClearClick
  end
  object BT_ExpressionPasteFromClipboard: TSpeedButton
    Left = 318
    Top = 32
    Width = 22
    Height = 21
    Hint = 'Paste From Clipboard Into Expression'
    Caption = '+'
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Courier New'
    Font.Style = []
    ParentFont = False
    OnClick = BT_ExpressionPasteFromClipboardClick
  end
  object L_HexResult: TLabel
    Left = 328
    Top = 131
    Width = 14
    Height = 14
    Hint = 'Result in hex format'
    Caption = '0h'
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Consolas'
    Font.Style = []
    ParentFont = False
  end
  object BT_DefaultVars: TSpeedButton
    Left = 318
    Top = 328
    Width = 22
    Height = 21
    Action = acDefaultVars
    Caption = '*'
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Courier New'
    Font.Style = []
    ParentFont = False
  end
  object BT_SicCompile: TButton
    Left = 344
    Top = 64
    Width = 128
    Height = 25
    Action = acSicCompile
    TabOrder = 17
  end
  object BT_SicExecute: TButton
    Left = 344
    Top = 8
    Width = 128
    Height = 25
    Action = acSicExecute
    TabOrder = 15
  end
  object ED_Result: TEdit
    Left = 344
    Top = 104
    Width = 128
    Height = 22
    Hint = 'Result'
    Color = clBlack
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clLime
    Font.Height = -12
    Font.Name = 'Consolas'
    Font.Style = [fsBold]
    ParentFont = False
    ReadOnly = True
    TabOrder = 20
    Text = '0'
  end
  object ED_VarA: TEdit
    Left = 24
    Top = 230
    Width = 128
    Height = 22
    Hint = '"A" variable'
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Courier New'
    Font.Style = []
    ParentFont = False
    TabOrder = 2
    Text = '1'
    OnKeyPress = edKeyPress
  end
  object ED_mcsTime: TEdit
    Left = 344
    Top = 184
    Width = 128
    Height = 22
    Hint = 'Time (microseconds per cycle)'
    Color = 15794144
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Courier New'
    Font.Style = []
    ParentFont = False
    ReadOnly = True
    TabOrder = 23
    Text = '0'
  end
  object ED_VarB: TEdit
    Left = 24
    Top = 254
    Width = 128
    Height = 22
    Hint = '"B" variable'
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Courier New'
    Font.Style = []
    ParentFont = False
    TabOrder = 3
    Text = '1'
    OnKeyPress = edKeyPress
  end
  object BT_DelphiExec: TButton
    Left = 488
    Top = 8
    Width = 128
    Height = 25
    Action = acDelphiExec
    TabOrder = 18
  end
  object ED_Expression: TMemo
    Left = 8
    Top = 8
    Width = 304
    Height = 188
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Courier New'
    Font.Style = []
    HideSelection = False
    Lines.Strings = (
      'sin(logn(10,ln(33.33)*sqrt(abs('
      'sin(a)*tan(11.11)+'
      'cos(b)*cotan(22.22)))+'
      'exp(c)+power(x,y))-'
      'a/b+x*y+z^10)-log10(100*a)+logn(x,y)*z-'
      'sqr(a*b)+sqrt(abs(atan2(a,x)))+'
      'cos(a*b/c-x*y/z)+hypot(x,y)+'
      'arcsin(cos(a*b*c))+arccos(sin(x*y*z))+'
      'sh(x)+ch(y)+th(z)+cth(a)+sch(b)+csh(c)')
    ParentFont = False
    ScrollBars = ssVertical
    TabOrder = 0
  end
  object ED_CodeSize: TEdit
    Left = 344
    Top = 240
    Width = 128
    Height = 22
    Hint = 'Code Size (Code Space)'
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Courier New'
    Font.Style = []
    ParentFont = False
    ReadOnly = True
    TabOrder = 25
    Text = '0'
  end
  object ED_VarC: TEdit
    Left = 24
    Top = 278
    Width = 128
    Height = 22
    Hint = '"C" variable'
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Courier New'
    Font.Style = []
    ParentFont = False
    TabOrder = 4
    Text = '1'
    OnKeyPress = edKeyPress
  end
  object ED_VarX: TEdit
    Left = 184
    Top = 230
    Width = 128
    Height = 22
    Hint = '"X" variable'
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Courier New'
    Font.Style = []
    ParentFont = False
    TabOrder = 6
    Text = '1'
    OnKeyPress = edKeyPress
  end
  object ED_VarY: TEdit
    Left = 184
    Top = 254
    Width = 128
    Height = 22
    Hint = '"Y" variable'
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Courier New'
    Font.Style = []
    ParentFont = False
    TabOrder = 7
    Text = '1'
    OnKeyPress = edKeyPress
  end
  object ED_VarZ: TEdit
    Left = 184
    Top = 278
    Width = 128
    Height = 22
    Hint = '"Z" variable'
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Courier New'
    Font.Style = []
    ParentFont = False
    TabOrder = 8
    Text = '1'
    OnKeyPress = edKeyPress
  end
  object BT_SicCompileExec: TButton
    Left = 344
    Top = 36
    Width = 128
    Height = 25
    Action = acSicCompileExec
    TabOrder = 16
  end
  object BT_SaveCode: TButton
    Left = 344
    Top = 320
    Width = 128
    Height = 25
    Action = acSaveCode
    TabOrder = 28
  end
  object CB_Expression: TComboBox
    Left = 8
    Top = 200
    Width = 304
    Height = 22
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Courier New'
    Font.Style = []
    ParentFont = False
    TabOrder = 1
    OnChange = CB_ExpressionChange
  end
  object GB_Options: TGroupBox
    Left = 488
    Top = 112
    Width = 136
    Height = 200
    Caption = ' Compiler Options '
    TabOrder = 29
    OnClick = FormClick
    object P_COP_T: TPanel
      Left = 2
      Top = 15
      Width = 132
      Height = 24
      Align = alTop
      BevelOuter = bvNone
      TabOrder = 0
      OnClick = FormClick
      object BT_DefaultOptions: TSpeedButton
        Left = 8
        Top = 2
        Width = 116
        Height = 22
        Action = acDefaultOptions
        AllowAllUp = True
      end
    end
    object SB_COP: TScrollBox
      Left = 2
      Top = 39
      Width = 132
      Height = 159
      HorzScrollBar.Visible = False
      VertScrollBar.Visible = False
      Align = alClient
      BorderStyle = bsNone
      TabOrder = 1
      OnClick = FormClick
      object P_COP: TPanel
        Left = 0
        Top = 0
        Width = 132
        Height = 159
        BevelOuter = bvNone
        TabOrder = 0
        OnClick = FormClick
        object CB_SIC_OPT_FLAG_OPTIMIZATION: TCheckBox
          Left = 8
          Top = 8
          Width = 104
          Height = 17
          Hint = 'SIC_OPT_FLAG_OPTIMIZATION'
          Caption = ' OPTIMIZATION'
          Checked = True
          State = cbChecked
          TabOrder = 0
          OnClick = CB_SIC_OPT_FLAG_Click
        end
        object CB_SIC_OPT_FLAG_STACK_FRAME: TCheckBox
          Left = 8
          Top = 26
          Width = 104
          Height = 17
          Hint = 'SIC_OPT_FLAG_STACK_FRAME'
          Caption = ' STACK_FRAME'
          Checked = True
          State = cbChecked
          TabOrder = 1
          OnClick = CB_SIC_OPT_FLAG_Click
        end
        object CB_SIC_OPT_FLAG_FP_FRAME: TCheckBox
          Left = 8
          Top = 62
          Width = 104
          Height = 17
          Hint = 'SIC_OPT_FLAG_FP_FRAME'
          Caption = ' FP_FRAME'
          TabOrder = 3
          OnClick = CB_SIC_OPT_FLAG_Click
        end
        object CB_SIC_OPT_FLAG_NO_CALIGN: TCheckBox
          Left = 8
          Top = 80
          Width = 104
          Height = 17
          Hint = 'SIC_OPT_FLAG_NO_CALIGN'
          Caption = ' NO_CALIGN'
          TabOrder = 4
          OnClick = CB_SIC_OPT_FLAG_Click
        end
        object CB_SIC_OPT_FLAG_LOCALS: TCheckBox
          Left = 8
          Top = 44
          Width = 104
          Height = 17
          Hint = 'SIC_OPT_FLAG_LOCALS'
          Caption = ' LOCALS'
          Checked = True
          State = cbChecked
          TabOrder = 2
          OnClick = CB_SIC_OPT_FLAG_Click
        end
        object CB_SIC_OPT_FLAG_DEBUG: TCheckBox
          Left = 8
          Top = 122
          Width = 104
          Height = 17
          Hint = 'SIC_OPT_FLAG_DEBUG'
          Caption = ' DEBUG'
          TabOrder = 5
          OnClick = CB_SIC_OPT_FLAG_Click
        end
      end
    end
  end
  object ED_TokensRpn: TEdit
    Left = 344
    Top = 264
    Width = 128
    Height = 22
    Hint = 'Tokens:Rpn Item Count'
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Courier New'
    Font.Style = []
    ParentFont = False
    ReadOnly = True
    TabOrder = 26
    Text = '0'
  end
  object GB_MultiLineExpression: TGroupBox
    Left = 0
    Top = 358
    Width = 480
    Height = 274
    Caption = ' Multi Line Expression '
    TabOrder = 14
    OnClick = FormClick
    object BT_Bu01: TSpeedButton
      Left = 344
      Top = 104
      Width = 22
      Height = 21
      GroupIndex = 1
      Caption = '0'
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Courier New'
      Font.Style = []
      ParentFont = False
      OnClick = BT_Bu01Click
    end
    object BT_Bu02: TSpeedButton
      Left = 368
      Top = 104
      Width = 22
      Height = 21
      GroupIndex = 1
      Caption = '1'
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Courier New'
      Font.Style = []
      ParentFont = False
      OnClick = BT_Bu02Click
    end
    object BT_Bu03: TSpeedButton
      Left = 392
      Top = 104
      Width = 22
      Height = 21
      GroupIndex = 1
      Caption = '2'
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Courier New'
      Font.Style = []
      ParentFont = False
      OnClick = BT_Bu03Click
    end
    object BT_Bu04: TSpeedButton
      Left = 416
      Top = 104
      Width = 22
      Height = 21
      GroupIndex = 1
      Caption = '3'
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Courier New'
      Font.Style = []
      ParentFont = False
      OnClick = BT_Bu04Click
    end
    object BT_Bu05: TSpeedButton
      Left = 440
      Top = 104
      Width = 22
      Height = 21
      GroupIndex = 1
      Caption = '4'
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Courier New'
      Font.Style = []
      ParentFont = False
      OnClick = BT_Bu05Click
    end
    object BT_Bu06: TSpeedButton
      Left = 344
      Top = 128
      Width = 22
      Height = 21
      GroupIndex = 1
      Caption = '5'
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Courier New'
      Font.Style = []
      ParentFont = False
      OnClick = BT_Bu06Click
    end
    object BT_Bu07: TSpeedButton
      Left = 368
      Top = 128
      Width = 22
      Height = 21
      GroupIndex = 1
      Caption = '6'
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Courier New'
      Font.Style = []
      ParentFont = False
      OnClick = BT_Bu07Click
    end
    object BT_Bu08: TSpeedButton
      Left = 392
      Top = 128
      Width = 22
      Height = 21
      GroupIndex = 1
      Caption = '7'
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Courier New'
      Font.Style = []
      ParentFont = False
      OnClick = BT_Bu08Click
    end
    object BT_Bu09: TSpeedButton
      Left = 416
      Top = 128
      Width = 22
      Height = 21
      GroupIndex = 1
      Caption = '8'
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Courier New'
      Font.Style = []
      ParentFont = False
      OnClick = BT_Bu09Click
    end
    object BT_Bu10: TSpeedButton
      Left = 440
      Top = 128
      Width = 22
      Height = 21
      GroupIndex = 1
      Caption = '9'
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Courier New'
      Font.Style = []
      ParentFont = False
      OnClick = BT_Bu10Click
    end
    object BT_Bu11: TSpeedButton
      Left = 344
      Top = 152
      Width = 22
      Height = 21
      GroupIndex = 1
      Caption = 'A'
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Courier New'
      Font.Style = []
      ParentFont = False
      OnClick = BT_Bu11Click
    end
    object BT_Bu12: TSpeedButton
      Left = 368
      Top = 152
      Width = 22
      Height = 21
      GroupIndex = 1
      Caption = 'B'
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Courier New'
      Font.Style = []
      ParentFont = False
      OnClick = BT_Bu12Click
    end
    object BT_Bu13: TSpeedButton
      Left = 392
      Top = 152
      Width = 22
      Height = 21
      GroupIndex = 1
      Caption = 'C'
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Courier New'
      Font.Style = []
      ParentFont = False
      OnClick = BT_Bu13Click
    end
    object BT_Bu14: TSpeedButton
      Left = 416
      Top = 152
      Width = 22
      Height = 21
      GroupIndex = 1
      Caption = 'D'
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Courier New'
      Font.Style = []
      ParentFont = False
      OnClick = BT_Bu14Click
    end
    object BT_Bu15: TSpeedButton
      Left = 440
      Top = 152
      Width = 22
      Height = 21
      GroupIndex = 1
      Caption = 'E'
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Courier New'
      Font.Style = []
      ParentFont = False
      OnClick = BT_Bu15Click
    end
    object BT_Bu16: TSpeedButton
      Left = 344
      Top = 176
      Width = 22
      Height = 21
      GroupIndex = 1
      Caption = 'F'
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Courier New'
      Font.Style = []
      ParentFont = False
      OnClick = BT_Bu16Click
    end
    object BT_Bu17: TSpeedButton
      Left = 368
      Top = 176
      Width = 22
      Height = 21
      GroupIndex = 1
      Caption = 'G'
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Courier New'
      Font.Style = []
      ParentFont = False
      OnClick = BT_Bu17Click
    end
    object BT_Bu18: TSpeedButton
      Left = 392
      Top = 176
      Width = 22
      Height = 21
      GroupIndex = 1
      Caption = 'H'
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Courier New'
      Font.Style = []
      ParentFont = False
      OnClick = BT_Bu18Click
    end
    object BT_Bu19: TSpeedButton
      Left = 416
      Top = 176
      Width = 22
      Height = 21
      GroupIndex = 1
      Caption = 'I'
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Courier New'
      Font.Style = []
      ParentFont = False
      OnClick = BT_Bu19Click
    end
    object BT_Bu20: TSpeedButton
      Left = 440
      Top = 176
      Width = 22
      Height = 21
      GroupIndex = 1
      Caption = 'J'
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Courier New'
      Font.Style = []
      ParentFont = False
      OnClick = BT_Bu20Click
    end
    object BT_Bu21: TSpeedButton
      Left = 344
      Top = 200
      Width = 22
      Height = 21
      GroupIndex = 1
      Caption = 'K'
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Courier New'
      Font.Style = []
      ParentFont = False
      OnClick = BT_Bu21Click
    end
    object BT_Bu22: TSpeedButton
      Left = 368
      Top = 200
      Width = 22
      Height = 21
      GroupIndex = 1
      Caption = 'L'
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Courier New'
      Font.Style = []
      ParentFont = False
      OnClick = BT_Bu22Click
    end
    object BT_Bu23: TSpeedButton
      Left = 392
      Top = 200
      Width = 22
      Height = 21
      GroupIndex = 1
      Caption = 'M'
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Courier New'
      Font.Style = []
      ParentFont = False
      OnClick = BT_Bu23Click
    end
    object BT_Bu24: TSpeedButton
      Left = 416
      Top = 200
      Width = 22
      Height = 21
      GroupIndex = 1
      Caption = 'N'
      Enabled = False
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Courier New'
      Font.Style = []
      ParentFont = False
      OnClick = BT_Bu24Click
    end
    object BT_Bu25: TSpeedButton
      Left = 440
      Top = 200
      Width = 22
      Height = 21
      GroupIndex = 1
      Caption = 'O'
      Enabled = False
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Courier New'
      Font.Style = []
      ParentFont = False
      OnClick = BT_Bu25Click
    end
    object BT_MultiLineClipboard: TSpeedButton
      Left = 344
      Top = 240
      Width = 22
      Height = 21
      Hint = 'Clipboard As Multi-line Expression'
      Caption = '~'
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Courier New'
      Font.Style = []
      ParentFont = False
      OnClick = BT_MultiLineClipboardClick
    end
    object BT_MultiLineClear: TSpeedButton
      Left = 392
      Top = 240
      Width = 22
      Height = 21
      Hint = 'Clear Multi-line Expression'
      Caption = 'X'
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Courier New'
      Font.Style = []
      ParentFont = False
      OnClick = BT_MultiLineClearClick
    end
    object BT_MultiLinePasteFromClipboard: TSpeedButton
      Left = 368
      Top = 240
      Width = 22
      Height = 21
      Hint = 'Paste From Clipboard Into Multi-line Expression'
      Caption = '+'
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Courier New'
      Font.Style = []
      ParentFont = False
      OnClick = BT_MultiLinePasteFromClipboardClick
    end
    object BT_Bench: TSpeedButton
      Left = 440
      Top = 240
      Width = 22
      Height = 21
      Hint = 'Benchmark'
      GroupIndex = 1
      Caption = '*'
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Courier New'
      Font.Style = [fsBold]
      ParentFont = False
      OnClick = BT_BenchClick
    end
    object ED_MultiLine: TMemo
      Left = 8
      Top = 16
      Width = 320
      Height = 252
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Courier New'
      Font.Style = []
      HideSelection = False
      ParentFont = False
      ScrollBars = ssBoth
      TabOrder = 0
      OnChange = ED_MultiLineChange
    end
    object BT_MultiLineExecute: TButton
      Left = 344
      Top = 16
      Width = 120
      Height = 25
      Action = acMultiLineExecute
      TabOrder = 1
    end
    object BT_MultiLineBuild: TButton
      Left = 344
      Top = 72
      Width = 120
      Height = 25
      Action = acMultiLineBuild
      TabOrder = 3
    end
    object BT_MultiLineBuildExec: TButton
      Left = 344
      Top = 44
      Width = 120
      Height = 25
      Action = acMultiLineBuildExec
      TabOrder = 2
    end
  end
  object GB_Global: TGroupBox
    Left = 488
    Top = 358
    Width = 136
    Height = 134
    Caption = ' Global '
    TabOrder = 31
    OnClick = FormClick
    object BT_GFunTable: TButton
      Left = 16
      Top = 18
      Width = 104
      Height = 22
      Action = acGFunTable
      TabOrder = 0
    end
    object BT_GConTable: TButton
      Left = 16
      Top = 42
      Width = 104
      Height = 22
      Action = acGConTable
      TabOrder = 1
    end
    object BT_GVarTable: TButton
      Left = 16
      Top = 66
      Width = 104
      Height = 22
      Action = acGVarTable
      TabOrder = 2
    end
    object BT_GRunTable: TButton
      Left = 16
      Top = 90
      Width = 104
      Height = 22
      Action = acGRunTable
      TabOrder = 3
    end
  end
  object GB_Local: TGroupBox
    Left = 488
    Top = 498
    Width = 136
    Height = 134
    Caption = ' Local '
    TabOrder = 32
    OnClick = FormClick
    object BT_LConTable: TButton
      Left = 16
      Top = 42
      Width = 104
      Height = 22
      Action = acLConTable
      TabOrder = 1
    end
    object BT_LVarTable: TButton
      Left = 16
      Top = 66
      Width = 104
      Height = 22
      Action = acLVarTable
      TabOrder = 2
    end
    object BT_LFunTable: TButton
      Left = 16
      Top = 18
      Width = 104
      Height = 22
      Action = acLFunTable
      TabOrder = 0
    end
    object BT_LRunTable: TButton
      Left = 16
      Top = 90
      Width = 104
      Height = 22
      Action = acLRunTable
      TabOrder = 3
    end
  end
  object ED_VarU_0: TEdit
    Left = 24
    Top = 328
    Width = 72
    Height = 22
    Hint = '"U" array variable, Item #0'
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Courier New'
    Font.Style = []
    ParentFont = False
    TabOrder = 10
    Text = '1'
    OnKeyPress = edKeyPress
  end
  object ED_VarU_1: TEdit
    Left = 96
    Top = 328
    Width = 72
    Height = 22
    Hint = '"U" array variable, Item #1'
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Courier New'
    Font.Style = []
    ParentFont = False
    TabOrder = 11
    Text = '1'
    OnKeyPress = edKeyPress
  end
  object ED_VarU_2: TEdit
    Left = 168
    Top = 328
    Width = 72
    Height = 22
    Hint = '"U" array variable, Item #2'
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Courier New'
    Font.Style = []
    ParentFont = False
    TabOrder = 12
    Text = '1'
    OnKeyPress = edKeyPress
  end
  object ED_VarU_3: TEdit
    Left = 240
    Top = 328
    Width = 72
    Height = 22
    Hint = '"U" array variable, Item #3'
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Courier New'
    Font.Style = []
    ParentFont = False
    TabOrder = 13
    Text = '1'
    OnKeyPress = edKeyPress
  end
  object ED_sTime: TEdit
    Left = 344
    Top = 208
    Width = 128
    Height = 22
    Hint = 'Time (seconds)'
    Color = 15794144
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Courier New'
    Font.Style = []
    ParentFont = False
    ReadOnly = True
    TabOrder = 24
    Text = '0'
  end
  object CB_Cycles: TComboBox
    Left = 488
    Top = 56
    Width = 80
    Height = 21
    TabOrder = 19
    Text = 'CB_Cycles'
    Items.Strings = (
      '1'
      '1000'
      '1000000')
  end
  object BT_SicConfig: TButton
    Left = 488
    Top = 320
    Width = 128
    Height = 25
    Action = acSicConfig
    TabOrder = 30
  end
  object ED_IntHexResult: TEdit
    Left = 344
    Top = 152
    Width = 128
    Height = 22
    Hint = 'Trunc (Result) in hex format'
    Color = clBlack
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clLime
    Font.Height = -12
    Font.Name = 'Consolas'
    Font.Style = [fsBold]
    ParentFont = False
    ReadOnly = True
    TabOrder = 22
    Text = '0'
  end
  object ED_RpnItems: TEdit
    Left = 344
    Top = 288
    Width = 128
    Height = 22
    Hint = 'Rpn Array Item Count (F:C:V:R)'
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Courier New'
    Font.Style = []
    ParentFont = False
    ReadOnly = True
    TabOrder = 27
    Text = '0'
  end
  object ED_VarD: TEdit
    Left = 24
    Top = 302
    Width = 128
    Height = 22
    Hint = '"D" variable'
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Courier New'
    Font.Style = []
    ParentFont = False
    TabOrder = 5
    Text = '1'
    OnKeyPress = edKeyPress
  end
  object ED_VarT: TEdit
    Left = 184
    Top = 302
    Width = 128
    Height = 22
    Hint = '"T" variable'
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Courier New'
    Font.Style = []
    ParentFont = False
    TabOrder = 9
    Text = '1'
    OnKeyPress = edKeyPress
  end
  object ED_HexResult: TEdit
    Left = 344
    Top = 128
    Width = 128
    Height = 22
    Hint = 'Result in hex format'
    Color = clBlack
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clLime
    Font.Height = -12
    Font.Name = 'Consolas'
    Font.Style = [fsBold]
    MaxLength = 16
    ParentFont = False
    TabOrder = 21
    Text = '0'
    OnChange = ED_HexResultChange
    OnKeyPress = ED_HexResultKeyPress
  end
  object StatusBar: TStatusBar
    Left = 0
    Top = 635
    Width = 630
    Height = 19
    Panels = <>
    SimplePanel = True
    ExplicitTop = 634
    ExplicitWidth = 626
  end
  object Actions: TActionList
    Left = 56
    Top = 384
    object acSicExecute: TAction
      Caption = 'Execute'
      Hint = 'Execute Code'
      ShortCut = 120
      OnExecute = acSicExecuteExecute
    end
    object acSicCompile: TAction
      Caption = 'Compile'
      ShortCut = 16504
      OnExecute = acSicCompileExecute
    end
    object acSicCompileExec: TAction
      Caption = 'Compile && Execute'
      Hint = 'Compile and Execute Code'
      OnExecute = acSicCompileExecExecute
    end
    object acDelphiExec: TAction
      Caption = 'Execute  [ DELPHI ]'
      OnExecute = acDelphiExecExecute
    end
    object acGFunTable: TAction
      Caption = 'Functions'
      Hint = 'Global Functions'
      OnExecute = acGFunTableExecute
    end
    object acGConTable: TAction
      Caption = 'Constants'
      Hint = 'Global Constants'
      OnExecute = acGConTableExecute
    end
    object acGVarTable: TAction
      Caption = 'Variables'
      Hint = 'Global Variables'
      OnExecute = acGVarTableExecute
    end
    object acGRunTable: TAction
      Caption = 'Runtimes'
      Hint = 'Global Runtimes'
      OnExecute = acGRunTableExecute
    end
    object acLFunTable: TAction
      Caption = 'Functions'
      Hint = 'Local Functions'
      OnExecute = acLFunTableExecute
    end
    object acLConTable: TAction
      Caption = 'Constants'
      Hint = 'Local Constants'
      OnExecute = acLConTableExecute
    end
    object acLVarTable: TAction
      Caption = 'Variables'
      Hint = 'Local Variables'
      OnExecute = acLVarTableExecute
    end
    object acLRunTable: TAction
      Caption = 'Runtimes'
      Hint = 'Local Runtimes'
      OnExecute = acLRunTableExecute
    end
    object acSaveCode: TAction
      Caption = 'Save > CODE.bin'
      Hint = 'Save Code'
      OnExecute = acSaveCodeExecute
    end
    object acDefaultVars: TAction
      Caption = 'acDefaultVars'
      Hint = 'Set default variables'
      OnExecute = acDefaultVarsExecute
    end
    object acDefaultOptions: TAction
      Caption = 'Defaults'
      Hint = 'Set Default Compiler Options'
      OnExecute = acDefaultOptionsExecute
    end
    object acMultiLinePreBuild: TAction
      Caption = 'acMultiLinePreBuild'
      OnExecute = acMultiLinePreBuildExecute
    end
    object acMultiLineExecute: TAction
      Caption = 'Execute'
      Hint = 'Execute Multi-line Expression'
      OnExecute = acMultiLineExecuteExecute
    end
    object acMultiLineBuildExec: TAction
      Caption = 'Build && Execute'
      Hint = 'Build and Execute Multi-line Expression'
      OnExecute = acMultiLineBuildExecExecute
    end
    object acMultiLineBuild: TAction
      Caption = 'Build'
      Hint = 'Build Multi-line Expression'
      OnExecute = acMultiLineBuildExecute
    end
    object acEscape: TAction
      Caption = 'acEscape'
      ShortCut = 27
      OnExecute = acEscapeExecute
    end
    object acSelectAll: TAction
      Caption = 'acSelectAll'
      ShortCut = 16449
      OnExecute = acSelectAllExecute
    end
    object acSicConfig: TAction
      Caption = 'Config'
      Hint = 'Show Compiler Config'
      OnExecute = acSicConfigExecute
    end
    object acIDA: TAction
      Caption = 'IDA'
      OnExecute = acIDAExecute
    end
    object ac_TEST: TAction
      Caption = 'TEST'
      OnExecute = ac_TESTExecute
    end
    object ac_TEST_LIST: TAction
      Caption = 'TEST LIST'
      ShortCut = 24652
      OnExecute = ac_TEST_LISTExecute
    end
    object ac_TEST_VOC: TAction
      Caption = 'TEST VOC'
      ShortCut = 24662
      OnExecute = ac_TEST_VOCExecute
    end
    object ac_TEST_SICx: TAction
      Caption = 'TEST _SICx'
      Visible = False
      OnExecute = ac_TEST_SICxExecute
    end
    object acRecreateSICx: TAction
      Caption = 'Recreate SICx'
      OnExecute = acRecreateSICxExecute
    end
    object ac_TEST_mt19937_SICx: TAction
      Caption = 'mt19937 - SICx'
      OnExecute = ac_TEST_mt19937_SICxExecute
    end
    object ac_TEST_mt19937_Delphi: TAction
      Caption = 'mt19937 - Delphi'
      OnExecute = ac_TEST_mt19937_DelphiExecute
    end
    object ac_TEST_sfmt: TAction
      Caption = 'sfmt * init_gen_rand'
      OnExecute = ac_TEST_sfmtExecute
    end
    object ac_TEST_sfmt_a: TAction
      Caption = 'sfmt * init_by_array'
      OnExecute = ac_TEST_sfmt_aExecute
    end
  end
  object MainMenu: TMainMenu
    Left = 24
    Top = 384
    object mmi_TEST: TMenuItem
      Action = ac_TEST
      object mmi_TEST_LIST: TMenuItem
        Action = ac_TEST_LIST
      end
      object mmi_TEST_VOC: TMenuItem
        Action = ac_TEST_VOC
      end
      object mmi_TEST_SICx: TMenuItem
        Action = ac_TEST_SICx
      end
      object NOP: TMenuItem
        Caption = '-'
      end
      object mmi_TEST_mt19937_SICx: TMenuItem
        Action = ac_TEST_mt19937_SICx
      end
      object mmi_TEST_mt19937_Delphi: TMenuItem
        Action = ac_TEST_mt19937_Delphi
      end
      object NUB: TMenuItem
        Caption = '-'
      end
      object mmi_TEST_sfmt: TMenuItem
        Action = ac_TEST_sfmt
      end
      object mmi_TEST_sfmt_a: TMenuItem
        Action = ac_TEST_sfmt_a
      end
      object NUP: TMenuItem
        Caption = '-'
      end
      object mmiRecreateSICx: TMenuItem
        Action = acRecreateSICx
      end
    end
  end
end
