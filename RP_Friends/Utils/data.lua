-- rp:Friends
-- by Oraibi, Moon Guard (US) server
-- ------------------------------------------------------------------------------
-- This work is licensed under the Creative Commons Attribution 4.0 International
-- (CC BY 4.0) license. 

local RP_FRIENDS = RP_FRIENDS;

table.insert(RP_FRIENDS.startup, function(state)

  RP_FRIENDS.friendDB = { };  -- initialize

  -- libraries
  local Const = RP_FRIENDS.const;
  local Utils = RP_FRIENDS.utils;
  local notify       = RP_FRIENDS.utils.text.notify;

  local LibRealmInfo   = LibStub("LibRealmInfo");
  local friendslist        = RP_FRIENDS.friendslist;

  if not Utils.data then Utils.data = {} end;

  local BTAG_FIELDS  = RP_FRIENDS.grid.FIELDS.BTAG;
  local ACCT_FIELDS  = RP_FRIENDS.grid.FIELDS.ACCT;
  local REALM_FIELDS = RP_FRIENDS.grid.FIELDS.REALM;
  
  friendslist.tracked = { };
  friendslist.tracked_reverse = { };

  friendslist.msp_fields = { 
    "CO",  -- rp_oocinfo
    "CU",  -- rp_curr
    "FC",  -- rp_status
    "IC",  -- rp_icon
    "NA",  -- rp_name
    "NI",  -- rp_nick
    "NT",  -- rp_title
    "PX",  -- rp_honorific
    "RA",  -- rp_race
    "RC",  -- rp_class
    -- "AE",  -- rp_eyes
    -- "AG",  -- rp_age
    -- "FR",  -- rp_xp
    -- "GC",  -- acct_class
    -- "GF",  -- acct_faction
    -- "GR",  -- acct_race
    -- "GS",  -- acct_gender
    -- "GU",  -- acct_characterGUID
    -- "TT",  -- rp_tooltip
    -- "VA",  -- rp_client
  };

  local function generateFriendID(data) if not data then return "Unknown" end;
    local friendID = (data.bnet_battleTag and (data.bnet_battleTag) ..  "-" ..  (data.acct_client or data.bnet_client or "DISCONNECT"))
                  or (data.acct_characterName) .. "-" ..(data.acct_realmName or ""):gsub(" ","");
    return friendID;
  end; 
    
  function friendslist:PurgeBNFriends(pattern)
    if not RP_FRIENDS.friendDB then return end;
    for k, v in pairs(RP_FRIENDS.friendDB) do if k:match(pattern) then RP_FRIENDS.friendDB[k] = nil end; end;
  end;

  function friendslist:UpdateBNFriends()
    local numBNFriends, numBNFriendsOnline = BNGetNumFriends();
    self.statusBar.bn.count:SetText(numBNFriendsOnline .. "/" .. numBNFriends);
    self.numBNFriends = numBNFriends;
    self.numBNFriendsOnline = numBNFriendsOnline;

    -- go through each bnet friend and grab their data
    for f = 1, numBNFriends
    do  local bnData = { BNGetFriendInfo(f) };
        local friend = {}; 

        -- store the data in friend[]
        for i, field in ipairs(BTAG_FIELDS) do friend[field] = bnData[i] end;

        local friendAccounts = BNGetNumFriendGameAccounts(f);
      
        self:PurgeBNFriends(friend.bnet_battleTag);

        friend.bnet_friendID = f;
        -- are they on any accounts right now?
        if    friendAccounts > 0
              -- if so then go through each account that friend is on and grab their data
        then  friend.accountList = {};
              for a = 1, friendAccounts
              do  local acctData = { BNGetFriendGameAccountInfo(f, a) };
                  local account = {};
                  for field, value in pairs(friend) do account[field] = value end;
                  -- store the data in account[]
                  for i, field in ipairs(ACCT_FIELDS) do account[field] = acctData[i] end;
                  -- is the account using wow?
                  if   account.acct_client == "WoW" and account.acct_realmName and account.acct_realmName ~= ""
                       -- if so then we're going to lookup their realm info
                  then local realmData = { LibRealmInfo:GetRealmInfo(account.acct_realmName) };
                       -- and store the data in account
                       for i, field in pairs(REALM_FIELDS) do account[field] = realmData[i] end;
                       account.unitID = account.acct_characterName .. "-" .. account.acct_realmName:gsub(" ","");
                  end;
                  -- each account gets a separate entry
                  local friendID = generateFriendID(account);
                  table.insert(friend.accountList, account.acct_client or "Unknown")
                  if not RP_FRIENDS.friendDB[friendID] then RP_FRIENDS.friendDB[friendID] = {} end;
                  for k, v in pairs (account) do RP_FRIENDS.friendDB[friendID][k] = v; end;
              end; -- for a
            -- each bnet friend who isn't on an account gets a separate entry
        else friend.bnet_client = "DISCONNECT"; 
             local friendID = generateFriendID(account);
             if not RP_FRIENDS.friendDB[friendID] then RP_FRIENDS.friendDB[friendID] = {} end;
             for k, v in pairs (friend) do RP_FRIENDS.friendDB[friendID][k] = v; end;

        end; -- if friendAccounts > 0
        
    end; -- for f
  end; -- function
       
  function friendslist:UpdateServerFriends()
    local numFriends = C_FriendList.GetNumFriends()
    local numFriendsOnline = C_FriendList.GetNumOnlineFriends()

    self.statusBar.server.count:SetText(numFriendsOnline .. "/" .. numFriends);

    self.numFriends = numFriends;
    self.numFriendsOnline = numFriendsOnline;
    self.myServer = GetRealmName();

    for f = 1, numFriends
    do  local friendInfo = C_FriendList.GetFriendInfoByIndex(f);
        local friend = {
          acct_characterName  = friendInfo.name or "", 
          acct_client         = (friendInfo.connected and "WoW") or "DISCONNECT", 
          acct_class          = friendInfo.className or "",
          acct_zoneName       = friendInfo.area or "",
          acct_charNoteText   = friendInfo.notes or "",
          acct_characterGUID  = friendInfo.guid or "",
          acct_level          = friendInfo.level or 0,
          bnet_isDND          = friendInfo.dnd or false,
          bnet_isAFK          = friendInfo.afk or false,
          bnet_isReferAFriend = friendInfo.referAFriend or false,
          bnet_isOnline       = friendInfo.connected or false,
        }; 
       friend.acct_friendID = f;
       friend.acct_faction = UnitFactionGroup('player');
       friend.acct_realmName = self.myServer; 
       friend.unitID = friend.acct_characterName .. "-" .. friend.acct_realmName:gsub(" ","");
       local realmData = { LibRealmInfo:GetRealmInfo(self.myServer) };
       for i, field in pairs(REALM_FIELDS) do friend[field] = realmData[i] end;
       local friendID = generateFriendID(friend)
       if not RP_FRIENDS.friendDB[friendID] then RP_FRIENDS.friendDB[friendID] = {} end;
       for k, v in pairs (friend) do RP_FRIENDS.friendDB[friendID][k] = v; end;
    end;
  end;

  function friendslist:UpdatePlayerMSP(friendID)
    if not friendID or not RP_FRIENDS.friendDB[friendID] then return nil end;
    local unitID = RP_FRIENDS.friendDB[friendID].unitID;

    local profile = msp.char[unitID].field;
    local rpData = 
      { rp_age     = profile.AG, rp_birthplace = profile.BH, rp_class     = profile.RC,  rp_client  = profile.VA,
        rp_curr    = profile.CU, rp_desc       = profile.DE, rp_eyes      = profile.AE,  rp_glance  = profile.PE,
        rp_height  = profile.AH, rp_home       = profile.HH, rp_honorific = profile.PX,  rp_icon    = profile.IC,
        rp_motto   = profile.MO, rp_name       = profile.NA, rp_nick      = profile.NI, 
        rp_oocinfo = profile.CO, rp_title      = profile.NT, rp_race      = profile.RA,  rp_rstatus = profile.RS,
        rp_sliders = profile.PS, rp_status     = profile.FC, rp_tooltip   = profile.TT,  rp_weight  = profile.AW,
        rp_xp      = profile.FR, acct_gender   = profile.GS,
        };
    if state.mrp
    then local player, realm = unpack(RP_FRIENDS.utils.text.split(unitID:upper(), "-"));
         rpData.rp_noteText = mrpNotes 
                          and mrpNotes[realm]
                          and mrpNotes[realm][player]
    elseif state.trp3
      then rpData.rp_noteText = TRP3_API.profile.getPlayerCurrentProfile().notes
                            and TRP3_Register.character[unitID]
                            and TRP3_Register.character[unitID].profileID
                            and TRP3_API.profile.getPlayerCurrentProfile().notes[TRP3_Register.character[unitID].profileID]

    end;

    for k, v in pairs(rpData) do RP_FRIENDS.friendDB[friendID][k] = v end;
  end; -- function

  function friendslist:Track(friendID) if not friendID then return nil end; 
    local unitID = RP_FRIENDS.friendDB[friendID].unitID; 
    self.tracked[friendID] = unitID;
    self.tracked_reverse[unitID] = friendID;
    return true; 
  end;

  function friendslist:UnitIDIsTracked(unitID) if not unitID   then return nil end; return self.tracked_reverse[unitID]       end;
  function friendslist:IsTracked(friendID)     if not friendID then return nil end; return self.tracked[friendID];            end;
  function friendslist:Untrack(friendID)       if not friendID then return nil end; self.tracked[friendID] = nil; return nil; end;


  function friendslist:TrackAll()
    self.tracked = { }; -- reset the tracked list
    self.tracked_reverse = { };
    for friendID, f in pairs(RP_FRIENDS.friendDB)
    do  
        if   f.unitID and (f.acct_client == "WoW" or (not f.acct_client and f.bnet_client == "WoW"))
        then self.tracked[friendID]         = f.unitID; 
             self.tracked_reverse[f.unitID] = friendID;
        end;
                    
    end;
  end;

  function friendslist:RequestTrackedMSP()        
    for _, unitID in pairs(self.tracked) 
    do  msp:Request(unitID, self.msp_fields) end; end;

  function friendslist:RequestMSPByUnitID(unitID) 
    msp:Request(unitID, self.msp_fields) end;

  function friendslist:RequestMSP(friendID)       
    msp:Request(RP_FRIENDS.friendDB[friendID].unitID, self.msp_fields); end;

  function friendslist:UpdateRPNotes()
    for friendID, unitID in pairs(self.tracked)
    do local friendData = RP_FRIENDS.friendDB[friendID];

       if state.mrp
       then   local player, realm = unpack(RP_FRIENDS.utils.text.split(unitID:upper(), "-"));
              RP_FRIENDS.friendDB[friendID].rp_noteText = mrpNotes and mrpNotes[realm] and mrpNotes[realm][player]
       elseif state.trp3
       then   RP_FRIENDS.friendDB[friendID].rp_noteText = TRP3_API.profile.getPlayerCurrentProfile().notes
                          and TRP3_Register.character[unitID]
                          and TRP3_Register.character[unitID].profileID
                          and TRP3_API.profile.getPlayerCurrentProfile().notes[TRP3_Register.character[unitID].profileID]
       end; -- if stat

    end; -- for friendID
  end

  function friendslist:SetCategory(f, hex)
    local noteText = f.bnet_battleTag and f.bnet_noteText or f.acct_charNoteText or "";
    local note = noteText:match("^(.+) %[rp:%x+%]$");
    note = note or noteText;

    if   note:len() > 120
    then note = note:sub(1, 120)
         notify("Trimming end of friend note for " .. ( f.bnet_battleTag and BATTLENET_FONT_COLOR_CODE .. f.bnet_battleTag:gsub("#.+","") .. "|r"
                                                                        or f.acct_characterName) .. " to add category.");
    end;

    if f.bnet_battleTag
    then BNSetFriendNote(f.bnet_bnetIDAccount, note .. " [rp:" .. hex .. "]");
    else SetFriendNotes(f.acct_characterName,  note .. " [rp:" .. hex .. "]");
    end;
  end;

  function friendslist:AddCategory(f, hex)
    local noteText = f.bnet_battleTag and f.bnet_noteText or f.acct_charNoteText or "";
    local note = noteText:match("^(.+) %[rp:%x+%]$");
    local cats = noteText:match("%[rp:(%x+)%]$")
    cats = cats or "";
    cats = cats:gsub(hex, "");
    note = note or noteText;

    if   note:len() + cats:len() + 6 > 127
    then note = note:sub(1, 127 - 6 - cats:len());
         notify("Trimming end of friend note for " .. ( f.bnet_battleTag and BATTLENET_FONT_COLOR_CODE .. f.bnet_battleTag:gsub("#.+","") .. "|r"
                                                                       or f.acct_characterName) .. " to add category.");
    end;

    if f.bnet_battleTag 
    then BNSetFriendNote(f.bnet_bnetIDAccount, note .. " [rp:" .. cats .. hex .. "]");
    else SetFriendNotes(f.acct_characterName,  note .. " [rp:" .. cats .. hex .. "]");
    end;
    return true;
  end;

  function friendslist:RemoveCategory(f, hex)
    local noteText = f.bnet_battleTag and f.bnet_noteText or f.acct_charNoteText or "";
    local note = noteText:match("^(.+) %[rp:%x+%]$");
    local cats = noteText:match(" %[rp:(%x+)%]$")
    cats = cats or "";
    cats = cats:gsub(hex, "");
    note = note or noteText;
    if     f.bnet_battleTag and cats ~= ""
    then   BNSetFriendNote(f.bnet_bnetIDAccount, note .. " [rp:" .. cats .. "]");
    elseif f.bnet_battleTag
    then   BNSetFriendNote(f.bnet_bnetIDAccount, note);
    elseif cats ~= ""
    then   SetFriendNotes(f.acct_characterName,  note .. " [rp:" .. cats .. "]");
    else   SetFriendNotes(f.acct_characterName,  note);
    end;
  end;

  function friendslist:GetCategories(f)
    local noteText = f.bnet_battleTag and (f.bnet_noteText or "") and f.bnet_noteText or f.acct_charNoteText or "";
    local cats= noteText:match(" %[rp:(%x+)%]$")
    return cats or ""
  end;

  function friendslist:IsInCategory(f, hex)
    return friendslist:GetCategories(f):match(hex)
  end;

  function friendslist:CategoryCount(hex)
    local bnCount = 0;
    local serverCount = 0;

    local numFriends = C_FriendList.GetNumFriends()
    if numFriends == nil then return end;
    for f = 1, numFriends
    do  local friendInfo = C_FriendList.GetFriendInfoByIndex(f);
        if   friendInfo.notes and friendInfo.notes:match(" %[rp:%x*" .. hex .. "%x*%]")
        then serverCount = serverCount + 1;
        end;
    end;

    local numBNFriends = BNGetNumFriends();
    if numBNFriends == nil then return end;
    for f = 1, numBNFriends
    do  local bnData = { BNGetFriendInfo(f) };
        if bnData[13] and bnData[13]:match(" %[rp:%x*" .. hex .. "%x*%]")
        then bnCount = bnCount + 1;
        end;
    end;

    return bnCount, serverCount, BATTLENET_FONT_COLOR_CODE .. bnCount .. "|r/" .. serverCount
  end;

  function friendslist:ClearCategories(f)
    if f.bnet_noteText then BNSetFriendNote(f.bnet_bnetIDAccount, f.bnet_noteText:gsub(" %[rp:%x+%]", "")); end;
    if f.acct_charNoteText then SetFriendNotes(f.acct_characterName,  f.acct_charNoteText:gsub(" %[rp:%x+%]", "")); end;
  end;

  function friendslist:FindCategory(hex, num)
    local count = 0;
    local friendNames = {};

    local numFriends = C_FriendList.GetNumFriends()
    for f = 1, numFriends
    do  local friendInfo = C_FriendList.GetFriendInfoByIndex(f);
        if   friendInfo.notes and friendInfo.notes:match(" %[rp:%x*" .. hex .. "%x*%]")
        then count = count + 1;
             table.insert(friendNames, friendInfo.name);
             if count >= num then return friendNames end;
        end;
    end;

    local numBNFriends = BNGetNumFriends();
    for f = 1, numBNFriends
    do  local bnData = { BNGetFriendInfo(f) };
        if bnData[13] and bnData[13]:match(" %[rp:%x*" .. hex .. "%x*%]")
        then count = count + 1;
             table.insert(friendNames, BATTLENET_FONT_COLOR_CODE .. bnData[3] .. "|r" );
             if count >= num then return friendNames end;
        end;
    end;

    return friendNames;
  end;

  function friendslist:ClearAllCategories()
    local bnCount = 0;
    local serverCount = 0;
  
    local numFriends = C_FriendList.GetNumFriends()
    for f = 1, numFriends
    do  local friendInfo = C_FriendList.GetFriendInfoByIndex(f);
        if    friendInfo.notes and friendInfo.notes:match(" %[rp:%x*%]")
        then  serverCount = serverCount + 1;
              local oldNote = friendInfo.notes;
              local newNote = oldNote:gsub(" %[rp:%x*%]", "")
              SetFriendNotes(friendInfo.name, newNote);
        end;
    end;

    local numBNFriends = BNGetNumFriends();
    for f = 1, numBNFriends
    do  local bnData = { BNGetFriendInfo(f) };
        if bnData[13] and bnData[13]:match(" %[rp:%x*%]")
        then bnCount = bnCount + 1;
             local oldNote= bnData[13];
             local newNote = oldNote:gsub(" %[rp:%x*%]", "")
             BNSetFriendNote(bnData[1], newNote);
        end;
    end;

    if serverCount > 0 then self:UpdateServerFriends() RP_FRIENDS.displayFrame:Update("showdatacolsoffseticons") end;

    notify("Removing categories from " ..  bnCount .. BATTLENET_FONT_COLOR_CODE .. " BattleNet|r friend" .. (bnCount == 1 and "" or "s") .. " and " ..
           serverCount .. " friend" .. (serverCount == 1 and "" or "s") .. " on |cff11dd11" .. GetRealmName() .. "|r.");

  end;

  return "utils-data"
end);
