unit Projeto.Controller.PedidoHeader;

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections, Data.DB,
  Projeto.Model.Interfaces,
  Projeto.Model.DTO.Classes,
  Projeto.Controller.Interfaces,
  Projeto.Controller.RegisterLog;

Type
  TPedidoHeaderController = class(TInterfacedObject, iPedidoHeaderController)
  private
    FConexao: iConexao;
    FQuerys: iQuerys;
    function GetPedidoHeaderFromDataSet(const ADataSet: TDataSet): TPedidoHeaderDTO;
    function GetPedidoStatusFromDataSet(const ADataSet: TDataSet): TPedidoStatusDTO;
  public
    constructor Create(AConexao: iConexao);
    destructor Destroy; override;
    class function New(AConexao: iConexao): iPedidoHeaderController;

    function Insert(const APedidoHeader: TPedidoHeaderDTO): Integer;
    function Update(const APedidoHeader: TPedidoHeaderDTO): Boolean;
    function Delete(const ACodigo: Integer): Boolean;
    function GetByCode(const ACodigo: Integer): TPedidoHeaderDTO;
    function GetAll: TObjectList<TPedidoHeaderDTO>;
    function GetAllStatus: TObjectList<TPedidoStatusDTO>;
    function GetByCodigoOrNome(const AValue: String): TObjectList<TPedidoHeaderDTO>;
  end;

implementation

uses
  Projeto.Model.Querys;

{ TPedidoHeaderController }

constructor TPedidoHeaderController.Create(AConexao: iConexao);
begin
  FConexao := AConexao;
  FQuerys := TModelQuerys.New(FConexao);
end;

destructor TPedidoHeaderController.Destroy;
begin
  FQuerys := nil;
  FConexao := nil;
  inherited;
end;

class function TPedidoHeaderController.New(AConexao: iConexao): iPedidoHeaderController;
begin
  Result := Self.Create(AConexao);
end;

function TPedidoHeaderController.GetPedidoHeaderFromDataSet(const ADataSet: TDataSet): TPedidoHeaderDTO;
begin
  Result                  := TPedidoHeaderDTO.Create;
  Result.Codigo           := ADataSet.FieldByName('codigo').AsInteger;
  Result.DtEmissao        := ADataSet.FieldByName('dt_emissao').AsDateTime;
  Result.CodigoCliente    := ADataSet.FieldByName('codigo_cliente').AsInteger;
  Result.NomeCliente      := ADataSet.FieldByName('nome_cliente').asString;
  Result.VlrTotal         := ADataSet.FieldByName('vlr_total').AsCurrency;
  Result.CodigoStatus     := ADataSet.FieldByName('codigo_status').AsInteger;
  Result.DescricaoStatus  := ADataSet.FieldByName('descricao_status').asString;
end;

function TPedidoHeaderController.GetPedidoStatusFromDataSet(const ADataSet: TDataSet): TPedidoStatusDTO;
begin
  Result                := TPedidoStatusDTO.Create;
  Result.Codigo         := ADataSet.FieldByName('codigo').AsInteger;
  Result.Descricao      := ADataSet.FieldByName('descricao').AsString;
end;

function TPedidoHeaderController.Insert(const APedidoHeader: TPedidoHeaderDTO): Integer;
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

    SQL := Format('INSERT INTO pedido_header (dt_emissao, codigo_cliente, vlr_total, codigo_status) VALUES (''%s'', %d, %s, %d)',
                  [FormatDateTime('yyyy-mm-dd hh:nn:ss', APedidoHeader.DtEmissao), APedidoHeader.CodigoCliente, FormatFloat('0.00', APedidoHeader.VlrTotal, LFormatSettings), APedidoHeader.CodigoStatus]);
    if FQuerys.ExecuteSQL(SQL) then
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
      TRegisterLog.i.Log('Erro ao inserir cabeçalho de pedido: ' + E.Message);
    end;
  end;
end;

function TPedidoHeaderController.Update(const APedidoHeader: TPedidoHeaderDTO): Boolean;
var
  SQL: string;
  DataSet: TDataSet;
  LFormatSettings: TFormatSettings;
begin
  Result := False;

  GetLocaleFormatSettings(0, LFormatSettings);
  LFormatSettings.DecimalSeparator := '.';
  try
    FConexao.BeginTransaction;
    SQL := Format('UPDATE pedido_header SET dt_emissao = ''%s'', codigo_cliente = %d, vlr_total = %s, codigo_status = %d WHERE codigo = %d',
                  [FormatDateTime('yyyy-mm-dd hh:nn:ss', APedidoHeader.DtEmissao), APedidoHeader.CodigoCliente, FormatFloat('0.00', APedidoHeader.VlrTotal, LFormatSettings), APedidoHeader.CodigoStatus, APedidoHeader.Codigo]);
    Result := FQuerys.ExecuteSQL(SQL);
    FConexao.CommitTransaction;
  except
    on E: Exception do
    begin
      FConexao.RollbackTransaction;
      TRegisterLog.i.Log('Erro ao atualizar cabeçalho de pedido: ' + E.Message);
    end;
  end;
end;

function TPedidoHeaderController.Delete(const ACodigo: Integer): Boolean;
var
  SQL: string;
