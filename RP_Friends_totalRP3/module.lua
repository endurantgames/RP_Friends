-- RP Tags 
-- by Oraibi, Moon Guard (US) server
-- ------------------------------------------------------------------------------
-- This work is licensed under the Creative Commons Attribution 4.0 International
-- (CC BY 4.0) license.
--
local addOnName, ns = ...;
local RPTAGS        = RPTAGS;
local Module        = RPTAGS.queue:NewModule(addOnName, "rpClient");

Module:WaitUntil("ADDON_LOAD",
function(self, event, ...)
    local refreshFriendsList = RP_FRIENDS.utils.friendsList.refresh;
    table.insert(msp.callback.received, 
      function(unitID) refreshFriendsList(); end);
   end
);

Module:WaitUntil("MODULE_C",
function(self, event, ...)
  local registerFunction = RP_FRIENDS.utils.modules.registerFunction;

  local function mapMrpSlash(mrpParam)
    return function(a) SlashCmdList["MYROLEPLAY"](mrpParam .. " " .. (a or "")); end;
  end;

  registerFunction("MyRolePlay", "open",       mapMrpSlash(""          ));
  registerFunction("MyRolePlay", "options",    mapMrpSlash("options"   ));
  registerFunction("MyRolePlay", "version",    mapMrpSlash("version"   ));
  registerFunction("MyRolePlay", "help",       mapMrpSlash("help"      ));
  registerFunction("MyRolePlay", "on",         mapMrpSlash("enable"    ));
  registerFunction("MyRolePlay", "off",        mapMrpSlash("disable"   ));
  registerFunction("MyRolePlay", "showplayer", mapMrpSlash("show"      ));
  registerFunction("MyRolePlay", "setcurr",    mapMrpSlash("currently" ));
  registerFunction("MyRolePlay", "setic",      mapMrpSlash("ic"        ));
  registerFunction("MyRolePlay", "setooc",     mapMrpSlash("ooc"       ));
  registerFunction("MyRolePlay", "about",      mapMrpSlash("version"   ));

end);

