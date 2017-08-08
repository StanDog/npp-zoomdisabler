//****************************************************************
//**                       Zoom Disabler                        **
//**                    (a Notepad++ plugin)                    **
//**                                                            **
//**           Written by Stanislav Eckert, 2014-2016           **
//**         Base plugin template by Damjan Zobo Cvetko         **
//****************************************************************

library zoomdisabler;

{ Important note about DLL memory management: ShareMem must be the
  first unit in your library's USES clause AND your project's (select
  Project-View Source) USES clause if your DLL exports any procedures or
  functions that pass strings as parameters or function results. This
  applies to all strings passed to and from your DLL--even those that
  are nested in records and classes. ShareMem is the interface unit to
  the BORLNDMM.DLL shared memory manager, which must be deployed along
  with your DLL. To avoid using BORLNDMM.DLL, pass string information
  using PChar or ShortString parameters. }

uses
  SysUtils,
  Classes,
  Types,
  Windows,
  Messages,
  helper_functions in 'helper_functions.pas',
  nppplugin in 'lib\nppplugin.pas',
  SciSupport in 'lib\SciSupport.pas',
  NppForms in 'lib\NppForms.pas' {NppForm},
  NppDockingForms in 'lib\NppDockingForms.pas' {NppDockingForm},
  plugin in 'plugin.pas',
  AboutForms in 'AboutForms.pas' {AboutForm},
  dockingforms in 'dockingforms.pas' {CCCDockingForm},
  helper_class in 'helper_class.pas';

{$R *.res}

{$Include 'lib\NppPluginInclude.pas'}

begin
  { First, assign the procedure to the DLLProc variable }
  DllProc := @DLLEntryPoint;
  { Now invoke the procedure to reflect that the DLL is attaching to the process }
  DLLEntryPoint(DLL_PROCESS_ATTACH);
end.
