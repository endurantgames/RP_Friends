-- rp:Friends
-- by Oraibi, Moon Guard (US) server
-- ------------------------------------------------------------------------------
-- This work is licensed under the Creative Commons Attribution 4.0 International
-- (CC BY 4.0) license. 

local RP_FRIENDS = RP_FRIENDS;

table.insert(RP_FRIENDS.startup, function(state) -- startup function

  local LDBI = LibStub("LibDBIcon-1.0");
  local Config = RP_FRIENDS.utils.config;
  local loc    = RP_FRIENDS.utils.locale.loc;

  -- creates a random frame for storing our button; parented to UIParent because we don't want it appearing/disappearing with friendslist
  local friendsButton = CreateFrame("Button", nil, UIParent);

  -- the button frame's function for creating what we need
  function friendsButton:CreateButton()

    -- this creates a data broker object
    --
    local friendsDataBroker = LibStub:GetLibrary("LibDataBroker-1.1"):NewDataObject("rp:Friends", {
      type    = "launcher",
      text    = "rp:Friends",
      label   = "rp:Friends",
      tocname = "RP_Friends",

      -- the icon[RGB] is used by LDBI; the color is the addon color
      -- icon = "Interface\\FriendsFrame\\UI-Toast-ChatInviteIcon",
      -- iconR = 0.20, iconG = 0.73, iconB = 0.6,
      -- icon = "Interface\\AddOns\\RP_Friends\\resources\\Graphics\\rpfriends-person-64x64",
      icon = RP_FRIENDS.const.icons.BUTTON,

      -- our click function
      OnClick = 
        function(clickedframe, button) -- on Control-Click, pop up otions, otherwise toggle friends list
          if   IsControlKeyDown()
          then RP_FRIENDS.keybinds.options();
          else RP_FRIENDS.friendslist:SetShown(not RP_FRIENDS.friendslist:IsShown()); 
          end; -- if
        end;

      -- our tooltip
      OnEnter =
        function(self)
          GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
          GameTooltip:ClearLines();
          GameTooltip:AddLine(loc("APP_NAME"));
          GameTooltip:AddLine("Click to " .. 
            (RP_FRIENDS.friendslist:IsShown() and "hide" or "show")                      -- switches between states
            .. " the " .. loc("APP_NAME") .. " friendslist.", 0.7, 0.7, 0.7, true);
          GameTooltip:AddLine("Control-click to set options.", 0.7, 0.7, 0.7, true);
          GameTooltip:Show();
        end,
      OnLeave = function(self) GameTooltip:Hide(); end,
    }); 
    
    -- make sure we have somewhere to store the settings
    RP_FriendsDB.settings.button = RP_FriendsDB.settings.button or {};

    -- tell LDBI that we have this thing called "rp:Friends"
    LDBI:Register("rp:Friends", friendsDataBroker, RP_FriendsDB.settings.button);

    -- set the startup state of the button
    if Config.get("BUTTON") then LDBI:Show("rp:Friends"); else LDBI:Hide("rp:Friends"); end;

  end; -- :CreateButton()

  -- so we can access it later
  RP_FRIENDS.button = friendsButton;

  -- tell button where we are
  return "button ";
end);  -- startup function