begin
  Result := False;
  try
    FConexao.BeginTransaction;

    SQL := Format('DELETE FROM pedido_itens WHERE numero_pedido = %d', [ACodigo]);
    FQuerys.ExecuteSQL(SQL);

    SQL := Format('DELETE FROM pedido_header WHERE codigo = %d', [ACodigo]);
    Result := FQuerys.ExecuteSQL(SQL);
    FConexao.CommitTransaction;
  except
    on E: Exception do
    begin
      FConexao.RollbackTransaction;
      TRegisterLog.i.Log('Erro ao deletar cabeçalho de pedido: ' + E.Message);
    end;
  end;
end;

function TPedidoHeaderController.GetByCode(const ACodigo: Integer): TPedidoHeaderDTO;
var
  SQL: string;
  DataSet: TDataSet;
begin
  Result := nil;
  try
    SQL := Format('select ph.*, c.nome as nome_cliente, ps.codigo as codigo_status, ps.descricao as descricao_status '+
                  'from pedido_header ph '+
                  'left join clientes c on c.codigo = ph.codigo_cliente '+
                  'left join pedido_status ps on ps.codigo = ph.codigo_status '+
                  'where ph.codigo = %d', [ACodigo]);
    if FQuerys.ExecuteSQL(SQL) then
    begin
      DataSet := FQuerys.DataSet;
      if not DataSet.IsEmpty then
      begin
        Result := GetPedidoHeaderFromDataSet(DataSet);
      end;
    end;
  except
    on E: Exception do
    begin
      TRegisterLog.i.Log('Erro ao buscar cabeçalho de pedido por código: ' + E.Message);
    end;
  end;
end;

function TPedidoHeaderController.GetByCodigoOrNome(const AValue: String): TObjectList<TPedidoHeaderDTO>;
var
  SQL: string;
  DataSet: TDataSet;
  LCodigo: Integer;
begin
  Result := TObjectList<TPedidoHeaderDTO>.Create;
  try
    if TryStrToInt(AValue, LCodigo) then
    begin
      SQL := Format('select ph.*, c.nome as nome_cliente, ps.codigo as codigo_status, ps.descricao as descricao_status '+
                  'from pedido_header ph '+
                  'left join clientes c on c.codigo = ph.codigo_cliente '+
                  'left join pedido_status ps on ps.codigo = ph.codigo_status '+
                    'where (ph.codigo = %d) or (c.nome like ''%%%s%%'')', [LCodigo, AValue]);
    end
    else
    begin
      SQL := Format('select ph.*, c.nome as nome_cliente, ps.codigo as codigo_status, ps.descricao as descricao_status '+
                  'from pedido_header ph '+
                  'left join clientes c on c.codigo = ph.codigo_cliente '+
                  'left join pedido_status ps on ps.codigo = ph.codigo_status '+
                    'where (c.nome like ''%%%s%%'')', [AValue]);
    end;

    if FQuerys.ExecuteSQL(SQL) then
    begin
      DataSet := FQuerys.DataSet;

      if Assigned(DataSet) and DataSet.Active and not DataSet.IsEmpty then
      begin
        DataSet.First;
        while not DataSet.Eof do
        begin
          Result.Add(GetPedidoHeaderFromDataSet(DataSet));
          DataSet.Next;
        end;
      end
      else
      begin
        TRegisterLog.i.Log('GetByCodigoOrDescricao: Nenhuns produtos encontrados para o valor: ' + AValue);
      end;
    end
    else
    begin
      TRegisterLog.i.Log('GetByCodigoOrDescricao: A execução da consulta SQL falhou para o valor: ' + AValue);
    end;
  except
    on E: Exception do
    begin
      TRegisterLog.i.Log('Erro ao buscar produtos por código ou descrição para "' + AValue + '": ' + E.Message);
      FreeAndNil(Result);
      Result := nil;
    end;
  end;
end;

function TPedidoHeaderController.GetAll: TObjectList<TPedidoHeaderDTO>;
var
  SQL: string;
  DataSet: TDataSet;
begin
  Result := TObjectList<TPedidoHeaderDTO>.Create;
  try
    SQL := 'select ph.*, c.nome as nome_cliente, ps.codigo as codigo_status, ps.descricao as descricao_status '+
           'from pedido_header ph '+
           'left join clientes c on c.codigo = ph.codigo_cliente '+
                  'left join pedido_status ps on ps.codigo = ph.codigo_status ';
    if FQuerys.ExecuteSQL(SQL) then
    begin
      DataSet := FQuerys.DataSet;
      DataSet.First;
      while not DataSet.Eof do
      begin
        Result.Add(GetPedidoHeaderFromDataSet(DataSet));
        DataSet.Next;
      end;
    end;
  except
    on E: Exception do
    begin
      TRegisterLog.i.Log('Erro ao buscar todos os cabeçalhos de pedido: ' + E.Message);
      FreeAndNil(Result);
    end;
  end;
end;

function TPedidoHeaderController.GetAllStatus: TObjectList<TPedidoStatusDTO>;
var
  SQL: string;
  DataSet: TDataSet;
begin
  Result := TObjectList<TPedidoStatusDTO>.Create;
  try
    SQL := 'select ps.* '+
           'from pedido_status ps  ';
    if FQuerys.ExecuteSQL(SQL) then
    begin
      DataSet := FQuerys.DataSet;
      DataSet.First;
      while not DataSet.Eof do
      begin
        Result.Add(GetPedidoStatusFromDataSet(DataSet));
        DataSet.Next;
      end;
    end;
  except
    on E: Exception do
    begin
      TRegisterLog.i.Log('Erro ao buscar todos os Status de pedido: ' + E.Message);
      FreeAndNil(Result);
    end;
  end;
end;

end.

