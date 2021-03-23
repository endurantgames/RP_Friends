-- ------------------------------------------------------------------------------
-- rp:Friends
-- by Oraibi, Moon Guard (US) server
--
-- Ora's twitter: http://twitter.com/oraibimoonguard
--
-- ------------------------------------------------------------------------------
--
-- This work is licensed under the Creative Commons Attribution 4.0 International
-- (CC BY 4.0) license. To view a copy of the license, visit
--
--     https://creativecommons.org/licenses/by/4.0/
--
-- This license is acceptable for Free Cultural Works.
--
-- You are free to:
--
-- Share -- copy and redistribute the material in any medium or format
-- Adapt -- remix, transform, and build upon the material
--         for any purpose, even commercially.
-- 
-- The licensor cannot revoke these freedoms as long as you follow the 
-- license terms.
-- 
-- Under the following terms:
-- Attribution -- You must give appropriate credit, provide a link to the
--         license, and indicate if changes were made. You may do
--         so in any reasonable manner, but not in any way that
--         suggests the licensor endorses you or your use.
--
-- No additional restrictions -- You may not apply legal terms or
--         technological measures that legally restrict others from doing
--         anything the license permits.
--
-- Notices:
--
-- You do not have to comply with the license for elements of the material
-- in the public domain or where your use is permitted by an applicable
-- exception or limitation.
--
-- No warranties are given. The license may not give you all of the
-- permissions necessary for your intended use. For example, other rights
-- such as publicity, privacy, or moral rights may limit how you use the
-- material.
-- ------------------------------------------------------------------------------

local RP_FRIENDS     = RP_FRIENDS;

table.insert(RP_FRIENDS.startup, function(state) -- startup function

  local notify = RP_FRIENDS.utils.text.notify;
  local Config = RP_FRIENDS.utils.config;
  local loc    = RP_FRIENDS.utils.locale.loc;

  local function keybind_friendsList()
    if   RP_FRIENDS.friendslist:IsShown() then RP_FRIENDS.friendslist:Hide()
    else RP_FRIENDS.friendslist:Show()
    end;
  end;

  local function keybind_options()
    if not InterfaceOptionsFrame:IsShown() then InterfaceOptionsFrame_Show(); end;
    InterfaceOptionsFrame_OpenToCategory(RP_FRIENDS_Main_OptionsPanel) 
  end;

  RP_FRIENDS.keybinds.options     = keybind_options;
  RP_FRIENDS.keybinds.friendsList = keybind_friendsList;

    -- keybindings
  BINDING_HEADER_RP_FRIENDS              = RP_FRIENDS.utils.locale.loc("APP_NAME");
  BINDING_NAME_RP_FRIENDS_FRIENDSLIST    = RP_FRIENDS.utils.locale.loc("KEYBIND_FRIENDSLIST");
  BINDING_NAME_RP_FRIENDS_OPTIONS        = RP_FRIENDS.utils.locale.loc("KEYBIND_OPTIONS");

  -- slash commands
  SLASH_RP_FRIENDS1 = loc("APP_SLASH");
  SLASH_RP_FRIENDS2 = loc("APP_SLASH_SHORT");
  SLASH_RP_FRIENDS3 = loc("APP_SLASH_SHORTER");

  SlashCmdList["RP_FRIENDS"] =
    function(a)
      if   a == "help" or a == "config" or a == "settings" or a == "set" or a == "options"
      then keybind_options()
      else keybind_friendsList()
      end;
    end;

  return "keybinds";

end); -- startup function  
