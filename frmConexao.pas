unit frmConexao;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, frmModeloDados, Mask, StdCtrls, DB, Buttons, ExtCtrls;

type
  TFormConexao = class(TFormModeloDados)
    Image2: TImage;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    editServidor: TEdit;
    editPorta: TEdit;
    editDatabase: TEdit;
    editUsuario: TEdit;
    editSenha: TEdit;
    procedure btnSalvarClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnFecharClick(Sender: TObject);
  protected
    function validar : Boolean; override;
  private
    { Private declarations }
  public
    { Public declarations }
    host : String;
    port : String;
    database : String;
    user : String;
    password : String;
    validou : Boolean;
  end;

var
  FormConexao: TFormConexao;

implementation

uses frmListagemCriticas;

{$R *.dfm}

procedure TFormConexao.btnFecharClick(Sender: TObject);
begin
  inherited;
  validou := false;
end;

procedure TFormConexao.btnSalvarClick(Sender: TObject);
begin
//  inherited;
  validou := validar;
  if validou then
    begin

      host     := editServidor.Text;
      port     := editPorta.Text;
      database := editDatabase.Text;
      user     := editUsuario.Text;
      password := editSenha.Text;
      Close;
      
    end;

end;

procedure TFormConexao.FormCreate(Sender: TObject);
begin
  inherited;

  host     := '';
  port     := '';
  database := '';
  user     := '';
  password := '';
  validou  := false;

end;

function TFormConexao.validar : Boolean;
var erros : TStringList;
begin

  erros := TStringList.Create;

  if editServidor.Text = '' then
    erros.Add('Servidor não foi informado');

  if editPorta.Text = '' then
    erros.Add('Porta não foi informada');

  if editDatabase.Text = '' then
    erros.Add('Database não foi informado');

  if editUsuario.Text = '' then
    erros.Add('Usuário não foi informado');

  if editSenha.Text = '' then
    erros.Add('Senha não foi informada');

  Result := exibirCriticas(erros);

  erros.Free;

end;

end.
