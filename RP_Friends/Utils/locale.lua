-- rp:Friends
-- by Oraibi, Moon Guard (US) server
-- ------------------------------------------------------------------------------
-- This work is licensed under the Creative Commons Attribution 4.0 International
-- (CC BY 4.0) license. 

local RP_FRIENDS     = RP_FRIENDS;

table.insert(RP_FRIENDS.startup, function(state)

  local Const      = RP_FRIENDS.const;
  local Utils      = RP_FRIENDS.utils;
  
  if not Utils.locale then Utils.locale = {}; end;
  local Loc = Utils.locale;
  
        -- localization
  local function loc(k)  local lang = "enUS"; return RP_FRIENDS.locale[lang][k or ""] or ""; end; 
  
  -- Functions available under RP_FRIENDS.utils.locale
  --
  Loc.loc     = loc;
  Loc.floc    = floc;

  return "utils-locale-break" -- "break" lets us tell core/init that we can stop here if we need to
end); -- startup function
