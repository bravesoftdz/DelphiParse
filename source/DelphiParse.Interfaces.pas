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

unit DelphiParse.Interfaces;

interface

uses System.JSON, System.SysUtils, System.Generics.Collections;

type
  IResponseParse = interface
    ['{D356B879-8FAC-47BC-8946-7418497C1047}']
    function ResponseAsString(const Encoding: TEncoding = nil): string;
  end;

  IDelphiParse = interface
    ['{87E940B9-D2F8-4197-84D8-A84A426049BA}']
    function Post(const UrlParams: array of string;
      ObjectJson: TJSONValue = nil;
      QueryParams: string = ''): IResponseParse;

    function Get(const UrlParams: array of string;
      ObjectJson: TJSONValue = nil;
      QueryParams: string = ''): IResponseParse;

    function Put(const UrlParams: array of string;
      ObjectJson: TJSONValue = nil;
      QueryParams: string = ''): IResponseParse;

    function Delete(const UrlParams: array of string;
      ObjectJson: TJSONValue = nil;
      QueryParams: string = ''): IResponseParse;
    procedure SetRevocableSession(Value: Boolean);

    function GetSessionToken: string;
    procedure SetSessionToken(Value: string);
  end;

  IParseQuery = interface
    ['{A00E5771-50D0-44C2-86BC-2F0ED2418CF9}']

    function Count: Integer;

    //where
    procedure WhereEqualTo(Key, Value: string);
    procedure WhereStartsWith(Key, Value: string);
    procedure WhereContains(Key, Value: string);

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

  IParseObject = interface
    ['{A6616D36-B794-46DC-BBC9-51CF0AC18E5F}']
    procedure WhereEqualTo(Key, Value: string);
    procedure WhereStartsWith(Key, Value: string);
    procedure WhereContains(Key, Value: string);
    procedure Limit(Value: Integer);
    procedure Skip(Value: Integer);
    procedure AddRestrictFields(Field: string);
    procedure AddOrderAsc(Field: string);
    procedure AddOrderDesc(Field: string);

    procedure Add(Key, Value: Variant);

    function SaveInBackGround: string;
    function GetInBackGround: string;
    function DeleteInBackGround(ObjectId: string): string;
  end;

  IParseUser = interface
    ['{D75AD7B0-21BA-4749-B4EB-A94FB66DAC34}']

    procedure SetUserName(Value: string);
    procedure SetEmail(Value: string);
    procedure SetPassword(Value: string);

    function GetSessionToken: string;

    //custom fields
    procedure Add(Key, Value: Variant);

    function Login(UserName, Password: string): string;
    function LogOut: string;
    function GetCurrencyUser: string;
    function SignUpInBackground: string;
  end;

implementation

end.
