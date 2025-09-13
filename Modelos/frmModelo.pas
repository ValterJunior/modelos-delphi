unit frmModelo;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, Buttons;

type
  TFormModelo = class(TForm)
    imgTop: TImage;
    Image1: TImage;
    btnFechar: TBitBtn;
    lblTitulo: TLabel;
    procedure btnFecharClick(Sender: TObject);
  private
   { Private declarations }
  public
    { Public declarations }
  end;

var
  FormModelo: TFormModelo;

implementation

{$R *.dfm}

procedure TFormModelo.btnFecharClick(Sender: TObject);
begin
  Close;
end;

end.
