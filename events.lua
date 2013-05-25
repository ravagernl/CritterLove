local _, addon = ...

local frame = CreateFrame'Frame'

addon.eventFrame = frame
function addon:RegisterEvent(event, func)
    --self:Debug('Registering ' ..event..' to '.. (func or '<self>:'..event))
    frame:RegisterEvent(event)
    if func then self[event] = func end
    assert(self[event], 'Missing event in table: '..event)
end

function addon:UnregisterEvent(event)
    --self:Debug('Unregistering ' ..event)
    frame:UnregisterEvent(event)
end

function addon:UnregisterAllEvents()
    --self:Debug'Unregistering all events'
    frame:UnregisterAllEvents()
end

do
    local function OnEvent(self, event, ...)
        --addon:Debug('Event: '.. event, ...)
        if addon[event] then addon[event](addon, ...) end
    end

    local function ProcessOnLoad(self, event, arg1)
        if arg1 ~= addon.name then return end

        if addon.OnLoad then
            addon:OnLoad()
            addon.OnLoad = nil
        end

        ProcessOnLoad = nil
        if not addon.ADDON_LOADED then
            frame:UnregisterEvent'ADDON_LOADED'
        end

        self:SetScript('OnEvent', OnEvent)
    end

    frame:RegisterEvent'ADDON_LOADED'
    frame:SetScript('OnEvent', ProcessOnLoad)
end
