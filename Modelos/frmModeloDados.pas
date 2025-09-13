unit frmModeloDados;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, frmModelo, StdCtrls, Buttons, ExtCtrls, DB, ADODB;

type
  TFormModeloDados = class(TFormModelo)
    btnSalvar: TBitBtn;
    DataSource1: TDataSource;
    procedure btnSalvarClick(Sender: TObject);
    procedure btnFecharClick(Sender: TObject);
  protected
    procedure salvar; virtual;
    procedure setup; virtual;
    function validar : Boolean; virtual;
  private
    { Private declarations }
  public
  end;

var
  FormModeloDados: TFormModeloDados;

implementation

uses frmListagemCriticas;

{$R *.dfm}

procedure TFormModeloDados.btnFecharClick(Sender: TObject);
begin
  inherited;

  if DataSource1.DataSet <> nil then
    if DataSource1.DataSet.State in [dsInsert,dsEdit] then
      DataSource1.DataSet.Cancel;

end;

procedure TFormModeloDados.btnSalvarClick(Sender: TObject);
begin
  inherited;

  if validar then
    begin

      salvar;

      if DataSource1.DataSet.State in [dsInsert,dsEdit] then
        DataSource1.DataSet.Post;

      setup;
      Close;

    end;

end;

procedure TFormModeloDados.salvar;
begin
// Abstract
end;

procedure TFormModeloDados.setup;
begin
// Abstract
end;

function TFormModeloDados.validar: Boolean;
begin
// Abstract
Result := true;
end;

end.
