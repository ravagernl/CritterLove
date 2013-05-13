local _, addon = ...
local L = addon.localization
addon.localization = nil

local EMOTE_LOVE = EMOTE152_TOKEN:lower()

addon.achievementIds = {
    1206, -- To All The Squirrels I've Loved Before (azeroth)
    2557, -- To All The Squirrels Who Shared My Life (azeroth 2)
    5548, -- To All the Squirrels Who Cared for Me (cataclysm)
    6350, -- To All the Squirrels I Once Caressed? (mop)
}

function addon:OnLoad()
    self:Debug'OnLoad'

    self:RegisterEvent'CRITERIA_UPDATE'
    self:RegisterEvent'PLAYER_TARGET_CHANGED'

    if InCombatLockdown() then
        self:PLAYER_REGEN_DISABLED()
    else
        self:PLAYER_REGEN_ENABLED()
    end
end

function addon:PLAYER_REGEN_ENABLED()
    self:UnregisterEvent'PLAYER_REGEN_ENABLED'

    self:RegisterEvent'UPDATE_MOUSEOVER_UNIT'
    self:RegisterEvent'UNIT_TARGET'
    self:RegisterEvent'PLAYER_REGEN_DISABLED'
end

function addon:PLAYER_REGEN_DISABLED()
    self:RegisterEvent'PLAYER_REGEN_ENABLED'

    self:UnregisterEvent'UPDATE_MOUSEOVER_UNIT'
    self:UnregisterEvent'UNIT_TARGET'
    self:UnregisterEvent'PLAYER_REGEN_DISABLED'
end

function addon:PLAYER_TARGET_CHANGED()
    self:Scan('target')
    self:Scan('targettarget')
end

function addon:UPDATE_MOUSEOVER_UNIT()
    self:Scan('mouseover')
    self:Scan('mouseovertarget')
end

function addon:UNIT_TARGET(unit)
    if not unit or unit == 'player' then
        return
    end
    -- units are party1, target etc. So need to scan unit.. target only
    self:Scan(unit..'target')
end

do
    local UnitExists = UnitExists
    local UnitCanAttack = UnitCanAttack
    local UnitCreatureType = UnitCreatureType
    local UnitIsDead = UnitIsDead
    local UnitName = UnitName

    function addon:Scan(unit)
        if
            not UnitExists(unit) or
            not UnitCanAttack('player', unit) or
            UnitIsDead(unit) or
            UnitCreatureType(unit) ~= L.Critter
        then
            return
        end
        local name = UnitName(unit)
        if not name or not self.critters[name] then
            return
        end
        local aid = self.critters[name]
        local link = self.achievements[aid]

        if name and link then
            self:Debug(unit, name, link)
            local message = L.found_message:format(EMOTE_LOVE, name, link)

            self:Print(message)
            RaidNotice_AddMessage(RaidBossEmoteFrame, message, ChatTypeInfo["RAID_WARNING"])
            PlaySoundFile("Sound\\Spells\\Valentines_Lookingforloveheart.ogg")
        end
    end
end

function addon:CRITERIA_UPDATE()
    local oldNumCritters = self.numCritters
    self.achievements = self.achievements and wipe(self.achievements) or {}
    self.critters = self.critters and wipe(self.critters) or {}
        self.numCritters = 0

    for idx, aid in pairs(self.achievementIds) do
        local _, _, _, completed = GetAchievementInfo(aid)
        if not completed then
            self.achievements[aid] = GetAchievementLink(aid)

            for cid =1, GetAchievementNumCriteria(aid) do
                local name, _, completed =  GetAchievementCriteriaInfo(aid, cid)

                if
                    not completed and
                    not self.critters[name]
                then
                    self.critters[name] = aid
                    self.numCritters = self.numCritters + 1
                end
            end
        end
    end

    if oldNumCritters ~= self.numCritters then
        return self:HasCrittersRemaining()
    end
end

function addon:HasCrittersRemaining()
    if self.numCritters > 1 then
        self:PrintFormatted(L.critters_remaining_plural, self.numCritters)
        return true
    elseif self.numCritters == 1 then
        self:Print(L.critters_remaining_single)
        return true
    end
    self:Print(L.all_found)
    self:PrintFormatted(L.addon_disabled, self.title)
    self:UnregisterAllEvents()
    DisableAddOn(self.name)
end

_G[addon.name] = addon
