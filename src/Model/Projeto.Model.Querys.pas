unit Projeto.Model.Querys;

interface

Uses
  System.SysUtils, Vcl.Dialogs, Projeto.Model.Interfaces, System.Types, StrUtils,
  FireDAC.Stan.Intf,FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf,
  FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys,
  FireDAC.VCLUI.Wait, Data.DB, FireDAC.Comp.Client, FireDAC.Phys.SQLite,
  FireDAC.Phys.SQLiteDef, FireDAC.Stan.ExprFuncs, FireDAC.Stan.Param,
  FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt, FireDAC.Comp.DataSet, System.JSON,
  System.Classes;

Type
  TModelQuerys = class(TInterfacedObject, iQuerys)
    private
      FParent : iConexao;
      FQry    : TFDQuery;
    public
      constructor Create(Parent : iConexao);
      destructor Destroy; override;
      class function New (Parent : iConexao): iQuerys;

      function DataSet : TDataSet;
      function CriarEstruturaBancoDeDados: Boolean;
      function ExecuteSQL(const ASQL: string): Boolean;
  end;

implementation

uses
  Projeto.Controller.RegisterLog;

constructor TModelQuerys.Create(Parent : iConexao);
begin
  FParent := Parent;

  FQry := TFDQuery.Create(nil);
  FQry.Connection := TFDConnection(FParent.Conexao);
end;

function TModelQuerys.DataSet: TDataSet;
begin
  Result := FQry;
end;

destructor TModelQuerys.Destroy;
begin
  TRegisterLog.myFree;
  FreeAndNil(FQry);
  inherited;
end;

