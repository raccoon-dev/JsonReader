Json reader for Delphi and Lazarus
===

Json Reader is working with Delphi and Lazarus. It's partly compatible (but not fully) with Json reader from Delphi.

How to use it
---

```
uses
  Rac.Json.Reader;
{...}
  var
    s: string;
{...}
  json = TJsonReader.Create('{"some": "json string"}');
  try
    while json.Read do
      if json.PropertyName = 'some' then
        s := json.ValueAsString else
      if json.TokenType = {$IFDEF FPC}jtStartArray{$ELSE}StartArray{$ENDIF} then
        ProcessJsonArray(json);
  finally
    json.Free;
  end;
```
