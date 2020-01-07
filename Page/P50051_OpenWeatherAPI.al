
pageextension 50100 CustomerListExt extends "Customer List"
{
    trigger OnOpenPage();
    begin
        Codeunit.Run(Codeunit::OpenWeatherAPI)
    end;
}