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

unit DelphiParse.Objects;

interface

uses DelphiParse, DelphiParse.Interfaces, System.JSON,
  System.Generics.Collections, DelphiParse.Configuration,
  DelphiParse.Query;

type
  TParseObjects = class(TInterfacedObject, IParseObject)
  private
    FClassName: string;
    Obj: TJSonObject;
    Parse: IDelphiParse;
    Query: IParseQuery;
  public
    constructor Create(ClassName: string);
    destructor Destroy; override;

    procedure WhereEqualTo(Key, Value: string);
    procedure WhereStartsWith(Key, Value: string);
    procedure WhereContains(Key, Value: string);
    procedure WhereLessThen(Key, Value: string; FieldType: string = '');
    procedure Limit(Value: Integer);
    procedure Skip(Value: Integer);
    procedure Others(Key, Value: string);

    procedure AddRestrictFields(Field: string);
    procedure AddOrderAsc(Field: string);
    procedure AddOrderDesc(Field: string);

    procedure Add(Key, Value: Variant);

    function SaveInBackGround: string;
    function GetInBackGround: string;
    function DeleteInBackGround(ObjectId: string): string;
  end;

implementation

uses
  System.SysUtils;

{ TDelphiParseObjects }

procedure TParseObjects.AddOrderAsc(Field: string);
begin
  Query.AscendingOrder(Field);
end;

procedure TParseObjects.AddOrderDesc(Field: string);
begin
  Query.DescendingOrder(Field);
end;

procedure TParseObjects.AddRestrictFields(Field: string);
begin
  Query.AddRestrictFields(Field);
end;

constructor TParseObjects.Create(ClassName: string);
begin
  inherited Create;
  FClassName := ClassName;
  Obj := TJSONObject.Create;
  Parse := TDelphiParse.Create;
  Query := TParseQuery.Create;
end;

destructor TParseObjects.Destroy;
begin
  Obj.Free;
  inherited;
end;

function TParseObjects.GetInBackGround: string;
begin
  Result := Parse.Get(['classes', FClassName], nil, Query.GetParamsFormatted).ResponseAsString();
end;

procedure TParseObjects.Add(Key, Value: Variant);
begin
  Obj.AddPair(Key, Value);
end;

function TParseObjects.SaveInBackGround: string;
begin
  if (Obj.Count = 0) then
    raise Exception.Create('Objeto JSON n�o preenchido!');
  if Assigned(Obj.GetValue('objectId')) then
    Result := Parse.Put(['classes', FClassName, Obj.GetValue<string>('objectId')], Obj).ResponseAsString()
  else
    Result := Parse.Post(['classes', FClassName], Obj).ResponseAsString();
end;

procedure TParseObjects.WhereContains(Key, Value: string);
begin
  Query.WhereContains(Key, Value);
end;

procedure TParseObjects.WhereEqualTo(Key, Value: string);
begin
  Query.WhereEqualTo(Key, Value);
end;

procedure TParseObjects.WhereLessThen(Key, Value, FieldType: string);
begin
  Query.WhereLessThen(Key, Value, FieldType);
end;

procedure TParseObjects.WhereStartsWith(Key, Value: string);
begin
  Query.WhereStartsWith(Key, Value);
end;

procedure TParseObjects.Limit(Value: Integer);
begin
  Query.SetLimit(Value);
end;

procedure TParseObjects.Others(Key, Value: string);
begin
  Query.Others(Key, Value);
end;

procedure TParseObjects.Skip(Value: Integer);
begin
  Query.SetSkip(Value);
end;

function TParseObjects.DeleteInBackGround(ObjectId: string): string;
begin
  if (ObjectId = '') then
    raise Exception.Create('ObjectId n�o informado!');
  Result := Parse.Delete(['classes', FClassName, ObjectId]).ResponseAsString();
end;

end.
