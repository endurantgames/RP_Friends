-- rp:Friends
-- by Oraibi, Moon Guard (US) server
-- ------------------------------------------------------------------------------
-- This work is licensed under the Creative Commons Attribution 4.0 International
-- (CC BY 4.0) license. 
  -- Utils-Config: Utilities for reading and registering configuration values

local RP_FRIENDS     = RP_FRIENDS;

table.insert(RP_FRIENDS.startup, function(state)
  local Const      = RP_FRIENDS.const;
  local Utils      = RP_FRIENDS.utils;
  local RP_FriendsDB = _G.RP_FriendsDB;
  
  if not Utils.config then Utils.config = {} end;
  local Config = Utils.config;
  
  local Default = Const.CONFIG.DEFAULTS;
  
  for key, _ in pairs(Default)
  do  local db = RP_FriendsDB.settings;
      if not db[key] then db[key] = {} end;
      if   db[key].value ~= nil then db[key].value = db[key].value 
      else db[key].value = Default[key];
      end;
      db[key].default = Default[key];
      db[key].init = nil;
      if key == "ALPHA" and db[key].value > 1 then db[key].value = db[key].value / 100 end;
  end;
         
        -- return the value of a config setting
  local function getConfig(key) if not key then return nil; end;
    if  RP_FriendsDB.settings[key] then return RP_FriendsDB.settings[key].value else return nil end;
  end;  
  
  local function setConfig(key, value) if not key then return nil; end;
    if   RP_FriendsDB.settings[key] then RP_FriendsDB.settings[key].value = value; return value; else return nil; end; -- if;
  end; -- function
  
  local function resetConfig(key) if not key then return nil; end; 
    if    RP_FriendsDB.settings[key]
    then RP_FriendsDB.settings[key].value = RP_FriendsDB.settings[key].default;
         return RP_FriendsDB.settings[key].default;
    else return nil;
    end; --if
  end; -- function
  
  local function getDefault(key) if not key then return nil; end;
    if RP_FriendsDB.settings[key]
    then return RP_FriendsDB.settings[key].default or Default[key];
    else return nil;
    end;
  end; -- function
  
  -- Functions available under RP_FRIENDS.utils.config
  --
  Config.get        = getConfig;
  Config.set        = setConfig;
  Config.reset      = resetConfig;
  Config.default    = getDefault;

  -- keybindings
  BINDING_HEADER_RP_FRIENDS              = RP_FRIENDS.utils.locale.loc("APP_NAME");

  return "config"

end); -- startup function
