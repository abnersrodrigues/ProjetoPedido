unit Projeto.Controller.Cliente;

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections, Data.DB,
  Projeto.Model.Interfaces,
  Projeto.Model.DTO.Classes,
  Projeto.Controller.Interfaces,
  Projeto.Controller.RegisterLog;

Type
  TClienteController = class(TInterfacedObject, iClienteController)
  private
    FConexao: iConexao;
    FQuerys: iQuerys;
    function GetClienteFromDataSet(const ADataSet: TDataSet): TClienteDTO;
  public
    constructor Create(AConexao: iConexao);
    destructor Destroy; override;
    class function New(AConexao: iConexao): iClienteController;

    function Insert(const ACliente: TClienteDTO): Integer; // Alterado para retornar Integer
    function Update(const ACliente: TClienteDTO): Boolean;
    function Delete(const ACodigo: Integer): Boolean;
    function GetByCode(const ACodigo: Integer): TClienteDTO;
    function GetAll: TObjectList<TClienteDTO>;
    function GetByCodigoOrNome(const AValue: String): TObjectList<TClienteDTO>; // Novo método
  end;

implementation

uses
  Projeto.Model.Querys;

{ TClienteController }

constructor TClienteController.Create(AConexao: iConexao);
begin
  FConexao := AConexao;
  FQuerys := TModelQuerys.New(FConexao);
end;

destructor TClienteController.Destroy;
begin
  FQuerys := nil;
  FConexao := nil;
  inherited;
end;

class function TClienteController.New(AConexao: iConexao): iClienteController;
begin
  Result := Self.Create(AConexao);
end;

function TClienteController.GetClienteFromDataSet(const ADataSet: TDataSet): TClienteDTO;
var
  LCodigo: Integer;
  LNome: string;
  LCidade: string;
  LUF: string;
begin
  LCodigo := 0;
  LNome := '';
  LCidade := '';
  LUF := '';

  try
    if ADataSet.FieldByName('codigo') <> nil then
      LCodigo := ADataSet.FieldByName('codigo').AsInteger;
  except
    on E: Exception do
      TRegisterLog.i.Log('Erro ao ler campo "codigo" do DataSet (Cliente): ' + E.Message);
  end;

  try
    if ADataSet.FieldByName('nome') <> nil then
      LNome := ADataSet.FieldByName('nome').AsString;
  except
    on E: Exception do
      TRegisterLog.i.Log('Erro ao ler campo "nome" do DataSet (Cliente): ' + E.Message);
  end;

  try
    if ADataSet.FieldByName('cidade') <> nil then
      LCidade := ADataSet.FieldByName('cidade').AsString;
  except
    on E: Exception do
      TRegisterLog.i.Log('Erro ao ler campo "cidade" do DataSet (Cliente): ' + E.Message);
  end;

  try
    if ADataSet.FieldByName('uf') <> nil then
      LUF := ADataSet.FieldByName('uf').AsString;
  except
    on E: Exception do
      TRegisterLog.i.Log('Erro ao ler campo "uf" do DataSet (Cliente): ' + E.Message);
  end;

  Result := TClienteDTO.Create(LCodigo, LNome, LCidade, LUF);
end;

function TClienteController.Insert(const ACliente: TClienteDTO): Integer; // Alterado o tipo de retorno
var
  SQL: string;
  DataSet: TDataSet;
begin
  Result := -1;
  try
    FConexao.BeginTransaction;
    SQL := Format('INSERT INTO clientes (nome, cidade, uf) VALUES (''%s'', ''%s'', ''%s'')',
                  [ACliente.Nome, ACliente.Cidade, ACliente.UF]);
    if FQuerys.ExecuteSQL(SQL) then
    begin
      SQL := 'SELECT last_insert_rowid() as id';
      if FQuerys.ExecuteSQL(SQL) then
      begin
        DataSet := FQuerys.DataSet;
        if not DataSet.IsEmpty then
        begin
          Result := DataSet.FieldByName('id').AsInteger; // Retorna o ID
        end;
      end;
    end;
    FConexao.CommitTransaction;
  except
    on E: Exception do
    begin
      FConexao.RollbackTransaction;
      TRegisterLog.i.Log('Erro ao inserir cliente: ' + E.Message);
    end;
  end;
end;

function TClienteController.Update(const ACliente: TClienteDTO): Boolean;
var
  SQL: string;
