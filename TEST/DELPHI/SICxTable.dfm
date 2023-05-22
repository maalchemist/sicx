object SICxTableForm: TSICxTableForm
  Left = 631
  Top = 191
  ClientHeight = 537
  ClientWidth = 496
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = True
  Position = poScreenCenter
  OnClose = FormClose
  PixelsPerInch = 96
  TextHeight = 13
  object P_Display: TPanel
    Left = 0
    Top = 0
    Width = 496
    Height = 537
    Align = alClient
    BevelInner = bvRaised
    BevelOuter = bvLowered
    TabOrder = 0
    object ED_Display: TMemo
      Left = 2
      Top = 2
      Width = 492
      Height = 533
      Align = alClient
      BorderStyle = bsNone
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Courier New'
      Font.Style = []
      ParentFont = False
      ReadOnly = True
      ScrollBars = ssBoth
      TabOrder = 0
      WordWrap = False
    end
  end
  object ActionList: TActionList
    Left = 24
    Top = 24
    object acClose: TAction
      ShortCut = 27
      OnExecute = acCloseExecute
    end
  end
end
