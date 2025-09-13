inherited FormModeloListagem: TFormModeloListagem
  ClientWidth = 718
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  ExplicitWidth = 724
  ExplicitHeight = 525
  DesignSize = (
    718
    497)
  PixelsPerInch = 96
  TextHeight = 13
  inherited imgTop: TImage
    Width = 718
    ExplicitWidth = 727
  end
  inherited Image1: TImage
    Width = 719
    ExplicitTop = 457
    ExplicitWidth = 728
  end
  inherited btnFechar: TBitBtn
    Left = 635
    Top = 465
    TabOrder = 5
    ExplicitLeft = 635
    ExplicitTop = 465
  end
  object GroupBox1: TGroupBox
    Left = 7
    Top = 75
    Width = 702
    Height = 379
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 1
    DesignSize = (
      702
      379)
    object dbgListagem: TDBGrid
      Left = 8
      Top = 7
      Width = 684
      Height = 364
      Anchors = [akLeft, akTop, akRight, akBottom]
      DataSource = DataSource1
      Options = [dgTitles, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgAlwaysShowSelection, dgConfirmDelete, dgCancelOnExit]
      TabOrder = 0
      TitleFont.Charset = DEFAULT_CHARSET
      TitleFont.Color = clWindowText
      TitleFont.Height = -11
      TitleFont.Name = 'Tahoma'
      TitleFont.Style = []
      OnDblClick = dbgListagemDblClick
    end
  end
  object GroupBox3: TGroupBox
    Left = 7
    Top = 27
    Width = 702
    Height = 45
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Localizar'
    TabOrder = 0
    DesignSize = (
      702
      45)
    object Edit1: TEdit
      Left = 8
      Top = 16
      Width = 684
      Height = 21
      Anchors = [akLeft, akTop, akRight, akBottom]
      TabOrder = 0
      OnChange = Edit1Change
    end
  end
  object btnIncluir: TBitBtn
    Left = 401
    Top = 465
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = '&Incluir'
    TabOrder = 2
    OnClick = btnIncluirClick
  end
  object btnAlterar: TBitBtn
    Left = 477
    Top = 465
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = '&Alterar'
    TabOrder = 3
    OnClick = btnAlterarClick
  end
  object btnExcluir: TBitBtn
    Left = 556
    Top = 465
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = '&Excluir'
    TabOrder = 4
    OnClick = btnExcluirClick
  end
  object btnSelecionar: TBitBtn
    Left = 323
    Top = 465
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = '&Selecionar'
    TabOrder = 6
    Visible = False
    OnClick = btnSelecionarClick
  end
  object btnImprimir: TBitBtn
    Left = 7
    Top = 465
    Width = 82
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Im&primir'
    TabOrder = 7
    Visible = False
    Glyph.Data = {
      DE030000424DDE03000000000000360000002800000011000000120000000100
      180000000000A8030000130B0000130B00000000000000000000FCFCFCFFFFFF
      FFFFFF9B9B9B5757575757575757575757575757575757575757575757579B9B
      9BFFFFFFFFFFFFFCFCFCFFFFFFFFFFFFFFFDFDFDFFFFFF656565FFFFFFFBFBFB
      FFFFFFFFFFFFFFFFFFFFFFFFFCFCFCFFFFFF656565FEFEFEFFFFFFFEFEFEFFFF
      FFFFFEFEFEFFFFFFFCFCFC757575F6F6F6FCFCFCF6F6F6F8F8F8F8F8F8F6F6F6
      FCFCFCF6F6F6757575FCFCFCFFFFFFFEFEFEFDFDFDFF9999994848484C4C4C70
      7070BBBBBBEBEBEBF0F0F0F0F0F0F0F0F0F1F1F1EBEBEBBBBBBB6F6F6F4D4D4D
      474747989898FFFFFFFF515151A8A8A8A9A9A95252527272728F8F8F8D8D8D8C
      8C8C8D8D8D8E8E8E909090737373545454ACACACABABAB525252FFFFFFFF5A5A
      5AA9A9A9AAAAAA4E4E4E4E4E4E4B4B4B4949494C4C4C4D4D4D4B4B4B4E4E4E51
      5151535353ADADADB1B1B1595959FEFEFEFF636363ACACACB7B7B7B2B2B2B4B4
      B4B1B1B1B6B6B6B1B1B1B2B2B2B8B8B8B4B4B4B8B8B8B9B9B9BBBBBBB8B8B861
      6161FFFFFFFF6C6C6CBBBBBBC5C5C5C6C6C6C7C7C7C4C4C4C5C5C5C5C5C5C5C5
      C5C6C6C6C6C6C6C9C9C9CCCCCCCACACAC6C6C66D6D6DFEFEFEFF797979D7D7D7
      E1E1E1E6E6E6E3E3E3E7E7E7E3E3E3E7E7E7E7E7E7E3E3E3E8E8E8E4E4E4E4E4
      E4E2E2E2DADADA767676FFFFFFFF909090F1F1F1FDFDFDF6F6F6F8F8F8F8F8F8
      FAFAFAF9F9F9F9F9F9FAFAFAF8F8F8F8F8F8F9F9F9F6F6F6F1F1F1929292FEFE
      FEFFCECECEC5C5C5EBEBEB7171715E5E5E595959585858565656565656585858
      5959595E5E5E707070EFEFEFC7C7C7C7C7C7FEFEFEFFEEEEEEA5A5A5EBEBEB3E
      3E3E686868FFFFFFFDFDFDFFFFFFFFFFFFFDFDFDFFFFFF6868683D3D3DEEEEEE
      A7A7A7E8E8E8FFFFFFFFFFFFFFC5C5C59C9C9C3C3C3C757575FFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFF7575753C3C3C9A9A9AC5C5C5FFFFFFFFFFFFFFFCFC
      FCFEFEFEFFFFFF3B3B3B8A8A8AFFFFFFFEFEFEFEFEFEFEFEFEFEFEFEFFFFFF8A
      8A8A3B3B3BFFFFFFFDFDFDFDFDFDFFFFFFFFFFFFFFFDFDFDFFFFFFFFFFFF9696
      96FFFFFFFDFDFDFFFFFFFFFFFFFDFDFDFFFFFF969696FFFFFFFFFFFFFCFCFCFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFEFEC6C6C6A4A4A4A1A1A1A1A1A1A1A1
      A1A1A1A1A4A4A4C6C6C6FEFEFEFFFFFFFFFFFFFFFFFFF9F9F9FFFDFDFDFFFFFF
      FAFAFAFFFFFFFFFFFFFCFCFCFFFFFFFFFFFFFFFFFFFFFFFFFCFCFCFFFFFFFFFF
      FFFFFFFFFFFFFFFCFCFCFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFF}
  end
  object ADOQuery1: TADOQuery
    Connection = DM.conexao
    Parameters = <>
    Left = 680
    Top = 392
  end
  object DataSource1: TDataSource
    DataSet = ADOQuery1
    OnDataChange = DataSource1DataChange
    Left = 648
    Top = 392
  end
end