function TModelQuerys.CriarEstruturaBancoDeDados:Boolean;
Begin
  try
    with FQry do
    Begin
      Close;
      SQL.Clear;
      SQL.Add('CREATE TABLE IF NOT EXISTS clientes (');
      SQL.Add('codigo          INTEGER PRIMARY KEY AUTOINCREMENT,');
      SQL.Add('nome            VARCHAR(100) NOT NULL,');
      SQL.Add('cidade          VARCHAR(50),');
      SQL.Add('uf              VARCHAR(2)');
      SQL.Add(');');
      ExecSQL;

      Close;
      SQL.Clear;
      SQL.Add('CREATE TABLE IF NOT EXISTS produtos (');
      SQL.Add('codigo          INTEGER PRIMARY KEY AUTOINCREMENT,');
      SQL.Add('descricao       VARCHAR(100) NOT NULL,');
      SQL.Add('vlr_venda       DECIMAL(9,2)');
      SQL.Add(');');
      ExecSQL;

      Close;
      SQL.Clear;
      SQL.Add('CREATE TABLE IF NOT EXISTS pedido_status (');
      SQL.Add('codigo          INTEGER PRIMARY KEY AUTOINCREMENT,');
      SQL.Add('descricao       VARCHAR(100) NOT NULL');
      SQL.Add(');');
      ExecSQL;

      Close;
      SQL.Clear;
      SQL.Add('insert into pedido_status (descricao) VALUES (''Pendente'');');
      ExecSQL;

      Close;
      SQL.Clear;
      SQL.Add('insert into pedido_status (descricao) VALUES (''Em Processamento'');');
      ExecSQL;

      Close;
      SQL.Clear;
      SQL.Add('insert into pedido_status (descricao) VALUES (''Concluído'');');
      ExecSQL;

      Close;
      SQL.Clear;
      SQL.Add('insert into pedido_status (descricao) VALUES (''Cancelado'');');
      ExecSQL;

      Close;
      SQL.Clear;
      SQL.Add('CREATE TABLE IF NOT EXISTS pedido_header (');
      SQL.Add('codigo          INTEGER PRIMARY KEY AUTOINCREMENT,');
      SQL.Add('dt_emissao      TIMESTAMP NOT NULL,');
      SQL.Add('codigo_cliente  INTEGER,');
      SQL.Add('codigo_status   INTEGER,');
      SQL.Add('vlr_total       DECIMAL(9,2),');
      SQL.Add('FOREIGN KEY (codigo_cliente) REFERENCES clientes(codigo)');
      SQL.Add('FOREIGN KEY (codigo_status)  REFERENCES pedido_status(codigo)');
      SQL.Add(');');
      ExecSQL;

      Close;
      SQL.Clear;
      SQL.Add('CREATE TABLE IF NOT EXISTS pedido_itens (');
      SQL.Add('codigo          INTEGER PRIMARY KEY AUTOINCREMENT,');
      SQL.Add('numero_pedido   INTEGER,');
      SQL.Add('codigo_produto  INTEGER,');
      SQL.Add('qtde            INTEGER,');
      SQL.Add('vlr_unitario    DECIMAL(9,2),');
      SQL.Add('vlr_total       DECIMAL(9,2),');
      SQL.Add('FOREIGN KEY (numero_pedido) REFERENCES pedido_header(codigo),');
      SQL.Add('FOREIGN KEY (codigo_produto) REFERENCES produtos(codigo)');
      SQL.Add(');');
      ExecSQL;

      Close;
      SQL.Clear;
      SQL.Add('CREATE TRIGGER IF NOT EXISTS trg_after_insert_pedido_item');
      SQL.Add('AFTER INSERT ON pedido_itens');
      SQL.Add('FOR EACH ROW');
      SQL.Add('BEGIN');
      SQL.Add('  UPDATE pedido_header');
      SQL.Add('  SET vlr_total = (SELECT SUM(qtde * vlr_unitario)');
      SQL.Add('                   FROM pedido_itens');
      SQL.Add('                   WHERE numero_pedido = NEW.numero_pedido)');
      SQL.Add('  WHERE codigo = NEW.numero_pedido;');
      SQL.Add('END;');
      ExecSQL;

      Close;
      SQL.Clear;
      SQL.Add('CREATE TRIGGER IF NOT EXISTS trg_after_update_pedido_item');
      SQL.Add('AFTER UPDATE OF qtde, vlr_unitario ON pedido_itens');
      SQL.Add('FOR EACH ROW');
      SQL.Add('BEGIN');
      SQL.Add('    -- Recalcula para o pedido antigo, caso o numero_pedido tenha sido alterado (improvável, mas boa prática)');
      SQL.Add('    UPDATE pedido_header');
      SQL.Add('   SET vlr_total = (SELECT SUM(qtde * vlr_unitario)');
      SQL.Add('                    FROM pedido_itens');
      SQL.Add('                    WHERE numero_pedido = OLD.numero_pedido)');
      SQL.Add('   WHERE codigo = OLD.numero_pedido;');
      SQL.Add('   -- Recalcula para o pedido novo');
      SQL.Add('   UPDATE pedido_header');
      SQL.Add('   SET vlr_total = (SELECT SUM(qtde * vlr_unitario)');
      SQL.Add('                    FROM pedido_itens');
      SQL.Add('                    WHERE numero_pedido = NEW.numero_pedido)');
      SQL.Add('   WHERE codigo = NEW.numero_pedido;');
      SQL.Add('END;');
      ExecSQL;

      Close;
      SQL.Clear;
      SQL.Add('CREATE TRIGGER IF NOT EXISTS trg_after_delete_pedido_item');
      SQL.Add('AFTER DELETE ON pedido_itens');
      SQL.Add('FOR EACH ROW');
      SQL.Add('BEGIN');
      SQL.Add('    UPDATE pedido_header');
      SQL.Add('    SET vlr_total = (SELECT COALESCE(SUM(qtde * vlr_unitario), 0)');
      SQL.Add('                     FROM pedido_itens');
      SQL.Add('                     WHERE numero_pedido = OLD.numero_pedido)');
      SQL.Add('    WHERE codigo = OLD.numero_pedido;');
      SQL.Add('END;');
      ExecSQL;

      Close;
      SQL.Clear;
      SQL.Add('CREATE TABLE IF NOT EXISTS clientes (');
      SQL.Add('codigo          INTEGER PRIMARY KEY AUTOINCREMENT,');
      SQL.Add('nome            VARCHAR(100) NOT NULL,');
      SQL.Add('cidade          VARCHAR(50),');
      SQL.Add('uf              VARCHAR(2)');
      SQL.Add(');');
      ExecSQL;
      Close;
      SQL.Clear;
      SQL.Add('CREATE TRIGGER IF NOT EXISTS trg_before_delete_cliente');
      SQL.Add('BEFORE DELETE ON clientes');
      SQL.Add('FOR EACH ROW');
      SQL.Add('BEGIN');
      SQL.Add('    SELECT RAISE(ABORT, ''Não é possível excluir o cliente, pois existem pedidos associados a ele.'')');
      SQL.Add('    WHERE EXISTS (SELECT 1 FROM pedido_header WHERE codigo_cliente = OLD.codigo);');
      SQL.Add('END;');
      ExecSQL;
      Close;
      SQL.Clear;
      SQL.Add('CREATE TABLE IF NOT EXISTS produtos (');
      SQL.Add('codigo          INTEGER PRIMARY KEY AUTOINCREMENT,');
      SQL.Add('descricao       VARCHAR(100) NOT NULL,');
      SQL.Add('vlr_venda       DECIMAL(9,2)');
      SQL.Add(');');
      ExecSQL;
      Close;
      SQL.Clear;
      SQL.Add('CREATE TRIGGER IF NOT EXISTS trg_before_delete_produto');
      SQL.Add('BEFORE DELETE ON produtos');
      SQL.Add('FOR EACH ROW');
      SQL.Add('BEGIN');
      SQL.Add('    SELECT RAISE(ABORT, ''Não é possível excluir o produto, pois existem itens de pedidos associados a ele.'')');
      SQL.Add('    WHERE EXISTS (SELECT 1 FROM pedido_itens WHERE codigo_produto = OLD.codigo);');
      SQL.Add('END;');
      ExecSQL;
    End;

    Result := true;
  Except
    on E: Exception do
    begin
      TRegisterLog.i.Log('Erro ao criar tabela "leitores": ' + E.Message);
      Result := false;
    end;
  end;
End;

function TModelQuerys.ExecuteSQL(const ASQL: string): Boolean;
begin
  Result := True;
  try
    with FQry do
    begin
      Close;
      SQL.Text := ASQL;

      if StartsText('SELECT', Trim(ASQL)) then
      begin
        Open;
      end
      else
      begin
        ExecSQL;
      end;
    end;
  except
    on E: Exception do
    begin
      Result := false;
      TRegisterLog.i.Log('Erro ao executar SQL: ' + ASQL + '. Erro: ' + E.Message);
    end;
  end;
end;

class function TModelQuerys.New(Parent: iConexao): iQuerys;
begin
  Result := Self.Create(Parent);
end;

end.

