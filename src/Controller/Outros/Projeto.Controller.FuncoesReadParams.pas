unit Projeto.Controller.FuncoesReadParams;

interface

function ExistsParam(xParam: string): boolean;

implementation

uses
  System.SysUtils;


function ExistsParam(xParam: string): boolean;
var
  i: integer;
begin
    Result := false;

    for i := 1 to ParamCount do
    begin
        if LowerCase(ParamStr(i)) = LowerCase(xParam) then
        begin
            exit(true);
        end;
    end;
end;

end.
