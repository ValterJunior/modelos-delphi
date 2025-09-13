unit uEnviarEmail;

interface

uses Windows, Classes, IdMessage, IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient,
     IdExplicitTLSClientServerBase, IdMessageClient, IdSMTPBase, IdSMTP, IdEMailAddress,
     IdIOHandler, IdIOHandlerSocket, IdIOHandlerStack, IdSSL,
  IdSSLOpenSSL, IdAttachmentFile, sysUtils, WinInet;

type

  TEnviarEmail = class
  private
    function IsConnected: Boolean;

    protected
      fUsuario : String;
      fSenha : String;
      fServidor : String;
      fPorta : String;
      fNomeRemetente : String;
      fEndRemetente : String;
      fAssunto : String;
      fCorpo : String;
      fUtilizaSSL : Boolean;
      fAutenticar : Boolean;
      fUtilizaTLS : Boolean;
      fTimeOut : Integer;
      aAnexos : TStringList;
      aDestinatarios : TStringList;
      aNomesDestinatarios : TStringList;
      smtp : TIDSmtp;
      msg : TIDMessage;
    public
      procedure setUsuario( usuario : String );
      procedure setSenha( senha : String );
      procedure setServidor( servidor : String );
      procedure setPorta( porta : String );
      procedure setRemetente( nome, endereco : String );
      procedure setAssunto( assunto : String );
      procedure setCorpo( corpo : String );
      procedure setSSL( utiliza : Boolean );
      procedure setTLS( utiliza : Boolean );
      procedure setAutenticacao( autenticar : Boolean );
      procedure addAnexo( caminho : String );
      procedure addDestinatario( nome, destinatario : String );
      procedure Free;
      function enviar : Boolean;
      constructor Create( timeOut : Integer = 0 );
      destructor Destroy; override;
  end;

implementation

uses uFuncoes;

{ TEnviarEmail }

procedure TEnviarEmail.addAnexo(caminho: String);
begin
  aAnexos.add( caminho );
end;

procedure TEnviarEmail.addDestinatario( nome, destinatario: String);
begin
  aDestinatarios.add( destinatario );
  aNomesDestinatarios.add( nome );
end;

constructor TEnviarEmail.Create( timeOut : Integer = 0 );
begin

  if timeOut = 0 then
    fTimeOut := 10000
  else
    fTimeOut := timeOut;

  aDestinatarios      := TStringList.Create;
  aNomesDestinatarios := TStringList.Create;
  aAnexos             := TStringList.Create;

  fUtilizaSSL := false;
  fUtilizaTLS := false;
  fAutenticar := false;

end;

destructor TEnviarEmail.Destroy;
begin

  aDestinatarios.free;
  aNomesDestinatarios.free;
  aAnexos.free;

end;

function TEnviarEmail.enviar: Boolean;
var endereco : TIdEMailAddressItem;
    sslSocket : TIdSSLIOHandlerSocketOpenSSL;
    anexo : TIdAttachmentFile;
  i: Integer;
