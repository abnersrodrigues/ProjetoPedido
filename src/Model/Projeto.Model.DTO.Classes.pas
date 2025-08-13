unit Projeto.Model.DTO.Classes;

interface

uses
  System.SysUtils,
  System.Generics.Collections;

type
  { TProdutoDTO }
  TProdutoDTO = class
  private
    FCodigo: Integer;
    FDescricao: string;
    FVlrVenda: Currency;
    procedure SetDescricao(const Value: string);
    procedure SetVlrVenda(const Value: Currency);
  public
    constructor Create(ACodigo: Integer = 0; ADescricao: string = ''; AVlrVenda: Currency = 0); overload;

    property Codigo: Integer read FCodigo write FCodigo;
    property Descricao: string read FDescricao write SetDescricao;
    property VlrVenda: Currency read FVlrVenda write SetVlrVenda;
  end;

  { TClienteDTO }
  TClienteDTO = class
  private
    FCodigo: Integer;
    FNome: string;
    FCidade: string;
    FUF: string;
    procedure SetNome(const Value: string);
    procedure SetUF(const Value: string);
  public
    constructor Create(ACodigo: Integer = 0; ANome: string = ''; ACidade: string = ''; AUF: string = ''); overload;

    property Codigo: Integer read FCodigo write FCodigo;
    property Nome: string read FNome write SetNome;
    property Cidade: string read FCidade write FCidade;
    property UF: string read FUF write SetUF;
  end;

  { TPedidoStatusDTO }
  TPedidoStatusDTO = class
  private
    FCodigo: Integer;
    FDescricao: string;
  public
    property Codigo: Integer read FCodigo write FCodigo;
    property Descricao: string read FDescricao write FDescricao;
  end;

  { TPedidoHeaderDTO }
  TPedidoHeaderDTO = class
  private
    FCodigo: Integer;
    FDtEmissao: TDateTime;
    FCodigoCliente: Integer;
    FVlrTotal: Currency;
    FCodigoStatus: Integer;
    FNomeCliente: String;
    FDescricaoStatus: String;
    procedure SetDtEmissao(const Value: TDateTime);
    procedure SetVlrTotal(const Value: Currency);
  public
    constructor Create; overload;

    property Codigo: Integer read FCodigo write FCodigo;
    property DtEmissao: TDateTime read FDtEmissao write SetDtEmissao;
    property CodigoCliente: Integer read FCodigoCliente write FCodigoCliente;
    property NomeCliente: String read FNomeCliente write FNomeCliente;
    property VlrTotal: Currency read FVlrTotal write SetVlrTotal;
    property CodigoStatus: Integer read FCodigoStatus write FCodigoStatus;
    property DescricaoStatus: String read FDescricaoStatus write FDescricaoStatus;
  end;

  { TPedidoItemDTO }
  TPedidoItemDTO = class
  private
    FCodigo: Integer;
    FCodigoPedido: Integer;
    FCodigoProduto: Integer;
    FQtde: Integer;
    FVlrUnitario: Currency;
    FVlrTotal: Currency;
    FDescricaoProduto: string;
    procedure SetQtde(const Value: Integer);
    procedure SetVlrUnitario(const Value: Currency);
    procedure SetVlrTotal(const Value: Currency);
  public
    constructor Create; overload;

    property Codigo: Integer read FCodigo write FCodigo;
    property CodigoPedido: Integer read FCodigoPedido write FCodigoPedido;
    property CodigoProduto: Integer read FCodigoProduto write FCodigoProduto;
    property DescricaoProduto: string read FDescricaoProduto write FDescricaoProduto;
    property Qtde: Integer read FQtde write SetQtde;
    property VlrUnitario: Currency read FVlrUnitario write SetVlrUnitario;
    property VlrTotal: Currency read FVlrTotal write SetVlrTotal;
  end;

  { TDashBoardSummaryDTO}
  TDashBoardSummaryDTO = class
  private
    FClientesCount: Integer;
    FProdutosCount: Integer;
    FPedidosCount: Integer;
  public
    constructor Create(AClientesCount: Integer = 0; AProdutosCount: Integer = 0; APedidosCount: Integer = 0);
    property ClientesCount: Integer read FClientesCount write FClientesCount;
    property ProdutosCount: Integer read FProdutosCount write FProdutosCount;
    property PedidosCount: Integer read FPedidosCount write FPedidosCount;
  end;

implementation

{ TProdutoDTO }

constructor TProdutoDTO.Create(ACodigo: Integer; ADescricao: string; AVlrVenda: Currency);
begin
  inherited Create;
  Codigo := ACodigo;
  Descricao := ADescricao;
  VlrVenda := AVlrVenda;
end;

procedure TProdutoDTO.SetDescricao(const Value: string);
begin
  if Trim(Value).IsEmpty then
    raise EArgumentException.Create('A descrição do produto não pode ser vazia.');
  FDescricao := Value;
end;

procedure TProdutoDTO.SetVlrVenda(const Value: Currency);
begin
  if Value < 0 then
    raise EArgumentException.Create('O valor de venda não pode ser negativo.');
  FVlrVenda := Value;
end;

{ TClienteDTO }

constructor TClienteDTO.Create(ACodigo: Integer; ANome: string; ACidade: string; AUF: string);
begin
  inherited Create;
  Codigo := ACodigo;
  Nome := ANome;
  Cidade := ACidade;
  UF := AUF;
end;

procedure TClienteDTO.SetNome(const Value: string);
begin
  if Trim(Value).IsEmpty then
    raise EArgumentException.Create('O nome do cliente não pode ser vazio.');
  FNome := Trim(Value);
end;

procedure TClienteDTO.SetUF(const Value: string);
var
  TrimmedUF: string;
begin
  TrimmedUF := Trim(Value);
  if (Length(TrimmedUF) <> 2) or (TrimmedUF <> UpperCase(TrimmedUF)) then
    raise EArgumentException.Create('A UF deve conter 2 letras maiúsculas.');
  FUF := TrimmedUF;
end;

{ TPedidoHeaderDTO }

constructor TPedidoHeaderDTO.Create;
begin
  inherited Create;

end;

procedure TPedidoHeaderDTO.SetDtEmissao(const Value: TDateTime);
begin
  FDtEmissao := Value;
end;

procedure TPedidoHeaderDTO.SetVlrTotal(const Value: Currency);
begin
  if Value < 0 then
    raise EArgumentException.Create('O valor total do pedido não pode ser negativo.');
  FVlrTotal := Value;
end;

{ TPedidoItemDTO }

constructor TPedidoItemDTO.Create;
begin
  inherited Create;

end;

procedure TPedidoItemDTO.SetQtde(const Value: Integer);
begin
  if Value <= 0 then
    raise EArgumentException.Create('A quantidade deve ser maior que zero.');
  FQtde := Value;
end;

procedure TPedidoItemDTO.SetVlrUnitario(const Value: Currency);
begin
  if Value < 0 then
    raise EArgumentException.Create('O valor unitário não pode ser negativo.');
  FVlrUnitario := Value;
end;

procedure TPedidoItemDTO.SetVlrTotal(const Value: Currency);
begin
  if Value < 0 then
    raise EArgumentException.Create('O valor total do item não pode ser negativo.');
  FVlrTotal := Value;
end;

{ TDashBoardSummaryDTO }

constructor TDashBoardSummaryDTO.Create(AClientesCount, AProdutosCount, APedidosCount: Integer);
begin
  inherited Create;

  FClientesCount  := AClientesCount;
  FProdutosCount  := AProdutosCount;
  FPedidosCount   := APedidosCount;
end;

end.
