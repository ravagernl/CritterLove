local _, ns = ...

local frame = CreateFrame("Frame")

function ns.RegisterEvent(event, func)
    frame:RegisterEvent(event)
    if func then ns[event] = func end
end

function ns.UnregisterEvent(event)
    frame:UnregisterEvent(event)
end

function ns:UnregisterAllEvents()
    frame:UnregisterAllEvents()
end

local function ProcessOnLoad(arg1)
    if arg1 ~= ns.name then return end

    if ns.OnLoad then
        ns:OnLoad()
        ns.OnLoad = nil
    end

    ProcessOnLoad = nil
    if not ns.ADDON_LOADED then frame:UnregisterEvent("ADDON_LOADED") end
end

frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(self, event, arg1, ...)
    if ProcessOnLoad and event == "ADDON_LOADED" then ProcessOnLoad(arg1) end
    if ns[event] then ns[event](event, arg1, ...) end
end)
