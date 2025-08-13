unit Projeto.Model.Interfaces;

interface

uses
  Data.Db, System.Classes;

Type

  iConexao = interface ['{D23460F7-A705-4F9F-A3AE-34D07883D95B}']
    function Conexao : TCustomConnection;
    procedure BeginTransaction;
    procedure CommitTransaction;
    procedure RollbackTransaction;
  end;

  iQuerys = interface ['{66BDAF23-1949-4082-B680-81818DF14FE3}']
    function DataSet : TDataSet;
    function CriarEstruturaBancoDeDados: Boolean;
    function ExecuteSQL(const ASQL: string): Boolean;
  end;

implementation

end.
