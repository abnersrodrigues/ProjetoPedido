unit Projeto.View.Cadastro.Pedido;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, System.Generics.Collections,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls, System.Actions, System.Rtti,
  FMX.ActnList, FMX.TabControl, FMX.Layouts, FMX.ListBox, FMX.Edit, FMX.Controls.Presentation, FMX.Objects,
  FMX.DialogService,

  Projeto.View.Heranca,
  Projeto.Controller.Fancy.Dialog,
  Projeto.Model.Conexao,
  Projeto.Controller.Produto,
  Projeto.Controller.Cliente,
  Projeto.Controller.PedidoHeader,
  Projeto.Controller.PedidoItem,
  Projeto.Model.DTO.Classes,
  Projeto.Model.Interfaces,
  Projeto.Controller.Interfaces,
  Projeto.Controller.Utils,
  Projeto.Controller.Types
  ;

type
  TViewCadastroPedidos = class(TViewHeranca)
    Layout13: TLayout;
    Rectangle6: TRectangle;
    Layout15: TLayout;
    Layout16: TLayout;
    lblDadosPedido: TLabel;
    Layout17: TLayout;
    Layout18: TLayout;
    Layout19: TLayout;
    Layout20: TLayout;
    Layout21: TLayout;
    Label7: TLabel;
    Label8: TLabel;
    edt_dt_emissao_pedido: TEdit;
    edtCliente: TEdit;
    edt_status_pedido: TEdit;
    Label9: TLabel;
    Rectangle7: TRectangle;
    Rectangle8: TRectangle;
    Rectangle9: TRectangle;
    lay_lancamento_item: TLayout;
    Rectangle10: TRectangle;
    Layout23: TLayout;
    Label10: TLabel;
    Layout27: TLayout;
    Layout28: TLayout;
    edtProdutos: TEdit;
    Label13: TLabel;
    Rectangle13: TRectangle;
    Layout24: TLayout;
    edtVlrProduto: TEdit;
    Label11: TLabel;
    Rectangle11: TRectangle;
    Layout25: TLayout;
    edtQtde: TEdit;
    Label12: TLabel;
    Rectangle12: TRectangle;
    Layout26: TLayout;
    Layout30: TLayout;
    rect_lancar_item_pedido: TRectangle;
    lbl_lancamento_item: TLabel;
    ListBoxItens: TListBox;
    Layout29: TLayout;
    Rectangle15: TRectangle;
    Layout31: TLayout;
    Rectangle16: TRectangle;
    Layout32: TLayout;
    Layout33: TLayout;
    lblVlrTotalPedido: TLabel;
    Label16: TLabel;
    Layout34: TLayout;
    Label17: TLabel;
    Cic_Pendente: TCircle;
    Label18: TLabel;
    cic_em_processamento: TCircle;
    Label19: TLabel;
    cic_concluido: TCircle;
    Label20: TLabel;
    cic_cancelado: TCircle;
    Label21: TLabel;
    SearchEditButton2: TSearchEditButton;
    SearchEditButton3: TSearchEditButton;
    SearchEditButton4: TSearchEditButton;
    Layout35: TLayout;
    Label15: TLabel;
    Rectangle14: TRectangle;
    edt_codigo_pedido: TEdit;
    lay_cancelar_lancamento_item: TLayout;
    rect_cancelar_lancamento_item: TRectangle;
    Label3: TLabel;
    procedure rect_voltarClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure rect_novoClick(Sender: TObject);
    procedure edt_dt_emissao_pedidoTyping(Sender: TObject);
    procedure SearchEditButton4Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure SearchEditButton3Click(Sender: TObject);
    procedure SearchEditButton2Click(Sender: TObject);
    procedure rect_lancar_item_pedidoClick(Sender: TObject);
    procedure edtVlrProdutoKeyDown(Sender: TObject; var Key: Word;
      var KeyChar: Char; Shift: TShiftState);
    procedure edtQtdeKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char;
      Shift: TShiftState);
    procedure edtProdutosKeyDown(Sender: TObject; var Key: Word;
      var KeyChar: Char; Shift: TShiftState);
    procedure rect_gravarClick(Sender: TObject);
    procedure rect_cancelar_lancamento_itemClick(Sender: TObject);
    procedure edt_dt_emissao_pedidoExit(Sender: TObject);
    procedure SearchEditButton1Click(Sender: TObject);
  private
    FConexao: iConexao;

    FPedidoController: iPedidoHeaderController;
    FPedido: TPedidoHeaderDTO;
    FBuscarPedidos: TThread;

    FPedidoItemController: iPedidoItemController;
    FBuscaPedidosItens: TThread;
    FItemPedido: TPedidoItemDTO;

    FIsFormatting: Boolean;
    FMessage: TFancyDialog;

    procedure BuscaPedidos;
    procedure BuscaPedidosItens(const APedido: Integer);

    procedure EditarPedido(Sender: TObject);
    procedure ExcluirPedido(Sender: TObject);
    procedure EditarItemPedido(Sender: TObject);
    procedure ExcluirItemPedido(Sender: TObject);

    procedure LimpaDadosItens;
    procedure LimpaDadosHeader;
    procedure FocoNaQuantidade;
    procedure FocoNoValorUnitarioProduto;
    procedure FocoNoProduto;
    procedure ValidaLancamentoItem;
    procedure ValidaLancamentoPedido;
    procedure FocoNoCliente;
    procedure FocoNoStatusPedido;
    procedure FocoNoDataEmissao;
    procedure SetarTituloDadosPedido;
  public

  end;

