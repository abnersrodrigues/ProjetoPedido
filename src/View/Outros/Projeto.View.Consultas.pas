unit Projeto.View.Consultas;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,  System.Rtti,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts, FMX.Objects, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Edit, FMX.ListBox, System.Generics.Collections,

  Projeto.Model.DTO.Classes, Projeto.Controller.Interfaces,
  Projeto.Model.Interfaces, Projeto.Controller.Cliente, Projeto.Model.Conexao,
  Projeto.View.Cadastro.Produto, Projeto.Controller.Produto, Projeto.Controller.PedidoHeader,
  Projeto.Controller.Types,
  Projeto.Controller.Loading;

type
  TFormOrigem = class(TForm);

  TViewCadastroConsultas = class(TForm)
    layConsultaPrincipal: TLayout;
    rect_fundo_principal: TRectangle;
    rect_fundo_branco: TRectangle;
    Layout1: TLayout;
    lblTituloConsulta: TLabel;
    SpeedButton1: TSpeedButton;
    Rectangle1: TRectangle;
    edtBusca: TEdit;
    Layout29: TLayout;
    Rectangle15: TRectangle;
    ListBoxConsultas: TListBox;
    StyleBook1: TStyleBook;
    lblTituloGrid: TLabel;
    procedure SpeedButton1Click(Sender: TObject);
    procedure rect_fundo_principalClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    FConexao: iConexao;

    FListaCliente: TObjectList<TClienteDTO>;
    FClienteController: iClienteController;
    FBuscaClientes: TThread;

    FListaProduto: TObjectList<TProdutoDTO>;
    FProdutoController: iProdutoController;
    FBuscarProdutos: TThread;

    FListaStatusPedidos: TObjectList<TPedidoStatusDTO>;
    FStatusPedidoController: iPedidoHeaderController;
    FBuscarStatuspedido: TThread;

    FFormOrigem: TFormOrigem;
    FTipoPesquisa: TTipoPesquisa;
    FDescricao: String;
    FCodigo: Integer;
    FVlrProduto: Currency;
    FBuscaIndividual: Boolean;
    procedure SetTituloBusca(const Value: string);
    procedure SetTituloGrid(const Value: string);
    procedure SetPromptBusca(const Value: string);

    procedure ConfiguraTelaConsulta;
    procedure SelecionarItem(Sender: TObject);

    procedure BuscaClientes;
    procedure BuscaProdutos;
    procedure BuscaStatusPedido;

  public
    property TituloBusca: string write SetTituloBusca;
    property TituloGrid:  string write SetTituloGrid;
    property PromptBusca: string write SetPromptBusca;

    property Codigo:      Integer   read FCodigo      write FCodigo;
    property Descricao:   String    read FDescricao   write FDescricao;
    property VlrProduto:  Currency  read FVlrProduto  write FVlrProduto;

    property BuscaIndividual:  Boolean  read FBuscaIndividual  write FBuscaIndividual;

    constructor Create(AOwner: TComponent; AFormOrigem: TFormOrigem; ATipoPesquisa: TTipoPesquisa; const ABuscaIndividual: Boolean); reintroduce;
    procedure BuscaProdutosByCodigo(ACodigoProduto: integer);
  end;

 function FindItemParent(Obj: TFMXObject; ParentClass: TClass): TFMXObject;

var
  ViewCadastroConsultas: TViewCadastroConsultas;

implementation

{$R *.fmx}

function FindItemParent(Obj: TFMXObject; ParentClass: TClass): TFMXObject;
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

constructor TViewCadastroConsultas.Create(AOwner: TComponent; AFormOrigem: TFormOrigem; ATipoPesquisa: TTipoPesquisa; const ABuscaIndividual: Boolean);
begin
  inherited Create(AOwner);
  FFormOrigem := AFormOrigem;
  FTipoPesquisa := ATipoPesquisa;
  FBuscaIndividual := ABuscaIndividual;

  ConfiguraTelaConsulta;
end;

procedure TViewCadastroConsultas.FormCreate(Sender: TObject);
begin
  FConexao                := TModelConexao.New;

  FClienteController      := TClienteController.New(FConexao);
  FBuscaClientes          := nil;

  FProdutoController      := TProdutoController.New(FConexao);
  FBuscarProdutos         := nil;

  FStatusPedidoController := TPedidoHeaderController.New(FConexao);
  FBuscarStatuspedido     := nil;
