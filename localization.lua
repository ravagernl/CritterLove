local _, addon = ...
local L = setmetatable({}, { __index = function(t,k)
    if addon.debug then
        error(addon.name..': localized string missing: '..k)
    end
    t[k] = k
    return k
end })

L.addon_disabled = '%s is now turned off and will be disabled the next time you log in.'
L.all_found = 'Congratulations, you have found all the loveable critters on this character.'
L.critters_remaining_plural = 'You have to find %d more critters on this character.'
L.critters_remaining_single = 'You have to find one more critter on this character.'
L.found_message = 'You can /%s a nearby %s for %s! Click your macro!'

addon.localization = L
