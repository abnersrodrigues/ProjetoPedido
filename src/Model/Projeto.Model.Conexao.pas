unit Projeto.Model.Conexao;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool,
  FireDAC.Stan.Async, FireDAC.Phys, FireDAC.VCLUI.Wait, Data.DB,
  FireDAC.Comp.Client, FireDAC.Phys.PGDef, FireDAC.Phys.PG, FireDAC.Phys.SQLite,
  FireDAC.Phys.SQLiteDef, FireDAC.Stan.ExprFuncs, FireDAC.Comp.UI,
  FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.Comp.DataSet,
  FireDAC.Stan.StorageBin, System.IniFiles, Projeto.Model.Interfaces,
  Projeto.Controller.RegisterLog;

Type

  TModelConexao = class(TInterfacedObject, iConexao)
    private
      FConexao : TFDConnection;
    public
      constructor Create;
      destructor Destroy; override;
      class function New : iConexao;

      function Conexao : TCustomConnection;
      procedure BeginTransaction;
      procedure CommitTransaction;
      procedure RollbackTransaction;
  end;

const
  DB_DIRECTORY_NAME = 'bd';
  DB_FILE_NAME = 'bd.db';

implementation

uses
  Projeto.Model.Querys;

{ TModelConexao }

function TModelConexao.Conexao: TCustomConnection;
begin
  Result := FConexao;
end;

constructor TModelConexao.Create;
var
  DatabaseFullPath: string;
  DatabaseFilePath: string;
  Querys: iQuerys;
  ArquivoJaExistia: Boolean;
begin
  DatabaseFullPath := ExtractFilePath(ParamStr(0)) + DB_DIRECTORY_NAME;
  DatabaseFilePath := DatabaseFullPath + PathDelim + DB_FILE_NAME;

  if not DirectoryExists(DatabaseFullPath) then
  begin
    CreateDir(DatabaseFullPath);
  end;

  ArquivoJaExistia := FileExists(DatabaseFilePath);

  FConexao := TFDConnection.Create(nil);
  FConexao.ResourceOptions.SilentMode := true;
  FConexao.Params.DriverID := 'SQLite';
  FConexao.Params.Database := DatabaseFilePath;

  try
    FConexao.Connected  := true;

    if not ArquivoJaExistia then
    begin
      Querys := TModelQuerys.New(Self);
      try
        Querys.CriarEstruturaBancoDeDados;
      finally
        Querys := nil;
      end;
    end;
  Except
    on E: Exception do
    begin
      TRegisterLog.i.Log('Erro ao conectar ou inicializar Banco de Dados: ' + E.Message);
    end;
  end;
end;

destructor TModelConexao.Destroy;
begin
  TRegisterLog.myFree;
  FreeAndNil(FConexao);
  inherited;
end;

class function TModelConexao.New: iConexao;
begin
  Result := Self.Create;
end;

procedure TModelConexao.BeginTransaction;
begin
  if Assigned(FConexao) and FConexao.Connected then
    FConexao.StartTransaction;
end;

procedure TModelConexao.CommitTransaction;
begin
  if Assigned(FConexao) and FConexao.Connected then
    FConexao.Commit;
end;

procedure TModelConexao.RollbackTransaction;
begin
  if Assigned(FConexao) and FConexao.Connected then
    FConexao.Rollback;
end;

end.

