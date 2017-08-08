//****************************************************************
//**                       Zoom Disabler                        **
//**                    (a Notepad++ plugin)                    **
//**                                                            **
//**           Written by Stanislav Eckert, 2014-2015           **
//**         Base plugin template by Damjan Zobo Cvetko         **
//****************************************************************

unit helper_class;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms,
  Vcl.Dialogs, NppForms, Vcl.StdCtrls, shellapi, SciSupport, Vcl.FileCtrl, System.AnsiStrings;

type
  Thelper_class = class
  public
    procedure foregroundTimerOnTimer(Sender: TObject);
    procedure accpc_settings_btnZoomStandardClick(Sender: TObject);
  end;

implementation

uses plugin, helper_functions;

// Note: This is a dirty fix to bring windows with fsStayOnTop flag back to front
// after the main Notepad++ window was activated (for some reason, windows with that
// flag do not stay on top...). It would be better to find a way to react to Notepad++'s
// main window, when it gets de-/activated.
procedure Thelper_class.foregroundTimerOnTimer(Sender: TObject);
var
  hWndForeground: HWND;
  className: array[0..95] of WideChar;
begin
  hWndForeground := GetForegroundWindow();

  if (hWndForeground <> 0) then
  begin
    GetClassNameW(hWndForeground, className, 95);
    if String(className) = 'Notepad++' then
    begin
      // Bring settings window to front if it is opened
      if accpc_settings.Visible then
        accpc_settings.BringToFront();
    end;
  end;
end;

procedure Thelper_class.accpc_settings_btnZoomStandardClick(Sender: TObject);
begin
  accpc_settings_edtZoom.Text := '0';
  accpc_settings_udCZoom.Position := 0;
end;

end.
