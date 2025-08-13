unit Projeto.View.Cadastro.Cliente;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, System.Generics.Collections,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls, FMX.Layouts, System.Rtti,
  FMX.ListBox, FMX.Edit, FMX.Controls.Presentation, FMX.TabControl, FMX.Objects,
  System.Actions, FMX.ActnList, FMX.DialogService,

  Projeto.Controller.Fancy.Dialog,
  Projeto.View.Heranca,
  Projeto.Model.Conexao,
  Projeto.Controller.Cliente,
  Projeto.Model.DTO.Classes,
  Projeto.Model.Interfaces,
  Projeto.Controller.Loading,
  Projeto.Controller.Interfaces
  ;

type
  TViewCadastroCliente = class(TViewHeranca)
    Rectangle9: TRectangle;
    Layout13: TLayout;
    Label3: TLabel;
    Rectangle6: TRectangle;
    edtNome: TEdit;
    Layout15: TLayout;
    Label7: TLabel;
    Rectangle7: TRectangle;
    edtCidade: TEdit;
    Layout16: TLayout;
    Label8: TLabel;
    Rectangle8: TRectangle;
    edtUF: TEdit;
    procedure rect_novoClick(Sender: TObject);
    procedure rect_gravarClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure rect_voltarClick(Sender: TObject);
    procedure SearchEditButton1Click(Sender: TObject);
    procedure ClearEditButton1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    FListaCliente: TObjectList<TClienteDTO>;
    FConexao: iConexao;
    FClienteController: iClienteController;
    FBuscaClientes: TThread;
    FMessage: TFancyDialog;
    procedure BuscaClientes;
    procedure ClearFormFields;
    function GetClienteDTOFromForm: TClienteDTO;
    procedure EditarItem(Sender: TObject);
    procedure ExcluirItem(Sender: TObject);
    procedure FocoNoNomeCliente;

  public
    { Public declarations }
  end;

var
  ViewCadastroCliente: TViewCadastroCliente;

implementation

{$R *.fmx}

procedure TViewCadastroCliente.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  inherited;

  if Assigned(FMessage) then
    FreeAndNil(FMessage);
end;

procedure TViewCadastroCliente.FormCreate(Sender: TObject);
begin
  inherited;

  FConexao                := TModelConexao.New;
  FClienteController      := TClienteController.New(FConexao);
  FMessage                := TFancyDialog.Create(Self);
  FBuscaClientes          := nil;
end;

procedure TViewCadastroCliente.FormDestroy(Sender: TObject);
begin
  inherited;

  if Assigned(FBuscaClientes) then
  begin
    FBuscaClientes.Terminate;
    FBuscaClientes.WaitFor;
    FreeAndNil(FBuscaClientes);
  end;

  FClienteController  := nil;
  FConexao            := nil;
  FreeAndNil(FListaCliente);
end;

procedure TViewCadastroCliente.FormShow(Sender: TObject);
begin
  inherited;
  BuscaClientes;
end;

procedure TViewCadastroCliente.ExcluirItem(Sender: TObject);
begin
  TDialogService.MessageDialog(
    'Deseja excluir este cliente?',
    TMsgDlgType.mtConfirmation,
    [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo],
    TMsgDlgBtn.mbYes,
    0,
    procedure(const AResult: TModalResult)
    var
      ListBoxItem: TListBoxItem;
    begin
      if AResult = mrYes then
      begin
        if Sender is TFmxObject then
        begin
          ListBoxItem := TListBoxItem(FindItemParent(Sender as TFmxObject, TListBoxItem));
          if Assigned(ListBoxItem) then
          begin
            if not FClienteController.Delete(ListBoxItem.Tag) then
              FMessage.Show(TIconDialog.Error, 'Atenção', 'Impossivel excluir cliente verifique log.')
            else
            begin
              FMessage.Show(TIconDialog.Success, 'Sucesso', 'Cliente excluído.');
              BuscaClientes;
            end;
          end;
        end;
      end;
    end
  );
end;

procedure TViewCadastroCliente.FocoNoNomeCliente;
begin
  TThread.CreateAnonymousThread(procedure
  begin
      TThread.Synchronize( nil,
      procedure
        begin
          self.ActiveControl := edtNome;
          edtNome.SetFocus;
        end);
    end).Start;
end;

procedure TViewCadastroCliente.EditarItem(Sender: TObject);
Var
  ClienteDTO: TClienteDTO;
  ListBoxItem: TListBoxItem;
begin
  ListBoxItem := TListBoxItem(FindItemParent(Sender as TFmxObject, TListBoxItem));

  ClienteDTO        := FClienteController.GetByCode(ListBoxItem.Tag);

  if Assigned(ClienteDTO) then
  begin
    edtCodigo.Text    := ClienteDTO.Codigo.ToString;
    edtCodigo.Enabled := false;

    edtNome.Text      := ClienteDTO.Nome;
    edtNome.Enabled   := true;

    edtCidade.Text    := ClienteDTO.Cidade;
    edtCidade.Enabled := true;

    edtUF.Text        := ClienteDTO.UF;
    edtUF.Enabled     := true;

    FreeAndNil(ClienteDTO);
  end
  else
  begin
    FMessage.Show(TIconDialog.Warning, 'Atenção', 'Cliente não encontrado.');
  end;

  TabControl.Tag := 2;
  actCadastro.Execute;
end;

procedure TViewCadastroCliente.rect_gravarClick(Sender: TObject);
Var
  ClienteDTO: TClienteDTO;
  CodigoCliente: Integer;
