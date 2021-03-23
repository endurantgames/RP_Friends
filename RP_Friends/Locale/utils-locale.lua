-- ------------------------------------------------------------------------------
-- rp:Friends
-- by Oraibi, Moon Guard (US) server
--
-- Ora's twitter: http://twitter.com/oraibimoonguard
-- Download site: http://tinyurl.com/rptags-tukui
-- Documentation: http://tinyurl.com/rptags-wiki
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

  -- Utils-Locale: Utilities for localizing text strings
  --
  -- List of functions at the end

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
