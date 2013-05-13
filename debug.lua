local name, addon = ...

addon.name = name
addon.title = GetAddOnMetadata(addon.name, 'Title')

do
    local debugf = tekDebug and tekDebug:GetFrame(addon.name)
    if debugf then
        function addon:Debug(...)
            debugf:AddMessage(string.join(", ", tostringall(...)))
        end
    else
        function addon:Debug() end
    end
    -- double negate equals to a boolean
    addon.debug = not not debugf
end

do
    local title = '|cFF33FF99'.. addon.title .. '|r:'
    local format = string.format
    function addon:Print(...) print(title, ...) end
    function addon:PrintFormatted(msg,...) print(title, format(msg, ...)) end
end
