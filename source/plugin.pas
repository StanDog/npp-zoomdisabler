//****************************************************************
//**                       Zoom Disabler                        **
//**                    (a Notepad++ plugin)                    **
//**                                                            **
//**           Written by Stanislav Eckert, 2014-2016           **
//**         Base plugin template by Damjan Zobo Cvetko         **
//****************************************************************

unit plugin;

interface

uses
  NppPlugin, SysUtils, Windows, SciSupport, AboutForms, DockingForms,
  Vcl.Forms, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Controls, shlwapi, helper_class,
  helper_functions, System.WideStrUtils, System.Classes, System.Generics.Collections,
  Vcl.ComCtrls;

type
  TCCCPlugin = class(TNppPlugin)
  public
    helper_class: Thelper_class;
    constructor Create;
    destructor Destroy; override;
    procedure BeforeDestruction; override;
    procedure FuncSettings;
    procedure FuncAbout;
    {procedure DoNppnToolbarModification; override;}
    procedure DoNppnReady; override;
    procedure DoNppnShutdown; override;
    procedure BeNotified(sn: PSCNotification); override;
  end;

procedure _FuncSettings; cdecl;
procedure _FuncAbout; cdecl;

var
  Npp: TCCCPlugin;
  foregroundTimer: TTimer;
  settingsPath: String;
  settingsFile: String;
  settingsCompatibleVersions: System.Generics.Collections.TList<integer>;

  accpc_settings: TForm;
  accpc_settings_btnSave: TButton;
  accpc_settings_btnCancel: TButton;
  accpc_settings_cbDisableMouseZoom: TCheckBox;
  accpc_settings_cbDisableKeyboardZoom: TCheckBox;
  accpc_settings_lblZoom: TLabel;
  accpc_settings_edtZoom: TEdit;
  accpc_settings_udCZoom: TUpDown;
  accpc_settings_btnZoomStandard: TButton;

  bInitialized: Boolean;

  iAppVersion: UINT32;
  sAppVersion: String;
  sAppVersionDisplay: String;
  sPlatformBit: String;

implementation

uses
  Winapi.Messages;

{ TCCCPlugin }

constructor TCCCPlugin.Create;
var
  settingYOffset: Integer;
  settingYPadding: Integer;
  {sk: TShortcutKey;}
