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

unit DelphiParse.Utils;

interface

uses
  System.SysUtils, Generics.Collections;
type
  ExceptionParseKeyDuplicate = class(Exception);

  TParams = record
    Key: string;
    Value: string;
    FieldType: string;
  end;

function GetElementsNotEmpty(Separator: String; Elements: Array of string): string;
function FormatParams(CustomParameter: string; Params: TList<TParams>): string;
procedure AddParams(Key, Value, FieldType: string; Params: TList<TParams>);
procedure ValidatesKey(Key: string; Params: TList<TParams>);
function ContainsKey(Key: string; List: TList<TParams>): Boolean;
function GetIndexParams(Key: string; List: TList<TParams>): Integer;

implementation

uses
   System.Net.URLClient;

function GetIndexParams(Key: string; List: TList<TParams>): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to List.Count - 1 do
    if Key = List.Items[I].Key then
      Result := I;
end;

function ContainsKey(Key: string; List: TList<TParams>): Boolean;
var
  Param: TParams;
begin
  Result := False;
  for Param in List do
    if Key = Param.Key then
      Result := True;
end;

procedure ValidatesKey(Key: string; Params: TList<TParams>);
begin
  if ContainsKey(Key, Params) then
    raise ExceptionParseKeyDuplicate.Create('Key already exists with that name');
end;

procedure AddParams(Key, Value, FieldType: string; Params: TList<TParams>);
var
  Param: TParams;
begin
  Param.Key := Key;
  Param.Value := Value;
  Param.FieldType := FieldType;
  ValidatesKey(Key, Params);
  Params.Add(Param);
end;

function GetElementsNotEmpty(Separator: String; Elements: Array of string): string;
var
  ListElements: TList<string>;
  Param: string;
begin
  if Length(Elements) = 0 then
    Exit;
  ListElements := TList<string>.Create;
  try
    for Param in Elements do
    begin
      if Param.IsEmpty then
        Continue;
      ListElements.Add(Param);
    end;
    Result := String.Join(Separator, ListElements.ToArray);
  finally
    ListElements.Free;
  end;
end;

function FormatParams(CustomParameter: string; Params: TList<TParams>): string;
var
  Param: TParams;
  KeyDec, ValueDec: string;
begin
  if Params.Count = 0 then
    Exit;
  for Param in Params do
  begin
    KeyDec := TURI.URLDecode(Param.Key);
    ValueDec := TURI.URLDecode(Param.Value);
    if Result <> '' then
      Result := Result + ',';
    Result := Result + Format(CustomParameter, [KeyDec, ValueDec]);
  end;
end;

end.
