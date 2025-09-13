unit uCarregaEstrutura;

interface

  uses ADODB, SysUtils;

  type
    TCarregaEstrutura = class
    protected
      query : TADOQuery;
    public
      constructor Create( conexao : TADOConnection );
      destructor Free;
      procedure carregar; virtual;
    end;

implementation

constructor TCarregaEstrutura.Create( conexao : TADOConnection );
begin

  query := TADOQuery.Create(nil);
  query.Connection := conexao;

end;

destructor TCarregaEstrutura.Free;
begin

  FreeAndNil( query );

end;

procedure TCarregaEstrutura.carregar;
begin
// override
end;

end.
