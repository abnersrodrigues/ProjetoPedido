unit Projeto.Controller.Produto;

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections, Data.DB,
  Projeto.Model.Interfaces,
  Projeto.Model.DTO.Classes,
  Projeto.Controller.Interfaces,
  Projeto.Controller.RegisterLog;

Type
  TProdutoController = class(TInterfacedObject, iProdutoController)
  private
    FConexao: iConexao;
    FQuerys: iQuerys;
    function GetProdutoFromDataSet(const ADataSet: TDataSet): TProdutoDTO;
  public
    constructor Create(AConexao: iConexao);
    destructor Destroy; override;
    class function New(AConexao: iConexao): iProdutoController;

    function Insert(const AProduto: TProdutoDTO): Integer;
    function Update(const AProduto: TProdutoDTO): Boolean;
    function Delete(const ACodigo: Integer): Boolean;
    function GetByCode(const ACodigo: Integer): TProdutoDTO;
    function GetAll: TObjectList<TProdutoDTO>;
    function GetByCodigoOrDescricao(const AValue: String): TObjectList<TProdutoDTO>;
  end;

implementation

uses
  Projeto.Model.Querys;

{ TProdutoController }

constructor TProdutoController.Create(AConexao: iConexao);
begin
  FConexao := AConexao;
  FQuerys := TModelQuerys.New(FConexao);
end;

destructor TProdutoController.Destroy;
begin
  FQuerys := nil;
  FConexao := nil;
  inherited;
end;

class function TProdutoController.New(AConexao: iConexao): iProdutoController;
begin
  Result := Self.Create(AConexao);
end;

function TProdutoController.GetProdutoFromDataSet(const ADataSet: TDataSet): TProdutoDTO;
begin
  Result := TProdutoDTO.Create(ADataSet.FieldByName('codigo').AsInteger,
                               ADataSet.FieldByName('descricao').AsString,
                               ADataSet.FieldByName('vlr_venda').AsCurrency);
end;

function TProdutoController.Insert(const AProduto: TProdutoDTO): Integer;
var
  SQL: string;
  LFormatSettings: TFormatSettings;
  DataSet: TDataSet;
begin
  Result := -1;
  try
    FConexao.BeginTransaction;

    LFormatSettings := TFormatSettings.Create;
    LFormatSettings.DecimalSeparator := '.';
    LFormatSettings.ThousandSeparator := ' ';

    SQL := Format('INSERT INTO produtos (descricao, vlr_venda) VALUES (''%s'', %s)',
                  [AProduto.Descricao, FormatFloat('0.00', AProduto.VlrVenda, LFormatSettings)]);

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
      TRegisterLog.i.Log('Erro ao inserir produto: ' + E.Message);
    end;
  end;
end;

function TProdutoController.Update(const AProduto: TProdutoDTO): Boolean;
var
  SQL: string;
  LFormatSettings: TFormatSettings;
begin
  Result := False;
  try
    FConexao.BeginTransaction;

    LFormatSettings := TFormatSettings.Create;
    LFormatSettings.DecimalSeparator := '.';
    LFormatSettings.ThousandSeparator := ' ';

    SQL := Format('UPDATE produtos SET descricao = ''%s'', vlr_venda = %s WHERE codigo = %d',
                  [AProduto.Descricao, FormatFloat('0.00', AProduto.VlrVenda, LFormatSettings), AProduto.Codigo]);
    Result := FQuerys.ExecuteSQL(SQL);
    FConexao.CommitTransaction;
  except
    on E: Exception do
    begin
      FConexao.RollbackTransaction;
      TRegisterLog.i.Log('Erro ao atualizar produto: ' + E.Message);
    end;
  end;
end;

function TProdutoController.Delete(const ACodigo: Integer): Boolean;
var
  SQL: string;
begin
  Result := False;
  try
    FConexao.BeginTransaction;
    SQL := Format('DELETE FROM produtos WHERE codigo = %d', [ACodigo]);
    Result := FQuerys.ExecuteSQL(SQL);
    FConexao.CommitTransaction;
  except
    on E: Exception do
    begin
      FConexao.RollbackTransaction;
      TRegisterLog.i.Log('Erro ao deletar produto: ' + E.Message);
    end;
  end;
end;

function TProdutoController.GetByCodigoOrDescricao(const AValue: String): TObjectList<TProdutoDTO>;
var
  SQL: string;
  DataSet: TDataSet;
  LCodigo: Integer;
begin
  Result := TObjectList<TProdutoDTO>.Create;
  try
    if TryStrToInt(AValue, LCodigo) then
    begin
      SQL := Format('SELECT * FROM produtos WHERE (codigo = %d) OR (descricao LIKE ''%%%s%%'')', [LCodigo, AValue]);
    end
    else
    begin
      SQL := Format('SELECT * FROM produtos WHERE (descricao LIKE ''%%%s%%'')', [AValue]);
    end;

    if FQuerys.ExecuteSQL(SQL) then
    begin
      DataSet := FQuerys.DataSet;

      if Assigned(DataSet) and DataSet.Active and not DataSet.IsEmpty then
      begin
        DataSet.First;
        while not DataSet.Eof do
        begin
          Result.Add(GetProdutoFromDataSet(DataSet));
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

function TProdutoController.GetByCode(const ACodigo: Integer): TProdutoDTO;
var
  SQL: string;
  DataSet: TDataSet;
begin
  Result := nil;
  try
    SQL := Format('SELECT * FROM produtos WHERE codigo = %d', [ACodigo]);
    if FQuerys.ExecuteSQL(SQL) then
    begin
      DataSet := FQuerys.DataSet;
      if not DataSet.IsEmpty then
      begin
        Result := GetProdutoFromDataSet(DataSet);
      end;
    end;
  except
    on E: Exception do
    begin
      TRegisterLog.i.Log('Erro ao buscar produto por código: ' + E.Message);
    end;
  end;
end;

function TProdutoController.GetAll: TObjectList<TProdutoDTO>;
var
  SQL: string;
  DataSet: TDataSet;
begin
  Result := TObjectList<TProdutoDTO>.Create;
  try
    SQL := 'SELECT * FROM produtos';
    if FQuerys.ExecuteSQL(SQL) then
    begin
      DataSet := FQuerys.DataSet;
      DataSet.First;
      while not DataSet.Eof do
      begin
        Result.Add(GetProdutoFromDataSet(DataSet));
        DataSet.Next;
      end;
    end;
  except
    on E: Exception do
    begin
      TRegisterLog.i.Log('Erro ao buscar todos os produtos: ' + E.Message);
      FreeAndNil(Result);
    end;
  end;
end;

end.

