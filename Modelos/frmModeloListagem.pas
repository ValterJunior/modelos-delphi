unit frmModeloListagem;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, frmModelo, Grids, DBGrids, StdCtrls, Buttons, ExtCtrls, DB, ADODB,
  frmModeloDados, frmModeloImpressao, IniFiles;

type
  TFormModeloListagem = class(TFormModelo)
    GroupBox1: TGroupBox;
    dbgListagem: TDBGrid;
    GroupBox3: TGroupBox;
    btnIncluir: TBitBtn;
    btnAlterar: TBitBtn;
    btnExcluir: TBitBtn;
    Edit1: TEdit;
    ADOQuery1: TADOQuery;
    DataSource1: TDataSource;
    btnSelecionar: TBitBtn;
    btnImprimir: TBitBtn;
    procedure btnFecharClick(Sender: TObject);
    procedure DataSource1DataChange(Sender: TObject; Field: TField);
    procedure btnExcluirClick(Sender: TObject);
    procedure dbgListagemDblClick(Sender: TObject);
    procedure btnSelecionarClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Edit1Change(Sender: TObject);
    procedure btnIncluirClick(Sender: TObject);
    procedure btnAlterarClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  protected
    classeCadastro : TComponentClass;
    objetoCadastro : TFormModeloDados;
    cSelect  : String;
    cJoin    : String;
    cWhere   : String;
    cOrderBy : String;
    lSelecionado : Boolean;
    procedure addJanelaCadastro( classe : TComponentClass; objeto : TFormModeloDados );
    procedure addQuery( select : String; joins : String = ''; where : String = ''; orderBy : String = '' );
    procedure startQuery( cFilter : String = '' );
  private
    { Private declarations }
    arquivoMem : String;
    procedure salvarUltimaPesquisa;
    procedure carregarUltimaPesquisa;
    function getAlias(field: String): String;
  public
    { Public declarations }
    lSelecionar : Boolean;
    lSalvarPesquisa : Boolean;
    function ShowPesquisa( campoChave : String; var valorChave : Variant; campoAux : String; var retornoAux : Variant; tela : Boolean = true ) : Boolean;
  end;

var
  FormModeloListagem: TFormModeloListagem;

const MEM_SESSAO = 'VARIAVEL';
      MEM_IDENT  = 'SAVE';

implementation

uses uDM, uFuncoes;

{$R *.dfm}

procedure TFormModeloListagem.addJanelaCadastro(classe: TComponentClass; objeto: TFormModeloDados);
begin

  classeCadastro := classe;
  objetoCadastro := objeto;

end;

procedure TFormModeloListagem.addQuery( select : String; joins : String = ''; where : String = ''; orderBy : String = '' );

begin

  cSelect  := select;
  cJoin    := joins;
  cWhere   := where;
  cOrderBy := orderBy;

  startQuery;

end;

procedure TFormModeloListagem.btnAlterarClick(Sender: TObject);
begin
  inherited;

  ADOQuery1.Edit;
  Application.CreateForm( classeCadastro, objetoCadastro );

  try

    objetoCadastro.DataSource1.DataSet := ADOQuery1;
    objetoCadastro.ShowModal;

    ADOQuery1.Requery;

  finally

    objetoCadastro.Free;

  end;

end;

procedure TFormModeloListagem.btnExcluirClick(Sender: TObject);
begin
  inherited;

  if mensagemConfirmacao( 'Deseja realmente excluir o registro?' ) then
    ADOQuery1.Delete;

end;

procedure TFormModeloListagem.btnFecharClick(Sender: TObject);
begin
  inherited;
  Close;
end;

procedure TFormModeloListagem.btnIncluirClick(Sender: TObject);
begin
  inherited;

  ADOQuery1.Append;

  Application.CreateForm( classeCadastro, objetoCadastro );

  try

    objetoCadastro.DataSource1.DataSet := ADOQuery1;
    objetoCadastro.ShowModal;

    ADOQuery1.Requery;

  finally

    objetoCadastro.Free;

  end;

end;

procedure TFormModeloListagem.btnSelecionarClick(Sender: TObject);
begin
  inherited;
  lSelecionado := true;
  Close;
end;

procedure TFormModeloListagem.carregarUltimaPesquisa;
var memFile : TIniFile;
    pesquisa : String;
begin

  pesquisa := '';

  if FileExists( arquivoMem ) then
    begin

      memFile := TIniFile.Create(arquivoMem);
      pesquisa := memFile.ReadString( MEM_SESSAO, MEM_IDENT, pesquisa );
      memFile.Free;

    end;

  if pesquisa <> '' then
    begin
      Edit1.Text := pesquisa;
      Edit1Change(Self);
    end;

end;

procedure TFormModeloListagem.DataSource1DataChange(Sender: TObject;
  Field: TField);
begin
  inherited;

  btnAlterar.Enabled  := ( ADOQuery1.RecordCount > 0 );
  btnExcluir.Enabled  := ( ADOQuery1.RecordCount > 0 );
  btnImprimir.Enabled := ( ADOQuery1.RecordCount > 0 );

