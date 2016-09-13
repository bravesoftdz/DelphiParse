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

unit DelphiParse.User;

interface

uses
  DelphiParse, DelphiParse.Interfaces, DelphiParse.Query,
  System.JSON, System.SysUtils, Generics.Collections;

type
  ExceptionParseUserNameIsEmpty = class(Exception);
  ExceptionParsePasswordIsEmpty = class(Exception);
  ExcpetionParseEmailIsEmpty = class(Exception);

  TParseUser = class(TInterfacedObject, IParseUser)
  private
    FUserName: string;
    FEmail: string;
    FPassword: string;

    Obj: TJSonObject;
    CustomField: TDictionary<string,string>;
    Parse: IDelphiParse;
    Query: IParseQuery;

    procedure ValidatesNewUser;
    procedure FormatParams;
    procedure ProcessResponse(AResponse: string);
  public
    constructor Create;
    destructor Destroy; override;

    procedure SetUserName(Value: string);
    procedure SetEmail(Value: string);
    procedure SetPassword(Value: string);

    function GetSessionToken: string;

    procedure Add(Key, Value: Variant);


    function Login(UserName, Password: string): string;
    function LogOut: string;
    function GetCurrencyUser: string;
    function SignUpInBackground: string;
  end;

implementation

{ TParseUser }

uses System.Net.URLClient;

constructor TParseUser.Create;
begin
  inherited;
  Parse := TDelphiParse.Create;
  Query := TParseQuery.Create;
  Obj := TJSONObject.Create;
  CustomField := TDictionary<string, string>.Create();
end;

destructor TParseUser.Destroy;
begin
  inherited;
  CustomField.Free;
  Obj.Free;
end;

procedure TParseUser.Add(Key, Value: Variant);
begin
  CustomField.Add(Key, Value);
end;

procedure TParseUser.ProcessResponse(AResponse: string);
var
  Obj: TJSONObject;
begin
  Obj := TJSONObject.ParseJSONValue(AResponse) as TJSONObject;
  try
    if assigned(Obj.GetValue('sessionToken')) then
      Parse.SetSessionToken(Obj.GetValue<string>('sessionToken'))
    else
      Parse.SetSessionToken('');
  finally
    Obj.Free;
  end;
end;

function TParseUser.Login(UserName, Password: string): string;
var
  Params: string;
begin
  Parse.SetRevocableSession(True);
  Params := Format('%s=%s&%s=%s', [
    TURI.URLEncode('username'),
    TURI.URLEncode(UserName),
    TURI.URLEncode('password'),
    TURI.URLEncode(Password)]);
  Result := Parse.Get(['login'], nil, Params).ResponseAsString();
  ProcessResponse(Result);
end;

function TParseUser.LogOut: string;
begin
  Parse.SetRevocableSession(False);
  Result := Parse.Post(['logout']).ResponseAsString();
  ProcessResponse(Result);
end;

function TParseUser.GetCurrencyUser: string;
begin
  if Parse.GetSessionToken.IsEmpty then
    Exit;
  Parse.SetRevocableSession(False);
  Result := Parse.Get(['users', 'me']).ResponseAsString();
  ProcessResponse(Result);
end;

procedure TParseUser.SetEmail(Value: string);
begin
  FEmail := Value;
end;

procedure TParseUser.SetPassword(Value: string);
begin
  FPassword := Value;
end;

procedure TParseUser.SetUserName(Value: string);
begin
  FUserName := Value;
end;

function TParseUser.SignUpInBackground: string;
begin
  ValidatesNewUser;
  FormatParams;
  Parse.SetRevocableSession(True);
  Result := Parse.Post(['users'], Obj).ResponseAsString();
  ProcessResponse(Result);
end;

procedure TParseUser.FormatParams;
var
  Key: string;
begin
  Obj.AddPair('username', FUserName);
  Obj.AddPair('password', FPassword);
  Obj.AddPair('email', FEmail);
  for Key in CustomField.Keys do
     Obj.AddPair(Key, CustomField.Items[Key]);
end;

function TParseUser.GetSessionToken: string;
begin
  Result := Parse.GetSessionToken;
end;

procedure TParseUser.ValidatesNewUser;
begin
  if FUserName.IsEmpty then
    raise ExceptionParseUserNameIsEmpty.Create('Username is empty!');

  if FPassword.IsEmpty then
    raise ExceptionParsePasswordIsEmpty.Create('Password is empty!');

  if FEmail.IsEmpty then
    raise ExcpetionParseEmailIsEmpty.Create('E-mail is empty!');
end;

end.
