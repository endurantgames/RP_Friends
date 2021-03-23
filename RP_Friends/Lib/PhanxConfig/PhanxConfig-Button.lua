
--[[--------------------------------------------------------------------
	PhanxConfig-Button
	Simple button widget generator. Requires LibStub.
	https://github.com/Phanx/PhanxConfig-Button
	Copyright (c) 2009-2015 Phanx <addons@phanx.net>. All rights reserved.
	Feel free to include copies of this file WITHOUT CHANGES inside World of
	Warcraft addons that make use of it as a library, and feel free to use code
	from this file in other projects as long as you DO NOT use my name or the
	original name of this file anywhere in your project outside of an optional
	credits line -- any modified versions must be renamed to avoid conflicts.
----------------------------------------------------------------------]]

local MINOR_VERSION = 20170904

local lib, oldminor = LibStub:NewLibrary("PhanxConfig-Button", MINOR_VERSION)
if not lib then return end

------------------------------------------------------------------------

local scripts = {}

function scripts:OnEnter() -- same as InterfaceOptionsCheckButtonTemplate
	if self.tooltipText then
		GameTooltip:SetOwner(self, self.tooltipOwnerPoint or "ANCHOR_RIGHT")
		GameTooltip:SetText(self.tooltipText, nil, nil, nil, nil, true)
	end
end

scripts.OnLeave = GameTooltip_Hide

function scripts:OnClick(button)
	PlaySound(SOUNDKIT.GS_TITLE_OPTION_OK)
	local callback = self.OnClick or self.Callback or self.callback
	if callback then
		callback(self, button)
	end
end

------------------------------------------------------------------------

function lib:New(parent, name, tooltipText)
	assert(type(parent) == "table" and parent.CreateFontString, "PhanxConfig-Button: Parent is not a valid frame!")
	if type(name) ~= "string" then name = nil end
	if type(tooltipText) ~= "string" then tooltipText = nil end

	local button = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
	button:GetFontString():SetPoint("CENTER", -1, 0)
	button:SetMotionScriptsWhileDisabled(true)
	button:RegisterForClicks("AnyUp")

	for name, func in pairs(scripts) do
		button:SetScript(name, func)
	end

	button:SetText(name)
	button:SetWidth(max(110, button:GetFontString():GetStringWidth() + 24))
	button.tooltipText = tooltipText

	return button
end

function lib.CreateButton(...) return lib:New(...) end
