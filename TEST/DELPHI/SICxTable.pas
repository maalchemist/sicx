unit SICxTable;

// SICx.DLL test
// table display form

// Copyright © 2000-3000, Andrey A. Meshkov (AL-CHEMIST)
// All rights reserved
//
// http://maalchemist.ru
// http://maalchemist.narod.ru
// maa@maalchemist.ru
// maalchemist@yandex.ru
// maalchemist@gmail.com

{$I version.inc}

interface

uses
  Forms, Classes, Controls, StdCtrls, ExtCtrls,
  {$IFDEF UNICODE} System.Actions, {$ENDIF}
  ActnList;

type
  TSICxTableForm = class(TForm)
    P_Display: TPanel;
    ED_Display: TMemo;
    ActionList: TActionList;
    acClose: TAction;

    procedure acCloseExecute(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  end;

procedure ShowSicTable (const Amsg, ATitle: string);

implementation

{$R *.dfm}

{
}
procedure ShowSicTable (const Amsg, ATitle: string);
var
  VForm : TSICxTableForm;
begin
  VForm := TSICxTableForm.Create (Application);
  VForm.Caption := ATitle;
  VForm.ED_Display.Text := Amsg;
  VForm.Show;
end;

{
}
procedure TSICxTableForm.acCloseExecute (Sender: TObject);
begin
  Close;
end;

{
}
procedure TSICxTableForm.FormClose (Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

end.

