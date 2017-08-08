inherited AboutForm: TAboutForm
  AlignWithMargins = True
  Left = 640
  Top = 457
  BorderStyle = bsToolWindow
  Caption = 'About Zoom Disabler'
  ClientHeight = 154
  ClientWidth = 401
  KeyPreview = True
  Position = poScreenCenter
  OnKeyDown = FormKeyDown
  ExplicitWidth = 407
  ExplicitHeight = 178
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 24
    Top = 24
    Width = 68
    Height = 13
    Caption = 'Zoom Disabler'
  end
  object Label2: TLabel
    Left = 24
    Top = 40
    Width = 297
    Height = 13
    Caption = 'Version {sAppVersionDisplay} ({sPlatformBit}, Unicode) for NPP'
  end
  object Label3: TLabel
    Left = 24
    Top = 67
    Width = 188
    Height = 13
    Caption = 'Written by Stanislav Eckert, 2014-2016,'
  end
  object Label4: TLabel
    Left = 218
    Top = 66
    Width = 134
    Height = 13
    Cursor = crHandPoint
    Caption = 'github@stanislaveckert.com'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlue
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    OnClick = Label4Click
  end
  object Label5: TLabel
    Left = 24
    Top = 85
    Width = 216
    Height = 13
    Caption = 'Base plugin template by Damjan Zobo Cvetko'
  end
  object Button1: TButton
    Left = 163
    Top = 118
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'OK'
    ModalResult = 1
    TabOrder = 0
  end
end
