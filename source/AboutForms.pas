//****************************************************************
//**                       Zoom Disabler                        **
//**                    (a Notepad++ plugin)                    **
//**                                                            **
//**           Written by Stanislav Eckert, 2014-2016           **
//**         Base plugin template by Damjan Zobo Cvetko         **
//****************************************************************

unit AboutForms;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms,
  Vcl.Dialogs, NppForms, Vcl.StdCtrls, shellapi;

type
  TAboutForm = class(TNppForm)
    Button1: TButton;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    procedure Label4Click(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  AboutForm: TAboutForm;

implementation

uses plugin;

{$R *.dfm}

procedure TAboutForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  inherited;
    if Key = VK_ESCAPE then
    begin
      ModalResult := mrOk;
      //Close();
    end;
end;

procedure TAboutForm.Label4Click(Sender: TObject);
var
  emailLabel: TLabel;
begin
  inherited;
  emailLabel := Sender as TLabel;
  ShellExecute(Handle, 'open', PWideChar('mailto:' + emailLabel.Caption + '?subject=Zoom%20Disabler%20plugin%20v' + sAppVersionDisplay + ',%20' + sPlatformBit), nil, nil, SW_SHOW);
end;

end.
