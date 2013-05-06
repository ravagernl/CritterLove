local _, ns = ...

local achievements = {
    1206, -- To All The Squirrels I've Loved Before (azeroth)
    2557, -- To All The Squirrels Who Shared My Life (azeroth 2)
    5548, -- To All the Squirrels Who Cared for Me (cataclysm)
    6350, -- To All the Squirrels I Once Caressed? (mop)
}

-- Critter GUID to achievement ID
ns.critters = {}

function ns:OnLoad()
    self:Debug('OnLoad')
    for _, a_id in pairs(achievements) do
        self:Debug(GetAchievementLink(a_id))
        for c =1, GetAchievementNumCriteria(a_id) do
            local description, type, completed, _, _, _, _, asset_id, _, criteria_id = GetAchievementCriteriaInfo(a_id, c)
            self:Debug(description, type, completed, asset_id, criteria_id)
            if not completed then
                self.critters[description] = a_id
            end
        end
    end

    if not self:HasCrittersRemaining() then return end
end

function ns:HasCrittersRemaining()
    if #self.critters == 0 then
        return true
    end
    self:Print('Congratulations, you have found all the loveable critters in World of Warcraft!')
    self:Print(self.title, ' is not turned off and will be disabled the next time you log in.')
    self:UnregisterAllEvents()
    DisableAddOn(self.name)
end

_G[ns.name] = ns