begin

  Result := false;

  if not IsConnected then
    begin
      mensagemErro('Sem conexão com a internet');
      Result := false;
      exit;
    end;

  smtp      := TIDSmtp.Create(nil);
  msg       := TIDMessage.Create(nil);

  // Se utiliza conexao SSL (gmail)
  if fUtilizaSSL then
    begin

      sslSocket := TIdSSLIOHandlerSocketOpenSSL.Create(nil);

      try

        sslSocket.SSLOptions.Method := sslvTLSv1;
        sslSocket.SSLOptions.Mode := sslmClient;
        sslSocket.SSLOptions.VerifyMode := [];
        sslSocket.SSLOptions.VerifyDepth := 0;

        smtp.IOHandler := sslSocket;

        if fUtilizaTLS then
          smtp.UseTLS := utUseImplicitTLS;

      except on E: Exception do
        begin

          smtp.IOHandler := TIdIOHandler.MakeDefaultIOHandler( nil );

          if fUtilizaTLS then
            smtp.UseTLS := utNoTLSSupport;

        end;

    end;

  try

    with smtp do
      begin

        // Passando parametros de conexao!
        Host           := fServidor;
        Port           := strToInt( fPorta );
        ConnectTimeout := fTimeOut;
        ReadTimeout    := fTimeOut;

        AuthType := satDefault;

        if fAutenticar then
          begin
            Username := fUsuario;
            Password := fSenha;
          end;

        if not connected then
          Connect;

        if fAutenticar then
          smtp.Authenticate;

        Result := connected;

      end;

    if Result then
      begin

        try

          with msg do
            begin

              // Preparando email
              From.Name :=  fNomeRemetente;
              From.Address := fEndRemetente;
              Subject   := fAssunto;
              Body.SetText(Pchar(fCorpo));
              Priority := mpHighest;

              // Adicionando destinatários
              for i := 0 to aDestinatarios.Count - 1 do
                begin

                  endereco         := Recipients.Add;
                  endereco.Name    := aNomesDestinatarios[i];
                  endereco.Address := aDestinatarios[i];

                end;

              // Adicionando anexos
              for i := 0 to aAnexos.Count - 1 do
                begin

                  if fileExists( aAnexos.Strings[i] ) then
                    begin

                      try

                        anexo := TIdAttachmentFile.Create( msg.MessageParts, aAnexos.Strings[i] );
                        anexo.ContentType        :=  'application/pdf;' + 'name=' + extractFileName( aAnexos.Strings[i] );
                        anexo.ContentDescription := 'Arquivo Anexo: ' + extractFileName( aAnexos.Strings[i] );

                      except
                        mensagemErro('Erro ao tentar anexar arquivo ' +  aAnexos.Strings[i] );
                      end;

                    end;

                end;

              // Enviando email
              if smtp.connected then
                smtp.send( msg );

            end;

        finally
          smtp.Disconnect;
        end;

      end;

  finally

    msg.free;
    smtp.free;
    sslSocket.Free;

  end;
    end;

end;

procedure TEnviarEmail.Free;
begin
  destroy;
end;

procedure TEnviarEmail.setAssunto(assunto: String);
begin
  fAssunto := assunto;
end;

procedure TEnviarEmail.setAutenticacao(autenticar: Boolean);
begin
  fAutenticar := autenticar;
end;

procedure TEnviarEmail.setCorpo(corpo: String);
begin
  fCorpo := corpo;
end;

procedure TEnviarEmail.setPorta(porta: String);
begin
  fPorta := porta;
end;

procedure TEnviarEmail.setRemetente( nome, endereco : String);
begin
  fNomeRemetente := nome;
  fEndRemetente := endereco;
end;

procedure TEnviarEmail.setSenha(senha: String);
begin
  fSenha := senha;
end;

procedure TEnviarEmail.setServidor(servidor: String);
begin
  fServidor := servidor;
end;

procedure TEnviarEmail.setSSL(utiliza: Boolean);
begin
  fUtilizaSSL := utiliza;
end;

procedure TEnviarEmail.setTLS(utiliza: Boolean);
begin
  fUtilizaTLS := utiliza;
end;

procedure TEnviarEmail.setUsuario(usuario: String);
begin
  fUsuario := usuario;
end;

function TEnviarEmail.IsConnected: Boolean;
const
  INTERNET_CONNECTION_MODEM = 1;
  INTERNET_CONNECTION_LAN = 2;
  INTERNET_CONNECTION_PROXY = 4;
  INTERNET_CONNECTION_MODEM_BUSY = 8;
var
  dwConnectionTypes : DWORD;
begin
  dwConnectionTypes := INTERNET_CONNECTION_MODEM + INTERNET_CONNECTION_LAN + INTERNET_CONNECTION_PROXY;
  If InternetGetConnectedState(@dwConnectionTypes,0) then
    Result := True
  else
    Result := False;
end;

end.
