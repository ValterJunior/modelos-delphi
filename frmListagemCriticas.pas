unit frmListagemCriticas;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, frmModelo, StdCtrls, Buttons, ExtCtrls, ImgList;

type
  TFormListagemCriticas = class(TFormModelo)
    ListBox1: TListBox;
    ImageList1: TImageList;
    procedure FormCreate(Sender: TObject);
    procedure ListBox1DrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormListagemCriticas: TFormListagemCriticas;

function exibirCriticas( aErros : TStringList ) : Boolean;

implementation

{$R *.dfm}

function exibirCriticas( aErros : TStringList ) : Boolean;
begin

  if aErros.Count > 0 then
    begin

      try

        Application.CreateForm( TFormListagemCriticas, FormListagemCriticas );
        FormListagemCriticas.ListBox1.Items := TStrings( aErros );
        FormListagemCriticas.ShowModal;
      finally
        FormListagemCriticas.Free;
      end;
      
    end;

  Result := aErros.Count = 0;

end;

procedure TFormListagemCriticas.FormCreate(Sender: TObject);
begin
  inherited;

  ListBox1.ItemHeight := ImageList1.Height + 2;

end;

procedure TFormListagemCriticas.ListBox1DrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
const
  IconMargin  = 4;
  TextMargin  = 6;
var
  OffSetY :Integer;
  StatusIcon :TBitmap;
  
begin
  inherited;

// Pinta o fundo do retângulo
  (Control as TListBox).Canvas.FillRect(Rect);

// Para centralizar o texto na altura, iremos calcular aqui em que posição (Y)
// deverá ser desenhado o texto
  OffSetY := ((Rect.Bottom -Rect.Top) -(Control as TListBox).Canvas.TextHeight('A')) div 2;

// Para as próximas etapas, desenharemos apenas dentro do retângulo,
// não interferindo nas suas bordas
  Inc(Rect.Left, 1 +IconMargin);  // também ajustamos o início do icone
  Inc(Rect.Top, 1);
  Dec(Rect.Bottom, 1);
  Dec(Rect.Right, 1);

  // Alocamos um bitmap para obter uma figura referente ao status da lista de imagens
  StatusIcon := TBitmap.Create;

  try

   // obtemos o bitmap da lista, referente ao status armazenado no item de Objects
   // a conversão ser faz necessária porque Objects armazena ponteiros
    if ImageList1.GetBitmap(0, StatusIcon) then

     // Utilizando a função BrushCopy, pintamos o bitmap na definida por Rect.
     // A função fará um stretch da imagem se utilizar outro tamanho que não o da imagem
      (Control as TListBox).Canvas.BrushCopy(Classes.Rect(Rect.Left, Rect.Top, Rect.Left +ImageList1.Width, Rect.Top +ImageList1.Height),
                                             StatusIcon,  // imagem
                                             Classes.Rect(0, 0, ImageList1.Width -1, ImageList1.Height -1),   // área da imagem a copiar
                                             StatusIcon.Canvas.Pixels[0, 0]);  // cor de fundo (usamos o pixel superior-esquerdo
  finally
// liberamos o bitmap alocado
    StatusIcon.Free;
  end;

  // Para desenhar o texto após o icone, devemos avançar o início do retângulo para
// além da largura da imagem + a margem desejada
  Inc(Rect.Left, ImageList1.Width +TextMargin);
  (Control as TListBox).Canvas.TextRect(Rect,  // área onde será desenhado o texto
                                        Rect.Left,  // início na posição X
                                        Rect.Top +OffSetY,  // início na posição Y
                                        (Control as TListBox).Items[Index]);

end;

end.
