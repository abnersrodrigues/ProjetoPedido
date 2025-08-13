unit Projeto.View.Heranca;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, System.Rtti,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts, FMX.Objects, FMX.Controls.Presentation,
  FMX.StdCtrls, FMX.Edit, FMX.ListBox, FMX.TabControl, System.Actions, FMX.ActnList, Projeto.Controller.Loading;

type
  TViewHeranca = class(TForm)
    layPrincipal: TLayout;
    Layout2: TLayout;
    Layout3: TLayout;
    Layout4: TLayout;
    Layout5: TLayout;
    lblTitulo: TLabel;
    rect_fundo_principal: TRectangle;
    lay_tela_consulta: TLayout;
    rect_fundo_tela: TRectangle;
    Rectangle1: TRectangle;
    edtBusca: TEdit;
    StyleBook: TStyleBook;
    rect_novo: TRectangle;
    Label2: TLabel;
    Layout1: TLayout;
    Rectangle3: TRectangle;
    lblQtdeItens: TLabel;
    Layout6: TLayout;
    ListBoxPrincipal: TListBox;
    TabControl: TTabControl;
    tabPainel: TTabItem;
    tabCadastro: TTabItem;
    lay_cadastro_principal: TLayout;
    Rectangle2: TRectangle;
    Rectangle4: TRectangle;
    Layout8: TLayout;
    Layout9: TLayout;
    Layout10: TLayout;
    Label1: TLabel;
    edtCodigo: TEdit;
    Rectangle5: TRectangle;
    Label4: TLabel;
    ClearEditButton1: TClearEditButton;
    SearchEditButton1: TSearchEditButton;
    Layout11: TLayout;
    Layout14: TLayout;
    rect_gravar: TRectangle;
    Label6: TLabel;
    Layout12: TLayout;
    rect_voltar: TRectangle;
    Label5: TLabel;
    ActionList: TActionList;
    actCadastro: TChangeTabAction;
    actPainel: TChangeTabAction;
    actConsultas: TChangeTabAction;
    procedure FormCreate(Sender: TObject);
  private

  public

  protected
    function FindItemParent(Obj: TFMXObject; ParentClass: TClass): TFMXObject;
  end;

var
  ViewHeranca: TViewHeranca;

implementation

{$R *.fmx}

procedure TViewHeranca.FormCreate(Sender: TObject);
begin
  TabControl.TabPosition  := TTabPosition.None;
  TabControl.ActiveTab    := tabPainel;

  Self.ClientHeight       := 690;
  Self.ClientWidth        := 850;
end;

function TViewHeranca.FindItemParent(Obj: TFMXObject; ParentClass: TClass): TFMXObject;
Begin
  Result := nil;
  if Assigned(Obj.Parent) then
  Begin
    if Obj.Parent.ClassType = ParentClass then
      Result := obj.Parent
    else
      Result := FindItemParent(Obj.Parent, ParentClass);
  End;
End;

end.
