unit FrameDemoBase;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls;

type
  TfrDemoBase = class(TFrame)
  private
    FOnBackButtonClicked: TNotifyEvent;

  protected
    procedure Resize; override;

  public
    procedure BackButtonClicked;

    property OnBackButtonClicked: TNotifyEvent read FOnBackButtonClicked write FOnBackButtonClicked;

  public
    //constructor Create(AOwner: TComponent); override;
  end;

implementation

{$R *.fmx}

{ TfrDemoBase }

procedure TfrDemoBase.BackButtonClicked;
begin
  if Assigned(OnBackButtonClicked) then
    OnBackButtonClicked(Self);
end;

procedure TfrDemoBase.Resize;
begin
  inherited Resize;

end;

end.
