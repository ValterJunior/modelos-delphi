unit uFuncoes;

interface

  uses ADODB, SysUtils, Forms, Windows, Controls, StrUtils, IniFiles, StdCtrls;

  function conectar( conexao : TADOConnection ) : Boolean;
  function mensagemConfirmacao( cMsg : String ) : Boolean;
  function strZero( valor, qtd : Integer ) : String;
  function GetTempDirectory: String;
  function GetUserFromWindows: string;
  function encryptMySQL( texto : String; conexao : TADOConnection ) : String;
  function getDropForeignKeySQL( conexao : TADOConnection; database, tabela : String ) : String;
  function getVersao: String;
  function getItemCombo( id : Integer; combo : TComboBox ) : Integer;
  function getIdCombo( index : Integer; combo : TComboBox ) : Integer; overload;
  function getIdCombo( combo : TComboBox ) : Integer; overload;
  procedure mensagemErro( cMsg : String );
  procedure mensagemInfo( cMsg : String );
  procedure copyDataSet( queryOrigem : TADOQuery; queryDestino : TADODataSet; copiarDados : Boolean = true );
  procedure addDbColumn( conexao : TADOConnection; database, tabela, column, references : String );
  procedure addDbForeignKey( conexao : TADOConnection; database, tabela, key, tableReference, columnReference : String );
  procedure dropDbColumn( conexao : TADOConnection; database, tabela, coluna : String );
  procedure renameColumn( conexao : TADOConnection; database, tabela, column, newColumn, references : String );

implementation

uses frmConexao;

const 
  c1 = 52845;
  c2 = 22719;

function conectar( conexao : TADOConnection ) : Boolean;
var query : TADOQuery;
    stringConnection, arquivo : String;
    configFile : TIniFile;
    host, port, database, user, pass, sessao : String;
begin

  arquivo := ExtractFilePath(Application.ExeName) + 'config.ini';
  sessao  := 'CONEXAO';

  if not FileExists(arquivo) then
    begin

      Application.CreateForm( TFormConexao, FormConexao );

      FormConexao.ShowModal;

      if FormConexao.validou then
        begin

          host     := FormConexao.host;
          port     := FormConexao.port;
          database := FormConexao.database;
          user     := FormConexao.user;
          pass     := FormConexao.password;

          configFile := TIniFile.Create(arquivo);

          configFile.WriteString(sessao, 'HOST'    , host );
          configFile.WriteString(sessao, 'PORT'    , port );
          configFile.WriteString(sessao, 'DATABASE', database );
          configFile.WriteString(sessao, 'USER'    , user);
          configFile.WriteString(sessao, 'PASSWORD', pass);

          configFile.Free;

        end
      else
        begin
          Result := false;
          Exit;
        end;

      FormConexao.Free;

    end
  else
    begin

      configFile := TIniFile.Create(arquivo);

      host     := configFile.ReadString(sessao, 'HOST'    , host );
      port     := configFile.ReadString(sessao, 'PORT'    , port );
      database := configFile.ReadString(sessao, 'DATABASE', database );
      user     := configFile.ReadString(sessao, 'USER'    , user);
      pass     := configFile.ReadString(sessao, 'PASSWORD', pass);

      configFile.Free;

    end;


  Result := true;
  StringConnection := 'Driver={MySQL ODBC 3.51 Driver};Server=' + host + ';Port=' + port + ';Database=mysql;User=' + user + '; Password=' + pass + ';Option=3;';

  try

    // Conecto ao database default!
    conexao.LoginPrompt      := false;
    conexao.ConnectionString := StringConnection;
    conexao.Connected        := true;


    query := TADOQuery.Create(nil);

    with query do
      begin

        Connection := conexao;
        SQL.Text := 'create database if not exists ' + database;
        ExecSQL;

      end;

    FreeAndNil( query );

    conexao.Connected   := false;
    conexao.LoginPrompt := false;

    StringConnection := 'Driver={MySQL ODBC 3.51 Driver};Server=' + host + ';Port=' + port + ';Database=' + database + ';User=' + user + '; Password=' + pass + ';Option=3;';

    // Conecto ao database do sistema!
    conexao.ConnectionString := StringConnection;
    conexao.Connected        := true;

  except

    mensagemErro( 'Falha ao conectar com o banco de dados' );
    Result := false;
  end;

end;

function mensagemConfirmacao( cMsg : String ) : Boolean;
begin
  Result := (Application.MessageBox( PChar( cMsg ), 'Confirmação', MB_ICONQUESTION + MB_YESNO + MB_DEFBUTTON1 ) = mrYes);