begin
  inherited;

  iAppVersion := 1002000;
  sAppVersion := '1002000';
  sAppVersionDisplay := '1.2.0';
{$IFDEF WIN64}
  sPlatformBit := 'Win64';
{$ELSE}
  sPlatformBit := 'Win32';
{$ENDIF}

  // Define compatible settings file versions
  settingsCompatibleVersions := System.Generics.Collections.TList<integer>.Create();
  settingsCompatibleVersions.Add(iAppVersion);
  settingsCompatibleVersions.Add(1001003);
  settingsCompatibleVersions.Add(1001002);
  settingsCompatibleVersions.Add(1001001);
  settingsCompatibleVersions.Add(1001000);

  bInitialized := false;

  //****************************************************************
  //**                    Setup some variables                    **
  //****************************************************************
  self.PluginName := 'Zoom Disabler';

  //****************************************************************
  //**                 Create menu entries in NPP                 **
  //****************************************************************
  {sk.IsCtrl := true; sk.IsAlt := true; sk.IsShift := false;
  sk.Key := #118; // CTRL ALT SHIFT F7
  self.AddFuncItem('Replace ACCPC', _FuncCCC, sk);}

  self.AddFuncItem('Settings', _FuncSettings);
  self.AddFuncItem('---', nil);
  self.AddFuncItem('About...', _FuncAbout);

  //****************************************************************
  //**                    Create settings form                    **
  //****************************************************************
  settingYOffset := 16;
  settingYPadding := 8;
  accpc_settings := TForm.Create(nil);
  accpc_settings.Name := 'accpc_settings';
  accpc_settings.BorderStyle := bsDialog;
  accpc_settings.BorderIcons := [biSystemMenu];
  accpc_settings.Scaled := false;
  accpc_settings.Caption := 'Settings';
  accpc_settings.Position := poScreenCenter;
  accpc_settings.KeyPreview := true;
  accpc_settings.ClientWidth := 320;
  accpc_settings.ClientHeight := 103;
  //accpc_settings.OnKeyDown := self.helper_class.popupFormKeyDown;

  // Create checkbox
  accpc_settings_cbDisableMouseZoom := TCheckBox.Create(accpc_settings);
  accpc_settings_cbDisableMouseZoom.Parent := accpc_settings;
  accpc_settings_cbDisableMouseZoom.Left := 16;
  accpc_settings_cbDisableMouseZoom.Top := settingYOffset;
  accpc_settings_cbDisableMouseZoom.Width := 290;
  accpc_settings_cbDisableMouseZoom.Caption := 'Disable mouse zoom';
  accpc_settings_cbDisableMouseZoom.Checked := true;
  Inc(settingYOffset, accpc_settings_cbDisableMouseZoom.Height + settingYPadding);

  // Create checkbox
  accpc_settings_cbDisableKeyboardZoom := TCheckBox.Create(accpc_settings);
  accpc_settings_cbDisableKeyboardZoom.Parent := accpc_settings;
  accpc_settings_cbDisableKeyboardZoom.Left := 16;
  accpc_settings_cbDisableKeyboardZoom.Top := settingYOffset;
  accpc_settings_cbDisableKeyboardZoom.Width := 290;
  accpc_settings_cbDisableKeyboardZoom.Caption := 'Disable keyboard zoom';
  accpc_settings_cbDisableKeyboardZoom.Checked := false;
  Inc(settingYOffset, accpc_settings_cbDisableKeyboardZoom.Height + settingYPadding);

  // Create zoom label
  accpc_settings_lblZoom := TLabel.Create(accpc_settings);
  accpc_settings_lblZoom.Parent := accpc_settings;
  accpc_settings_lblZoom.Left := 16;
  accpc_settings_lblZoom.Top := settingYOffset;
  accpc_settings_lblZoom.Caption := 'Zoom:';

  // Create zoom edit
  accpc_settings_edtZoom := TEdit.Create(accpc_settings);
  accpc_settings_edtZoom.Parent := accpc_settings;
  accpc_settings_edtZoom.Left := accpc_settings_lblZoom.Left + accpc_settings_lblZoom.Width + 24;
  accpc_settings_edtZoom.Top := settingYOffset - 2;
  accpc_settings_edtZoom.Width := 33;
  accpc_settings_edtZoom.ReadOnly := True;
  accpc_settings_edtZoom.Text := '0';
  accpc_settings_edtZoom.Alignment := taCenter;

  // Create zoom changer
  accpc_settings_udCZoom := TUpDown.Create(accpc_settings);
  accpc_settings_udCZoom.Parent := accpc_settings;
  accpc_settings_udCZoom.Top := accpc_settings_edtZoom.Top;
  accpc_settings_udCZoom.Left := accpc_settings_edtZoom.Left + accpc_settings_edtZoom.Width;
  accpc_settings_udCZoom.Height := accpc_settings_edtZoom.Height;
  accpc_settings_udCZoom.Min := -8;
  accpc_settings_udCZoom.Max := 20;
  accpc_settings_udCZoom.Associate := accpc_settings_edtZoom;
  accpc_settings_udCZoom.Position := 0;

  // Create button to set default zoom value
  accpc_settings_btnZoomStandard := TButton.Create(accpc_settings);
  accpc_settings_btnZoomStandard.Parent := accpc_settings;
  accpc_settings_btnZoomStandard.Font.Size := 7;
  accpc_settings_btnZoomStandard.Top := accpc_settings_udCZoom.Top;
  accpc_settings_btnZoomStandard.Left := accpc_settings_udCZoom.Left + accpc_settings_udCZoom.Width + 15;
  accpc_settings_btnZoomStandard.Height := accpc_settings_udCZoom.Height;
  accpc_settings_btnZoomStandard.Caption := 'default zoom';
  accpc_settings_btnZoomStandard.OnClick := self.helper_class.accpc_settings_btnZoomStandardClick;
  Inc(settingYOffset, accpc_settings_lblZoom.Height + settingYPadding + 8);

  // Create save button
  accpc_settings_btnSave := TButton.Create(accpc_settings);
  accpc_settings_btnSave.Parent := accpc_settings;
  accpc_settings_btnSave.Left := 79;
  accpc_settings_btnSave.Top := settingYOffset;
  accpc_settings_btnSave.Height := 23;
  accpc_settings_btnSave.Caption := 'Save';
  accpc_settings_btnSave.ModalResult := mrOk;

  // Create cancel button
  accpc_settings_btnCancel := TButton.Create(accpc_settings);
  accpc_settings_btnCancel.Parent := accpc_settings;
  accpc_settings_btnCancel.Left := 167;
  accpc_settings_btnCancel.Top := settingYOffset;
  accpc_settings_btnCancel.Height := 23;
  accpc_settings_btnCancel.Caption := 'Cancel';
  accpc_settings_btnCancel.ModalResult := mrCancel;
  Inc(settingYOffset, accpc_settings_btnSave.Height + settingYPadding);

  // Update settings window's height
  accpc_settings.ClientHeight := settingYOffset;

  //****************************************************************
  //**         Create timer to set windows to foreground          **
  //**             (this is a bug which puts N++ over             **
  //**              our windows which stays on top)               **
  //****************************************************************
  foregroundTimer := TTimer.Create(nil);
  foregroundTimer.Interval := 100;
  foregroundTimer.OnTimer := self.helper_class.foregroundTimerOnTimer;
