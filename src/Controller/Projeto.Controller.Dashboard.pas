unit Projeto.Controller.Dashboard;

interface

uses
  System.SysUtils, System.Classes, Data.DB,
  Projeto.Model.Interfaces,
  Projeto.Model.DTO.Classes,
  Projeto.Controller.Interfaces,
  Projeto.Controller.RegisterLog;

Type
  TDashBoardController = class(TInterfacedObject, iDashBoardController)
  private
    FConexao: iConexao;
    FQuerys: iQuerys;
    function GetCount(const ATableName: string): Integer;
  public
    constructor Create(AConexao: iConexao);
    destructor Destroy; override;
    class function New(AConexao: iConexao): iDashBoardController;

    function GetSummaryCounts: TDashBoardSummaryDTO;
  end;

implementation

uses
  Projeto.Model.Querys;

{ TDashBoardController }

constructor TDashBoardController.Create(AConexao: iConexao);
begin
  FConexao := AConexao;
  FQuerys := TModelQuerys.New(FConexao);
end;

destructor TDashBoardController.Destroy;
begin
  FQuerys := nil;
  FConexao := nil;
  inherited;
end;

class function TDashBoardController.New(AConexao: iConexao): iDashBoardController;
begin
  Result := Self.Create(AConexao);
end;

function TDashBoardController.GetCount(const ATableName: string): Integer;
var
  SQL: string;
  DataSet: TDataSet;
begin
  Result := 0;
  try
    SQL := Format('SELECT COUNT(*) AS TotalCount FROM %s', [ATableName]);
    if FQuerys.ExecuteSQL(SQL) then
    begin
      DataSet := FQuerys.DataSet;
      if Assigned(DataSet) and DataSet.Active and not DataSet.IsEmpty then
      begin
        Result := DataSet.FieldByName('TotalCount').AsInteger;
      end;
    end;
  except
    on E: Exception do
    begin
      TRegisterLog.i.Log(Format('Erro ao obter contagem para a tabela "%s": %s', [ATableName, E.Message]));
    end;
  end;
end;

function TDashBoardController.GetSummaryCounts: TDashBoardSummaryDTO;
var
  ClientesCount: Integer;
  ProdutosCount: Integer;
  PedidosCount: Integer;
begin
  ClientesCount := GetCount('clientes');
  ProdutosCount := GetCount('produtos');
  PedidosCount  := GetCount('pedido_header');

  Result := TDashBoardSummaryDTO.Create(ClientesCount, ProdutosCount, PedidosCount);
end;

end.

