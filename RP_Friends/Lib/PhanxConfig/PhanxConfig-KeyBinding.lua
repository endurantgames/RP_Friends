
--[[--------------------------------------------------------------------
	PhanxConfig-KeyBinding
	Key binding button widget generator. Requires LibStub.
	Originally based on AceGUI-3.0-Keybinding.
	https://github.com/Phanx/PhanxConfig-KeyBinding
	Copyright (c) 2009-2015 Phanx <addons@phanx.net>. All rights reserved.
	Feel free to include copies of this file WITHOUT CHANGES inside World of
	Warcraft addons that make use of it as a library, and feel free to use code
	from this file in other projects as long as you DO NOT use my name or the
	original name of this file anywhere in your project outside of an optional
	credits line -- any modified versions must be renamed to avoid conflicts.
----------------------------------------------------------------------]]

local MINOR_VERSION = 20150112

local PhanxConfigButton = LibStub:GetLibrary("PhanxConfig-Button", true)
assert(PhanxConfigButton, "PhanxConfig-KeyBinding requires PhanxConfig-Button")

local lib, oldminor = LibStub:NewLibrary("PhanxConfig-KeyBinding", MINOR_VERSION)
if not lib then return end

------------------------------------------------------------------------

local HINT_TEXT_ACTIVE = "Press a key to bind, press Escape to clear the binding, or click the button again to cancel."
local HINT_TEXT_INACTIVE = "Click the button to bind a key."

do
	local GAME_LOCALE = GetLocale()
	if GAME_LOCALE == "deDE" then
		HINT_TEXT_ACTIVE = "Drücke eine Taste, um sie zu belegen. Drücke ESC, um die Belegung zu löschen, oder klick erneut, um zu abbrechen."
		HINT_TEXT_INACTIVE = "Klick, um eine Taste zu belegen."

	elseif GAME_LOCALE == "esES" or GAME_LOCALE == "esMX" then
		HINT_TEXT_ACTIVE = "Pulse una tecla para asignarlo, pulse Escape para borrar la asignación, o clic en el botón otra vez para cancelar."
		HINT_TEXT_INACTIVE = "Clic en el botón para asignar una tecla."

	elseif GAME_LOCALE == "frFR" then
		HINT_TEXT_ACTIVE = "Appuyez sur une touche pour assigner un raccourci, appuyez sur Echap pour effacer le raccourci, ou cliquez sur le bouton à nouveau pour annuler."
		HINT_TEXT_INACTIVE = "Cliquez sur le bouton pour assigner une touche."
	end
end

------------------------------------------------------------------------

local scripts = {} -- these are set on the button, not the container

function scripts:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	if self.tooltipText then
		GameTooltip:SetText(self.tooltipText, nil, nil, nil, nil, true)
	elseif self.waitingForKey then
		GameTooltip:SetText(HINT_TEXT_ACTIVE, nil, nil, nil, nil, true)
	else
		GameTooltip:SetText(HINT_TEXT_INACTIVE, nil, nil, nil, nil, true)
	end
	GameTooltip:Show()
end

scripts.OnLeave = GameTooltip_Hide

function scripts:OnClick(button)
	if button ~= "LeftButton" and button ~= "RightButton" then return end

	if self.waitingForKey then
		self:EnableKeyboard(false)
		self:UnlockHighlight()
		self.waitingForKey = nil
	else
		self:EnableKeyboard(true)
		self:LockHighlight()
		self.waitingForKey = true
	end
end

local ignoreKeys = {
	["LeftButton"] = true, ["RightButton"] = true,
	["BUTTON1"] = true, ["BUTTON2"] = true,
	["LALT"] = true, ["LCTRL"] = true, ["LSHIFT"] = true,
	["RALT"] = true, ["RCTRL"] = true, ["RSHIFT"] = true,
	["UNKNOWN"] = true,
}

function scripts:OnKeyDown(key)
	if ignoreKeys[key] or not self.waitingForKey then return end

	if key == "ESCAPE" then
		key = ""
	elseif key == "MiddleButton" then
		key = "BUTTON3"
	elseif key:match("^Button") then
		key = button:upper()
	end

	if IsShiftKeyDown() then
		key = "SHIFT-" .. key
	end
	if IsControlKeyDown() then
		key = "CTRL-" .. key
	end
	if IsAltKeyDown() then
		key = "ALT-" .. key
	end

	self:EnableKeyboard(false)
	self:UnlockHighlight()
	self.waitingForKey = nil

	self:SetValue(key)
end

------------------------------------------------------------------------

local methods = {} -- these are set on the button, not the container

function methods:GetValue()
	return self.action and GetBindingKey(self.action) or nil
end

function methods:SetValue(value)
	if value and value ~= "" then
		self:SetText(value)
	else
		self:SetText(NOT_BOUND)
	end

	local action = self.action
	if action then
		-- clear any previous bindings
		local prev1, prev2 = GetBindingKey(action)
		if prev1 == value then return end
		if prev1 then SetBinding(prev1) end
		if prev2 then SetBinding(prev2) end

		if value and strlen(value) > 0 then
			-- warn if overwriting an existing binding
			local curr = GetBindingAction(value)
			if curr and strlen(curr) > 0 then
				print(format(KEY_UNBOUND_ERROR, curr))
			end

			-- set new binding
			SetBinding(value, action)

			-- restore second binding if there was one
			if prev2 then SetBinding(prev2, action) end
		end

		-- save
		SaveBindings(GetCurrentBindingSet())
	end

	local callback = self.OnValueChanged or self.Callback or self.callback
	if callback then
		callback(self, value)
	end
end

function methods:RefreshValue()
	self:SetText(self:GetValue() or NOT_BOUND)
	self:EnableKeyboard(false) -- no idea why this needs to be here, but...
end

function methods:SetBindingAction(action)
	self.action = action
end

function methods:SetPoint(...)
	return self.container:SetPoint(...)
end

------------------------------------------------------------------------

function lib:New(parent, name, tooltipText, action)
	assert(type(parent) == "table" and parent.CreateFontString, "PhanxConfig-KeyBinding: Parent is not a valid frame!")
	if type(name) ~= "string" then name = nil end
	if type(tooltipText) ~= "string" then tooltipText = nil end

	local frame = CreateFrame("Frame", nil, parent)
	frame:SetSize(186, 38)

	--frame.bg = frame:CreateTexture(nil, "BACKGROUND")
	--frame.bg:SetAllPoints(true)
	--frame.bg:SetTexture(0, 0, 0, 0)

	local button = PhanxConfigButton:New(frame, nil, tooltipText)
	button:SetPoint("BOTTOMLEFT")
	button:SetPoint("BOTTOMRIGHT")

	local label = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	label:SetPoint("TOPLEFT", frame, 5, 0)
	label:SetPoint("TOPRIGHT", frame, -5, 0)
	label:SetJustifyH("LEFT")
	button.labelText = label

	button:SetNormalFontObject(GameFontHighlightSmall)
	button:EnableKeyboard(false)
	button:EnableMouse(true)
	button:RegisterForClicks("AnyDown")

	button.container = frame

	for name, func in pairs(scripts) do
		button:SetScript(name, func)
	end
	for name, func in pairs(methods) do
		button[name] = func
	end

	label:SetText(name)
	button.action = action
	button:RefreshValue()

	return button
end

function lib.CreateKeyBinding(...) return lib:New(...) end