end;

procedure TViewCadastroConsultas.FormDestroy(Sender: TObject);
begin
  if Assigned(FBuscaClientes) then
  begin
    FBuscaClientes.Terminate;
    FBuscaClientes.WaitFor;
    FreeAndNil(FBuscaClientes);
  end;

  FClienteController  := nil;
  FreeAndNil(FListaCliente);

  if Assigned(FBuscarProdutos) then
  begin
    FBuscarProdutos.Terminate;
    FBuscarProdutos.WaitFor;
    FreeAndNil(FBuscarProdutos);
  end;

  FProdutoController  := nil;
  FreeAndNil(FListaProduto);

  if Assigned(FBuscarStatuspedido) then
  begin
    FBuscarStatuspedido.Terminate;
    FBuscarStatuspedido.WaitFor;
    FreeAndNil(FBuscarStatuspedido);
  end;

  FStatusPedidoController  := nil;
  FreeAndNil(FListaStatusPedidos);

  FConexao            := nil;
end;

procedure TViewCadastroConsultas.rect_fundo_principalClick(Sender: TObject);
begin
  Close;
end;

procedure TViewCadastroConsultas.SetPromptBusca(const Value: string);
begin
  edtBusca.TextPrompt := Value;
end;

procedure TViewCadastroConsultas.SetTituloBusca(const Value: string);
begin
  lblTituloConsulta.Text := Value;
end;

procedure TViewCadastroConsultas.SetTituloGrid(const Value: string);
begin
  lblTituloGrid.Text  := Value;
end;

procedure TViewCadastroConsultas.SpeedButton1Click(Sender: TObject);
begin
  Close;
end;

procedure TViewCadastroConsultas.BuscaClientes;
begin
  TLoading.Show(Self, 'Buscando Clientes');

  TThread.CreateAnonymousThread(procedure
  var
    LListaClientes: TObjectList<TClienteDTO>;
    LSearchText: string;
  begin
    Sleep(500);

    TThread.Synchronize(nil, procedure
    begin
      LSearchText := edtBusca.Text;
    end);

    if LSearchText <> '' then
      LListaClientes := FClienteController.GetByCodigoOrNome(LSearchText)
    else
      LListaClientes := FClienteController.GetAll;

    TThread.Synchronize(nil, procedure
    var
      ListBoxItem: TListBoxItem;
      i: Integer;
    begin
      ListBoxConsultas.Items.Clear;
      ListBoxConsultas.BeginUpdate;
      try
        if Assigned(LListaClientes) then
        begin
          for i := 0 to Pred(LListaClientes.Count) do
          begin
            ListBoxItem             := TListBoxItem.Create(ListBoxConsultas);
            ListBoxItem.Parent      := ListBoxConsultas;
            ListBoxItem.StyleLookup := 'StyleConsultas';
            ListBoxItem.Height      := 70;

            ListBoxItem.Tag         := LListaClientes.Items[i].Codigo;
            ListBoxItem.TagString   := LListaClientes.Items[i].Nome;

            ListBoxItem.StylesData['lblDescricao']       := LListaClientes.Items[i].Nome;

            ListBoxItem.StylesData['rect_selecionar.OnClick']    := TValue.From<TNotifyEvent>(SelecionarItem);

            ListBoxConsultas.AddObject(ListBoxItem);
          end;
        end;
      finally
        ListBoxConsultas.EndUpdate;
        FreeAndNil(LListaClientes);
        TLoading.Hide;
      end;
    end);
  end).Start;
end;