end;

destructor TCCCPlugin.Destroy;
begin
  // Delete timers first
  if Assigned(foregroundTimer) then
  begin
    foregroundTimer.Enabled := false;
    FreeAndNil(foregroundTimer);
  end;

  if Assigned(settingsCompatibleVersions) then
  begin
    settingsCompatibleVersions.Free();
    settingsCompatibleVersions := nil;
  end;

  // Delete settings form
  if Assigned(accpc_settings) then
  begin
    FreeAndNil(accpc_settings_btnSave);
    FreeAndNil(accpc_settings_btnCancel);
    FreeAndNil(accpc_settings_cbDisableMouseZoom);
    FreeAndNil(accpc_settings_cbDisableKeyboardZoom);
    FreeAndNil(accpc_settings_lblZoom);
    FreeAndNil(accpc_settings_edtZoom);
    FreeAndNil(accpc_settings_udCZoom);
    FreeAndNil(accpc_settings_btnZoomStandard);

    FreeAndNil(accpc_settings);  // Must be deleted after the other components has been deleted
  end;

  // Delete helper function class
  if Assigned(helper_class) then
  begin
    FreeAndNil(helper_class);
  end;

  bInitialized := false;

  inherited;
end;

procedure TCCCPlugin.DoNppnShutdown;
begin
  // Save settings
  try
    WritePrivateProfileString('settings', 'version', PWideChar(sAppVersion), PWideChar(settingsPath + settingsFile));
    WritePrivateProfileString('settings', 'DisableMouseZoom', PWideChar(String(iif(accpc_settings_cbDisableMouseZoom.Checked, '1', '0'))), PWideChar(settingsPath + settingsFile));
    WritePrivateProfileString('settings', 'DisableKeyboardZoom', PWideChar(String(iif(accpc_settings_cbDisableKeyboardZoom.Checked, '1', '0'))), PWideChar(settingsPath + settingsFile));
    WritePrivateProfileString('settings', 'zoom', PWideChar(accpc_settings_edtZoom.Text), PWideChar(settingsPath + settingsFile));
  except
  end;

  bInitialized := false;

  inherited;
end;

procedure TCCCPlugin.BeNotified(sn: PSCNotification);
var
  hCurrentEditView: HWND;
  disallowZoom: Boolean;
  iZoom: Integer;
  key_control: Short;
  key_add: Short;
  key_subtract: Short;
  key_divide: Short;