function FormatCurrencyBrazil(const Value: Currency): string;

var
  ViewCadastroPedidos: TViewCadastroPedidos;

implementation

{$R *.fmx}

uses Projeto.View.Consultas;

function FormatCurrencyBrazil(const Value: Currency): string;
var
  LFormatSettings: TFormatSettings;
begin
  LFormatSettings := TFormatSettings.Create;
  LFormatSettings.DecimalSeparator := ',';
  LFormatSettings.ThousandSeparator := '.';
  LFormatSettings.CurrencyDecimals := 2;
  LFormatSettings.CurrencyString := 'R$ ';
  LFormatSettings.CurrencyFormat := 0;
  Result := FormatFloat('#,##0.00', Value, LFormatSettings);
end;

procedure TViewCadastroPedidos.BuscaPedidos;
begin
  TThread.CreateAnonymousThread(procedure
  var
    LListaPedidos: TObjectList<TPedidoHeaderDTO>;
    LSearchText: string;
  begin
    Sleep(500);

    TThread.Synchronize(nil, procedure
    begin
      LSearchText := edtBusca.Text;
    end);

    if LSearchText <> '' then
      LListaPedidos := FPedidoController.GetByCodigoOrNome(LSearchText)
    else
      LListaPedidos := FPedidoController.GetAll;

    TThread.Synchronize(nil, procedure
    var
      ListBoxItem: TListBoxItem;
      i: Integer;
    begin
      ListBoxPrincipal.Items.Clear;
      ListBoxPrincipal.BeginUpdate;
      try
        if Assigned(LListaPedidos) then
        begin
          for i := 0 to Pred(LListaPedidos.Count) do
          begin
            ListBoxItem             := TListBoxItem.Create(ListBoxPrincipal);
            ListBoxItem.Parent      := ListBoxPrincipal;
            ListBoxItem.StyleLookup := 'StyleItemPedidos';
            ListBoxItem.Height      := 70;

            ListBoxItem.Tag         := LListaPedidos.Items[i].Codigo;
            ListBoxItem.TagString   := LListaPedidos.Items[i].CodigoCliente.ToString;

            ListBoxItem.StylesData['lblCodigo']     := LListaPedidos.Items[i].Codigo.ToString;
            ListBoxItem.StylesData['lblNome']       := LListaPedidos.Items[i].NomeCliente;
            ListBoxItem.StylesData['lblDtEmissao']  := FormatDateTime('dd/MM/yyy', LListaPedidos.Items[i].DtEmissao);
            ListBoxItem.StylesData['lblVlrTotal']   := FormatCurrencyBrazil(LListaPedidos.Items[i].VlrTotal); //FormatFloat('#,##0.00', LListaPedidos.Items[i].VlrTotal);
            ListBoxItem.StylesData['lblStatus']     := LListaPedidos.Items[i].DescricaoStatus;

            if UpperCase(LListaPedidos.Items[i].DescricaoStatus) = UpperCase('Cancelado') then
            begin
              ListBoxItem.StylesData['rect_status.Fill.Color']            := cic_cancelado.Fill.Color;
              ListBoxItem.StylesData['lblStatus.TextSettings.FontColor']  := $FFE9FAE9;
            end;
            if UpperCase(LListaPedidos.Items[i].DescricaoStatus) = UpperCase('Em Processamento') then
            begin
              ListBoxItem.StylesData['rect_status.Fill.Color']            := cic_em_processamento.Fill.Color;
              ListBoxItem.StylesData['lblStatus.TextSettings.FontColor']  := $FFE9FAE9;
            end;
            if UpperCase(LListaPedidos.Items[i].DescricaoStatus) = UpperCase('Concluído') then
            begin
              ListBoxItem.StylesData['rect_status.Fill.Color']            := cic_concluido.Fill.Color;
              ListBoxItem.StylesData['lblStatus.TextSettings.FontColor']  := $FFE9FAE9;
            end;
            if UpperCase(LListaPedidos.Items[i].DescricaoStatus) = UpperCase('Pendente') then
            begin
              ListBoxItem.StylesData['rect_status.Fill.Color']            := cic_pendente.Fill.Color;
              ListBoxItem.StylesData['lblStatus.TextSettings.FontColor']  := $FFE9FAE9;
            end;

            ListBoxItem.StylesData['rect_editar.OnClick']    := TValue.From<TNotifyEvent>(EditarPedido);
            ListBoxItem.StylesData['rect_excluir.OnClick']   := TValue.From<TNotifyEvent>(ExcluirPedido);

            ListBoxPrincipal.AddObject(ListBoxItem);
          end;
        end;
      finally
        ListBoxPrincipal.EndUpdate;
        FreeAndNil(LListaPedidos);
        lblQtdeItens.Text := ListBoxPrincipal.Items.Count.ToString+' item(s) exibidos';
      end;
    end);
  end).Start;
