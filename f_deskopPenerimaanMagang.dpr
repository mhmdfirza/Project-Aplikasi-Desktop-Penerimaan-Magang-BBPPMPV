program f_deskopPenerimaanMagang;

uses
  Vcl.Forms,
  f_desktopPenerimaanMagang in 'f_desktopPenerimaanMagang.pas' {landingPage},
  myDataModule in 'myDataModule.pas' {DataModule3: TDataModule};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TlandingPage, landingPage);
  Application.CreateForm(TDataModule3, DataModule3);
  Application.Run;
end.