begin
  Result := False;
  try
    FConexao.BeginTransaction;
    SQL := Format('UPDATE clientes SET nome = ''%s'', cidade = ''%s'', uf = ''%s'' WHERE codigo = %d',
                  [ACliente.Nome, ACliente.Cidade, ACliente.UF, ACliente.Codigo]);
    Result := FQuerys.ExecuteSQL(SQL);
    FConexao.CommitTransaction;
  except
    on E: Exception do
    begin
      FConexao.RollbackTransaction;
      TRegisterLog.i.Log('Erro ao atualizar cliente: ' + E.Message);
    end;
  end;
end;

function TClienteController.Delete(const ACodigo: Integer): Boolean;
var
  SQL: string;
begin
  Result := False;
  try
    FConexao.BeginTransaction;
    SQL := Format('DELETE FROM clientes WHERE codigo = %d', [ACodigo]);
    Result := FQuerys.ExecuteSQL(SQL);
    FConexao.CommitTransaction;
  except
    on E: Exception do
    begin
      FConexao.RollbackTransaction;
      TRegisterLog.i.Log('Erro ao deletar cliente: ' + E.Message);
    end;
  end;
end;

function TClienteController.GetByCode(const ACodigo: Integer): TClienteDTO;
var
  SQL: string;
  DataSet: TDataSet;
begin
  Result := nil;
  try
    SQL := Format('SELECT * FROM clientes WHERE codigo = %d', [ACodigo]);
    if FQuerys.ExecuteSQL(SQL) then
    begin
      DataSet := FQuerys.DataSet;
      if not DataSet.IsEmpty then
      begin
        Result := GetClienteFromDataSet(DataSet);
      end;
    end;
  except
    on E: Exception do
    begin
      TRegisterLog.i.Log('Erro ao buscar cliente por código: ' + E.Message);
    end;
  end;
end;

function TClienteController.GetAll: TObjectList<TClienteDTO>;
var
  SQL: string;
  DataSet: TDataSet;
begin
  Result := TObjectList<TClienteDTO>.Create;
  try
    SQL := 'SELECT * FROM clientes';
    if FQuerys.ExecuteSQL(SQL) then
    begin
      DataSet := FQuerys.DataSet;
      if Assigned(DataSet) and DataSet.Active then
      begin
        if not DataSet.IsEmpty then
        begin
          DataSet.First;
          while not DataSet.Eof do
          begin
            Result.Add(GetClienteFromDataSet(DataSet));
            DataSet.Next;
          end;
        end
        else
        begin
          TRegisterLog.i.Log('GetAll Clientes: Nenhuns clientes encontrados na base de dados.');
        end;
      end
      else
      begin
        TRegisterLog.i.Log('GetAll Clientes: O DataSet não está ativo ou não foi atribuído corretamente após a execução da SQL.');
      end;
    end
    else
    begin
      TRegisterLog.i.Log('GetAll Clientes: A execução da consulta SQL falhou.');
    end;
  except
    on E: Exception do
    begin
      TRegisterLog.i.Log('Erro ao buscar todos os clientes: ' + E.Message);
      FreeAndNil(Result);
      Result := nil;
    end;
  end;
end;

function TClienteController.GetByCodigoOrNome(const AValue: String): TObjectList<TClienteDTO>;
var
  SQL: string;
  DataSet: TDataSet;
  LCodigo: Integer;
begin
  Result := TObjectList<TClienteDTO>.Create;
  try
    if TryStrToInt(AValue, LCodigo) then
    begin
      SQL := Format('SELECT * FROM clientes WHERE (codigo = %d) OR (nome LIKE ''%%%s%%'')', [LCodigo, AValue]);
    end
    else
    begin
      SQL := Format('SELECT * FROM clientes WHERE (nome LIKE ''%%%s%%'')', [AValue]);
    end;

    if FQuerys.ExecuteSQL(SQL) then
    begin
      DataSet := FQuerys.DataSet;
      if Assigned(DataSet) and DataSet.Active and not DataSet.IsEmpty then
      begin
        DataSet.First;
        while not DataSet.Eof do
        begin
          Result.Add(GetClienteFromDataSet(DataSet));
          DataSet.Next;
        end;
      end
      else
      begin
        TRegisterLog.i.Log('GetByCodigoOrNome: Nenhuns clientes encontrados para o valor: ' + AValue);
      end;
    end
    else
    begin
      TRegisterLog.i.Log('GetByCodigoOrNome: A execução da consulta SQL falhou para o valor: ' + AValue);
    end;
  except
    on E: Exception do
    begin
      TRegisterLog.i.Log('Erro ao buscar clientes por código ou nome para "' + AValue + '": ' + E.Message);
      FreeAndNil(Result);
      Result := nil;
    end;
  end;
end;

end.

