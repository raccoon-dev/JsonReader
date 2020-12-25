{******************************************************************************
 *                                                                            *
 * Based on rfc-4627                                                          *
 * https://www.rfc-editor.org/rfc/rfc4627.html                                *
 *                                                                            *
 ******************************************************************************}

unit Rac.Json.Reader;

interface

{$IFDEF FPC}
{$MODE DELPHI}
{$H+}
uses
  classes, Contnrs, sysutils;
{$ELSE}
uses
  System.Classes, System.SysUtils, System.Generics.Collections;
{$ENDIF}

const
  BUFFER_SIZE = 4 * 1024; // 4KB

{$SCOPEDENUMS ON}

////
// Partly compatible with TJsonToken from Embarcadero System.Json.Types
////
type
  TJsonToken = (
  {$IFDEF FPC}jtNone{$ELSE}None{$ENDIF},
  {$IFDEF FPC}jtStartObject{$ELSE}StartObject{$ENDIF},
  {$IFDEF FPC}jtStartArray{$ELSE}StartArray{$ENDIF},
  {$IFDEF FPC}jtStartConstructor{$ELSE}StartConstructor{$ENDIF}, // Not used
  {$IFDEF FPC}jtPropertyName{$ELSE}PropertyName{$ENDIF},
  {$IFDEF FPC}jtComment{$ELSE}Comment{$ENDIF}, // Not used
  {$IFDEF FPC}jtRaw{$ELSE}Raw{$ENDIF}, // Not used
  {$IFDEF FPC}jtInteger{$ELSE}Integer{$ENDIF},
  {$IFDEF FPC}jtFloat{$ELSE}Float{$ENDIF},
  {$IFDEF FPC}jtString{$ELSE}&String{$ENDIF},
  {$IFDEF FPC}jtBoolean{$ELSE}Boolean{$ENDIF},
  {$IFDEF FPC}jtNull{$ELSE}Null{$ENDIF},
  {$IFDEF FPC}jtUndefined{$ELSE}Undefined{$ENDIF},
  {$IFDEF FPC}jtEndObject{$ELSE}EndObject{$ENDIF},
  {$IFDEF FPC}jtEndArray{$ELSE}EndArray{$ENDIF},
  {$IFDEF FPC}jtEndConstructor{$ELSE}EndConstructor{$ENDIF}, // Not used
  {$IFDEF FPC}jtDate{$ELSE}Date{$ENDIF}, // Not used
  {$IFDEF FPC}jtBytes{$ELSE}Bytes{$ENDIF}, // Not used
  // Only in Extended JSON, BSON
  {$IFDEF FPC}jtOid{$ELSE}Oid{$ENDIF}, // Not used
  {$IFDEF FPC}jtRegEx{$ELSE}RegEx{$ENDIF}, // Not used
  {$IFDEF FPC}jtDBRef{$ELSE}DBRef{$ENDIF}, // Not used
  {$IFDEF FPC}jtCodeWScope{$ELSE}CodeWScope{$ENDIF}, // Not used
  {$IFDEF FPC}jtMinKey{$ELSE}MinKey{$ENDIF}, // Not used
  {$IFDEF FPC}jtMaxKey{$ELSE}MaxKey{$ENDIF} // Not used
    //{$IFDEF FPC}jt{$ENDIF}None,
    //{$IFDEF FPC}jt{$ENDIF}StartObject,
    //{$IFDEF FPC}jt{$ENDIF}StartArray,
    //{$IFDEF FPC}jt{$ENDIF}StartConstructor, // Not used
    //{$IFDEF FPC}jt{$ENDIF}PropertyName,
    //{$IFDEF FPC}jt{$ENDIF}Comment, // Not used
    //{$IFDEF FPC}jt{$ENDIF}Raw, // Not used
    //{$IFDEF FPC}jt{$ENDIF}Integer,
    //{$IFDEF FPC}jt{$ENDIF}Float,
    //{$IFDEF FPC}jt{$ELSE}&{$ENDIF}String,
    //{$IFDEF FPC}jt{$ENDIF}Boolean,
    //{$IFDEF FPC}jt{$ENDIF}Null,
    //{$IFDEF FPC}jt{$ENDIF}Undefined,
    //{$IFDEF FPC}jt{$ENDIF}EndObject,
    //{$IFDEF FPC}jt{$ENDIF}EndArray,
    //{$IFDEF FPC}jt{$ENDIF}EndConstructor, // Not used
    //{$IFDEF FPC}jt{$ENDIF}Date, // Not used
    //{$IFDEF FPC}jt{$ENDIF}Bytes, // Not used
    //// Only in Extended JSON, BSON
    //{$IFDEF FPC}jt{$ENDIF}Oid, // Not used
    //{$IFDEF FPC}jt{$ENDIF}RegEx, // Not used
    //{$IFDEF FPC}jt{$ENDIF}DBRef, // Not used
    //{$IFDEF FPC}jt{$ENDIF}CodeWScope, // Not used
    //{$IFDEF FPC}jt{$ENDIF}MinKey, // Not used
    //{$IFDEF FPC}jt{$ENDIF}MaxKey // Not used
  );

