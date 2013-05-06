local name, ns = ...

ns.name = name
ns.title = GetAddOnMetadata(ns.name, "Title")

local debugf = tekDebug and tekDebug:GetFrame(name)
function ns:Debug(...) if debugf then debugf:AddMessage(string.join(", ", tostringall(...))) end end

local title = "|cFF33FF99".. ns.title .. "|r:"
function ns:Print(...) print(title, ...) end