end;

procedure TFormModeloListagem.dbgListagemDblClick(Sender: TObject);
begin
  inherited;

  if ADOQuery1.RecordCount > 0 then
    if lSelecionar then
      btnSelecionar.Click
    else
      btnAlterar.Click;
    
end;

procedure TFormModeloListagem.Edit1Change(Sender: TObject);
var
  i: Integer;
  field, alias : String;
  achou : Boolean;
begin
  inherited;

  // Filtrando qualquer coisa no grid

  achou := false;

  if Edit1.Text = EmptyStr then
    begin
      startQuery;
      exit;
    end;   

  for i := 0 to dbgListagem.Columns.Count - 1 do
    begin

      field := dbgListagem.Columns.Items[i].FieldName;

      if ADOQuery1.AggFields.FindField( field ) = nil then // Não pesquiso em campos agregados
        begin

          if field <> EmptyStr then
            begin

              alias := getAlias( field );

              startQuery( alias + field + ' like ' + quotedStr( Edit1.Text + '%' ) );

              if ADOQuery1.RecordCount > 0 then
                begin
                  achou := true;
                  break;
                end;

            end;

        end;

    end;

  if not achou then
    startQuery;

end;

procedure TFormModeloListagem.FormCreate(Sender: TObject);
begin
  inherited;

  lSelecionado    := false;
  lSalvarPesquisa := false;
  arquivoMem      := ExtractFilePath( Application.ExeName ) + Self.Name + '.mem';

end;

procedure TFormModeloListagem.FormDestroy(Sender: TObject);
begin
  inherited;

  if ADOQuery1.Active then
    ADOQuery1.Close;

  if lSalvarPesquisa then
    salvarUltimaPesquisa;

end;

procedure TFormModeloListagem.FormShow(Sender: TObject);
begin
  inherited;

  btnSelecionar.Visible := lSelecionar;
  carregarUltimaPesquisa;

end;
procedure TFormModeloListagem.salvarUltimaPesquisa;
var memFile : TIniFile;
begin

  memFile := TIniFile.Create(arquivoMem);
  memFile.WriteString( MEM_SESSAO, MEM_IDENT, Edit1.Text );
  memFile.Free;

end;

function TFormModeloListagem.ShowPesquisa(campoChave: String; var valorChave: Variant; campoAux: String; var retornoAux: Variant; tela: Boolean): Boolean;
begin

  if tela then
    begin

      lSelecionar     := true;
      lSalvarPesquisa := true;
      ShowModal;

      Result     := lSelecionado;
      valorChave := DataSource1.DataSet.FieldByName(campoChave).AsVariant;

    end
  else
    begin

      Result := DataSource1.DataSet.Locate(campoChave, valorChave, [] );

      lSalvarPesquisa := false;

      if Result then
        valorChave := DataSource1.DataSet.FieldByName(campoChave).AsVariant;

    end;

  if campoAux <> '' then
    retornoAux := DataSource1.DataSet.FieldByName(campoAux).AsVariant;

end;

procedure TFormModeloListagem.startQuery( cFilter : String = '' );
begin

  try

    ADOQuery1.DisableControls;
    ADOQuery1.Close;
    ADOQuery1.SQL.Clear;
    ADOQuery1.SQL.Add(cSelect);

    if cJoin <> EmptyStr then
      ADOQuery1.SQL.Add(cJoin);

    if cWhere <> EmptyStr then
      begin

        ADOQuery1.SQL.Add(cWhere);

        if cFilter <> EmptyStr then
          ADOQuery1.SQL.Add( 'and ' + cFilter );

      end
    else
      if cFilter <> EmptyStr then
        ADOQuery1.SQL.Add( 'having ' + cFilter );

    if cOrderBy <> EmptyStr then
      ADOQuery1.SQL.Add(cOrderBy);

    ADOQuery1.Open;
    ADOQuery1.First;
    ADOQuery1.EnableControls;

  except on E:Exception do
    mensagemErro('Não foi posssível executar a query.' + #13 + 'Descrição do erro: ' + E.Message );
  end;

end;

function TFormModeloListagem.getAlias( field : String ) : String;
var
  i, espaco : Integer;
  achou : Boolean;
  alias, campo : String;
begin

  espaco := 0;
  achou  := false;
  alias  := '';
  campo  := '';

  result := '';

  for i := 1 to length( cSelect ) do
    begin

      if achou and ( (cSelect[i] <> '.') and (cSelect[i] <> ',') and (cSelect[i] <> ' ') ) then
        campo := campo + cSelect[i];

      if cSelect[i] = #32 then
        begin

          espaco := i;

          if campo <> '' then
            if campo = field then
              begin
                result := alias;
                exit;
              end;

          achou  := false;
          campo  := '';

        end;

      if cSelect[i] = '.' then
        begin

          if espaco >  0 then
            begin
              alias := copy( cSelect, espaco + 1, i - espaco );
              espaco := 0;
            end;

          achou := true;
          continue;
          
        end;

    end;

  if campo <> '' then
    if campo = field then
      result := alias;

end;

end.
