unit TestQuery;

interface

uses
  TestFramework, DelphiParse.Query, DelphiParse.Utils, DelphiParse.Constraints;
type
  TTestQuery = class(TTestCase)
  private
    Query: TParseQuery;
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure AdicionarUmParametro;
    procedure AdicionarDoisParametros;
    procedure AdicionarParametroJaExistente;
    procedure FormatarComClausulaStartsWith;
    procedure FormatarComClausulaContains;
    procedure FormatarComUmParametro;
    procedure FormatarComDoisParametros;
    procedure FormatarEqualToComStartsWith;
    procedure AdicionarLimiteTresRegistros;
    procedure AdicionarSkipDoisRegistros;
    procedure TestaWheresComLimiteESkip;
    procedure TestaWhereCampoComIntervalos;
  end;

implementation

uses System.SysUtils;

{ TTestQuery }
procedure TTestQuery.SetUp;
begin
  inherited;
  Query := TParseQuery.Create;
end;

procedure TTestQuery.TearDown;
begin
  inherited;
  Query.Free;
end;

procedure TTestQuery.TestaWhereCampoComIntervalos;
begin
  Query.WhereStartsWith('mensagem','m');
  Query.WhereContains('mensagem','feliz');
  CheckEqualsString('where={"mensagem":{"$regex":"^m","$regex":"feliz"}}', Query.GetParamsFormatted,'Resultado n�o confere com o experado');
end;

procedure TTestQuery.TestaWheresComLimiteESkip;
begin
  Query.WhereEqualTo('username', 'luiz');
  Query.SetLimit(10);
  Query.SetSkip(2);
  CheckEqualsString('where={"username":"luiz"}&limit=10&skip=2', Query.GetParamsFormatted, 'Limite inv�lido');
end;

procedure TTestQuery.AdicionarDoisParametros;
begin
  Query.WhereEqualTo('username', 'luiz');
  Query.WhereEqualTo('city', 'S�o Paulo');
  CheckTrue(Query.Count = 2, 'N�o cont�m dois elementos');
end;

procedure TTestQuery.AdicionarLimiteTresRegistros;
begin
  Query.SetLimit(3);
  CheckEqualsString('limit=3', Query.GetParamsFormatted, 'Limite inv�lido');
end;

procedure TTestQuery.AdicionarParametroJaExistente;
begin
  StartExpectingException(ExceptionParseKeyDuplicate);
  Query.WhereEqualTo('username', 'luiz');
  Query.WhereEqualTo('city', 'Sao Paulo');
  Query.WhereEqualTo('username', 'paulo');
  StopExpectingException('N�o gerou a exception esperada');
end;

procedure TTestQuery.AdicionarSkipDoisRegistros;
begin
  Query.SetSkip(2);
  CheckEqualsString('skip=2', Query.GetParamsFormatted, 'Skip inv�lido');
end;

procedure TTestQuery.AdicionarUmParametro;
begin
  Query.WhereEqualTo('username', 'luiz');
  CheckTrue(Query.Count > 0, 'Adicionado item, por�m parametros vazio');
end;

procedure TTestQuery.FormatarComDoisParametros;
begin
  Query.WhereEqualTo('username','luiz');
  Query.WhereEqualTo('city','S�o Paulo');
  CheckEqualsString('where={"username":"luiz","city":"S�o Paulo"}', Query.GetParamsFormatted);
end;

procedure TTestQuery.FormatarEqualToComStartsWith;
begin
  Query.WhereStartsWith('username','lu');
  Query.WhereEqualTo('city','S�o Paulo');
  CheckEqualsString('where={"city":"S�o Paulo","username":{"$regex":"^lu"}}',
    Query.GetParamsFormatted);
end;

procedure TTestQuery.FormatarComUmParametro;
begin
  Query.WhereEqualTo('username','luiz');
  CheckEqualsString('where={"username":"luiz"}', Query.GetParamsFormatted);
end;

procedure TTestQuery.FormatarComClausulaContains;
begin
  Query.WhereContains('username','lu');
  Check(Query.Count = 1, 'N�o adicionou par�metro utilizando WhereContains');
  CheckEqualsString('where={"username":{"$regex":"lu"}}', Query.GetParamsFormatted);
end;

procedure TTestQuery.FormatarComClausulaStartsWith;
begin
  Query.WhereStartsWith('username','lu');
  Check(Query.Count = 1, 'N�o adicionou par�metro utilizando WhereStartsWith');
  CheckEqualsString('where={"username":{"$regex":"^lu"}}', Query.GetParamsFormatted);
end;

initialization
RegisterTest(TTestQuery.Suite);

end.
