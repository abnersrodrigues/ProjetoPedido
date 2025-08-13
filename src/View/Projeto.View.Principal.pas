unit Projeto.View.Principal;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, System.Rtti, FMX.Grid.Style, FMX.Grid,
  FMX.Controls.Presentation, FMX.ScrollBox, FMX.StdCtrls, FMX.Objects, FMX.Layouts,

  Projeto.Controller.Interfaces;

type
  TViewPrincipal = class(TForm)
    SpeedButton2: TSpeedButton;
    Layout3: TLayout;
    Rectangle1: TRectangle;
    Layout4: TLayout;
    Rectangle2: TRectangle;
    lblProdutosCount: TLabel;
    Layout7: TLayout;
    Rectangle4: TRectangle;
    Layout1: TLayout;
    Label2: TLabel;
    Layout2: TLayout;
    Label4: TLabel;
    Layout5: TLayout;
    Rectangle3: TRectangle;
    Image1: TImage;
    Layout6: TLayout;
    Layout8: TLayout;
    Image2: TImage;
    Label5: TLabel;
    Label6: TLabel;
    Layout9: TLayout;
    Rectangle5: TRectangle;
    lblClientesCount: TLabel;
    Layout10: TLayout;
    Image3: TImage;
    Label7: TLabel;
    Label8: TLabel;
    Layout11: TLayout;
    Rectangle6: TRectangle;
    lblPedidosCount: TLabel;
    Rectangle7: TRectangle;
    Rectangle8: TRectangle;
    Label1: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Rectangle2Click(Sender: TObject);
    procedure Rectangle1Click(Sender: TObject);
    procedure Rectangle4Click(Sender: TObject);
  private
    FDashBoardController: iDashBoardController;
    procedure LoadDashboardSummary;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ViewPrincipal: TViewPrincipal;

implementation

Uses
  Projeto.View.Cadastro.Produto,
  Projeto.View.Cadastro.Cliente,
  Projeto.Model.DTO.Classes,
  Projeto.Controller.Dashboard,
  Projeto.Model.Conexao,
  Projeto.View.Cadastro.Pedido;

{$R *.fmx}

procedure TViewPrincipal.FormCreate(Sender: TObject);
begin
  FDashBoardController := TDashBoardController.New(TModelConexao.New);
end;

procedure TViewPrincipal.FormShow(Sender: TObject);
begin
  LoadDashboardSummary;
end;

procedure TViewPrincipal.LoadDashboardSummary;
begin
  TThread.CreateAnonymousThread(procedure
  var
    Summary: TDashBoardSummaryDTO;
  begin
    Summary := nil;
    try
      Summary := FDashBoardController.GetSummaryCounts;
      TThread.Synchronize(nil, procedure
      begin
        if Assigned(Summary) then
        begin
          lblClientesCount.Text := Summary.ClientesCount.ToString + ' Clientes';
          lblProdutosCount.Text := Summary.ProdutosCount.ToString + ' Itens';
          lblPedidosCount.Text  := Summary.PedidosCount.ToString + ' Pendentes';
        end
        else
        begin
          lblClientesCount.Text := '0';
          lblProdutosCount.Text := '0';
          lblPedidosCount.Text  := '0';
        end;
      end);
    finally
      FreeAndNil(Summary);
    end;
  end).Start;
end;

procedure TViewPrincipal.Rectangle1Click(Sender: TObject);
Var
  ViewCadastroCliente: TViewCadastroCliente;
begin
  try
    Application.CreateForm(TViewCadastroCliente, ViewCadastroCliente);
    ViewCadastroCliente.ShowModal;
  finally
    FreeAndNil(ViewCadastroCliente);
    LoadDashboardSummary;
  end;
end;

procedure TViewPrincipal.Rectangle2Click(Sender: TObject);
Var
  ViewCadastroProduto: TViewCadastroProduto;
begin
  try
    Application.CreateForm(TViewCadastroProduto, ViewCadastroProduto);
    ViewCadastroProduto.ShowModal;
  finally
    FreeAndNil(ViewCadastroProduto);
    LoadDashboardSummary;
  end;
end;

procedure TViewPrincipal.Rectangle4Click(Sender: TObject);
Var
  ViewCadastroPedidos: TViewCadastroPedidos;
begin
  try
    Application.CreateForm(TViewCadastroPedidos, ViewCadastroPedidos);
    ViewCadastroPedidos.ShowModal;
  finally
    FreeAndNil(ViewCadastroPedidos);
    LoadDashboardSummary;
  end;
end;

end.