procedure TViewCadastroConsultas.BuscaStatusPedido;
begin
  TThread.CreateAnonymousThread(procedure
  var
    LListaStatus: TObjectList<TPedidoStatusDTO>;
    LSearchText: string;
  begin
    Sleep(500);

    TThread.Synchronize(nil, procedure
    begin
      LSearchText := edtBusca.Text;
    end);

    LListaStatus := FStatusPedidoController.GetAllStatus;

    TThread.Synchronize(nil, procedure
    var
      ListBoxItem: TListBoxItem;
      i: Integer;
    begin
      ListBoxConsultas.Items.Clear;
      ListBoxConsultas.BeginUpdate;
      try
        if Assigned(LListaStatus) then
        begin
          for i := 0 to Pred(LListaStatus.Count) do
          begin
            ListBoxItem             := TListBoxItem.Create(ListBoxConsultas);
            ListBoxItem.Parent      := ListBoxConsultas;
            ListBoxItem.StyleLookup := 'StyleConsultas';
            ListBoxItem.Height      := 70;

            ListBoxItem.Tag         := LListaStatus.Items[i].Codigo;
            ListBoxItem.TagString   := LListaStatus.Items[i].Descricao;

            ListBoxItem.StylesData['lblDescricao']       := LListaStatus.Items[i].Descricao;

            ListBoxItem.StylesData['rect_selecionar.OnClick']    := TValue.From<TNotifyEvent>(SelecionarItem);

            ListBoxConsultas.AddObject(ListBoxItem);
          end;
        end;
      finally
        ListBoxConsultas.EndUpdate;
        FreeAndNil(LListaStatus);
      end;
    end);
  end).Start;
end;

procedure TViewCadastroConsultas.BuscaProdutos;
begin
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
      ListBoxConsultas.Items.Clear;
      ListBoxConsultas.BeginUpdate;
      try
        if Assigned(LListaProdutos) then
        begin
          for i := 0 to Pred(LListaProdutos.Count) do
          begin
            ListBoxItem             := TListBoxItem.Create(ListBoxConsultas);
            ListBoxItem.Parent      := ListBoxConsultas;
            ListBoxItem.StyleLookup := 'StyleConsultas';
            ListBoxItem.Height      := 70;

            ListBoxItem.Tag         := LListaProdutos.Items[i].Codigo;
            ListBoxItem.TagString   := LListaProdutos.Items[i].Descricao;
            ListBoxItem.TagFloat    := LListaProdutos.Items[i].VlrVenda;

            ListBoxItem.StylesData['lblDescricao']  := LListaProdutos.Items[i].Descricao;

            ListBoxItem.StylesData['rect_selecionar.OnClick']    := TValue.From<TNotifyEvent>(SelecionarItem);

            ListBoxConsultas.AddObject(ListBoxItem);
          end;
        end;
      finally
        ListBoxConsultas.EndUpdate;
        FreeAndNil(LListaProdutos);
      end;
    end);
  end).Start;
end;

procedure TViewCadastroConsultas.BuscaProdutosByCodigo(ACodigoProduto: integer);
Var
  LProdutos: TProdutoDTO;
begin
  LProdutos := FProdutoController.GetByCode(ACodigoProduto);
  try
    Codigo      := LProdutos.Codigo;
    Descricao   := LProdutos.Descricao;
    VlrProduto  := LProdutos.VlrVenda;
  Finally
    FreeAndNil(LProdutos);
  end;
end;

procedure TViewCadastroConsultas.SelecionarItem(Sender: TObject);
Var
  ListBoxItem: TListBoxItem;
begin
  ListBoxItem := TListBoxItem(FindItemParent(Sender as TFmxObject, TListBoxItem));

  if Assigned(ListBoxItem) then
  begin
    Codigo      := ListBoxItem.Tag;
    Descricao   := ListBoxItem.TagString;
    VlrProduto  := ListBoxItem.TagFloat;

    Close;
  end;
end;

procedure TViewCadastroConsultas.ConfiguraTelaConsulta;
begin
  Case FTipoPesquisa of
    pProdutos:
    begin
      SetTituloBusca('Consulta de Produtos');
      SetTituloGrid('Descrição');
      SetPromptBusca('Digite o nome do produto...');

      if not BuscaIndividual then
        BuscaProdutos;
    end;

    pClientes:
    begin
      SetTituloBusca('Consulta de Clientes');
      SetTituloGrid('Nome');
      SetPromptBusca('Digite o nome do cliente...');

      if not BuscaIndividual then
        BuscaClientes;
    end;

    pStatusPedidos:
    begin
      SetTituloBusca('Consulta de Status de Pedido');
      SetTituloGrid('Descrição');
      SetPromptBusca('Digite o status...');

      if not BuscaIndividual then
        BuscaStatusPedido;
    end;
  End;
end;

end.
