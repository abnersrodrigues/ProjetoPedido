unit Projeto.Controller.Loading;

interface

uses System.SysUtils, System.UITypes, FMX.Types, FMX.Controls, FMX.StdCtrls,
     FMX.Objects, FMX.Effects, FMX.Layouts, FMX.Forms, FMX.Graphics, FMX.Ani,
     FMX.VirtualKeyboard, FMX.Platform;

type
  TLoading = class
    private
      class var Layout : TLayout;
      class var Fundo : TRectangle;
      class var Arco : TArc;
      class var Mensagem : TLabel;
      class var Animacao : TFloatAnimation;
    public
      class procedure Show(const form : TForm; const msg: string);
      class procedure Hide;
      class procedure ChangeText(NewText: string); static;
  end;

implementation

{ TLoading }


class procedure TLoading.Hide;
begin
  if Assigned(Layout) then
  begin
    try
      if Assigned(Mensagem) then
              Mensagem.DisposeOf;

      if Assigned(Animacao) then
              Animacao.DisposeOf;

      if Assigned(Arco) then
              Arco.DisposeOf;

      if Assigned(Fundo) then
              Fundo.DisposeOf;

      if Assigned(Layout) then
              Layout.DisposeOf;
    except

    end;
  end;

  Mensagem := nil;
  Animacao := nil;
  Arco := nil;
  Layout := nil;
  Fundo := nil;
end;

class procedure TLoading.Show(const form : TForm; const msg: string);
var
  FService: IFMXVirtualKeyboardService;
begin
  Fundo := TRectangle.Create(form);
  Fundo.Opacity := 0;
  Fundo.Parent := form;
  Fundo.Visible := true;
  Fundo.Align := TAlignLayout.Contents;
  Fundo.Fill.Color := TAlphaColorRec.Black;
  Fundo.Fill.Kind := TBrushKind.Solid;
  Fundo.Stroke.Kind := TBrushKind.None;
  Fundo.Visible := true;

  Layout := TLayout.Create(form);
  Layout.Opacity := 0;
  Layout.Parent := form;
  Layout.Visible := true;
  Layout.Align := TAlignLayout.Contents;
  Layout.Width := 250;
  Layout.Height := 78;
  Layout.Visible := true;

  Arco := TArc.Create(form);
  Arco.Visible := true;
  Arco.Parent := Layout;
  Arco.Align := TAlignLayout.Center;
  Arco.Margins.Bottom := 55;
  Arco.Width := 25;
  Arco.Height := 25;
  Arco.EndAngle := 280;
  Arco.Stroke.Color := $FFFEFFFF;
  Arco.Stroke.Thickness := 2;
  Arco.Position.X := trunc((Layout.Width - Arco.Width) / 2);
  Arco.Position.Y := 0;

  Animacao := TFloatAnimation.Create(form);
  Animacao.Parent := Arco;
  Animacao.StartValue := 0;
  Animacao.StopValue := 360;
  Animacao.Duration := 0.8;
  Animacao.Loop := true;
  Animacao.PropertyName := 'RotationAngle';
  Animacao.AnimationType := TAnimationType.InOut;
  Animacao.Interpolation := TInterpolationType.Linear;
  Animacao.Start;

  Mensagem := TLabel.Create(form);
  Mensagem.Parent := Layout;
  Mensagem.Align := TAlignLayout.Center;
  Mensagem.Margins.Top := 60;
  Mensagem.Font.Size := 13;
  Mensagem.Height := 70;
  Mensagem.Width := form.Width - 100;
  Mensagem.FontColor := $FFFEFFFF;
  Mensagem.TextSettings.HorzAlign := TTextAlign.Center;
  Mensagem.TextSettings.VertAlign := TTextAlign.Leading;
  Mensagem.StyledSettings := [TStyledSetting.Family, TStyledSetting.Style];
  Mensagem.Text := msg;
  Mensagem.VertTextAlign := TTextAlign.Leading;
  Mensagem.Trimming := TTextTrimming.None;
  Mensagem.TabStop := false;
  Mensagem.SetFocus;

  Fundo.AnimateFloat('Opacity', 0.7);
  Layout.AnimateFloat('Opacity', 1);
  Layout.BringToFront;

  TPlatformServices.Current.SupportsPlatformService(IFMXVirtualKeyboardService,
                                                    IInterface(FService));

  if (FService <> nil) then
  begin
      FService.HideVirtualKeyboard;
  end;

  FService := nil;
end;

class procedure TLoading.ChangeText(NewText : string);
begin
  if Assigned(Layout) then
  begin
    try
      if Assigned(Mensagem) then
          Mensagem.Text := NewText;
    except

    end;
  end;
end;

end.