end;

procedure mensagemErro( cMsg : String );
begin
  Application.MessageBox(PChar(cMsg), 'Erro', MB_ICONERROR + MB_OK );
end;

procedure mensagemInfo( cMsg : String );
begin
  Application.MessageBox(PChar(cMsg), 'Informação', MB_ICONINFORMATION + MB_OK );
end;

function strZero( valor, qtd : Integer ) : String;
var i : Integer;
begin

  Result := '';

  qtd := qtd - length( intToStr( valor ) );

  for i := 1 to qtd do
    Result := Result + '0';

  Result := Result + intToStr( valor );
end;

function GetTempDirectory: String;
var
  tempFolder: array[0..MAX_PATH] of Char;
begin
  GetTempPath(MAX_PATH, @tempFolder);
  result := StrPas(tempFolder);
end;

function GetUserFromWindows: string;
var
  buffer: array[0..255] of char;
  size: dword;
begin
  size := 256;
  if GetUserName(buffer, size) then
    Result := buffer
  else
    Result := 'Desconhecido';
end;

function encryptMySQL( texto : String; conexao : TADOConnection ) : String;
var query : TADOQuery;
begin

  query := TADOQuery.Create(nil);

  try

    query.Connection := conexao;
    query.SQL.Text := 'select des_encrypt(' + quotedStr( texto ) + ') as crypt';
    query.Open;
    
    Result := query.FieldByName('crypt').asString;

    query.Close;

  finally
    query.Free;
  end;

end;

procedure copyDataSet( queryOrigem : TADOQuery; queryDestino : TADODataSet; copiarDados : Boolean = true );
var
  i: Integer;
begin

  queryDestino.Fields.Clear;
  queryDestino.FieldDefs.Clear;

  // Copiando estrutura
  for i := 0 to queryOrigem.FieldCount - 1 do
    queryDestino.FieldDefs.Add( queryOrigem.FieldDefList[i].Name, queryOrigem.FieldDefList[i].DataType, queryOrigem.FieldDefList[i].Size, queryOrigem.FieldDefList[i].Required );

  queryDestino.CreateDataSet;
  queryDestino.Open;

  // Copiando dados
  if copiarDados then
    begin

      queryOrigem.First;

      while not queryOrigem.Eof do
        begin

          queryDestino.Append;

          for i := 0 to queryOrigem.FieldCount - 1 do
            queryDestino.FieldByName( queryOrigem.FieldDefList[i].Name ).AsVariant := queryOrigem.FieldByName( queryOrigem.FieldDefList[i].Name ).asVariant;

          queryDestino.Post;

          queryOrigem.Next;

        end;

    end;

  queryOrigem.First;
  queryDestino.First;

end;

function getDropForeignKeySQL( conexao : TADOConnection; database, tabela : String ) : String;
var myQuery : TADOQuery;
begin

  myQuery := TADOQuery.Create(nil);

  myQuery.Connection := conexao;
  myQuery.SQL.Add( 'select concat(''alter ignore table '',table_schema,''.'',table_name,'' DROP FOREIGN KEY '',constraint_name,'';'') as query from information_schema.table_constraints');
  myQuery.SQL.Add( 'where constraint_type=''FOREIGN KEY'' and constraint_schema = ' + quotedStr( database ) + ' and table_schema = ' + QuotedStr( tabela ) + ';');
  myQuery.Open;

  Result := myQuery.FieldByName('query').AsString;

  myQuery.Close;
  myQuery.Free;

end;

procedure addDbColumn( conexao : TADOConnection; database, tabela, column, references : String );
var myQuery : TADOQuery;
begin

  myQuery := TADOQuery.Create(nil);

  myQuery.Connection := conexao;
  myQuery.SQL.Add('select * from information_schema.columns');
  myQuery.SQL.Add('where table_schema = ' + quotedStr( database ) );
  myQuery.SQL.Add('and table_name = ' + quotedStr( tabela ) );
  myQuery.SQL.Add('and column_name = ' + quotedStr( column ) );
  myQuery.Open;

  if myQuery.RecordCount = 0 then
    begin

      myQuery.Close;
      myQuery.SQL.Clear;
      myQuery.SQL.Text := 'alter ignore table ' + database + '.' + tabela + ' add column ' + column + ' ' + references;
      myQuery.ExecSQL;

    end
  else
    myQuery.Close;

  myQuery.Free;
  
end;

