{******************************************************************************}
{ Projeto: Delphi Parse                                                        }
{                                                                              }
{ Direitos Autorais Reservados (c) 2016 Luiz Carlos Alves                      }
{                                                                              }
{ Colaboradores nesse arquivo:                                                 }
{    Luiz Carlos Alves - contato@luizsistemas.com.br                           }
{                                                                              }
{ Voc� pode obter a �ltima vers�o desse arquivo no reposit�rio                 }
{ https://github.com/luizsistemas/DelphiParse                                  }
{                                                                              }
{  Esta biblioteca � software livre; voc� pode redistribu�-la e/ou modific�-la }
{ sob os termos da Licen�a P�blica Geral Menor do GNU conforme publicada pela  }
{ Free Software Foundation; tanto a vers�o 2.1 da Licen�a, ou (a seu crit�rio) }
{ qualquer vers�o posterior.                                                   }
{                                                                              }
{ Esta biblioteca � distribu�da na expectativa de que seja �til, por�m, SEM   }
{ NENHUMA GARANTIA; nem mesmo a garantia impl�cita de COMERCIABILIDADE OU      }
{ ADEQUA��O A UMA FINALIDADE ESPEC�FICA. Consulte a Licen�a P�blica Geral Menor}
{ do GNU para mais detalhes. (Arquivo LICEN�A.TXT ou LICENSE.TXT)              }
{                                                                              }
{ Voc� deve ter recebido uma c�pia da Licen�a P�blica Geral Menor do GNU junto}
{ com esta biblioteca; se n�o, escreva para a Free Software Foundation, Inc.,  }
{ no endere�o 59 Temple Street, Suite 330, Boston, MA 02111-1307 USA.          }
{ Voc� tamb�m pode obter uma copia da licen�a em:                              }
{ http://www.opensource.org/licenses/lgpl-license.php                          }
{                                                                              }
{ Luiz Carlos Alves - contato@luizsistemas.com.br -  www.luizsistemas.com.br   }
{                                                                              }
{******************************************************************************}

unit DelphiParse.Query;

interface

uses System.Generics.Collections, System.SysUtils,
  DelphiParse.Interfaces, DelphiParse.Utils,
  DelphiParse.Constraints, System.Net.URLClient;

type
  TParseQuery = class(TInterfacedObject, IParseQuery)
  private
    Constraints: TConstraints;
    ComparisonsParams: TList<TParams>;
    Keys: TList<string>;
    Order: TList<string>;
    FLimit: Integer;
    FSkip: Integer;
    function FormatEqualTo: string;

    //Comparisons
    procedure SetComparisons(ParameterValue: string; Params: TList<TParams>);
    procedure SetFormatStartsWith;
    procedure SetFormatContains;
    procedure SetFormatGreaterThan;
    procedure SetFormatLessThan;

    function FormatComparisons: String;

    function FormatLimit: string;
    function FormatWhereTerms: string;
    function FormatSkip: string;
    function FormatOthers: string;
    function FormatOrders: string;
    function FormatKeys: string;
  public
    constructor Create;
    destructor Destroy; override;

    function Count: Integer;

    //where
    procedure WhereEqualTo(Key, Value: string);
    procedure WhereStartsWith(Key, Value: string);
    procedure WhereContains(Key, Value: string);
    procedure WhereLessThan(Key, Value: string; FieldType: TFieldType = ftString);
    procedure WhereGreaterThan(Key, Value: string; FieldType: TFieldType = ftString);

    //others
    procedure SetLimit(Value: Integer);
    procedure SetSkip(Value: Integer);
    procedure Others(Key, Value: string);
    procedure AddRestrictFields(Field: string);

    //order
    procedure AscendingOrder(Field: string);
    procedure DescendingOrder(Field: string);

    //formatted
    function GetParamsFormatted: string;
  end;

implementation

{ TParseQuery }

uses Dialogs;

constructor TParseQuery.Create;
begin
  inherited;
  Constraints := TConstraints.Create;
  ComparisonsParams := TList<TParams>.Create();
  Keys := TList<string>.Create;
  Order := TList<string>.Create;
end;

destructor TParseQuery.Destroy;
begin
  Constraints.Free;
  ComparisonsParams.Free;
  Keys.Free;
  Order.Free;
  inherited;
end;

function TParseQuery.Count: Integer;
begin
  Result := Constraints.CountWhere;
end;

procedure TParseQuery.AddRestrictFields(Field: string);
begin
  Keys.Add(Field);
end;

procedure TParseQuery.AscendingOrder(Field: string);
begin
  Order.Add(Field);
end;

procedure TParseQuery.DescendingOrder(Field: string);
begin
  Order.Add('-' + Field);
end;

function TParseQuery.FormatEqualTo: string;
begin
  Result := FormatParams('"%s":"%s"', Constraints.Items(ctEqualTo));
end;

function TParseQuery.FormatComparisons: String;
begin
  SetFormatStartsWith;
  SetFormatContains;
  SetFormatLessThan;
  SetFormatGreaterThan;
  Result := FormatParams('"%s":{%s}', ComparisonsParams);
end;

procedure TParseQuery.SetComparisons(ParameterValue: string; Params: TList<TParams>);
var
  Param, ComparisonParam: TParams;
  Value: string;
  Index: Integer;
begin
  if Params.Count = 0 then
    Exit;

  for Param in Params do
  begin
    Value := Format(ParameterValue, [GetDataTypeFormatValue(Param)]);
    ComparisonParam.Key := TURI.URLDecode(Param.Key);
    ComparisonParam.FieldType := Param.FieldType;
    if ContainsKey(Param.Key, ComparisonsParams) then
    begin
      Index := GetIndexParams(Param.Key, ComparisonsParams);
      Value := ComparisonsParams.Items[Index].Value + ',' + Value;
      ComparisonParam.Value := TURI.URLDecode(Value);
      ComparisonsParams.Items[Index] := ComparisonParam;
    end
    else
    begin
      ComparisonParam.Value := TURI.URLDecode(Value);
      ComparisonsParams.Add(ComparisonParam);
    end;
  end;
end;

procedure TParseQuery.SetFormatStartsWith;
begin
  SetComparisons('"$regex":%s', Constraints.Items(ctStartsWith));
end;

procedure TParseQuery.SetFormatContains;
begin
  SetComparisons('"$regex":%s', Constraints.Items(ctContains));
end;

procedure TParseQuery.SetFormatLessThan;
begin
  SetComparisons('"$lte":%s', Constraints.Items(ctLessThan));
end;

procedure TParseQuery.SetFormatGreaterThan;
begin
  SetComparisons('"$gte":%s', Constraints.Items(ctGreaterThan));
end;

function TParseQuery.FormatOthers: string;
begin
  Result := FormatParams('"%s":"%s"', Constraints.Items(ctOthers));
end;

function TParseQuery.FormatLimit: string;
begin
  if FLimit > 0 then
    Result := 'limit=' + FLimit.ToString;
end;

function TParseQuery.FormatSkip: string;
begin
  if FSkip > 0 then
    Result := 'skip=' + FSkip.ToString;
end;

function TParseQuery.FormatKeys: string;
begin
  if Keys.Count = 0 then
    Exit;
  Result := 'keys=' + String.Join(',', Keys.ToArray);
end;

function TParseQuery.FormatOrders: string;
begin
  if Order.Count = 0 then
    Exit;
  Result := 'order=' + String.Join(',', Order.ToArray);
end;

function TParseQuery.FormatWhereTerms: string;
var
  Formats: Array[0..1] of string;
begin
  if Count = 0 then
    Exit;
  Formats[0] := FormatEqualTo;
  Formats[1] := FormatComparisons;
  Result := Format('where={%s}', [GetElementsNotEmpty(',', Formats)]);
end;

function TParseQuery.GetParamsFormatted: string;
var
  Terms: Array[0..5] of string;
begin
  Terms[0] := FormatWhereTerms;
  Terms[1] := FormatLimit;
  Terms[2] := FormatSkip;
  Terms[3] := FormatOthers;
  Terms[4] := FormatOrders;
  Terms[5] := FormatKeys;
  Result := GetElementsNotEmpty('&', Terms);
end;

procedure TParseQuery.SetLimit(Value: Integer);
begin
  FLimit := Value;
end;

procedure TParseQuery.SetSkip(Value: Integer);
begin
  FSkip := Value;
end;

procedure TParseQuery.Others(Key, Value: string);
begin
  Constraints.AddParams(Key, Value, ctOthers);
end;

procedure TParseQuery.WhereContains(Key, Value: string);
begin
  Constraints.AddParams(Key, Value, ctContains);
end;

procedure TParseQuery.WhereEqualTo(Key, Value: string);
begin
  Constraints.AddParams(Key, Value, ctEqualTo);
end;

procedure TParseQuery.WhereGreaterThan(Key, Value: string;
  FieldType: TFieldType);
begin
  Constraints.AddParams(Key, Value, ctGreaterThan, FieldType);
end;

procedure TParseQuery.WhereLessThan(Key, Value: string; FieldType: TFieldType);
begin
  Constraints.AddParams(Key, Value, ctLessThan, FieldType);
end;

procedure TParseQuery.WhereStartsWith(Key, Value: string);
begin
  Constraints.AddParams(Key, '^' + Value, ctStartsWith);
end;

end.