begin
  inherited;

  if
  (
    (bInitialized) and
    (sn^.nmhdr.code = SCN_ZOOM) and
    (
      (accpc_settings_cbDisableMouseZoom.Checked) or
      (accpc_settings_cbDisableKeyboardZoom.Checked)
    )
  )
  then
  begin
    hCurrentEditView := self.GetCurrentScintilla();

    if (HWND(sn^.nmhdr.hwndFrom) = hCurrentEditView) then
    begin
      disallowZoom := false;

      // Scintilla does not seem to capture / forward all keys. Keys like [control] or [left arrow]
      // cannot be intercepted here. VK_ADD, VK_SUBSTRACT and VK_DEVIDE can be intercepted if they
      // are used alone but not if in combination with VK_CONTROL. So we use GetAsynchKeyState() as
      // a dirty trick to get the key state of the keyboard hardware from the system pool.
      key_control  := GetAsyncKeyState(VK_CONTROL);
      key_add      := GetAsyncKeyState(VK_ADD);
      key_subtract := GetAsyncKeyState(VK_SUBTRACT);
      key_divide   := GetAsyncKeyState(VK_DIVIDE);

      // Disable mouse zoom?
      if
      (
        (accpc_settings_cbDisableMouseZoom.Checked) and
        (key_control and $FFFFFFFF <> 0) and
        (key_add and $FFFFFFFF = 0) and
        (key_subtract and $FFFFFFFF = 0) and
        (key_divide and $FFFFFFFF = 0)
      )
      then
      begin
        disallowZoom := true;
      end;

      // Disable keyboard zoom?
      if
      (
        (accpc_settings_cbDisableKeyboardZoom.Checked) and
        (key_control and $FFFFFFFF <> 0) and
        (
          (key_add and $FFFFFFFF <> 0) or
          (key_subtract and $FFFFFFFF <> 0) or
          (key_divide and $FFFFFFFF <> 0)
        )
      )
      then
      begin
        disallowZoom := true;
      end;

      // Disable zoom
      if (disallowZoom) then
      begin
        iZoom := SendMessage(hCurrentEditView, SCI_GETZOOM, 0, 0);
        if (iZoom <> accpc_settings_udCZoom.Position) then
        begin
          SendMessage(hCurrentEditView, SCI_SETZOOM, accpc_settings_udCZoom.Position, 0);
        end;
      end;
    end;
  end;
end;

procedure TCCCPlugin.BeforeDestruction;
begin
  bInitialized := false;

  inherited;
end;

procedure _FuncSettings; cdecl;
begin
  Npp.FuncSettings;
end;
procedure _FuncAbout; cdecl;
begin
  Npp.FuncAbout;
end;

procedure TCCCPlugin.FuncSettings;
Const
  settingsStringSize = 1024;
var
  iOKLoad: Integer;
  settingsVersion: UINT32;
  settingStringValue: String;
  settingIntegerValue: Integer;
  hCurrentEditView: HWND;
