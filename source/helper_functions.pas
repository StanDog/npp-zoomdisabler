//****************************************************************
//**                       Zoom Disabler                        **
//**                    (a Notepad++ plugin)                    **
//**                                                            **
//**           Written by Stanislav Eckert, 2014-2015           **
//**         Base plugin template by Damjan Zobo Cvetko         **
//****************************************************************

unit helper_functions;

interface

uses
  SysUtils, System.Generics.Collections, Vcl.Graphics, Windows;

function iif(Test: boolean; TrueR, FalseR: variant): variant;

implementation

uses
  plugin;

function iif(Test: boolean; TrueR, FalseR: variant): variant;
begin
 if Test then
  Result := TrueR
 else
  Result := FalseR;
end;

end.
