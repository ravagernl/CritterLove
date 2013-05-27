local _, addon = ...
local L = addon.localization
addon.localization = nil

local EMOTE_LOVE = EMOTE152_TOKEN:lower()
local InCombatLockdown = InCombatLockdown
local SOUND = 'Sound\\Spells\\Valentines_Lookingforloveheart.ogg'

addon.achievementIds = {
    1206, -- To All The Squirrels I've Loved Before (azeroth)
    2557, -- To All The Squirrels Who Shared My Life (azeroth 2)
    5548, -- To All the Squirrels Who Cared for Me (cataclysm)
    6350, -- To All the Squirrels I Once Caressed? (mop)
}

function addon:OnLoad()
    self.dirty = true
    self:Debug'OnLoad'
    self.achievements = {}
    self.critters = {}

    self.main = CreateFrame('Button', addon.name..'Button', nil, 'SecureActionButtonTemplate')
    self.main:SetAttribute('type', 'macro')
    self.macros = {}
    for idx, aid in ipairs(self.achievementIds) do
        self.macros[idx] = CreateFrame('Button', addon.name..'MacroButton'..idx, nil, 'SecureActionButtonTemplate')
        self.macros[idx]:SetAttribute('type', 'macro')
    end

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
    if self.dirty then
        self:Debug('Leaving combat, running postponed criteria update')
        self:CRITERIA_UPDATE()
    end
end

function addon:PLAYER_REGEN_DISABLED()
    self:RegisterEvent'PLAYER_REGEN_ENABLED'

    self:UnregisterEvent'UPDATE_MOUSEOVER_UNIT'
    self:UnregisterEvent'UNIT_TARGET'
    self:UnregisterEvent'PLAYER_REGEN_DISABLED'
end

function addon:PLAYER_TARGET_CHANGED()
    if self:Scan('target', true) then
        PlaySoundFile(SOUND)
        return DoEmote(EMOTE_LOVE)
    end
    self:Scan'targettarget'
end

function addon:UPDATE_MOUSEOVER_UNIT()
    self:Scan'mouseover'
    self:Scan'mouseovertarget'
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
    --local CRITTER = BATTLE_PET_DAMAGE_NAME_5

    function addon:Scan(unit, suppress)
        if
            not UnitExists(unit) or
            not UnitCanAttack('player', unit) or
            UnitIsDead(unit) --or
            --UnitCreatureType(unit) ~= CRITTER
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
            if not suppress then
                local message = L.found_message:format(EMOTE_LOVE, name, link)

                self:Print(message)
                RaidNotice_AddMessage(RaidBossEmoteFrame, message, ChatTypeInfo['RAID_WARNING'])
                PlaySoundFile(SOUND)
            end
            return true
        end
    end
end

do
    local sm = "\n/stopmacro [exists,nodead]\n"
    function addon:CRITERIA_UPDATE()
        if not self.dirty and InCombatLockdown() then
            self:Debug('postponing criteria update until after combat')
            self.dirty = true
            return
        end
        self.dirty = false

        local oldNumCritters = self.numCritters
        wipe(self.achievements)
        wipe(self.critters)
        self.numCritters = 0

        local m, s, name, completed, macro, _ = "/cleartarget\n"
        for idx, aid in ipairs(self.achievementIds) do
            _, _, _, completed = GetAchievementInfo(aid)
            macro, s = self.macros[idx], ''
            if not completed then
                m = m .. '/click '..macro:GetName()..sm
                self.achievements[aid] = GetAchievementLink(aid)

                for cid =1, GetAchievementNumCriteria(aid) do
                    name, _, completed =  GetAchievementCriteriaInfo(aid, cid)

                    if
                        not completed and
                        not self.critters[name]
                    then
                        s = s .. '/targetexact '..name..sm
                        self.critters[name] = aid
                        self.numCritters = self.numCritters + 1
                    end
                end
            end
            --self:Debug(aid, s)
            macro:SetAttribute('macrotext', s)
        end
        --self:Debug(m)
        self.main:SetAttribute('macrotext', m)

        if oldNumCritters ~= self.numCritters then
            return self:HasCrittersRemaining()
        end
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
