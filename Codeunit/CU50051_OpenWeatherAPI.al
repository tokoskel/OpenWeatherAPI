codeunit 50051 OpenWeatherAPI
{
    trigger OnRun()
    begin
        CurrentWeatherByCity('rostock,de');
    end;

    var
        APIKey: Label '64857812fa6bc8aa6cd8efc34b021781', Locked = true;

    local procedure CurrentWeatherByCity(City: Text)
    var
        NAVAppSetting: Record "NAV App Setting";
        TenantManagement: Codeunit "Tenant Management";
        AppInfo: ModuleInfo;
        HttpClient: HttpClient;
        Url: Text;
        ResponseMessage: HttpResponseMessage;
        JsonText: Text;
        JsonObject1: JsonObject;
        JsonObject2: JsonObject;
        JsonToken: JsonToken;
    begin
        NavApp.GetCurrentModuleInfo(AppInfo);

        if TenantManagement.IsSandbox() then begin
            NAVAppSetting."App ID" := AppInfo.Id();
            NAVAppSetting."Allow HttpClient Requests" := true;
            if not NAVAppSetting.Insert() then
                NAVAppSetting.Modify();
        end;

        Url := StrSubstNo('http://api.openweathermap.org/data/2.5/weather?q=%1&APPID=%2', City, APIKey);

        if not HttpClient.get(Url, ResponseMessage) then begin
            Error('No Connection to Url %1', Url)
        end;

        if not ResponseMessage.IsSuccessStatusCode() then begin
            Error('Current Weather for City failed with code %1\%2',
                  ResponseMessage.HttpStatusCode(),
                  ResponseMessage.ReasonPhrase());
        end;

        // Luetaan HTTP vastausviesti (JSON) tekstimuuttujaan
        ResponseMessage.Content().ReadAs(JsonText);
        // Muutetaan teksti JsonObjektiksi
        JsonObject1.ReadFrom(JsonText);
        // Lasketaan montako avainta objekti sisältää (13). 
        Message('JsonObjectCount1 keys %1', jsonObject1.Keys.Count);
        // Haetaan objekteista avainta 'main' ja tallennetaan tokeniin    
        if JsonObject1.Get('main', JsonToken) then begin
            // Tallennetaan nyt tokenin sisältä toiseksi JsonObjektiksi
            JsonObject2 := JsonToken.AsObject();
            // Tarkistetaan montako avainta tästä objektista löytyy (6).
            Message('JsonObjectCount2 keys %1', jsonObject2.Keys.Count);
            // Haetaan JsonObjektista avainta 'temp' ja tallennetaan tokeniin 
            if JsonObject2.Get('temp', JsonToken) then begin
                // Nyt haetaan tokenin arvo tekstinä
                Message('Temperature: %1', JsonToken.AsValue().AsText());
            end;
        end;
    end;
}