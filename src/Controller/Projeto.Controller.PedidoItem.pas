unit Projeto.Controller.PedidoItem;

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections, Data.DB,
  Projeto.Model.Interfaces,
  Projeto.Model.DTO.Classes,
  Projeto.Controller.Interfaces,
  Projeto.Controller.RegisterLog;

Type
  TPedidoItemController = class(TInterfacedObject, iPedidoItemController)
  private
    FConexao: iConexao;
    FQuerys: iQuerys;
    function GetPedidoItemFromDataSet(const ADataSet: TDataSet): TPedidoItemDTO;
  public
    constructor Create(AConexao: iConexao);
    destructor Destroy; override;
    class function New(AConexao: iConexao): iPedidoItemController;

    function Insert(const APedidoItem: TPedidoItemDTO): integer;
    function Update(const APedidoItem: TPedidoItemDTO): Boolean;
    function Delete(const ACodigo: Integer): Boolean;
    function GetByCode(const ACodigo: Integer): TPedidoItemDTO;
    function GetItemsByPedidoCode(const ACodigoPedido: Integer): TObjectList<TPedidoItemDTO>;
  end;

implementation

uses
  Projeto.Model.Querys;

{ TPedidoItemController }

constructor TPedidoItemController.Create(AConexao: iConexao);
begin
  FConexao := AConexao;
  FQuerys := TModelQuerys.New(FConexao);
end;

destructor TPedidoItemController.Destroy;
begin
  FQuerys := nil;
  FConexao := nil;
  inherited;
end;

class function TPedidoItemController.New(AConexao: iConexao): iPedidoItemController;
begin
  Result := Self.Create(AConexao);
end;

function TPedidoItemController.GetPedidoItemFromDataSet(const ADataSet: TDataSet): TPedidoItemDTO;
begin
  Result := TPedidoItemDTO.Create;
  Result.Codigo           := ADataSet.FieldByName('codigo').AsInteger;
  Result.CodigoPedido     := ADataSet.FieldByName('numero_pedido').AsInteger;
  Result.CodigoProduto    := ADataSet.FieldByName('codigo_produto').AsInteger;
  Result.DescricaoProduto := ADataSet.FieldByName('descricao_produto').AsString;
  Result.Qtde             := ADataSet.FieldByName('qtde').AsInteger;
  Result.VlrUnitario      := ADataSet.FieldByName('vlr_unitario').AsCurrency;
  Result.VlrTotal         := ADataSet.FieldByName('vlr_total').AsCurrency;
end;

function TPedidoItemController.Insert(const APedidoItem: TPedidoItemDTO): Integer;
var
  SQL: string;
  DataSet: TDataSet;
  LFormatSettings: TFormatSettings;
begin
  Result := -1;
  GetLocaleFormatSettings(0, LFormatSettings);
  LFormatSettings.DecimalSeparator := '.';
  try
    FConexao.BeginTransaction;
    SQL := Format('INSERT INTO pedido_itens (numero_pedido, codigo_produto, qtde, vlr_unitario, vlr_total) VALUES (%d, %d, %d, %s, %s)',
                  [APedidoItem.CodigoPedido, APedidoItem.CodigoProduto, APedidoItem.Qtde, FormatFloat('0.00', APedidoItem.VlrUnitario, LFormatSettings), FormatFloat('0.00', APedidoItem.VlrTotal, LFormatSettings)]);
    if FQuerys.ExecuteSQL(SQL) then;
    begin
      SQL := 'SELECT last_insert_rowid() as id';
      if FQuerys.ExecuteSQL(SQL) then
      begin
        DataSet := FQuerys.DataSet;
        if not DataSet.IsEmpty then
        begin
          Result := DataSet.FieldByName('id').AsInteger;
        end;
      end;
    end;
    FConexao.CommitTransaction;
  except
    on E: Exception do
    begin
      FConexao.RollbackTransaction;
      TRegisterLog.i.Log('Erro ao inserir item de pedido: ' + E.Message);
    end;
  end;
end;

function TPedidoItemController.Update(const APedidoItem: TPedidoItemDTO): Boolean;
var
  SQL: string;
  LFormatSettings: TFormatSettings;
begin
  Result := False;
  GetLocaleFormatSettings(0, LFormatSettings);
  LFormatSettings.DecimalSeparator := '.';
  try
    FConexao.BeginTransaction;
    SQL := Format('UPDATE pedido_itens SET numero_pedido = %d, codigo_produto = %d, qtde = %d, vlr_unitario = %s, vlr_total = %s WHERE codigo = %d',
                  [APedidoItem.CodigoPedido, APedidoItem.CodigoProduto, APedidoItem.Qtde, FormatFloat('0.00', APedidoItem.VlrUnitario, LFormatSettings), FormatFloat('0.00', APedidoItem.VlrTotal, LFormatSettings), APedidoItem.Codigo]);
    Result := FQuerys.ExecuteSQL(SQL);
    FConexao.CommitTransaction;
  except
    on E: Exception do
    begin
      FConexao.RollbackTransaction;
      TRegisterLog.i.Log('Erro ao atualizar item de pedido: ' + E.Message);
    end;
  end;
end;

function TPedidoItemController.Delete(const ACodigo: Integer): Boolean;
var
  SQL: string;
begin
  Result := False;
  try
    FConexao.BeginTransaction;
    SQL := Format('DELETE FROM pedido_itens WHERE codigo = %d', [ACodigo]);
    Result := FQuerys.ExecuteSQL(SQL);
    FConexao.CommitTransaction;
  except
    on E: Exception do
    begin
      FConexao.RollbackTransaction;
      TRegisterLog.i.Log('Erro ao deletar item de pedido: ' + E.Message);
    end;
  end;
end;

function TPedidoItemController.GetByCode(const ACodigo: Integer): TPedidoItemDTO;
var
  SQL: string;
  DataSet: TDataSet;
begin
  Result := nil;
  try
    SQL := Format('select pi.*, p.descricao as descricao_produto from pedido_itens pi '+
                  'left join produtos p on p.codigo = pi.codigo_produto '+
                  'WHERE pi.codigo = %d', [ACodigo]);
    if FQuerys.ExecuteSQL(SQL) then
    begin
      DataSet := FQuerys.DataSet;
      if not DataSet.IsEmpty then
      begin
        Result := GetPedidoItemFromDataSet(DataSet);
      end;
    end;
  except
    on E: Exception do
    begin
      TRegisterLog.i.Log('Erro ao buscar item de pedido por código: ' + E.Message);
    end;
  end;
end;

function TPedidoItemController.GetItemsByPedidoCode(const ACodigoPedido: Integer): TObjectList<TPedidoItemDTO>;
var
  SQL: string;
  DataSet: TDataSet;
begin
  Result := TObjectList<TPedidoItemDTO>.Create;
  try
    SQL := Format('select pi.*, p.descricao as descricao_produto from pedido_itens pi '+
                  'left join produtos p on p.codigo = pi.codigo_produto '+
                  'WHERE numero_pedido = %d', [ACodigoPedido]);
    if FQuerys.ExecuteSQL(SQL) then
    begin
      DataSet := FQuerys.DataSet;
      DataSet.First;
      while not DataSet.Eof do
      begin
        Result.Add(GetPedidoItemFromDataSet(DataSet));
        DataSet.Next;
      end;
    end;
  except
    on E: Exception do
    begin
      TRegisterLog.i.Log('Erro ao buscar itens de pedido por código do pedido: ' + E.Message);
      FreeAndNil(Result);
    end;
  end;
end;

end.

