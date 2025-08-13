unit Projeto.Controller.Interfaces;

interface

uses
  Data.Db, System.Classes, System.Generics.Collections,
  Projeto.Model.DTO.Classes;

Type

  // Interface para o Controller de Produtos
  iProdutoController = interface ['{EC58F97B-26D6-40A1-A567-7C5347B26F29}']
    function Insert(const AProduto: TProdutoDTO): Integer;
    function Update(const AProduto: TProdutoDTO): Boolean;
    function Delete(const ACodigo: Integer): Boolean;
    function GetByCode(const ACodigo: Integer): TProdutoDTO;
    function GetAll: TObjectList<TProdutoDTO>;
    function GetByCodigoOrDescricao(const AValue: String): TObjectList<TProdutoDTO>;
  end;

  // Interface para o Controller de Clientes
  iClienteController = interface ['{727E7941-B912-4791-AEE3-99B67A78C2D8}']
    function Insert(const ACliente: TClienteDTO): Integer;
    function Update(const ACliente: TClienteDTO): Boolean;
    function Delete(const ACodigo: Integer): Boolean;
    function GetByCode(const ACodigo: Integer): TClienteDTO;
    function GetAll: TObjectList<TClienteDTO>;
    function GetByCodigoOrNome(const AValue: String): TObjectList<TClienteDTO>;
  end;

  // Interface para o Controller de Cabeçalho de Pedidos
  iPedidoHeaderController = interface ['{BA604EBC-5A79-44CF-8363-1EBE1CFD0740}']
    function Insert(const APedidoHeader: TPedidoHeaderDTO): Integer;
    function Update(const APedidoHeader: TPedidoHeaderDTO): Boolean;
    function Delete(const ACodigo: Integer): Boolean;
    function GetByCode(const ACodigo: Integer): TPedidoHeaderDTO;
    function GetAll: TObjectList<TPedidoHeaderDTO>;
    function GetAllStatus: TObjectList<TPedidoStatusDTO>;
    function GetByCodigoOrNome(const AValue: String): TObjectList<TPedidoHeaderDTO>;
  end;

  // Interface para o Controller de Itens de Pedidos
  iPedidoItemController = interface ['{66261192-3ABF-45DA-A2D5-B721BE14DC9A}']
    function Insert(const APedidoItem: TPedidoItemDTO): integer;
    function Update(const APedidoItem: TPedidoItemDTO): Boolean;
    function Delete(const ACodigo: Integer): Boolean;
    function GetByCode(const ACodigo: Integer): TPedidoItemDTO;
    function GetItemsByPedidoCode(const ACodigoPedido: Integer): TObjectList<TPedidoItemDTO>;
  end;

  iDashBoardController = interface ['{C6E5A4CC-B8F8-4E76-B0B1-F2B89236F057}']
    function GetSummaryCounts: TDashBoardSummaryDTO;
  end;

implementation

end.