type TLevels = {$IFDEF FPC}TObjectStack{$ELSE}TStack<TJsonToken>{$ENDIF};

{$SCOPEDENUMS OFF}

////
// Partially compatible with TJsonTextReaded from Embarcadero System.Json.Readers
////
type

{ TJsonReader }

 TJsonReader = class(TObject)
  private
    FLevels: TLevels;
    FTokenType: TJsonToken;
    FPropertyName: {$IFDEF FPC}WideString{$ELSE}string{$ENDIF};
    FEncoding: TEncoding;
    FValue: {$IFDEF FPC}WideString{$ELSE}string{$ENDIF};
    function GetPropertyName: {$IFDEF FPC}WideString{$ELSE}string{$ENDIF};
    function GetLevel: Integer;
  protected
    FBuffer: {$IFDEF FPC}WideString{$ELSE}string{$ENDIF};
    FBufferPos: Cardinal;
    function ReadNextToken: Boolean;
    function GetNextChar(var Character: {$IFDEF FPC}WideChar{$ELSE}Char{$ENDIF}): Boolean;
    function IsWhitespace(const Character: {$IFDEF FPC}WideChar{$ELSE}Char{$ENDIF}): Boolean;
    function _ReadString: {$IFDEF FPC}WideString{$ELSE}string{$ENDIF};
    function _ReadValue: {$IFDEF FPC}WideString{$ELSE}string{$ENDIF};
    function _GetXChars(const X: Integer): {$IFDEF FPC}WideString{$ELSE}string{$ENDIF};
  public
    constructor Create(const JsonValue: {$IFDEF FPC}WideString{$ELSE}string{$ENDIF});
    destructor  Destroy; override;

    function JsonString: {$IFDEF FPC}WideString{$ELSE}string{$ENDIF};

    //

    // Read next token
    function Read: Boolean;

    // Skip whole object and go to next property
    procedure Skip;

    // Rewind to start of JSON and start read from beginning
    procedure Rewind;

    //

    // Json string encoding
    // Default = TEncoding.UTF8
    property Encoding: TEncoding read FEncoding write FEncoding;

    // Current token type
    property TokenType: TJsonToken read FTokenType;

    // Current level
    property Level: Integer read GetLevel;

    // Current property name
    property PropertyName: {$IFDEF FPC}WideString{$ELSE}string{$ENDIF} read GetPropertyName;

    // Return string value of actual token if token is not TJsonToken.PropertyName
    function ValueAsString: {$IFDEF FPC}WideString{$ELSE}string{$ENDIF};

    // Return float value of actual token if token is not TJsonToken.PropertyName
    function ValueAsFloat: Extended;

    // Return integer value of actual token if token is not TJsonToken.PropertyName
    function ValueAsInteger: Integer;

    // Return int64 value of actual token if token is not TJsonToken.PropertyName
    function ValueAsInt64: Int64;

    // Return cardinal value of actual token if token is not TJsonToken.PropertyName
    function ValueAsCardinal: Cardinal;

    // Return UInt64 value of actual token if token is not TJsonToken.PropertyName
    function ValueAsUInt64: UInt64;

    // Return DateTime value of actual token if token is not TJsonToken.PropertyName
    function ValueAsDateTime: TDateTime;

    // Return Boolean value of actual token if token is not TJsonToken.PropertyName
    function ValueAsBoolean: Boolean;

    //

    // Read next value after TJsonTokenPropertyName and return it as string
    function ReadAsString: {$IFDEF FPC}WideString{$ELSE}string{$ENDIF};

    // Read next value after TJsonTokenPropertyName and return it as float
    function ReadAsFloat: Extended;

    // Read next value after TJsonTokenPropertyName and return it as integer
    function ReadAsInteger: Integer;

    // Read next value after TJsonTokenPropertyName and return it as int64
    function ReadAsInt64: Int64;

    // Read next value after TJsonTokenPropertyName and return it as cardinal
    function ReadAsCardinal: Cardinal;

    // Read next value after TJsonTokenPropertyName and return it as UInt64
    function ReadAsUInt64: UInt64;

    // Read next value after TJsonTokenPropertyName and return it as DateTime
    function ReadAsDateTime: TDateTime;

    // Read next value after TJsonTokenPropertyName and return it as Boolean
    function ReadAsBoolean: Boolean;
