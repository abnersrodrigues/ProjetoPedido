unit Projeto.View.Cadastro.Produto;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, System.Generics.Collections,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls, System.Actions,  System.Rtti,
  FMX.ActnList, FMX.TabControl, FMX.Layouts, FMX.ListBox, FMX.Edit, FMX.Controls.Presentation, FMX.Objects,
  FMX.DialogService,

  Projeto.Controller.Fancy.Dialog,
  Projeto.View.Heranca,
  Projeto.Model.Conexao,
  Projeto.Controller.Produto,
  Projeto.Model.DTO.Classes,
  Projeto.Model.Interfaces,
  Projeto.Controller.Interfaces,
  Projeto.Controller.Loading;

type
  TViewCadastroProduto = class(TViewHeranca)
    Layout13: TLayout;
    Label3: TLabel;
    Rectangle6: TRectangle;
    edtDescricao: TEdit;
    Layout15: TLayout;
    Label7: TLabel;
    Rectangle7: TRectangle;
    edtVlrVenda: TEdit;
    procedure SearchEditButton1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure rect_novoClick(Sender: TObject);
    procedure rect_gravarClick(Sender: TObject);
    procedure rect_voltarClick(Sender: TObject);
    procedure ClearEditButton1Click(Sender: TObject);
  private
    FConexao: iConexao;
    FProdutoController: iProdutoController;
    FBuscarProdutos: TThread;
    FListaProduto: TObjectList<TProdutoDTO>;
    FMessage: TFancyDialog;
    function GetProdutoDTOFromForm: TProdutoDTO;
    procedure LimparCampos;
    procedure BuscaProdutos;
    procedure EditarItem(Sender: TObject);
    procedure ExcluirItem(Sender: TObject);
    procedure FocoNaDescricao;
    procedure FocoNoValorVenda;
  public
    { Public declarations }
  end;

var
  ViewCadastroProduto: TViewCadastroProduto;

implementation

{$R *.fmx}

procedure TViewCadastroProduto.ClearEditButton1Click(Sender: TObject);
begin
  inherited;
  BuscaProdutos;
end;

procedure TViewCadastroProduto.FormCreate(Sender: TObject);
begin
  inherited;

  FConexao                := TModelConexao.New;
  FMessage                := TFancyDialog.Create(Self);
  FProdutoController      := TProdutoController.New(FConexao);
  FBuscarProdutos         := nil;
end;

procedure TViewCadastroProduto.FormDestroy(Sender: TObject);
begin
  inherited;

  if Assigned(FBuscarProdutos) then
  begin
    FBuscarProdutos.Terminate;
    FBuscarProdutos.WaitFor;
    FreeAndNil(FBuscarProdutos);
  end;

  FProdutoController  := nil;
  FConexao            := nil;
  FreeAndNil(FListaProduto);


  if Assigned(FMessage)then
    FreeAndNil(FMessage);
end;

procedure TViewCadastroProduto.FormShow(Sender: TObject);
begin
  inherited;
  BuscaProdutos;
end;

procedure TViewCadastroProduto.rect_gravarClick(Sender: TObject);
Var
  ProdutoDTO: TProdutoDTO;
  CodigoProduto: Integer;
begin
  inherited;

  ProdutoDTO := nil;
  try
    try
      ProdutoDTO := GetProdutoDTOFromForm;

      if TabControl.Tag = 1 then
      begin
        CodigoProduto := FProdutoController.Insert(ProdutoDTO);

        if CodigoProduto > 0 then
        begin
          edtCodigo.Text := IntToStr(CodigoProduto);
          FMessage.Show(TIconDialog.Success, 'Sucesso', 'Código: ' + IntToStr(CodigoProduto) + sLineBreak + 'Produto inserido!');
        end
        else
        begin
          FMessage.Show(TIconDialog.Error, 'Atenção', 'Erro ao inserir produto. Verifique o log para mais detalhes.');
        end;
      end
      else
      begin
        if FProdutoController.Update(ProdutoDTO) then
          FMessage.Show(TIconDialog.Success, 'Sucesso', 'Produto alterado com sucesso!');
      end;

      LimparCampos;
      BuscaProdutos;
      actPainel.Execute;
    except
      on E: EArgumentException do
        FMessage.Show(TIconDialog.Error, 'Atenção', 'Erro de validação: ' + E.Message);
      on E: Exception do
        FMessage.Show(TIconDialog.Error, 'Atenção', 'Erro inesperado: ' + E.Message);
    end;
  finally
    FreeAndNil(ProdutoDTO);
  end;
end;

procedure TViewCadastroProduto.rect_novoClick(Sender: TObject);
begin
  inherited;
  edtCodigo.Enabled := false;
  TabControl.Tag := 1;
  LimparCampos;
  FocoNaDescricao;
  actCadastro.Execute;
end;

procedure TViewCadastroProduto.ExcluirItem(Sender: TObject);
Begin
  TDialogService.MessageDialog(
    'Deseja excluir este produto?',
    TMsgDlgType.mtConfirmation,
    [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo],
    TMsgDlgBtn.mbYes,
    0,
    procedure(const AResult: TModalResult)
    var
      ListBoxItem: TListBoxItem;
    begin
      if AResult = mrYes then
      begin
        if Sender is TFmxObject then
        begin
          ListBoxItem := TListBoxItem(FindItemParent(Sender as TFmxObject, TListBoxItem));
          if Assigned(ListBoxItem) then
          begin
            if not FProdutoController.Delete(ListBoxItem.Tag) then
              FMessage.Show(TIconDialog.Error, 'Atenção', 'Impossivel excluir produto verifique log.')
            else
            begin
              FMessage.Show(TIconDialog.Success, 'Sucesso', 'Produto excluído.');
              BuscaProdutos;
            end;
          end;
        end;
      end;
    end
  );
