-- RP Friends
-- by Oraibi, Moon Guard (US) server
-- ------------------------------------------------------------------------------
-- This work is licensed under the Creative Commons Attribution 4.0 International
-- (CC BY 4.0) license. 
--
local RP_FRIENDS = RP_FRIENDS;

table.insert(RP_FRIENDS.startup, function(state) -- startup function
  
    -- ----------------- - Temporary values that are used later in rptags.globals
    --  
  local SHORTTEXT_WIDTH  =  40;
  local TEXT_WIDTH       =  80;
  local LONGTEXT_WIDTH   = 100;
  local WIDETEXT_WIDTH   = 160;
  local ZZZ              = "zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"; 

  -- libraries
  --
  local Tourist = LibStub("LibTourist-3.0");

  RP_FRIENDS.grid = { 
    -- ------------- - addon details
  GROUPS = {
    COLOR = { BN   = { 0.510, 0.773, 1.000, 1 }, -- 82c5ff
              ACCT = { 1.000, 0.950, 0.750, 1 }, -- fff2bf
              RP   = { 0.100, 0.900, 0.100, 1 }, -- 1ae61a
            }, -- color
  },
  FIELDS = { 
    BTAG  = { "bnet_bnetIDAccount", "bnet_accountName",   "bnet_battleTag",     "bnet_isBattleTagPresence", "bnet_characterName",      "bnet_bnetIDGameAccount", 
              "bnet_client",        "bnet_isOnline",      "bnet_lastOnline",    "bnet_isAFK",               "bnet_isDND",              "bnet_messageText", 
              "bnet_noteText",      "bnet_isRIDFriend",   "bnet_messageTime",   "bnet_canSoR",              "bnet_isReferAFriend",     "bnet_canSummonFriend",
              "bnet_favorite",      "bnet_mobile", },

    ACCT  = { "acct_hasFocus",      "acct_characterName", "acct_client",        "acct_realmName",           "acct_realmID",            "acct_faction",
              "acct_race",          "acct_class",         "acct_guild",         "acct_zoneName",            "acct_level",              "acct_gameText", 
              "acct_broadcastText", "acct_broadcastTime", "acct_canSoR",        "acct_bnetIDGameAccount",   "acct_presenceID",         "acct_unused_1", 
              "acct_unused_2",      "acct_characterGUID" },

    REALM = { "realm_id",           "realm_name",         "realm_nameForAPI",   "realm_rules",              "realm_locale",            "realm_unused",
              "realm_region",       "realm_timezone",     "realm_connectedIDs", "realm_englishName",        "realm_englishNameForAPI", },

    RP = {    "rp_age",             "rp_class",           "rp_client",          "rp_curr",                  "rp_desc",                 "rp_eyes",
              "rp_glance",          "rp_height",          "rp_home",            "rp_icon",                  "rp_motto",                "rp_name",
              "rp_nick",            "rp_oocinfo",         "rp_race",            "rp_rstatus",               "rp_tooltip",              "rp_weight",
              "rp_xp",              "rp_honorific",       "rp_title",           "rp_birthplace", },
  },

  -- searching uses the search parameter
  COLUMNS = { 
    { index  = "GAME",           
      search = 
        function(f, s) 
          return f.acct_client and f.acct_client:lower():match(s:lower()) 
              or f.bnet_client and f.bnet_client:lower():match(s:lower())
        end,
      sort  = function(f) return f.acct_client or f.bnet_client or ZZZ end, 
      group  = "BN", align = "LEFT", width = TEXT_WIDTH, 
      field  = 
        function(f) 
          return 
            f.acct_client and not f.bnet_battleTag and 
            "|cffffffff" .. RP_FRIENDS.utils.locale.loc("CLIENT_" .. f.acct_client:upper()) .. "|r"
            or f.acct_client and RP_FRIENDS.utils.locale.loc("CLIENT_" .. f.acct_client:upper()) 
            or not f.acct_client and f.bnet_client and RP_FRIENDS.utils.locale.loc("CLIENT_" .. f.bnet_client:upper())
        or "" end, },
    { index = "BATTLETAG",      search = "bnet_battleTag", group = "BN", align = "LEFT", width = LONGTEXT_WIDTH,      
                                sort   = function(f) return f.bnet_battleTag or ZZZ end,
                                alt    = function(f)
                                           return f.bnet_battleTag and 
                                                  (BATTLENET_FONT_COLOR_CODE .. f.bnet_battleTag .. "|r" ..  
                                                   (f.bnet_noteText  and "\n\nNote: " .. BATTLENET_FONT_COLOR_CODE .. f.bnet_noteText:gsub(" %[rp:%x+%]","") .. "|r" or "")
                                                  )
                                                  or ""
                                         end,
                                field  = function(f) return f.bnet_battleTag and f.bnet_battleTag:gsub("#.+$", "") or "" end, },
    { index = "CATEGORY",       search = false, group = "DEFAULT", align = "LEFT", width = TEXT_WIDTH + 15,
                                sort   = function(f) 
                                      local noteText = f.bnet_noteText and f.bnet_noteText ~= "" and f.bnet_noteText or f.acct_charNoteText or "";
                                      local cat = noteText:match(" %[rp:(%x)%x*%]$");
                                      if    cat then return RP_FRIENDS.utils.config.get("CAT" .. cat) else return ZZZ end;
                                      end,
                                click = function(f) RP_FRIENDS.displayFrame:SetFriendCategory(f) end,
                                alt = function(f) 
                                      local noteText = f.bnet_noteText and f.bnet_noteText ~= "" and f.bnet_noteText or f.acct_charNoteText or "";
                                      local cat = noteText:match(" %[rp:(%x+)%]$");
                                      if   not cat 
                                      then return "\n|cff999999Click to set categories.|r" 
                                      else local text = { };
                                           for i in cat:gmatch("%x")
                                           do  table.insert(text, 
                                                 RP_FRIENDS.const.icons.SMALL[RP_FRIENDS.utils.config.get("CAT" .. i .. "_ICON")].icon
                                                 .. " "
                                                 .. RP_FRIENDS.utils.config.get("CAT" .. i .. "_DESC"))
                                           end;
                                           table.insert(text, "\n|cff999999Click to set categories.|r");
                                           return table.concat(text, "\n")
                                      end;
                                end,
                                field = function(f)
                                      local noteText = f.bnet_noteText and f.bnet_noteText ~= "" and f.bnet_noteText or f.acct_charNoteText or "";
                                      local cat, cats = noteText:match(" %[rp:(%x)(%x*)%]$");
                                      if     cat and cats:len() > 0 then return RP_FRIENDS.utils.config.get("CAT" .. cat) .. " +" .. cats:len() 
                                      elseif cat                    then return RP_FRIENDS.utils.config.get("CAT" .. cat) 
                                      else   return "" end;
                                      end, },

    { index = "GAMENAME",       search = "acct_characterName",  group = "DEFAULT", align = "LEFT", width = LONGTEXT_WIDTH,    field = "acct_characterName",
                                sort   = function(f) return f.acct_characterName or ZZZ end,
                                click  = function(f) RP_FRIENDS.displayFrame:ShowProfile(f) end,
                                alt    = function(f) local tt = ""
                                                     if f.bnet_battleTag and f.bnet_battleTag:len() > 0
                                                        then tt = tt .. "\n" .. BATTLENET_FONT_COLOR_CODE .. f.bnet_battleTag .. "|r" 
                                                        end;
                                                     if f.acct_characterName and f.acct_realmName and f.acct_realmName:len() > 0
                                                        then tt = tt .. "\n" .. f.acct_characterName .. "-" .. f.acct_realmName;
                                                     end;
                                                     if (state.mrp or state.trp3) and f.acct_client ~= "DISCONNECT" and f.bnet_client ~= "DISCONNECT"
                                                        then tt = tt .. "\n\n|cff999999Click to open profile"
                                                                      .. (   state.mrp  and " in " .. RP_FRIENDS.utils.locale.loc("ADDON_MRP")
                                                                          or state.trp3 and " in " .. RP_FRIENDS.utils.locale.loc("ADDON_TRP3") 
                                                                          or "") ..".|r" 
                                                        end;
                                                     return tt:len() > 0 and tt or nil
                                                     end, },


    { index = "HONORIFIC",      search = "rp_honorific", group = "RP", align = "RIGHT", width = SHORTTEXT_WIDTH, field = "rp_honorific", 
                                sort = function(f) return f.rp_honorific or ZZZ end, },
    { index = "NAME",           
                                sort = function(f) return f.rp_name or f.acct_characterName or ZZZ end,
                                search = function(f, s)
                                           return f.rp_name            and f.rp_name:lower():match(s:lower())
                                               or f.acct_characterName and f.acct_characterName:lower():match(s:lower()) 
                                         end,
                                group  = "RP",   align = "LEFT",   width = WIDETEXT_WIDTH, 

                                click  = function(f) RP_FRIENDS.displayFrame:ShowProfile(f) end,
                                alt    = function(f) local tt = ""
                                                     if f.rp_title and f.rp_title:len() > 0 then tt = tt .. f.rp_title end;
                                                     if (state.mrp or state.trp3) and f.acct_client ~= "DISCONNECT" and f.bnet_client ~= "DISCONNECT"
                                                        then tt = tt ..  "\n\n|cff999999Click to open profile"
                                                                    .. (   state.mrp  and " in " .. RP_FRIENDS.utils.locale.loc("ADDON_MRP")
                                                                        or state.trp3 and " in " .. RP_FRIENDS.utils.locale.loc("ADDON_TRP3") 
                                                                        or "") ..".|r" 
                                                        end;
                                                     return tt:len() > 0 and tt or nil;
                                                     end, 
                                field  = function(f) return f.rp_name or f.acct_characterName end },
    { index = "NICKNAME",       search = "rp_nick", group = "RP",   align = "LEFT",   width = TEXT_WIDTH, field = "rp_nick", 
                                sort = function(f) return f.rp_nick or ZZZ end, },

    { index = "STATUS",         search = false, group = "RP", align = "CENTER",  width = SHORTTEXT_WIDTH, 
                                click  = function(f)  RP_FRIENDS.displayFrame:ShowProfile(f) end,

                                sort = function(f) return f.rp_status == "1" and "B" 
                                                       or f.rp_status == "2" and "A"
                                                       or f.rp_status == "3" and "C"
                                                       or f.rp_status == "4" and "D"
                                                       or f.rp_status        and "Z" .. f.rp_status
                                                       or "" end,
                                alt    = function(f)
                                           return 
                                             f.rp_status and
                                             (  (   tostring(f.rp_status) == "1" and "|cffdd0000Out of Character|r"
                                                or tostring(f.rp_status) == "0" and "|cff999999Unknown|r"
                                                or tostring(f.rp_status) == "2" and "|cff00dd00In Character|r"
                                                or tostring(f.rp_status) == "3" and "|cff33ff33Open to Roleplay|r"
                                                or tostring(f.rp_status) == "4" and "|cffdddd00Storyteller|r"
                                                or f.rp_status and f.rp_status ~= "" 
                                                   and "|cffffffffCustom Status:|r |cff33dd99" .. f.rp_status .. "|r"
                                                or "")
                                                .. 
                                                (   state.mrp  and "\n\n|cff999999Click to open profile in |cff" 
                                                                   .. RP_FRIENDS.utils.config.get("COLOR_RP") 
                                                                   .. RP_FRIENDS.utils.locale.loc("ADDON_MRP")  
                                                                   .. "|r."
                                                 or state.trp3 and "\n\n|cff999999Click to open profile in |cff" 
                                                                   .. RP_FRIENDS.utils.config.get("COLOR_RP") 
                                                                   .. RP_FRIENDS.utils.locale.loc("ADDON_TRP3") 
                                                                   .. "|r."
                                                 or "")
                                             ) or ""
                                          end, 
                                field = function(f)
                                          return tostring(f.rp_status)       == "1" and "|cffdd0000OOC|r"
                                              or tostring(f.rp_status)       == "0" and "|cff999999?|r"
                                              or tostring(f.rp_status)       == "2" and "|cff00dd00IC|r"
                                              or tostring(f.rp_status)       == "3" and "|cff33ff33Open|r"
                                              or tostring(f.rp_status)       == "4" and "|cffdddd00DM|r"
                                              or f.rp_status and f.rp_status ~= "" and "|cff33dd99Custom|r"
                                              or ""
                                        end, },
    { index = "SERVER_NAME",    search = "realm_name", group = "DEFAULT", align = "LEFT",   width = TEXT_WIDTH + 20, 
                                sort = function(f) return f.acct_realmName or ZZZ end, 
                                alt    = function(f) 
                                  return (f.acct_realmName == "" and f.bnet_client == "WoW"  and f.acct_realmID > 0 and "Blizzard Classic Test Realm"
                                          or f.acct_realmName  and f.acct_realmName ~= "" and f.realm_rules == "RP"  and "|cff" .. RP_FRIENDS.utils.config.get("COLOR_RP")   .. f.realm_name .. "|r"
                                          or f.acct_realmName  and f.acct_realmName ~= "" and "|cff" .. RP_FRIENDS.utils.config.get("COLOR_DEFAULT") .. f.realm_name .. "|r"
                                          or f.acct_realmName  and f.acct_realmName ~= "" and "|cff" .. RP_FRIENDS.utils.config.get("COLOR_DEFAULT") .. f.acct_realmName .. "|r"
                                          or f.acct_realmID    and f.acct_realmID > 0     and "|cff" .. f.bnet_client == "WoW" 
                                             and BATTLENET_FONT_COLOR_CODE .. "Realm #" .. f.acct_realmID .. "|r"
                                          or ""
                                          ) .. 
                                          "\n" .. 
                                          ((f.realm_rules and f.realm_rules .. " Server|r") or "")
                                      or "" end, -- alt
                                field  = function(f)
                                           return f.acct_realmName and f.acct_realmName ~= "" and f.realm_rules == "RP" and "|cff" .. RP_FRIENDS.utils.config.get("COLOR_RP") .. f.realm_name .. "|r"
                                               or f.acct_realmName and f.acct_realmName ~= "" and "|cff" .. RP_FRIENDS.utils.config.get("COLOR_DEFAULT") .. f.realm_name .. "|r"
                                               or f.acct_realmName and f.acct_realmName ~= "" and "|cff" .. RP_FRIENDS.utils.config.get("COLOR_DEFAULT") .. f.acct_realmName .. "|r"
                                               or f.acct_realmID   and f.acct_realmID > 0 and f.bnet_client == "WoW" and BATTLENET_FONT_COLOR_CODE .. f.acct_realmID .. "|r"
                                               or ""
                                         end, },
    { index = "SERVER_TYPE",    search = false,    group = "DEFAULT", align = "CENTER", width = SHORTTEXT_WIDTH, 
                                sort = function(f) return f.realm_rules == "RP" and "A" or f.realm_rules == "PVE" and "B" or "C" end,
                                alt    = function(f) return f.acct_realmName == "" and f.bnet_client == "WoW" and "Blizzard Classic Test Realm"
                                                         or f.realm_rules and f.realm_rules .. " Server"
                                                         or "" end,
                                field = function(f)     
                                          return f.acct_realmName == "" and f.bnet_client == "WoW" and f.acct_realmID > 0 and BATTLENET_FONT_COLOR_CODE .. "Test|r"
                                              or f.realm_rules == "RP"  and "|cff" .. RP_FRIENDS.utils.config.get("COLOR_RP") .. "RP|r" 
                                              or f.realm_rules == "PVE" and "|cff" .. RP_FRIENDS.utils.config.get("COLOR_DEFAULT") .. "PVE|r" 
                                              or "" end; },
    { index = "FACTION",        search = "acct_faction", group = "DEFAULT", align = "CENTER",   width = SHORTTEXT_WIDTH + 5,      
                                sort = function(f) return f.acct_faction or ZZZ end,
                                field  = function(f) 
                                           return f.acct_faction and GetFactionColor(f.acct_faction) and
                                                    (GetFactionColor(f.acct_faction):GenerateHexColorMarkup() .. f.acct_faction .. "|r")
                                                    or "" end, },
    { index = "GAMERACE",       search = "acct_race",   group = "DEFAULT", align = "LEFT",   width = TEXT_WIDTH, field = "acct_race",        
                                sort = function(f) return f.acct_race or ZZZ end, },
    { index = "GAMECLASS",      search = "acct_class",   group = "DEFAULT", align = "LEFT",   width = TEXT_WIDTH, 
                                sort = function(f) return f.acct_class or ZZZ end,
                                alt    = function(f)
                                           return f.acct_class and f.acct_class ~= "" 
                                              and (GetClassColorObj(f.acct_class:upper():gsub(" ","")):GenerateHexColorMarkup() .. f.acct_class .. "|r")
                                               or ""
                                         end ,
                                field  = function(f)
                                           return f.acct_class and f.acct_class ~= "" 
                                              and (GetClassColorObj(f.acct_class:upper():gsub(" ","")):GenerateHexColorMarkup() .. f.acct_class .. "|r")
                                               or ""
                                         end },
    { index = "RACE",           search = function(f, s)
                                           return f.rp_race and f.rp_race:lower():match(s:lower()) 
                                               or f.acct_race and f.acct_race:lower():match(s:lower())
                                         end,
                                sort = function(f) return f.rp_race or f.acct_race or ZZZ end, 
                                group = "RP",   align = "LEFT",   width = LONGTEXT_WIDTH,                  
                                field  = function(f) 
                                           return f.rp_race and f.rp_race ~= "" and f.rp_race
                                               or f.acct_race 
                                               or ""
                                            end, },
    { index = "CLASS",          search = function(f, s)
                                           return f.rp_class and f.rp_class:lower():match(s:lower())
                                               or f.acct_class and f.acct_class:lower():match(s:lower())
                                           end,
                                sort   = function(f) return f.rp_class or f.acct_class or ZZZ end,
                                group = "RP",   align = "LEFT", width = TEXT_WIDTH,
                                field  = function(f) 
                                           return f.rp_class and f.rp_class ~= "" and f.rp_class ~= 'Unknown' and f.rp_class
                                               or f.acct_class and f.acct_class ~= 'Unknown' and f.acct_class
                                               or ""
                                            end, },
    { index = "TITLE",          search = "rp_title", group = "RP", align = "LEFT", width = WIDETEXT_WIDTH, field = "rp_title", 
                                sort = function(f) return f.rp_title or ZZZ end, },
    { index = "LEVEL",          search = false,  group = "DEFAULT", align = "CENTER", width = SHORTTEXT_WIDTH, 
                                sort = function(f) return string.format("%04i", f.acct_level) end,
                                field = function(f)
                                          return (f.acct_level and tonumber(f.acct_level) and tonumber(f.acct_level) > 0 and f.acct_level)
                                                 or nil
                                                 end,
                                alt    = function(f) 
                                           return f.acct_level 
                                              and tonumber(f.acct_level) 
                                              and tonumber(f.acct_level) > 0
                                              and "Level " .. f.acct_level .. " " .. (f.acct_race or "") .. " " .. f.acct_class 
                                              or nil
                                              end },
    { index = "LOCATION",       search = "acct_zoneName", group = "DEFAULT", align = "LEFT",   width = LONGTEXT_WIDTH,                  
                                sort = function(f) return f.acct_zoneName or ZZZ end,
                                field  = 
                                  function(f)
                                    if not f.acct_zoneName or f.acct_zoneName == 'Unknown' then return "" end;
                                    local r, g, b = Tourist:GetFactionColor(f.acct_zoneName)

                                    return RP_FRIENDS.utils.color.colorCode(r * 230, g * 230, b * 230) .. f.acct_zoneName .. "|r"; -- 230 because 255 is too bright
                                  end, },
    -- wide texts come at the end
    { index = "BTAG_BROADCAST", search = "bnet_messageText", group = "BN",   align = "LEFT",   width = WIDETEXT_WIDTH,  
                                sort = function(f) return f.bnet_messageText or ZZZ end,
                                field = "bnet_messageText", },
    { index = "CURR",           search = "rp_curr", group = "RP",   align = "LEFT",   width = WIDETEXT_WIDTH,              
                                click  = function(f)  RP_FRIENDS.displayFrame:ShowProfile(f) end,
                                sort = function(f) return f.rp_curr or ZZZ end, 
                                alt    = function(f)
                                           return  f.rp_curr and 
                                            (
                                            f.rp_curr 
                                              .. (state.mrp     and "\n\n|cff999999Click to open profile in |cff" 
                                              .. RP_FRIENDS.utils.config.get("COLOR_RP")
                                              .. RP_FRIENDS.utils.locale.loc("ADDON_MRP")  
                                              .. "|r."
                                            or state.trp3 and "\n\n|cff999999Click to open profile in |cff" 
                                               .. RP_FRIENDS.utils.config.get("COLOR_RP") 
                                               .. RP_FRIENDS.utils.locale.loc("ADDON_TRP3") 
                                               .. "|r."
                                               or "")
                                             ) or ""
                                          end, 
                                field  = "rp_curr"},

    { index = "OOCINFO",        search = "rp_oocinfo", group = "RP",   align = "LEFT",   width = WIDETEXT_WIDTH,              
                                sort = function(f) return f.rp_oocinfo or ZZZ end,
                                alt    = function(f)
                                           return  f.rp_oocinfo and 
                                            (
                                            f.rp_oocinfo
                                              .. (state.mrp     and "\n\n|cff999999Click to open profile in " 
                                              .. "|cff11dd11" 
                                              .. RP_FRIENDS.utils.locale.loc("ADDON_MRP")  
                                              .. "|r."
                                            or state.trp3 and "\n\n|cff999999Click to open profile in " 
                                              .. "|cff11dd11" 
                                              .. RP_FRIENDS.utils.locale.loc("ADDON_TRP3") .. "|r."
                                               or "")
                                             ) or ""
                                          end, 
                                click  = function(f)  RP_FRIENDS.displayFrame:ShowProfile(f) end,
                                field = "rp_oocinfo", },
    { index = "NOTE",    search = function(f, s)
                                           return 
                                               f.rp_noteText   and f.rp_noteText:lower():match(s:lower())
                                               or f.acct_charNoteText and f.acct_charNoteText:lower():match(s:lower())
                                               or f.bnet_noteText and f.bnet_noteText:lower():match(s:lower())
                                        end,
                          sort = function(f) return f.rp_noteText or f.acct_charNoteText or f.bnet_noteText or ZZZ end,
                                                                        
                           alt    = function(f)
                                      local found, altTable = false, {}
                                      if f.rp_noteText   then table.insert(altTable, "|cff1ea61a"              .. f.rp_noteText   .. "|r"); found = true; end;
                                      if f.acct_charNoteText then table.insert(altTable, "|cfffff2bf"              .. f.acct_charNoteText .. "|r"); found = true; end;
                                      if f.bnet_noteText then table.insert(altTable, BATTLENET_FONT_COLOR_CODE .. f.bnet_noteText .. "|r"); found = true; end;
                                      table.insert(altTable,
                                                   '|cff999999Click to edit player note.|r'
                                                   .. ((state.mrp  and f.rp_name) and '\n|cff999999Control-click to edit |cff11dd11MyRolePlay|r |cff999999note.|r' or '')
                                                   .. ((state.trp3 and f.rp_name) and '\n|cff999999Control-click to edit |cff11dd11Total RP 3|r |cff999999note.|r' or '')
                                                  );
                                      return found and table.concat(altTable, "\n\n"):gsub(" %[rp:%x+%]", "") or "" end,
                           click  = function(f, _, mod)
                                      if     state.mrp and f.unitID and mod == "CONTROL" and f.rp_name
                                      then   mrp.BFShown = f.unitID;
                                             if not(MyRolePlayNotesFrame) then mrp:CreateNotesFrame() end
                                             mrp:UpdateNotesFrame(); MyRolePlayNotesFrame:Show()
                                             RP_FRIENDS.friendslist:Hide();
                                      elseif state.trp3 and f.unitID and mod == "CONTROL" and f.rp_name
                                      then   RP_FRIENDS.displayFrame:ShowProfile(f)
                                             RP_FRIENDS.friendslist:Hide();
                                             TRP3_RegisterCharact:Hide();
                                             TRP3_RegisterAbout:Hide();
                                             TRP3_RegisterMisc:Hide();
                                             TRP3_API.register.ui.showNotesTab()
                                      elseif mod == nil and f.bnet_battleTag -- it's a battlenet friend
                                      then   _G.FriendsFrame.NotesID, _ = f.bnet_bnetIDAccount; 
                                             StaticPopup_Show('SET_BNFRIENDNOTE',  f.bnet_accountName)
                                      else -- it's a server level friend
                                             _G.FriendsFrame.NotesID = f.acct_characterName;
                                             StaticPopup_Show('SET_FRIENDNOTE', f.acct_characterName)
                                      end
                                    end, -- /click
                                group = "DEFAULT", align = "LEFT",   width = WIDETEXT_WIDTH,              
                                field  = function(f)
                                           return f.rp_noteText       and "|cff1ea61a"                 .. f.rp_noteText:gsub(" %[rp:%x+%]","") .. "|r"
                                               or f.acct_charNoteText and "|cfffff2bf"                 .. f.acct_charNoteText:gsub(" %[rp:%x+%]","") .. "|r"
                                               or f.bnet_noteText     and _G.BATTLENET_FONT_COLOR_CODE .. f.bnet_noteText:gsub(" %[rp:%x+%]","") .. "|r"
                                         end, },
  }, -- /columns
  ICONS = {
    { index = "FAVORITE",  alt    = function(f) return f.bnet_favorite and "|cffdd1111Favorite Friend|r" or nil end,
                           sort   = function(f) return f.bnet_favorite and "yes" or ZZZ end,
                           icon   = function(f) return f.bnet_favorite 
                                                        and RP_FRIENDS.utils.color.ico(RP_FRIENDS.const.icons.FAVORITE, "dd1111")
                                                        or nil
                                         end, },
    { index = "CATEGORY",  
                           
                                alt = function(f) 
                                      local noteText = f.bnet_noteText and f.bnet_noteText ~= "" and f.bnet_noteText or f.acct_charNoteText or "";
                                      local cat = noteText:match(" %[rp:(%x+)%]$");
                                      if   not cat 
                                      then return "\n|cff999999Click to set categories.|r" 
                                      else local text = { };
                                           for i in cat:gmatch("%x")
                                           do  table.insert(text, 
                                                 RP_FRIENDS.const.icons.SMALL[RP_FRIENDS.utils.config.get("CAT" .. i .. "_ICON")].icon
                                                 .. " "
                                                 .. RP_FRIENDS.utils.config.get("CAT" .. i .. "_DESC"))
                                           end;
                                           table.insert(text, "|cff999999Click to set categories.|r");
                                           return table.concat(text, "\n")
                                      end;
                                end,

                           click = function(f) RP_FRIENDS.displayFrame:SetFriendCategory(f) end,
                           sort   = function(f) 
                                      local noteText = f.bnet_noteText and f.bnet_noteText ~= "" and f.bnet_noteText or f.acct_charNoteText or "";
                                      local cat = noteText:match(" %[rp:(%x)%x*%]$");
                                      if    cat then return string.format("%02d", tonumber(cat, 16)) else return ZZZ end;
                                      end,
                           icon   = function(f)
                                      local noteText = f.bnet_noteText and f.bnet_noteText ~= "" and f.bnet_noteText or f.acct_charNoteText or "";
                                      local cat = noteText:match(" %[rp:(%x)%x*%]$");
                                      return cat and RP_FRIENDS.const.icons.SMALL[RP_FRIENDS.utils.config.get("CAT" .. cat .. "_ICON")].icon or
                                             RP_FRIENDS.const.icons.DEFAULT_SMALL
                                      end, },
    { index = "GAME",      alt    = function(f) return f.acct_client and RP_FRIENDS.utils.locale.loc("CLIENT_" .. f.acct_client:upper())
                                               or not f.acct_client and f.bnet_client and RP_FRIENDS.utils.locale.loc("CLIENT_" .. f.bnet_client:upper())
                                               or "" 
                                         end,
                           sort   = function(f) return f.acct_client or f.bnet_client or "DISCONNECT"; end,
                           icon  = function(f)     
                                    local game = f.acct_client or f.bnet_client or "DISCONNECT";
                                           if          RP_FRIENDS.const.icons.CLIENTS[game:upper()] 
                                           then return RP_FRIENDS.utils.color.ico(RP_FRIENDS.const.icons.CLIENTS[game:upper()]:gsub("Interface\\",""), "ffffff", "MEDIAN")
                                           else return "" end
                                         end, },
    { index = "ICON",          click  = function(f) 
                                           if     IsControlKeyDown() and (state.mrp or state.trp3)
                                           then   RP_FRIENDS.displayFrame:ShowProfile(f)
                                           elseif f.rp_icon and f.rp_icon ~= "" 
                                           then   RP_FRIENDS.displayFrame:PopupIcon("Interface\\Icons\\" .. f.rp_icon, 
                                                  { f.rp_name, f.rp_race and f.rp_class and f.rp_race .. ' ' .. f.rp_class
                                                             or f.rp_race or frp.class or nil } ) 
                                           else   RP_FRIENDS.displayFrame.popup:Hide();
                                           end end,
                              sort = function(f) return f.rp_icon and "A" or "B" end, 
                                alt    = function(f) return f.rp_icon and "|cff999999Click to view character icon.|r"
                                                         .. (    state.mrp and "\n|cff999999Control-click to open profile in " 
                                                                 .. "|cff" .. RP_FRIENDS.utils.config.get("COLOR_RP") .. RP_FRIENDS.utils.locale.loc("ADDON_MRP") .. "|r."
                                                             or state.trp3 and "\n|cff999999Control-click to open profile in " 
                                                                 .. "|cff" .. RP_FRIENDS.utils.config.get("COLOR_RP") .. RP_FRIENDS.utils.locale.loc("ADDON_TRP3") .. "|r."
                                                             or ""
                                                            )
                                                         or ""
                                                     end,
                                icon  = function(f) return f.rp_icon and f.rp_icon ~= "" and "|TInterface\\ICONS\\" .. f.rp_icon .. ":0|t" or "" end },
    { index = "GAMESTATUS", alt    = function(f) 
                                           return f.bnet_isDND and "Do Not Disturb"
                                               or f.bnet_isAFK and "Away from Keyboard" 
                                               or "" end, 
                                sort   = function(f) return f.bnet_isDND and "dnd" or f.bnet_isAFK and "akf" or ZZZ end,
                                icon  = function(f) 
                                           return f.bnet_isDND and RP_FRIENDS.utils.color.ico("FriendsFrame\\StatusIcon-DnD", "ffffff", "HOURGLASS")
                                               or f.bnet_isAFK and RP_FRIENDS.utils.color.ico("FriendsFrame\\StatusIcon-Away", "ffffff", "HOURGLASS")
                                               or "" 
                                         end, },
    { index = "STATUS",   click  = function(f)  RP_FRIENDS.displayFrame:ShowProfile(f) end,
                                alt    = function(f)
                                           return 
                                             f.rp_status and
                                             (  (   tostring(f.rp_status) == "1" and "|cffdd0000Out of Character|r"
                                                or tostring(f.rp_status) == "0" and "|cff999999Unknown|r"
                                                or tostring(f.rp_status) == "2" and "|cff00dd00In Character|r"
                                                or tostring(f.rp_status) == "3" and "|cff33ff33Open to Roleplay|r"
                                                or tostring(f.rp_status) == "4" and "|cffdddd00Storyteller|r"
                                                or f.rp_status      and "|cff33dd99" .. f.rp_status .. "|r"
                                                or "")
                                                .. 
                                                (   state.mrp  and "\n\n|cff999999Click to open profile in " .. "|cff11dd11" .. RP_FRIENDS.utils.locale.loc("ADDON_MRP")  .. "|r."
                                                 or state.trp3 and "\n\n|cff999999Click to open profile in " .. "|cff11dd11" .. RP_FRIENDS.utils.locale.loc("ADDON_TRP3") .. "|r."
                                                 or "")
                                             ) or ""
                                          end, 
                                
                                sort = function(f) return f.rp_status == "1" and "B" 
                                                       or f.rp_status == "2" and "A"
                                                       or f.rp_status == "3" and "C"
                                                       or f.rp_status == "4" and "D"
                                                       or f.rp_status        and "Z" .. f.rp_status
                                                       or "" end,
                                icon = function(f) 
                                          return tostring(f.rp_status) == "0" and RP_FRIENDS.utils.color.ico(RP_FRIENDS.const.icons.STATUS, "999999", "STATUS")
                                              or tostring(f.rp_status) == "1" and RP_FRIENDS.utils.color.ico(RP_FRIENDS.const.icons.STATUS, "dd0000", "STATUS")
                                              or tostring(f.rp_status) == "2" and RP_FRIENDS.utils.color.ico(RP_FRIENDS.const.icons.STATUS, "00dd00", "STATUS")
                                              or tostring(f.rp_status) == "3" and RP_FRIENDS.utils.color.ico(RP_FRIENDS.const.icons.STATUS, "33ff33", "STATUS")
                                              or tostring(f.rp_status) == "4" and RP_FRIENDS.utils.color.ico(RP_FRIENDS.const.icons.STATUS, "dddd00", "STATUS")
                                              or f.rp_status                  and RP_FRIENDS.utils.color.ico(RP_FRIENDS.const.icons.STATUS, "33dd99", "STATUS")
                                              or ""
                                        end, },
                                

    { index = "SERVER",    alt    = function(f) 
                                  return (f.acct_realmName == "" and f.bnet_client == "WoW"  and f.acct_realmID > 0 
                                             and BATTLENET_FONT_COLOR_CODE .. "Blizzard Classic Test Realm|r"
                                          or f.acct_realmName  and f.acct_realmName ~= "" and f.realm_rules == "RP"  
                                             and "|cff" .. RP_FRIENDS.utils.config.get("COLOR_RP") .. f.realm_name .. "|r"
                                          or f.realm_name and f.realm_name ~= "" 
                                             and "|cff" .. RP_FRIENDS.utils.config.get("COLOR_DEFAULT") .. f.realm_name .. "|r"
                                          or f.acct_realmName  and f.acct_realmName ~= "" 
                                             and "|cff" .. RP_FRIENDS.utils.config.get("COLOR_DEFAULT") .. f.acct_realmName .. "|r"
                                          or f.acct_realmID    and f.acct_realmID > 0     and f.bnet_client == "WoW" 
                                             and BATTLENET_FONT_COLOR_CODE .. "Realm #" .. f.acct_realmID  .. "|r"
                                          or ""
                                          ) .. 
                                          "\n" .. 
                                          ((f.realm_rules and f.realm_rules .. " Server|r") or "")
                                      or "" end, -- alt
                                sort = function(f) return f.realm_rules or ZZZ end,
                                icon  = function(f) 
                                           return f.acct_realmName == "" and f.bnet_client == "WoW" and f.acct_realmID > 0
                                                  and RP_FRIENDS.utils.color.ico(RP_FRIENDS.const.icons.TEST, "ffffff", "CROPPED")
                                               or f.realm_rules == "RP" 
                                                  and RP_FRIENDS.utils.color.ico(RP_FRIENDS.const.icons.RP,   RP_FRIENDS.utils.config.get("COLOR_RP"), "CROPPED")
                                               or f.realm_rules == "PVE" 
                                                  and RP_FRIENDS.utils.color.ico(RP_FRIENDS.const.icons.PVE,  "ffffff", "CROPPED")
                                               or "" end, }, 
    { index = "FACTION",   alt    = "acct_faction",
                                sort = function(f) return f.acct_faction or ZZZ end,
                                icon  = function(f) return f.acct_faction and 
                                           RP_FRIENDS.utils.color.ico(RP_FRIENDS.const.icons[f.acct_faction:upper()], "ffffff", "HOURGLASS")  or "" end, },
    { index = "GAMECLASS", alt    = function(f)
                                           return f.acct_class and f.acct_class ~= "" 
                                              and (GetClassColorObj(f.acct_class:upper():gsub(" ","")):GenerateHexColorMarkup() .. f.acct_class .. "|r")
                                               or ""
                                         end ,
                                sort = function(f) return f.acct_sort or ZZZ end,
                                icon  = function(f)
                                           if not f.acct_class or f.acct_class == "" then return "" end;
                                           return "|A:groupfinder-icon-class-" .. f.acct_class:lower():gsub(" ","") .. ":0:0|a";
                                          end },
    { index = "BTAG_BROADCAST", alt    = "bnet_messageText",
                                sort = function(f) return f.bnet_messageText and f.bnet_messageText ~= "" and "A" or ZZZ end,
                                icon = function(f)
                                                return f.bnet_messageText and f.bnet_messageText ~= "" 
                                                   and RP_FRIENDS.utils.color.ico("FriendsFrame\\BroadcastIcon", "ffffff", "STATUS")
                                                   or  ""
                                              end, },
    { index = "CURR",           click  = function(f)  RP_FRIENDS.displayFrame:ShowProfile(f) end,
                                sort   = function(f) 
                                           return f.rp_curr and f.rp_curr ~= "" and f.rp_oocinfo and f.rp_oocinfo ~= "" and "A"
                                               or f.rp_curr and f.rp_curr ~= ""                                         and "B"
                                               or                                   f.rp_oocinfo and f.rp_oocinfo ~= "" and "C"
                                               or                                                                           "D"
                                         end,
                                alt    = function(f)
                                           return (f.rp_curr and f.rp_curr ~= "" and f.rp_oocinfo and f.rp_oocinfo ~= "" and "|cff1ae61aCurrently:|r " .. f.rp_curr .. "|r\n\n" 
                                                            .. "|cffdd0000OOC Info:|r " .. f.rp_oocinfo .. "|r"
                                               or f.rp_curr and f.rp_curr ~="" and "|cff1ae61aCurrently: |r" .. f.rp_curr .. "|r"
                                               or f.rp_oocinfo and f.rp_oocinfo ~="" and "|cffdd0000OOC Info:|r " .. f.rp_oocinfo .. "|r"
                                               or "")
                                               .. (state.mrp     and "\n\n|cff999999Click to open profile in " .. "|cff11dd11" .. RP_FRIENDS.utils.locale.loc("ADDON_MRP")  .. "|r."
                                                   or state.trp3 and "\n\n|cff999999Click to open profile in " .. "|cff11dd11" .. RP_FRIENDS.utils.locale.loc("ADDON_TRP3") .. "|r."
                                                   or "")
                                           end,
                                icon  = function(f)
                                           return f.rp_curr    and f.rp_curr ~= ""    and f.rp_oocinfo and f.rp_oocinfo ~= "" 
                                                                                      and RP_FRIENDS.utils.color.ico(RP_FRIENDS.const.icons.CURR, "dd00ff", "HOURGLASS")
                                               or f.rp_curr    and f.rp_curr ~= ""    and RP_FRIENDS.utils.color.ico(RP_FRIENDS.const.icons.CURR, "1ae61a", "HOURGLASS")
                                               or f.rp_oocinfo and f.rp_oocinfo ~= "" and RP_FRIENDS.utils.color.ico(RP_FRIENDS.const.icons.CURR, "dd0000", "HOURGLASS")
                                               or ""
                                           end, },

    { index = "NOTE", alt    = function(f)
                                      local altTable = {}

                                      if   f.rp_noteText   and f.rp_noteText ~= "" 
                                      then table.insert(altTable, "|cff1ea61a" .. (state.mrp and "|cffffffffMyRolePlay Note:|r |cff11dd11" 
                                                                                   or state.trp3 and "|cffffffTotal RP 3 Note|r: |cff11dd11" or "") .. f.rp_noteText   .. "|r"); 
                                      end;
                                      
                                      if f.acct_charNoteText and f.acct_charNoteText ~= "" 
                                      then table.insert(altTable, "|cfffff2bf"              .. f.acct_charNoteText .. "|r"); 
                                      end;

                                      if f.bnet_noteText and f.bnet_noteText ~= "" 
                                      then table.insert(altTable, "|cffffffffBattleNet Note:|r " .. BATTLENET_FONT_COLOR_CODE .. f.bnet_noteText .. "|r"); 
                                      end;

                                      table.insert(altTable,
                                                   '|cff999999Click to edit player note.|r'
                                                   .. ((state.mrp  and f.rp_name) and '\n|cff999999Control-click to edit |cff11dd11MyRolePlay|r |cff999999note.|r' or '')
                                                   .. ((state.trp3 and f.rp_name and false) and '\n|cff999999Control-click to edit |cff11dd11Total RP 3|r |cff999999note.|r' or '')
                                                  );

                                      return table.concat(altTable, "\n\n"):gsub(" %[rp:%x+%]","") or "" end,
                           sort = function(f) return f.rp_noteText   and f.rp_noteText   ~= "" and "A"
                                                  or f.acct_charNoteText and f.acct_noteText ~= "" and "B"
                                                  or f.bnet_noteText and f.bnet_noteText ~= "" and "C"
                                                  or ZZZ
                                              end,
                           click  = function(f, _, mod)
                                      if     state.mrp and f.unitID and mod == "CONTROL" and f.rp_name
                                      then   mrp.BFShown = f.unitID;
                                             if not(MyRolePlayNotesFrame) then mrp:CreateNotesFrame() end
                                             mrp:UpdateNotesFrame(); MyRolePlayNotesFrame:Show()
                                             RP_FRIENDS.friendslist:Hide();
                                      elseif state.trp3 and f.unitID and mod == "CONTROL" and f.rp_name and false
                                      then   RP_FRIENDS.displayFrame:ShowProfile(f)
                                             RP_FRIENDS.friendslist:Hide();
                                             TRP3_RegisterCharact:Hide();
                                             TRP3_RegisterAbout:Hide();
                                             TRP3_RegisterMisc:Hide();
                                             TRP3_API.register.ui.showNotesTab()
                                      elseif mod == nil and f.bnet_battleTag -- it's a battlenet friend
                                      then   _G.FriendsFrame.NotesID, _ = f.bnet_bnetIDAccount; 
                                             StaticPopup_Show('SET_BNFRIENDNOTE',  BATTLENET_FONT_COLOR_CODE .. f.bnet_battleTag .. "|r")
                                      elseif mod == "CONTROL"
                                      then   -- do nothing
                                      else -- it's a server level friend
                                             _G.FriendsFrame.NotesID = f.acct_characterName;
                                             StaticPopup_Show('SET_FRIENDNOTE', f.acct_characterName .. "-" .. GetRealmName())
                                      end
                                    end, -- /click
                                  icon = function(f)
                                            return 
                                                f.rp_noteText   and f.rp_noteText ~=   "" and 
                                                   RP_FRIENDS.utils.color.ico(RP_FRIENDS.const.icons.NOTE, "1ae61a", "STATUS")
                                                or f.acct_charNoteText and f.acct_charNoteText ~= "" and 
                                                   RP_FRIENDS.utils.color.ico(RP_FRIENDS.const.icons.NOTE, "fff2bf", "STATUS")
                                                or f.bnet_noteText and f.bnet_noteText ~= "" and 
                                                   RP_FRIENDS.utils.color.ico(RP_FRIENDS.const.icons.NOTE, "82c5ff", "STATUS")
                                                or RP_FRIENDS.utils.color.ico(RP_FRIENDS.const.icons.NOTE, "666666", "STATUS")
                                          end, },

  },  -- /icons ##
} -- /grid

  return "grid";
end);  -- startup function