end;

procedure TViewCadastroPedidos.BuscaPedidosItens(const APedido: Integer);

begin
  TThread.CreateAnonymousThread(procedure
  var
    LSearchItem: integer;
    FListaPedidoItem: TObjectList<TPedidoItemDTO>;
  begin
    TThread.Synchronize(nil, procedure
    begin
      LSearchItem := APedido;
    end);

    FListaPedidoItem := FPedidoItemController.GetItemsByPedidoCode(LSearchItem);

    TThread.Synchronize(nil, procedure
    var
      ListBoxItem: TListBoxItem;
      i: Integer;
      LValorTotalPedido: Currency;
    begin
      LValorTotalPedido := 0;

      ListBoxItens.Items.Clear;
      ListBoxItens.BeginUpdate;
      try
        if Assigned(FListaPedidoItem) then
        begin
          for i := 0 to Pred(FListaPedidoItem.Count) do
          begin
            ListBoxItem             := TListBoxItem.Create(ListBoxItens);
            ListBoxItem.Parent      := ListBoxItens;
            ListBoxItem.StyleLookup := 'StyleItemProdutosItens';
            ListBoxItem.Height      := 70;

            ListBoxItem.Tag         := FListaPedidoItem.Items[i].Codigo;
            ListBoxItem.TagString   := FListaPedidoItem.Items[i].CodigoProduto.ToString;

            ListBoxItem.StylesData['lblCodigo']       := FListaPedidoItem.Items[i].Codigo.ToString;
            ListBoxItem.StylesData['lblProduto']      := FListaPedidoItem.Items[i].DescricaoProduto;
            ListBoxItem.StylesData['lblQtde']         := FListaPedidoItem.Items[i].Qtde.ToString;
            ListBoxItem.StylesData['lblVlrUnitario']  := FormatFloat('#,##0.00', FListaPedidoItem.Items[i].VlrUnitario);
            ListBoxItem.StylesData['lblVlrTotal']     := FormatFloat('#,##0.00', FListaPedidoItem.Items[i].VlrTotal);

            LValorTotalPedido := LValorTotalPedido + FListaPedidoItem.Items[i].VlrTotal;

            ListBoxItem.StylesData['rect_editar.OnClick']    := TValue.From<TNotifyEvent>(EditarItemPedido);
            ListBoxItem.StylesData['rect_excluir.OnClick']   := TValue.From<TNotifyEvent>(ExcluirItemPedido);

            ListBoxItens.AddObject(ListBoxItem);
          end;
        end;
      finally
        ListBoxItens.EndUpdate;
        lblQtdeItens.Text       := ListBoxItens.Items.Count.ToString+' item(s) exibidos';
        lblVlrTotalPedido.Text  := 'R$ '+FormatFloat('#,##0.00', LValorTotalPedido);

        FreeAndNil(FListaPedidoItem);
      end;
    end);
  end).Start;
