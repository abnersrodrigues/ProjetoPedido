unit Projeto.Controller.Utils;

interface

Uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  FMX.Edit;

procedure FormatarEdits(AEdit: TEdit; Out AValidacao: Boolean);

implementation

procedure FormatarEdits(AEdit: TEdit; Out AValidacao: Boolean);
var
  S: string;
  OriginalSelStart: Integer;
begin
  if AValidacao then
    Exit;
  AValidacao := True;
  try
    S := AEdit.Text.Replace('.', '').Replace('/', '');
    OriginalSelStart := AEdit.SelStart;
    if Length(S) > 4 then
      Insert('/', S, 5); // Insere após 4 dígitos (MMDD/YYYY)
    if Length(S) > 2 then
      Insert('/', S, 3); // Insere após 2 dígitos (DD/MM/YYYY)
    // Limita o tamanho a 10 caracteres (DD/MM/YYYY)
    if Length(S) > 10 then
      SetLength(S, 10);
    if AEdit.Text <> S then
    begin
      AEdit.Text := S;
      if OriginalSelStart = 3 then
        AEdit.SelStart := 4
      else if OriginalSelStart = 6 then
        AEdit.SelStart := 7
      else if OriginalSelStart > Length(S) then
        AEdit.SelStart := Length(S)
      else
        AEdit.SelStart := OriginalSelStart;
    end;
  finally
    AValidacao := False;
  end;
end;

end.