procedure renameColumn( conexao : TADOConnection; database, tabela, column, newColumn, references : String );
var myQuery : TADOQuery;
begin

  myQuery := TADOQuery.Create(nil);

  myQuery.Connection := conexao;
  myQuery.SQL.Add('select * from information_schema.columns');
  myQuery.SQL.Add('where table_schema = ' + quotedStr( database ) );
  myQuery.SQL.Add('and table_name = ' + quotedStr( tabela ) );
  myQuery.SQL.Add('and column_name = ' + quotedStr( column ) );
  myQuery.Open;

  if myQuery.RecordCount > 0 then
    begin

      myQuery.Close;
      myQuery.SQL.Clear;
      myQuery.SQL.Text := 'alter ignore table ' + database + '.' + tabela + ' change ' + column + ' ' + newColumn + ' ' + references;
      myQuery.ExecSQL;

    end
  else
    myQuery.Close;

  myQuery.Free;
  
end;


procedure addDbForeignKey( conexao : TADOConnection; database, tabela, key, tableReference, columnReference : String );
var myQuery : TADOQuery;
begin

  myQuery := TADOQuery.Create(nil);

  myQuery.Connection := conexao;
  myQuery.SQL.Add('select * from information_schema.key_column_usage');
  myQuery.SQL.Add('where table_schema = ' + quotedStr( database ) );
  myQuery.SQL.Add('and table_name = ' + quotedStr( tabela ) );
  myQuery.SQL.Add('and column_name = ' + quotedStr( key ) );
  myQuery.Open;

  if myQuery.RecordCount = 0 then
    begin

      myQuery.Close;

      myQuery.SQL.Clear;
      myQuery.SQL.Add('alter ignore table ' + database + '.' + tabela + ' add foreign key(' + key + ') references ' + tableReference + '(' + columnReference + ') on delete cascade');
      myQuery.ExecSQL;

    end
  else
    myQuery.Close;

  myQuery.Free;
    
end;

procedure dropDbColumn( conexao : TADOConnection; database, tabela, coluna : String );
var myQuery : TADOQuery;
begin

  myQuery := TADOQuery.Create(nil);

  myQuery.Connection := conexao;
  myQuery.SQL.Add('select * from information_schema.columns');
  myQuery.SQL.Add('where table_schema = ' + quotedStr( database ) );
  myQuery.SQL.Add('and table_name = ' + quotedStr( tabela ) );
  myQuery.SQL.Add('and column_name = ' + quotedStr( coluna ) );
  myQuery.Open;

  if myQuery.RecordCount > 0 then
    begin

      myQuery.Close;

      myQuery.SQL.Clear;
      myQuery.SQL.Add('alter ignore table ' + database + '.' + tabela + ' drop column ' + coluna );
      myQuery.ExecSQL;

    end
  else
    myQuery.Close;

  myQuery.Free;
    
end;

function getVersao: String;
type
  PFFI = ^vs_FixedFileInfo;
var
  F : PFFI;
  Handle : Dword;
  Len : Longint;
  Data : Pchar;
  Buffer : Pointer;
  Tamanho : Dword;
  Parquivo: Pchar;
  Arquivo : String;
begin

  Arquivo := Application.ExeName;
  Parquivo := StrAlloc(Length(Arquivo) + 1);
  StrPcopy(Parquivo, Arquivo);
  Len := GetFileVersionInfoSize(Parquivo, Handle);
  Result := '';

  if Len > 0 then
    begin
      Data:=StrAlloc(Len+1);

      if GetFileVersionInfo(Parquivo,Handle,Len,Data) then
        begin
          VerQueryValue(Data, '\',Buffer,Tamanho);
          F := PFFI(Buffer);
          Result := Format('%d.%d.%d.%d',
                           [HiWord(F^.dwFileVersionMs),
                            LoWord(F^.dwFileVersionMs),
                            HiWord(F^.dwFileVersionLs),
                            Loword(F^.dwFileVersionLs)]
                    );
        end;

      StrDispose(Data);

    end;

    StrDispose(Parquivo);

end;

function getItemCombo( id : Integer; combo : TComboBox ) : Integer;
var
  i: Integer;
  begin

    result := 0;

    for i := 0 to combo.Items.Count - 1 do
      if Integer( combo.Items.Objects[i] ) = id then
        begin
          result := i;
          exit;
        end;

  end;

function getIdCombo( index : Integer; combo : TComboBox ) : Integer;
begin

  Result := Integer( combo.Items.Objects[index] );

end;

function getIdCombo( combo : TComboBox ) : Integer;
begin
  result := getIdCombo( combo.ItemIndex, combo );
end;

end.
