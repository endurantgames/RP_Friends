-- rp:Friends
-- by Oraibi, Moon Guard (US) server
-- ------------------------------------------------------------------------------
-- This work is licensed under the Creative Commons Attribution 4.0 International
-- (CC BY 4.0) license. 

local RP_FRIENDS = RP_FRIENDS;

table.insert(RP_FRIENDS.startup, function(state)

  -- libraries
  local Utils = RP_FRIENDS.utils;
  local loc = RP_FRIENDS.utils.locale.loc;

  local displayFrame = RP_FRIENDS.displayFrame;
  local friendslist = RP_FRIENDS.friendslist;
  
  friendslist:RegisterEvent("PLAYER_ENTERING_WORLD");                   -- when player logs on and everything is ready to go


    -- Wowpedia:
    --
    --   Payload: None
    --
    --   Fired when ...
    --
    --   You log in                                                                   -- this is why we end up firing twice on login
    --   Open the friends window (twice)                                              -- doesn't affect us directly
    --   Switch from the ignore list to the friend's list                             -- doesn't affect us directly
    --   Switch from the guild, raid, or who tab back to the friends tab (twice)      -- doesn't affect us directly
    --   Add a friend                                                                 -- we use this
    --   Remove a friend                                                              -- we use this
    --   Friend comes online                                                          -- we use this
    --   Friend goes offline                                                          -- we use this

  -- unused events: these are set on the default blizzard friend list
  --
  -- friendslist:RegisterEvent("BN_BLOCK_LIST_UPDATED");                -- we don't handle BN blocking
  -- friendslist:RegisterEvent("GROUP_JOINED");                         -- these are for the invite-to-group functions which we don't handle
  -- friendslist:RegisterEvent("GROUP_LEFT");                           -- these are for the invite-to-group functions which we don't handle
  -- friendslist:RegisterEvent("GROUP_ROSTER_UPDATE");                  -- these are for the invite-to-group functions which we don't handle
  -- friendslist:RegisterEvent("GROUP_ROSTER_UPDATE");                  -- these are for the invite-to-group functions which we don't handle
  -- friendslist:RegisterEvent("GUILD_ROSTER_UPDATE");                  -- these are for the invite-to-group functions which we don't handle
  -- friendslist:RegisterEvent("PARTY_REFER_A_FRIEND_UPDATED");         -- we don't handle RAF
  -- friendslist:RegisterEvent("IGNORELIST_UPDATE");                    -- we don't handle ignores
  -- friendslist:RegisterEvent("SOCIAL_QUEUE_UPDATE");                  -- we don't handle social queueing
  -- friendslist:RegisterEvent("SPELL_UPDATE_COOLDOWN");                -- we don't handle summoning people
  -- friendslist:RegisterEvent("WHO_LIST_UPDATE");                      -- we don't handle who lists

  function friendslist:UpdateAll(request, getMSP, from)
    if request == "server" or not request then self:UpdateServerFriends(); end
    if request == "bn"     or not request then self:UpdateBNFriends();     end;

    self:TrackAll();
    RP_FRIENDS.displayFrame:Update("colsdatashow")
    if getMSP then self:RequestTrackedMSP(); end; -- send MSP request for friends I'm tracking
  end; -- function

  function friendslist:UpdateOne(payload, field)                        -- e.g, self:UpdateOne(payload, "acct_accountD");
    for _, row in pairs(displayFrame.rows)
    do  if row.f[field] == payload then row:LoadFriend(f); end;
    end;
  end;

  friendslist:SetScript("OnEvent",
    function (self, event, ...)
      if     event == "PLAYER_ENTERING_WORLD" 
      then   local isInitialLogin, isReload = ...
             if isInitialLogin or isReload
             then -- things that should only run once

                     -- register for events 
                     self:RegisterEvent("BN_CONNECTED");                         -- when @player connects to BN
                     self:RegisterEvent("BN_DISCONNECTED");                      -- when @player disconnects from BN
                     self:RegisterEvent("BN_CUSTOM_MESSAGE_CHANGED");            -- when a friend changes their BN message
                                                                                 --   Payload: friendIndex
                     self:RegisterEvent("BN_CUSTOM_MESSAGE_LOADED");             -- when a BN message is loaded
                     self:RegisterEvent("BN_FRIEND_INFO_CHANGED");               -- when a BN friend changes their info
                                                                                 --   Payload: friendIndex
                     self:RegisterEvent("BN_FRIEND_LIST_SIZE_CHANGED");          -- when @player adds or removes a BN friend, or someone logs on or disconnects
                                                                                 --   Payload: accountID
                     self:RegisterEvent("BN_INFO_CHANGED");                      -- when my own battlenet info changes
                     self:RegisterEvent("PLAYER_FLAGS_CHANGED");                 -- "This event fires when a Unit's flags change (e.g. /afk, /dnd)."
                                                                                 -- Payload: "unitTarget (string)"
                     self:RegisterEvent("BATTLETAG_INVITE_SHOW");                -- 
                     self:RegisterEvent("BN_FRIEND_INVITE_ADDED");               -- 
                     self:RegisterEvent("BN_FRIEND_INVITE_LIST_INITIALIZED");    -- 
                     self:RegisterEvent("BN_FRIEND_INVITE_REMOVED");             -- 
                     self:RegisterEvent("FRIENDLIST_UPDATE");                       

                     --UI creation
                     RP_FRIENDS.button:CreateButton();                           -- create the minimap button

                     -- apply config settings
                     self:ShowButtonBar();                                       -- makes the extra buttons (Overwatch, etc) show/hide
                     RP_FRIENDS.friendslist:ShrinkStatusBar();                   -- hides the friend count if friendslist is too small
                     RP_FRIENDS.friendslist:UpdateMyOwnStatus();                 -- set the toggle of the IC/OOC button if state.mrp or state.trp3
                     
                     -- friendDB
                     self:UpdateAll(nil, true, event); 

             else -- things that should run every time PLAYER_ENTERING_WORLD fires
                  self:UpdateAll(nil, false, event);
                  self:ShowButtonBar();
             end;

      elseif event == "BN_CONNECTED" or event == "BN_DISCONNECTED"
      then   self:UpdateAll(nil, false, event);
             self:ShowButtonBar();
      elseif (event == "BATTLETAG_INVITE_SHOW" or event == "BN_FRIEND_INVITE_ADDED" or event == "BN_FRIEND_INVITE_LIST_INITIALIZE"
          or event == "BN_FRIEND_INVITE_REMOVED") and self:IsShown()
        then self:InviteGlow();

      elseif event == "BN_FRIEND_LIST_SIZE_CHANGED" or event == "BN_FRIEND_INFO_CHANGED" or event == "BN_CUSTOM_MESSAGE_CHANGED"
      then   self:UpdateAll("bn", true, event)

      elseif event == "FRIENDLIST_UPDATE"
      then   self:UpdateAll("server", true, event)

      end; --if

    end); -- setscript ##

  table.insert(msp.callback.received, 
    function(u) 
      local friendID = RP_FRIENDS.friendslist:UnitIDIsTracked(u)
      if friendID
      then RP_FRIENDS.friendslist:UpdatePlayerMSP(friendID)
           RP_FRIENDS.displayFrame:Update("datashow") 
      end; 
      if u == UnitName('player') .. "-" .. GetRealmName():gsub(" ", "") then RP_FRIENDS.friendslist:UpdateMyOwnStatus() end;

    end); -- callback

  if state.trp3
  then 
    TRP3_API.module.registerModule( { -- let trp3 know we exist and set up our callback for new profile received
      ["name"]        = loc("APP_NAME"),
      ["description"] = loc("APP_DESC"),
      ["version"]     = loc("APP_VERSION"),
      ["id"]          = loc("APP_ID"),
      ["minVersion"]  = 3,
      ["autoEnable"]  = true,
       }); -- closes the addon registering table and the function params
   end;
  --------------------------

  return "events";
end);
