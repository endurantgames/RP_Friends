-- rp:Friends
-- by Oraibi, Moon Guard (US) server
-- ------------------------------------------------------------------------------
-- This work is licensed under the Creative Commons Attribution 4.0 International
-- (CC BY 4.0) license. 
--
local addOnName, RP_FRIENDS = ...;
RP_FRIENDS.addOnName = addOnName;

for _, item in ipairs({ "cache", "const", "keybinds", "locale", "startup", "utils", }) do RP_FRIENDS[item] = {} end;

local startupFrame = CreateFrame("frame")
startupFrame:RegisterEvent("ADDON_LOADED");
startupFrame:SetScript("OnEvent", 
  function(self, event, addOnLoaded)
    if addOnLoaded == addOnName
       then -- make sure our saved variables exist
            if not RP_FriendsDB          then RP_FriendsDB          = {} end;
            if not RP_FriendsDB.settings then RP_FriendsDB.settings = {} end;
            local state      = {};

            if _G["msp"]      then state.msp  = true end; -- yay we don't need to use our own, we can piggyback off someone else's!
            if _G["TRP3_API"] then state.trp3 = true end;
            if _G["mrp"]      then state.mrp  = true end;

            RP_FRIENDS.cache.startLog = { "This table contains a list of each startup routine excuted, in the order in which they were executed." };
            for _, startupRoutine in ipairs(RP_FRIENDS.startup)
            do  local started = startupRoutine(state)
                table.insert(RP_FRIENDS.cache.startLog, started)
                if started:match("%-break$") and state.err then break end; -- we have enough to give error messages
            end; -- for

            RP_FRIENDS.startup = nil; -- save memory

            table.insert(RP_FRIENDS.cache.startLog, "Startup routines finished.");

            -- if the user wants the login message, show it
            if RP_FRIENDS.utils.config.get("LOGIN_MESSAGE")   then RP_FRIENDS.utils.text.notify(RP_FRIENDS.utils.text.version(state)); end; -- if
            if RP_FRIENDS.utils.config.get("CHANGES_MESSAGE") and RP_FRIENDS.utils.config.get("LOGIN_MESSAGE") 
            then RP_FRIENDS.utils.text.notify(RP_FRIENDS.utils.text.changes(state)); end; -- if

            RP_FRIENDS.cache.state    = state;


       end; -- if addOnLoaded
    end); -- function
_G.RP_FRIENDS = RP_FRIENDS;