begin
  // Save settings if save button clicked
  if (accpc_settings.ShowModal() = mrOk) then
  begin
    WritePrivateProfileString('settings', 'version', PWideChar(sAppVersion), PWideChar(settingsPath + settingsFile));
    WritePrivateProfileString('settings', 'DisableMouseZoom', PWideChar(String(iif(accpc_settings_cbDisableMouseZoom.Checked, '1', '0'))), PWideChar(settingsPath + settingsFile));
    WritePrivateProfileString('settings', 'DisableKeyboardZoom', PWideChar(String(iif(accpc_settings_cbDisableKeyboardZoom.Checked, '1', '0'))), PWideChar(settingsPath + settingsFile));
    WritePrivateProfileString('settings', 'zoom', PWideChar(accpc_settings_edtZoom.Text), PWideChar(settingsPath + settingsFile));

    // Update zoom in Scintilla when setting changed
    hCurrentEditView := self.GetCurrentScintilla();
    SendMessage(hCurrentEditView, SCI_SETZOOM, accpc_settings_udCZoom.Position, 0);
  end
  else
  begin
    // Re-load settings
    iOKLoad := IDYES;
    settingsVersion := GetPrivateProfileInt('settings', 'version', iAppVersion, PWideChar(settingsPath + settingsFile));
    if not settingsCompatibleVersions.Contains(settingsVersion) then
    begin
      iOKLoad := Application.MessageBox('Settings file seems to be incompatible.'+ #10 +'Loading it may mess things up.'+ #10#10 +'Do you want to try to load it?', PWideChar(self.PluginName + ' - Loading configuration file'), 4+48);
    end;

    if (iOKLoad = IDYES) then
    begin
      accpc_settings_cbDisableMouseZoom.Checked := Boolean(GetPrivateProfileInt('settings', 'DisableMouseZoom', 1, PWideChar(settingsPath + settingsFile)));
      accpc_settings_cbDisableKeyboardZoom.Checked := Boolean(GetPrivateProfileInt('settings', 'DisableKeyboardZoom', 0, PWideChar(settingsPath + settingsFile)));
      settingIntegerValue := GetPrivateProfileInt('settings', 'zoom', 0, PWideChar(settingsPath + settingsFile));
      if (settingIntegerValue < -8) then
      begin
        settingIntegerValue := -8;
      end
      else if (settingIntegerValue > 20) then
      begin
        settingIntegerValue := 20;
      end;
      accpc_settings_edtZoom.Text := IntToStr(settingIntegerValue);
      accpc_settings_udCZoom.Position := settingIntegerValue;
    end;
  end;
end;

procedure TCCCPlugin.FuncAbout;
var
  a: TAboutForm;
begin
  a := TAboutForm.Create(self);
  a.Label2.Caption := 'Version '+ sAppVersionDisplay +' ('+ sPlatformBit +', Unicode) for Notepad++';
  a.ShowModal;
  a.Free;
end;

procedure TCCCPlugin.DoNppnReady;
Const
  settingsStringSize = 1024;
var
  iOKLoad: Integer;
  settingsVersion: UINT32;
  settingStringValue: String;
  settingIntegerValue: Integer;
begin
  bInitialized := true;

  // Get path for configuration & other files
  settingsFile := 'zoom_disabler.ini';
  settingsPath := self.GetPluginsConfigDir();

  if not DirectoryExists(settingsPath) then
  begin
    ForceDirectories(settingsPath);
  end;
  settingsPath := IncludeTrailingPathDelimiter(settingsPath);

  // Pre-load settings
  iOKLoad := IDYES;
  settingsVersion := GetPrivateProfileInt('settings', 'version', iAppVersion, PWideChar(settingsPath + settingsFile));
  if not settingsCompatibleVersions.Contains(settingsVersion) then
  begin
    iOKLoad := Application.MessageBox('Settings file seems to be incompatible.' + #10 + 'Loading it may mess things up.'+ #10#10 +'Do you want to try to load it?', PWideChar(self.PluginName + ' - Loading configuration file'), 4+48);
  end;

  if (iOKLoad = IDYES) then
  begin
    Application.ProcessMessages();  // Without this the next following objects's attribute (ClientWidth) is not set correctly for some reason (14 is substracted from the loaded value on my system - it might be the width of a window border * 2 => find out)
    accpc_settings_cbDisableMouseZoom.Checked := Boolean(GetPrivateProfileInt('settings', 'DisableMouseZoom', 1, PWideChar(settingsPath + settingsFile)));
    accpc_settings_cbDisableKeyboardZoom.Checked := Boolean(GetPrivateProfileInt('settings', 'DisableKeyboardZoom', 0, PWideChar(settingsPath + settingsFile)));
    settingIntegerValue := GetPrivateProfileInt('settings', 'zoom', 0, PWideChar(settingsPath + settingsFile));
    if (settingIntegerValue < -8) then
    begin
      settingIntegerValue := -8;
    end
    else if (settingIntegerValue > 20) then
    begin
      settingIntegerValue := 20;
    end;
    accpc_settings_edtZoom.Text := IntToStr(settingIntegerValue);
    accpc_settings_udCZoom.Position := settingIntegerValue;
  end;
end;

initialization
  Npp := TCCCPlugin.Create;
end.