begin
  inherited;

  ClienteDTO := nil;
  try
    try
      ClienteDTO := GetClienteDTOFromForm;

      if TabControl.Tag = 1 then
      begin
        CodigoCliente := FClienteController.Insert(ClienteDTO);

        if CodigoCliente > 0 then
        begin
          edtCodigo.Text := IntToStr(CodigoCliente);
          FMessage.Show(TIconDialog.Success, 'Sucesso', 'Código: ' + IntToStr(CodigoCliente) + sLineBreak + 'Cliente inserido!');
        end
        else
        begin
          FMessage.Show(TIconDialog.Error, 'Atenção', 'Erro ao inserir cliente. Verifique o log para mais detalhes.');
        end;
      end
      else
      begin
        if FClienteController.Update(ClienteDTO) then
          FMessage.Show(TIconDialog.Success, 'Sucesso', 'Cliente alterado com sucesso!');
      end;

      ClearFormFields;
      BuscaClientes;
      actPainel.Execute;
    except
      on E: EArgumentException do
        FMessage.Show(TIconDialog.Error, 'Atenção', 'Erro de validação: ' + E.Message);
      on E: Exception do
        FMessage.Show(TIconDialog.Error, 'Atenção', 'Erro inesperado: ' + E.Message);
    end;
  finally
    FreeAndNil(ClienteDTO);
  end;
end;

procedure TViewCadastroCliente.BuscaClientes;
begin
  TLoading.Show(Self, 'Buscando clientes...');
  TThread.CreateAnonymousThread(procedure
  var
    LListaClientes: TObjectList<TClienteDTO>;
    LSearchText: string;
  begin
    Sleep(500);

    TThread.Synchronize(nil, procedure
    begin
      LSearchText := edtBusca.Text;
    end);

    if LSearchText <> '' then
      LListaClientes := FClienteController.GetByCodigoOrNome(LSearchText)
    else
      LListaClientes := FClienteController.GetAll;

    TThread.Synchronize(nil, procedure
    var
      ListBoxItem: TListBoxItem;
      i: Integer;
    begin
      ListBoxPrincipal.Items.Clear;
      ListBoxPrincipal.BeginUpdate;
      try
        if Assigned(LListaClientes) then
        begin
          for i := 0 to Pred(LListaClientes.Count) do
          begin
            ListBoxItem             := TListBoxItem.Create(ListBoxPrincipal);
            ListBoxItem.Parent      := ListBoxPrincipal;
            ListBoxItem.StyleLookup := 'StyleItemClientes';
            ListBoxItem.Height      := 70;

            ListBoxItem.Tag         := LListaClientes.Items[i].Codigo;
            ListBoxItem.TagString   := LListaClientes.Items[i].Nome;

            ListBoxItem.StylesData['lblCodigo']     := LListaClientes.Items[i].Codigo.ToString;
            ListBoxItem.StylesData['lblNome']       := LListaClientes.Items[i].Nome;
            ListBoxItem.StylesData['lblCidade']     := LListaClientes.Items[i].Cidade;
            ListBoxItem.StylesData['lblUF']         := LListaClientes.Items[i].UF;

            ListBoxItem.StylesData['rect_editar.OnClick']    := TValue.From<TNotifyEvent>(EditarItem);
            ListBoxItem.StylesData['rect_excluir.OnClick']   := TValue.From<TNotifyEvent>(ExcluirItem);

            ListBoxPrincipal.AddObject(ListBoxItem);
          end;
        end;
      finally
        ListBoxPrincipal.EndUpdate;
        FreeAndNil(LListaClientes);

        lblQtdeItens.Text := ListBoxPrincipal.Items.Count.ToString+' item(s) exibidos';
        TLoading.Hide;
      end;
    end);
  end).Start;
end;

procedure TViewCadastroCliente.rect_novoClick(Sender: TObject);
begin
  inherited;

  edtCodigo.Enabled := false;
  TabControl.Tag := 1;
  ClearFormFields;
  FocoNoNomeCliente;
  actCadastro.Execute;
end;

procedure TViewCadastroCliente.rect_voltarClick(Sender: TObject);
begin
  inherited;
  TabControl.Tag := 0;
  ClearFormFields;
  BuscaClientes;
  actPainel.Execute;
end;

procedure TViewCadastroCliente.SearchEditButton1Click(Sender: TObject);
begin
  inherited;

  BuscaClientes;
end;

procedure TViewCadastroCliente.ClearEditButton1Click(Sender: TObject);
begin
  inherited;

  BuscaClientes;
end;

procedure TViewCadastroCliente.ClearFormFields;
begin
  edtCodigo.Text    := '';
  edtNome.Text      := '';
  edtCidade.Text    := '';
  edtUF.Text        := '';
  FocoNoNomeCliente;
end;

function TViewCadastroCliente.GetClienteDTOFromForm: TClienteDTO;
var
  LCodigo: Integer;
begin
  if Trim(edtNome.Text).IsEmpty then
  begin
    raise EArgumentException.Create('O nome do cliente não pode ser vazio. Por favor, preencha o campo.');
  end;

  if (Length(Trim(edtUF.Text)) <> 2) or (Trim(edtUF.Text) <> UpperCase(Trim(edtUF.Text))) then
  begin
    raise EArgumentException.Create('A UF deve conter 2 letras maiúsculas.');
  end;

  LCodigo := StrToIntDef(edtCodigo.Text, 0);

  Result := TClienteDTO.Create(LCodigo, edtNome.Text, edtCidade.Text, edtUF.Text);
end;

end.