end;

implementation

const
  BEGIN_ARRAY     : {$IFDEF FPC}WideChar{$ELSE}Char{$ENDIF} = #$5B; // [ left square bracket
  BEGIN_OBJECT    : {$IFDEF FPC}WideChar{$ELSE}Char{$ENDIF} = #$7B; // { left curly bracket
  END_ARRAY       : {$IFDEF FPC}WideChar{$ELSE}Char{$ENDIF} = #$5D; // ] right square bracket
  END_OBJECT      : {$IFDEF FPC}WideChar{$ELSE}Char{$ENDIF} = #$7D; // } right curly bracket
  NAME_SEPARATOR  : {$IFDEF FPC}WideChar{$ELSE}Char{$ENDIF} = #$3A; // : colon
  VALUE_SEPARATOR : {$IFDEF FPC}WideChar{$ELSE}Char{$ENDIF} = #$2C; // , comma
  WS_TAB   : {$IFDEF FPC}WideChar{$ELSE}Char{$ENDIF} = #$9;  // Horizontal tab
  WS_LF    : {$IFDEF FPC}WideChar{$ELSE}Char{$ENDIF} = #$A;  // Line feed or New line
  WS_CR    : {$IFDEF FPC}WideChar{$ELSE}Char{$ENDIF} = #$D;  // Carriage return
  WS_SPACE : {$IFDEF FPC}WideChar{$ELSE}Char{$ENDIF} = #$20; // Space
  VAL_TRUE  : {$IFDEF FPC}WideString{$ELSE}String{$ENDIF} = 'true';
  VAL_FALSE : {$IFDEF FPC}WideString{$ELSE}String{$ENDIF} = 'false';
  VAL_NULL  : {$IFDEF FPC}WideString{$ELSE}String{$ENDIF} = 'null';

  CHR_QUOT : {$IFDEF FPC}WideChar{$ELSE}Char{$ENDIF} = #$22; //  "    quotation mark  U+0022
  ESC_RSOL : {$IFDEF FPC}WideChar{$ELSE}Char{$ENDIF} = #$5C; //  \    reverse solidus U+005C
  ESC_SOL  : {$IFDEF FPC}WideChar{$ELSE}Char{$ENDIF} = #$2F; //  /    solidus         U+002F
  ESC_BSP  : {$IFDEF FPC}WideChar{$ELSE}Char{$ENDIF} = #$62; //  b    backspace       U+0008
  ESC_FF   : {$IFDEF FPC}WideChar{$ELSE}Char{$ENDIF} = #$66; //  f    form feed       U+000C
  ESC_LF   : {$IFDEF FPC}WideChar{$ELSE}Char{$ENDIF} = #$6E; //  n    line feed       U+000A
  ESC_CR   : {$IFDEF FPC}WideChar{$ELSE}Char{$ENDIF} = #$72; //  r    carriage return U+000D
  ESC_TAB  : {$IFDEF FPC}WideChar{$ELSE}Char{$ENDIF} = #$74; //  t    tab             U+0009
  ESC_UNIC : {$IFDEF FPC}WideChar{$ELSE}Char{$ENDIF} = #$75; //  uXXXX                U+XXXX
  CHR_BSP  : {$IFDEF FPC}WideChar{$ELSE}Char{$ENDIF} = #$8;  //  backspace       U+0008
  CHR_FF   : {$IFDEF FPC}WideChar{$ELSE}Char{$ENDIF} = #$C;  //  form feed       U+000C

{ TJsonReader }

