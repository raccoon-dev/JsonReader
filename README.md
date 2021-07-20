Json reader for Delphi and Lazarus
===

Json Reader is working with Delphi and Lazarus. It's partially compatible with Json reader from Delphi.

How to use it
---

```
uses
  Rac.Json.Reader;
{...}
  var
    s: string;
    b: Boolean;
{...}
  json = TJsonReader.Create('{"some": "json string", "other": true}');
  try
    while json.Read do
      if json.TokenType = {$IFDEF FPC}jtPropertyName{$ELSE}TJsonToken.PropertyName{$ENDIF} then
        if json.PropertyName = 'some' then
          s := json.ReadAsString else
        if json.PropertyName = 'other' then
          b := json.ReadAsBoolean;
  finally
    json.Free;
  end;
```
