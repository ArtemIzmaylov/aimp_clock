object frmClock: TfrmClock
  Left = 0
  Top = 0
  BorderStyle = bsNone
  Caption = 'Clock'
  ClientHeight = 218
  ClientWidth = 1051
  Color = clBlack
  Constraints.MinHeight = 160
  Constraints.MinWidth = 320
  DoubleBuffered = True
  Font.Charset = RUSSIAN_CHARSET
  Font.Color = clWhite
  Font.Height = -16
  Font.Name = 'Arial Black'
  Font.Style = [fsBold]
  PopupMenu = Settings
  OnPaint = FormPaint
  OnResize = FormResize
  OnShow = FormResize
  TextHeight = 23
  object Timer: TACLTimer
    OnTimer = FormTimer
    Left = 8
    Top = 8
  end
  object Settings: TACLPopupMenu
    OnPopup = SettingsPopup
    Left = 56
    Top = 8
    object miSettings: TACLMenuItem
      Tag = -1
      Caption = 'Settings'
      object miBlinkColon: TACLMenuItem
        AutoCheck = True
        Caption = 'Blink the colon'
      end
    end
    object miClock: TACLMenuItem
      Caption = 'Clock'
      RadioItem = True
      OnClick = miClockClick
    end
    object miLine1: TACLMenuItem
      Caption = '-'
    end
    object miTrackElapsed: TACLMenuItem
      Tag = 1
      Caption = 'Track Elapsed'
      RadioItem = True
      OnClick = miClockClick
    end
    object miTrackRemaining: TACLMenuItem
      Tag = 2
      Caption = 'Track Remaining'
      RadioItem = True
      OnClick = miClockClick
    end
    object miLine2: TACLMenuItem
      Caption = '-'
    end
    object miPlaylistElapsed: TACLMenuItem
      Tag = 3
      Caption = 'Playlist Elapsed'
      RadioItem = True
      OnClick = miClockClick
    end
    object miPlaylistRemaining: TACLMenuItem
      Tag = 4
      Caption = 'Playlist Remaining'
      RadioItem = True
      OnClick = miClockClick
    end
    object miLine3: TACLMenuItem
      Caption = '-'
    end
    object miClose: TACLMenuItem
      Tag = -1
      Caption = 'Nothing (Close)'
      RadioItem = True
      OnClick = miCloseClick
    end
  end
  object UI: TACLApplicationController
    DarkMode = True
    Left = 8
    Top = 64
  end
end