constructor TJsonReader.Create(const JsonValue: {$IFDEF FPC}WideString{$ELSE}string{$ENDIF});
begin
  FLevels     := TLevels.Create;
  FBuffer     := JsonValue;
  FBufferPos  := 0;
  FTokenType  := {$IFDEF FPC}TJsonToken.jtNone{$ELSE}TJsonToken.None{$ENDIF};
  FEncoding   := TEncoding.UTF8;
end;

destructor TJsonReader.Destroy;
begin
  FBuffer := '';
  FLevels.Free;
  inherited;
end;

function TJsonReader.JsonString: {$IFDEF FPC}WideString{$ELSE}string{$ENDIF};
begin
  Result := StringReplace(StringReplace(FBuffer, #13#10, #13, [rfReplaceAll]), #13, '', [rfReplaceAll]);
end;

function TJsonReader.GetLevel: Integer;
begin
  Result := FLevels.Count;
end;

function TJsonReader.GetNextChar(var Character: {$IFDEF FPC}WideChar{$ELSE}Char{$ENDIF}): Boolean;
begin
  Result := True;
  if (FBufferPos + 1 > Cardinal(Length(FBuffer))) then
  begin
    Result := False;
    Exit;
  end;

  Inc(FBufferPos);
  Character := FBuffer[FBufferPos];
end;

function TJsonReader.GetPropertyName: {$IFDEF FPC}WideString{$ELSE}string{$ENDIF};
begin
  if TokenType in [{$IFDEF FPC}TJsonToken.jtPropertyName{$ELSE}TJsonToken.PropertyName{$ENDIF} .. {$IFDEF FPC}TJsonToken.jtNull{$ELSE}TJsonToken.Null{$ENDIF}] then
    Result := FPropertyName
  else
    Result := '';
end;

function TJsonReader.IsWhitespace(const Character: {$IFDEF FPC}WideChar{$ELSE}Char{$ENDIF}): Boolean;
begin
  Result := (Character = WS_SPACE) or
            (Character = WS_CR) or
            (Character = WS_LF) or
            (Character = WS_TAB);
end;

function TJsonReader.Read: Boolean;
begin
  Result := ReadNextToken;
end;

function TJsonReader.ReadAsBoolean: Boolean;
begin
  if ReadNextToken and (TokenType = {$IFDEF FPC}TJsonToken.jtBoolean{$ELSE}TJsonToken.Boolean{$ENDIF}) then
    Result := ValueAsBoolean
  else
    raise Exception.Create('String value expected for property ' + PropertyName);
end;

function TJsonReader.ReadAsCardinal: Cardinal;
begin
  if ReadNextToken and (TokenType = {$IFDEF FPC}TJsonToken.jtInteger{$ELSE}TJsonToken.Integer{$ENDIF}) then
    Result := ValueAsCardinal
  else
    raise Exception.Create('Integer value expected for property ' + PropertyName);
end;

function TJsonReader.ReadAsDateTime: TDateTime;
begin
  if ReadNextToken and (TokenType = {$IFDEF FPC}TJsonToken.jtString{$ELSE}TJsonToken.String{$ENDIF}) then
    Result := ValueAsDateTime
  else
    raise Exception.Create('DateTime string value expected for property ' + PropertyName);
end;

function TJsonReader.ReadAsFloat: Extended;
begin
  if ReadNextToken and (TokenType = {$IFDEF FPC}TJsonToken.jtFloat{$ELSE}TJsonToken.Float{$ENDIF}) then
    Result := ValueAsFloat
  else
    raise Exception.Create('Float value expected for property ' + PropertyName);
end;

function TJsonReader.ReadAsInt64: Int64;
begin
  if ReadNextToken and (TokenType = {$IFDEF FPC}TJsonToken.jtInteger{$ELSE}TJsonToken.Integer{$ENDIF}) then
    Result := ValueAsInt64
  else
    raise Exception.Create('Integer value expected for property ' + PropertyName);
end;

function TJsonReader.ReadAsInteger: Integer;
begin
  if ReadNextToken and (TokenType = {$IFDEF FPC}TJsonToken.jtInteger{$ELSE}TJsonToken.Integer{$ENDIF}) then
    Result := ValueAsInteger
  else
    raise Exception.Create('Integer value expected for property ' + PropertyName);
end;

function TJsonReader.ReadAsString: {$IFDEF FPC}WideString{$ELSE}string{$ENDIF};
begin
  if ReadNextToken and (TokenType = {$IFDEF FPC}TJsonToken.jtString{$ELSE}TJsonToken.String{$ENDIF}) then
    Result := ValueAsString
  else
    raise Exception.Create('String value expected for property ' + PropertyName);
end;

function TJsonReader.ReadAsUInt64: UInt64;
begin
  if ReadNextToken and (TokenType = {$IFDEF FPC}TJsonToken.jtInteger{$ELSE}TJsonToken.Integer{$ENDIF}) then
    Result := ValueAsUInt64
  else
    raise Exception.Create('Integer value expected for property ' + PropertyName);
end;

function TJsonReader.ReadNextToken: Boolean;
var
  c: {$IFDEF FPC}WideChar{$ELSE}Char{$ENDIF};
begin

  while GetNextChar(c) do
  begin
    if IsWhitespace(c) then
      Continue;

    if c = '{' then
    begin
      FTokenType := {$IFDEF FPC}TJsonToken.jtStartObject{$ELSE}TJsonToken.StartObject{$ENDIF};
      {$IFDEF FPC}
      FLevels.Push(TObject(FTokenType));
      {$ELSE}
      FLevels.Push(FTokenType);
      {$ENDIF}
      Result := True;
      Exit;
    end else
    if c = '}' then
    begin
      FTokenType := {$IFDEF FPC}TJsonToken.jtEndObject{$ELSE}TJsonToken.EndObject{$ENDIF};
      FLevels.Pop;
      Result := True;
      Exit;
    end else
    if c = '[' then
    begin
      FTokenType := {$IFDEF FPC}TJsonToken.jtStartArray{$ELSE}TJsonToken.StartArray{$ENDIF};
      {$IFDEF FPC}
      FLevels.Push(TObject(FTokenType));
      {$ELSE}
      FLevels.Push(FTokenType);
      {$ENDIF}
      Result := True;
      Exit;
    end else
    if c = ']' then
    begin
      FTokenType := {$IFDEF FPC}TJsonToken.jtEndArray{$ELSE}TJsonToken.EndArray{$ENDIF};
      FLevels.Pop;
      Result := True;
      Exit;
    end else
    if c = '"' then
    begin
      if (FTokenType = {$IFDEF FPC}TJsonToken.jtStartObject{$ELSE}TJsonToken.StartObject{$ENDIF}) or (FTokenType = {$IFDEF FPC}TJsonToken.jtUndefined{$ELSE}TJsonToken.Undefined{$ENDIF}) then
      begin
        FTokenType := {$IFDEF FPC}TJsonToken.jtPropertyName{$ELSE}TJsonToken.PropertyName{$ENDIF};
        FPropertyName := _ReadString;
        Result := True;
        Exit;
      end else
      begin
        FTokenType := {$IFDEF FPC}TJsonToken.jtString{$ELSE}TJsonToken.String{$ENDIF};
        FValue := _ReadString;
        Result := True;
        Exit;
      end;
    end else
    if (c = ':') then
    begin
      FTokenType := {$IFDEF FPC}TJsonToken.jtRaw{$ELSE}TJsonToken.Raw{$ENDIF};
      Continue;
    end else
    if (c = ',') then
    begin
      if (FLevels.Count > 0) and (TJsonToken(FLevels.Peek) = {$IFDEF FPC}TJsonToken.jtStartArray{$ELSE}TJsonToken.StartArray{$ENDIF}) then
        FTokenType := {$IFDEF FPC}TJsonToken.jtRaw{$ELSE}TJsonToken.Raw{$ENDIF}
      else
        FTokenType := {$IFDEF FPC}TJsonToken.jtUndefined{$ELSE}TJsonToken.Undefined{$ENDIF};
      Continue;
    end else
    if (c = 't') then
    begin
      FValue := c + _ReadValue;
      if FValue <> 'true' then
        raise Exception.Create('Wrong value: ' + FValue);
      FTokenType := {$IFDEF FPC}TJsonToken.jtBoolean{$ELSE}TJsonToken.Boolean{$ENDIF};
      Result := True;
      Exit;
    end else
    if (c = 'f') then
    begin
      FValue := c + _ReadValue;
      if FValue <> 'false' then
        raise Exception.Create('Wrong value: ' + FValue);
      FTokenType := {$IFDEF FPC}TJsonToken.jtBoolean{$ELSE}TJsonToken.Boolean{$ENDIF};
      Result := True;
      Exit;
    end else
    if (c = 'n') then
    begin
      FValue := c + _ReadValue;
      if FValue <> 'null' then
        raise Exception.Create('Wrong value: ' + FValue);
      FTokenType := {$IFDEF FPC}TJsonToken.jtNull{$ELSE}TJsonToken.Null{$ENDIF};
      Result := True;
      Exit;
    end else
    if (c = '-') or ((Ord(c) >= $30) and (Ord(c) <= $39)) then
    begin
      FValue := c + _ReadValue;
      if (Pos('.', FValue) > 0) or (Pos('E', FValue) > 0) or (Pos('e', FValue) > 0) then
        FTokenType := {$IFDEF FPC}TJsonToken.jtFloat{$ELSE}TJsonToken.Float{$ENDIF}
      else
        FTokenType := {$IFDEF FPC}TJsonToken.jtInteger{$ELSE}TJsonToken.Integer{$ENDIF};
      Result := True;
      Exit;
    end;

  end;
  Result := False;
end;

procedure TJsonReader.Rewind;
begin
  FBufferPos := 0;
end;

procedure TJsonReader.Skip;
var
  lDst: Integer;
begin
  lDst := Level;
  if read then
  begin
    while(Level > lDst)do
      read;
  end;
end;

function TJsonReader.ValueAsBoolean: Boolean;
begin
  Result := StrToBool(FValue);
end;

function TJsonReader.ValueAsCardinal: Cardinal;
begin
  Result := Cardinal(StrToInt(FValue));
end;

function TJsonReader.ValueAsDateTime: TDateTime;
begin
  Result := StrToDateTime(FValue);
end;

function TJsonReader.ValueAsFloat: Extended;
begin
  Result := StrToFloat(FValue);
end;

function TJsonReader.ValueAsInt64: Int64;
begin
  Result := StrToInt64(FValue);
end;

function TJsonReader.ValueAsInteger: Integer;
begin
  Result := StrToInt(FValue);
end;

function TJsonReader.ValueAsString: {$IFDEF FPC}WideString{$ELSE}string{$ENDIF};
begin
  Result := FValue;
end;

function TJsonReader.ValueAsUInt64: UInt64;
begin
  Result := StrToUInt64(FValue);
end;

function TJsonReader._ReadString: {$IFDEF FPC}WideString{$ELSE}string{$ENDIF};
var
  c: {$IFDEF FPC}WideChar{$ELSE}Char{$ENDIF};
  bEsc: Boolean;
begin
  bEsc    := False;
  Result  := '';

  while(GetNextChar(c))do
  begin
    if bEsc then
    begin
      if (c = CHR_QUOT) or (c = ESC_RSOL) or (c = ESC_SOL) then
        Result := Result + c else

      if c = ESC_BSP then
        Result := Result + CHR_BSP else

      if c = ESC_FF then
        Result := Result + CHR_FF else

      if c = ESC_LF then
        Result := Result + WS_LF else

      if c = ESC_CR then
        Result := Result + WS_CR else

      if c = ESC_TAB then
        Result := Result + WS_TAB else

      if c = ESC_UNIC then
        Result := Result + {$IFDEF FPC}WideChar{$ELSE}Char{$ENDIF}(StrToInt(_GetXChars(4)));

      bEsc := False;
    end else
    begin
      if c = ESC_RSOL then // Escape character
        bEsc := True else
      if c = CHR_QUOT then
        Break
      else
        Result := Result + c;
    end;
  end;
end;

function TJsonReader._ReadValue: {$IFDEF FPC}WideString{$ELSE}string{$ENDIF};
var
  c: {$IFDEF FPC}WideChar{$ELSE}Char{$ENDIF};
begin
  Result := '';

  while GetNextChar(c) do
  begin
    if IsWhitespace(c) then
      Continue;

    if c = NAME_SEPARATOR then
      Result := '' else
    if (c = VALUE_SEPARATOR) or (c = END_OBJECT) or (c = END_ARRAY) then
    begin
      Dec(FBufferPos);
      Exit;
    end else
      Result := Result + c;
  end;
end;

function TJsonReader._GetXChars(const X: Integer): {$IFDEF FPC}WideString{$ELSE}string{$ENDIF};
var
  i: Integer;
  c: {$IFDEF FPC}WideChar{$ELSE}Char{$ENDIF};
begin
  Result := '';
  for i := 1 to X do
    if GetNextChar(c) then
        Result := Result + c
    else
      Break;
end;

end.