end;

procedure TViewCadastroPedidos.SetarTituloDadosPedido;
begin
  lblDadosPedido.Text := 'Dados Pedido | ' + edt_codigo_pedido.Text;
end;

procedure TViewCadastroPedidos.ExcluirItemPedido(Sender: TObject);
begin
  TDialogService.MessageDialog(
    'Deseja excluir este item do pedido?',
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
          ListBoxItem := TListBoxItem(FindItemParent(TFmxObject(Sender), TListBoxItem));
          if Assigned(ListBoxItem) then
          begin
            if not FPedidoItemController.Delete(ListBoxItem.Tag) then
              FMessage.Show(TIconDialog.Error, 'Atenção', 'Impossivel excluir item do pedido verifique log.')
            else
            begin
              FMessage.Show(TIconDialog.Success, 'Sucesso', 'Item excluído.');
              BuscaPedidosItens(edt_codigo_pedido.Text.ToInteger);
            end;
          end;
        end;
      end;
    end
  );
end;

procedure TViewCadastroPedidos.ExcluirPedido(Sender: TObject);
begin
  TDialogService.MessageDialog(
    'Deseja excluir este item do pedido?',
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
            if not FPedidoController.Delete(ListBoxItem.Tag) then
              FMessage.Show(TIconDialog.Error, 'Atenção', 'Impossivel excluir pedido verifique log.')
            else
            begin
              FMessage.Show(TIconDialog.Success, 'Sucesso', 'Pedido excluído.');
              BuscaPedidos;
            end;
          end;
        end;
      end;
    end
  );
end;

procedure TViewCadastroPedidos.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  inherited;

  if Assigned(FMessage) then
    FreeAndNil(FMessage);
  if Assigned(FItemPedido) then
    FreeAndNil(FItemPedido);
  if Assigned(FPedido) then
    FreeAndNil(FPedido);

  if Assigned(ViewCadastroConsultas) then
    FreeAndNil(ViewCadastroConsultas);
end;

procedure TViewCadastroPedidos.FormCreate(Sender: TObject);
begin
  inherited;

  FConexao               := TModelConexao.New;
  FPedidoController      := TPedidoHeaderController.New(FConexao);
  FBuscarPedidos         := nil;
  FMessage               := TFancyDialog.Create(Self);

  FPedidoItemController  := TPedidoItemController.New(FConexao);
  FBuscaPedidosItens     := nil;

  Self.Width             := 968;
  Self.Height            := 728;
end;

procedure TViewCadastroPedidos.FormShow(Sender: TObject);
begin
  inherited;
  BuscaPedidos;

end;

procedure TViewCadastroPedidos.rect_cancelar_lancamento_itemClick(
  Sender: TObject);
begin
  lay_lancamento_item.Tag               := 0;

  lbl_lancamento_item.Text              := '+ Adicionar Item';
  lbl_lancamento_item.Tag               := 0;

  rect_lancar_item_pedido.Fill.Color    := $FF5498D7;
  lay_cancelar_lancamento_item.Visible  := false;

  LimpaDadosItens;
end;

procedure TViewCadastroPedidos.rect_gravarClick(Sender: TObject);
begin
  inherited;

  try
    if StrToIntDef(edt_codigo_pedido.Text, 0) > 0 then
      FPedidoController.Update(FPedido);
  finally
    rect_voltarClick(rect_voltar);
  end;
end;

