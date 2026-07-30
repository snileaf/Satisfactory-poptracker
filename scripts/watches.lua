Archipelago:AddClearHandler("clear handler", OnClear)
Archipelago:AddItemHandler("item handler", OnItem)
Archipelago:AddLocationHandler("location handler", OnLocation)

Archipelago:AddSetReplyHandler("notify handler", OnNotify)
Archipelago:AddRetrievedHandler("notify launch handler", OnNotifyLaunch)

if Archipelago.set_room_info_handler then
    Archipelago:set_room_info_handler(OnRoomInfo)
elseif Archipelago.SetRoomInfoHandler then
    Archipelago:SetRoomInfoHandler(OnRoomInfo)
end
-- ScriptHost:AddWatchForCode("settings autofill handler", "autofill_settings", AutoFill)