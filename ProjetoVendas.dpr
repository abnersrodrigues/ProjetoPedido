program ProjetoVendas;

uses
  System.StartUpCopy,
  FMX.Forms,
  Projeto.View.Principal in 'src\View\Projeto.View.Principal.pas' {ViewPrincipal},
  Projeto.Model.Conexao in 'src\Model\Projeto.Model.Conexao.pas',
  Projeto.Model.Querys in 'src\Model\Projeto.Model.Querys.pas',
  Projeto.Model.Interfaces in 'src\Model\Interfaces\Projeto.Model.Interfaces.pas',
  Projeto.Model.DTO.Classes in 'src\Model\Projeto.Model.DTO.Classes.pas',
  Projeto.Controller.Interfaces in 'src\Controller\Interfaces\Projeto.Controller.Interfaces.pas',
  Projeto.Controller.Produto in 'src\Controller\Projeto.Controller.Produto.pas',
  Projeto.Controller.Cliente in 'src\Controller\Projeto.Controller.Cliente.pas',
  Projeto.Controller.FuncoesReadParams in 'src\Controller\Outros\Projeto.Controller.FuncoesReadParams.pas',
  Projeto.Controller.RegisterLog in 'src\Controller\Outros\Projeto.Controller.RegisterLog.pas',
  Projeto.Controller.PedidoHeader in 'src\Controller\Projeto.Controller.PedidoHeader.pas',
  Projeto.Controller.PedidoItem in 'src\Controller\Projeto.Controller.PedidoItem.pas',
  Projeto.Controller.Dashboard in 'src\Controller\Projeto.Controller.Dashboard.pas',
  Projeto.View.Heranca in 'src\View\Outros\Projeto.View.Heranca.pas' {ViewHeranca},
  Projeto.View.Cadastro.Cliente in 'src\View\Projeto.View.Cadastro.Cliente.pas' {ViewCadastroCliente},
  Projeto.View.Cadastro.Produto in 'src\View\Projeto.View.Cadastro.Produto.pas' {ViewCadastroProduto},
  Projeto.View.Cadastro.Pedido in 'src\View\Projeto.View.Cadastro.Pedido.pas' {ViewCadastroPedidos},
  Projeto.Controller.Utils in 'src\Controller\Projeto.Controller.Utils.pas',
  Projeto.View.Consultas in 'src\View\Outros\Projeto.View.Consultas.pas' {ViewCadastroConsultas},
  Projeto.Controller.Types in 'src\Controller\Projeto.Controller.Types.pas',
  Projeto.Controller.Loading in 'src\Controller\Projeto.Controller.Loading.pas',
  Projeto.Controller.Fancy.Dialog in 'src\Controller\Projeto.Controller.Fancy.Dialog.pas';

{$R *.res}

begin
  ReportMemoryLeaksOnShutdown := true;

  Application.Initialize;
  Application.CreateForm(TViewPrincipal, ViewPrincipal);
  Application.Run;
end.