procedure TViewCadastroPedidos.rect_lancar_item_pedidoClick(Sender: TObject);
begin
  inherited;

  ValidaLancamentoPedido;

  if ((edt_codigo_pedido.Text = '') or (StrToIntDef(edt_codigo_pedido.Text, 0) <= 0)) then
  begin
    FPedido.DtEmissao       := StrToDateDef(edt_dt_emissao_pedido.Text, now());
    edt_codigo_pedido.Text  := FPedidoController.Insert(FPedido).ToString;
    SetarTituloDadosPedido;
  end;

  ValidaLancamentoItem;

  try
    try
      FItemPedido                   := TPedidoItemDTO.Create;
      FItemPedido.Codigo            := lay_lancamento_item.Tag;
      FItemPedido.CodigoPedido      := StrToIntDef(edt_codigo_pedido.Text, 0);
      FItemPedido.CodigoProduto     := edtProdutos.Tag;
      FItemPedido.DescricaoProduto  := edtProdutos.Text;
      FItemPedido.Qtde              := StrToIntDef(edtQtde.Text, 1);
      FItemPedido.VlrUnitario       := StrToFloatDef(edtVlrProduto.Text, 0);
      FItemPedido.VlrTotal          := (StrToIntDef(edtQtde.Text, 1)*StrToFloatDef(edtVlrProduto.Text, 0));

      case lbl_lancamento_item.Tag of
        0: FItemPedido.Codigo       := FPedidoItemController.Insert(FItemPedido);
        1: var Atualizado: Boolean := FPedidoItemController.Update(FItemPedido);
      end;
    except
      raise Exception.Create('Erro: Falha na transação com banco de dados');
    end;
  finally
    rect_cancelar_lancamento_itemClick(rect_cancelar_lancamento_item);
    FocoNoProduto;
    BuscaPedidosItens(StrToIntDef(edt_codigo_pedido.Text, 0));

    if Assigned(FItemPedido) then
      FreeAndNil(FItemPedido);
  end;
end;

procedure TViewCadastroPedidos.ValidaLancamentoPedido;
begin
  if (edtCliente.Text = '') or ((edtCliente.Tag = 0) and (edtCliente.Text <> '')) then
  begin
    raise Exception.Create('Necessário ter um cliente lançado');
    FocoNoCliente;
  end;
  if (edt_status_pedido.Text = '') or ((edt_status_pedido.Tag = 0) and (edt_status_pedido.Text <> '')) then
  begin
    raise Exception.Create('Necessário ter status pedido');
    FocoNoStatusPedido;
  end;
  if (edt_dt_emissao_pedido.Text = '') or (StrToDateDef(edt_dt_emissao_pedido.Text, 0) <= 0) then
  begin
    raise Exception.Create('Necessário data emissão');
    FocoNoDataEmissao;
  end;
end;

procedure TViewCadastroPedidos.ValidaLancamentoItem;
begin
  if (edtProdutos.Text = '') or ((edtProdutos.Tag = 0) and (edtProdutos.Text <> '')) then
  begin
    raise Exception.Create('Necessário ter um produto lançado');
    FocoNoProduto;
  end;
  if (edtQtde.Text = '') or (StrToIntDef(edtQtde.Text, 0) <= 0) then
  begin
    raise Exception.Create('Necessário ter quantidade de pelo menos 1');
    FocoNaQuantidade;
  end;
  if (edtVlrProduto.Text = '') or (StrToFloatDef(edtVlrProduto.Text, 0) <= 0) then
  begin
    raise Exception.Create('Valor não pode ser negativo ou zerado');
    FocoNoValorUnitarioProduto;
  end;
end;

procedure TViewCadastroPedidos.LimpaDadosItens;
begin
  edtProdutos.Tag     := 0;
  edtProdutos.Text    := '';
  edtVlrProduto.Text  := '';
  edtQtde.Text        := '';
end;

procedure TViewCadastroPedidos.LimpaDadosHeader;
begin
  edt_codigo_pedido.Text      := '';

  edtCliente.Tag              := 0;
  edtCliente.Text             := '';

  edt_dt_emissao_pedido.text  := '';

  edt_status_pedido.Text      := '';
  edt_status_pedido.tag       := 0;
end;

procedure TViewCadastroPedidos.FocoNoProduto;
begin
  TThread.CreateAnonymousThread(procedure
  begin
      TThread.Synchronize( nil,
      procedure
        begin
          self.ActiveControl := edtProdutos;
          edtProdutos.SetFocus;
        end);
    end).Start;
end;

procedure TViewCadastroPedidos.FocoNoCliente;
begin
  TThread.CreateAnonymousThread(procedure
  begin
      TThread.Synchronize( nil,
      procedure
        begin
          self.ActiveControl := edtCliente;
          edtCliente.SetFocus;
        end);
    end).Start;
end;

procedure TViewCadastroPedidos.FocoNoStatusPedido;
begin
  TThread.CreateAnonymousThread(procedure
  begin
      TThread.Synchronize( nil,
      procedure
        begin
          self.ActiveControl := edt_status_pedido;
          edt_status_pedido.SetFocus;
        end);
    end).Start;
end;