end;

procedure TViewCadastroProduto.FocoNaDescricao;
begin
  TThread.CreateAnonymousThread(procedure
  begin
      TThread.Synchronize( nil,
      procedure
        begin
          self.ActiveControl := edtDescricao;
          edtDescricao.SetFocus;
        end);
    end).Start;
end;

procedure TViewCadastroProduto.FocoNoValorVenda;
begin
  TThread.CreateAnonymousThread(procedure
  begin
      TThread.Synchronize( nil,
      procedure
        begin
          self.ActiveControl := edtVlrVenda;
          edtVlrVenda.SetFocus;
        end);
    end).Start;
end;

procedure TViewCadastroProduto.EditarItem(Sender: TObject);
Var
  ProdutoDTO: TProdutoDTO;
  ListBoxItem: TListBoxItem;
begin
  ListBoxItem := TListBoxItem(FindItemParent(Sender as TFmxObject, TListBoxItem));

  ProdutoDTO        := FProdutoController.GetByCode(ListBoxItem.Tag);

  if Assigned(ProdutoDTO) then
  begin
    edtCodigo.Text        := ProdutoDTO.Codigo.ToString;
    edtCodigo.Enabled     := false;

    edtDescricao.Text     := ProdutoDTO.Descricao;
    edtDescricao.Enabled  := true;

    edtVlrVenda.Text      := CurrToStr(ProdutoDTO.VlrVenda);
    edtVlrVenda.Enabled   := true;

    FreeAndNil(ProdutoDTO);
  end
  else
  begin
    FMessage.Show(TIconDialog.Warning, 'Atenção', 'Produto não encontrado.');
  end;

  TabControl.Tag := 2;
  actCadastro.Execute;
end;

procedure TViewCadastroProduto.rect_voltarClick(Sender: TObject);
begin
  inherited;
  TabControl.Tag := 0;
  LimparCampos;
  BuscaProdutos;
  actPainel.Execute;
end;

procedure TViewCadastroProduto.SearchEditButton1Click(Sender: TObject);
begin
  inherited;
  BuscaProdutos;
end;

procedure TViewCadastroProduto.BuscaProdutos;
begin
  TLoading.Show(Self, 'Buscando produtos...');

  TThread.CreateAnonymousThread(procedure
  var
    LListaProdutos: TObjectList<TProdutoDTO>;
    LSearchText: string;
  begin
    Sleep(500);

    TThread.Synchronize(nil, procedure
    begin
      LSearchText := edtBusca.Text;
    end);

    if LSearchText <> '' then
      LListaProdutos := FProdutoController.GetByCodigoOrDescricao(LSearchText)
    else
      LListaProdutos := FProdutoController.GetAll;

    TThread.Synchronize(nil, procedure
    var
      ListBoxItem: TListBoxItem;
      i: Integer;
    begin
      ListBoxPrincipal.Items.Clear;
      ListBoxPrincipal.BeginUpdate;
      try
        if Assigned(LListaProdutos) then
        begin
          for i := 0 to Pred(LListaProdutos.Count) do
          begin
            ListBoxItem             := TListBoxItem.Create(ListBoxPrincipal);
            ListBoxItem.Parent      := ListBoxPrincipal;
            ListBoxItem.StyleLookup := 'StyleItemProdutos';
            ListBoxItem.Height      := 70;

            ListBoxItem.Tag         := LListaProdutos.Items[i].Codigo;
            ListBoxItem.TagString   := LListaProdutos.Items[i].Descricao;

            ListBoxItem.StylesData['lblCodigo']     := LListaProdutos.Items[i].Codigo.ToString;
            ListBoxItem.StylesData['lblDescricao']  := LListaProdutos.Items[i].Descricao;
            ListBoxItem.StylesData['lblVlrVenda']   := FormatFloat('#,##0.00', LListaProdutos.Items[i].VlrVenda);

            ListBoxItem.StylesData['rect_editar.OnClick']    := TValue.From<TNotifyEvent>(EditarItem);
            ListBoxItem.StylesData['rect_excluir.OnClick']   := TValue.From<TNotifyEvent>(ExcluirItem);

            ListBoxPrincipal.AddObject(ListBoxItem);
          end;
        end;
      finally
        ListBoxPrincipal.EndUpdate;
        FreeAndNil(LListaProdutos);

        lblQtdeItens.Text := ListBoxPrincipal.Items.Count.ToString+' item(s) exibidos';
        TLoading.Hide;
      end;
    end);
  end).Start;
end;

function TViewCadastroProduto.GetProdutoDTOFromForm: TProdutoDTO;
var
  LCodigo: Integer;
  LVlrVenda: Currency;
begin
  if Trim(edtDescricao.Text).IsEmpty then
  begin
    raise EArgumentException.Create('A descrição do produto não pode ser vazia. Por favor, preencha o campo.');
  end;

  if not TryStrToCurr(edtVlrVenda.Text, LVlrVenda) then
  begin
    raise EArgumentException.Create('Valor de venda inválido.');
  end;

  LCodigo := StrToIntDef(edtCodigo.Text, 0);

  Result := TProdutoDTO.Create(LCodigo, edtDescricao.Text, LVlrVenda);
end;

procedure TViewCadastroProduto.LimparCampos;
begin
  edtCodigo.Text    := '';
  edtDescricao.Text := '';
  edtVlrVenda.Text  := '';
  edtDescricao.SetFocus;
end;

end.