procedure TViewCadastroPedidos.FocoNoDataEmissao;
begin
  TThread.CreateAnonymousThread(procedure
  begin
      TThread.Synchronize( nil,
      procedure
        begin
          self.ActiveControl := edt_dt_emissao_pedido;
          edt_dt_emissao_pedido.SetFocus;
        end);
    end).Start;
end;

procedure TViewCadastroPedidos.FocoNaQuantidade;
begin
  TThread.CreateAnonymousThread(procedure
  begin
      TThread.Synchronize( nil,
      procedure
        begin
          self.ActiveControl := edtQtde;
          edtQtde.SetFocus;
        end);
    end).Start;
end;

procedure TViewCadastroPedidos.FocoNoValorUnitarioProduto;
begin
  TThread.CreateAnonymousThread(procedure
  begin
      TThread.Synchronize( nil,
      procedure
        begin
          self.ActiveControl := edtVlrProduto;
          edtVlrProduto.SetFocus;
        end);
    end).Start;
end;

procedure TViewCadastroPedidos.rect_novoClick(Sender: TObject);
begin
  inherited;

  FPedido                     := TPedidoHeaderDTO.Create;

  edt_codigo_pedido.Text      := '';
  edt_dt_emissao_pedido.Text  := FormatDateTime('dd/MM/yyyy', Now());
  lay_cadastro_principal.tag  := 0;
  actCadastro.Execute;
end;

procedure TViewCadastroPedidos.rect_voltarClick(Sender: TObject);
begin
  inherited;

  lblDadosPedido.Text     := 'Dados Pedido';
  lblVlrTotalPedido.Text  := 'R$ 0,00';

  ListBoxItens.Items.Clear;

  LimpaDadosItens;
  LimpaDadosHeader;

  if Assigned(FPedido) then
    FreeAndNil(FPedido);

  BuscaPedidos;

  lay_cadastro_principal.tag := 0;
  actPainel.Execute;
end;

procedure TViewCadastroPedidos.SearchEditButton1Click(Sender: TObject);
begin
  inherited;
  BuscaPedidos;
end;

procedure TViewCadastroPedidos.SearchEditButton2Click(Sender: TObject);
begin
  inherited;

  try
    ViewCadastroConsultas := TViewCadastroConsultas.Create(Self, TFormOrigem(formPedido), TTipoPesquisa(pProdutos), false);

    with ViewCadastroConsultas do
    begin
      Height  := Self.Height;
      Width   := Self.Width;

      ShowModal;

      edtProdutos.Tag     := ViewCadastroConsultas.Codigo;
      edtProdutos.Text    := ViewCadastroConsultas.Descricao;
      edtVlrProduto.Text  := FormatFloat('#,##0.00', ViewCadastroConsultas.VlrProduto);
    end;

  finally
    FreeAndNil(ViewCadastroConsultas);
    FocoNaQuantidade;
  end;
end;

procedure TViewCadastroPedidos.SearchEditButton3Click(Sender: TObject);
begin
  inherited;

  try
    ViewCadastroConsultas := TViewCadastroConsultas.Create(Self, TFormOrigem(formPedido), TTipoPesquisa(pStatusPedidos), false);

    with ViewCadastroConsultas do
    begin
      Height  := Self.Height;
      Width   := Self.Width;

      ShowModal;

      edt_status_pedido.Tag   := ViewCadastroConsultas.Codigo;
      edt_status_pedido.Text  := ViewCadastroConsultas.Descricao;

      FPedido.CodigoStatus    := ViewCadastroConsultas.Codigo;
      FPedido.DescricaoStatus := ViewCadastroConsultas.Descricao;
    end;

  finally
    FreeAndNil(ViewCadastroConsultas);
  end;
end;

procedure TViewCadastroPedidos.SearchEditButton4Click(Sender: TObject);
Var
  ViewCadastroConsultas: TViewCadastroConsultas;
begin
  inherited;

  try
    ViewCadastroConsultas := TViewCadastroConsultas.Create(Self, TFormOrigem(formPedido), TTipoPesquisa(pClientes), false);

    with ViewCadastroConsultas do
    begin
      Height  := Self.Height;
      Width   := Self.Width;

      ShowModal;

      edtCliente.tag  := ViewCadastroConsultas.Codigo;
      edtCliente.Text := ViewCadastroConsultas.Descricao;

      FPedido.CodigoCliente := ViewCadastroConsultas.Codigo;
      FPedido.NomeCliente   := ViewCadastroConsultas.Descricao;
    end;

  finally
    FreeAndNil(ViewCadastroConsultas);
  end;
end;

procedure TViewCadastroPedidos.edtProdutosKeyDown(Sender: TObject;
  var Key: Word; var KeyChar: Char; Shift: TShiftState);
begin
  inherited;

  if Key = 13 then
  begin
    if (StrToIntDef(edtProdutos.Text, 0) > 0) then
    begin
      try
        ViewCadastroConsultas := TViewCadastroConsultas.Create(Self, TFormOrigem(formPedido), TTipoPesquisa(pProdutos), true);

        ViewCadastroConsultas.BuscaProdutosByCodigo(StrToIntDef(edtProdutos.Text, 0));

        edtProdutos.Tag     := ViewCadastroConsultas.Codigo;
        edtProdutos.Text    := ViewCadastroConsultas.Descricao;
        edtVlrProduto.Text  := FormatFloat('#,##0.00', ViewCadastroConsultas.VlrProduto);


      finally
        FreeAndNil(ViewCadastroConsultas);
        FocoNaQuantidade;
      end;

    end;
  end;
end;

procedure TViewCadastroPedidos.edtQtdeKeyDown(Sender: TObject; var Key: Word;
  var KeyChar: Char; Shift: TShiftState);
begin
  inherited;

  if Key = 13 then
  begin
    FocoNoValorUnitarioProduto;
  end;
end;

procedure TViewCadastroPedidos.edtVlrProdutoKeyDown(Sender: TObject;
  var Key: Word; var KeyChar: Char; Shift: TShiftState);
begin
  inherited;

  if Key = 13 then
    rect_lancar_item_pedidoClick(rect_lancar_item_pedido);
end;

procedure TViewCadastroPedidos.edt_dt_emissao_pedidoExit(Sender: TObject);
begin
  inherited;

  FPedido.DtEmissao := StrToDateDef(edt_dt_emissao_pedido.Text, Date);
end;

procedure TViewCadastroPedidos.edt_dt_emissao_pedidoTyping(Sender: TObject);
begin
  inherited;

  FormatarEdits(edt_dt_emissao_pedido, FIsFormatting);
end;

procedure TViewCadastroPedidos.EditarItemPedido(Sender: TObject);
Var
  ListBoxItem: TListBoxItem;
begin
  ListBoxItem                 := TListBoxItem(FindItemParent(Sender as TFmxObject, TListBoxItem));
  rect_lancar_item_pedido.Tag := ListBoxItem.Index;

  try
    FItemPedido               := FPedidoItemController.GetByCode(ListBoxItem.Tag);

    lay_lancamento_item.Tag     := FItemPedido.Codigo;

    edtProdutos.Text            := FItemPedido.DescricaoProduto;
    edtProdutos.Tag             := FItemPedido.CodigoProduto;

    edtQtde.Text                := FItemPedido.Qtde.ToString;
    edtVlrProduto.Text          := FormatFloat('#,##0.00', FItemPedido.VlrUnitario);

    lbl_lancamento_item.Text              := 'Atualizar Item';
    lbl_lancamento_item.Tag               := 1;

    rect_lancar_item_pedido.Fill.Color    := $FFCF4B4B;
    lay_cancelar_lancamento_item.Visible  := true;
  Finally
    FreeAndNIl(FItemPedido);
  end;
end;

procedure TViewCadastroPedidos.EditarPedido(Sender: TObject);
Var
  ListBoxItem: TListBoxItem;
begin
  ListBoxItem                 := TListBoxItem(FindItemParent(Sender as TFmxObject, TListBoxItem));

  if Assigned(FPedido) then
    FreeAndNil(FPedido);

  FPedido                     := FPedidoController.GetByCode(ListBoxItem.Tag);

  edt_codigo_pedido.Text      := FPedido.Codigo.ToString;
  edtCliente.Text             := FPedido.NomeCliente;
  edtCliente.Tag              := FPedido.CodigoCliente;
  edt_dt_emissao_pedido.Text  := FormatDateTime('dd/MM/yyyy', FPedido.DtEmissao);
  edt_status_pedido.Text      := FPedido.DescricaoStatus;
  edt_status_pedido.Tag       := FPedido.CodigoStatus;

  SetarTituloDadosPedido;

  BuscaPedidosItens(StrToIntDef(edt_codigo_pedido.Text, 0));

  lay_cadastro_principal.tag  := 1;
  actCadastro.Execute;
end;

end.
