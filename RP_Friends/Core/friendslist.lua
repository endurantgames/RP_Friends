-- rp:Friends
-- by Oraibi, Moon Guard (US) server
-- ------------------------------------------------------------------------------
-- This work is licensed under the Creative Commons Attribution 4.0 International
-- (CC BY 4.0) license. 

local RP_FRIENDS = RP_FRIENDS;

table.insert(RP_FRIENDS.startup, function(state)

  -- libraries
  local Const = RP_FRIENDS.const;
  local Utils = RP_FRIENDS.utils;
  local Config = RP_FRIENDS.utils.config;
  local loc = RP_FRIENDS.utils.locale.loc;

  local LibRealmInfo   = LibStub("LibRealmInfo");
  local PC_Text        = LibStub("PhanxConfig-EditBox");
  local LCG            = LibStub("LibCustomGlow-1.0");
  
  local friendslist = CreateFrame('Frame', "RP_FRIENDS_MonitorFrame", UIParent);
  RP_FRIENDS.friendslist = friendslist;
        friendslist:UnregisterAllEvents();
  tinsert(UISpecialFrames, friendslist:GetName()); -- closes when we hit escape
  
  friendslist:SetWidth(RP_FriendsDB.friendlistWidth    or 625);  -- temporary value
  friendslist:SetHeight(RP_FriendsDB.friendslistHeight or 300); 
  friendslist:SetBackdrop(RP_FRIENDS.const.BACKDROP.BLIZZTOOLTIPMED);
  friendslist:SetPoint("TOP", UIParent, "TOP", 0, -100);

  friendslist:SetMovable(true);
  friendslist:EnableMouse(true);
  friendslist:RegisterForDrag("LeftButton");
  friendslist:SetScript("OnDragStart", function(self) self:StartMoving() SetCursor("UI_MOVE_CURSOR") end);
  friendslist:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() SetCursor(nil) end);
  friendslist:SetClampedToScreen(true);

  friendslist.titleFrame = CreateFrame('frame', nil, friendslist);
  friendslist.titleFrame:SetPoint("TOPLEFT", friendslist, "TOPLEFT", 12, -8);
  friendslist.title = friendslist.titleFrame:CreateFontString(nil, 'OVERLAY', 'GameFontNormalLarge');
  friendslist.title:SetText(loc("APP_NAME"));
  friendslist.title:SetJustifyH("LEFT");
  friendslist.title:SetJustifyV("TOP");
  friendslist.title:SetAllPoints(friendslist.titleFrame);
  friendslist.titleFrame:SetSize(friendslist.title:GetStringWidth(), friendslist.title:GetStringHeight());
  friendslist.titleFrame:SetScript("OnEnter",
    function(self) 
      if   IsModifierKeyDown()
      then GameTooltip:SetOwner(friendslist, "ANCHOR_LEFT");
           GameTooltip:AddLine(loc("APP_NAME") .. " Debugging Details")

           -- state
           GameTooltip:AddLine(' ');
           GameTooltip:AddLine('|cffffffffState|r');
           for k, v in pairs(state)
           do if     type(v) == 'boolean' then GameTooltip:AddDoubleLine(k, v and "|cff11dd11true|r" or "|cffdd1111false|r")
              elseif type(v) == 'table'   then GameTooltip:AddDoubleLine(k, '|cffdd11ddTable|r')
              elseif type(v) == 'function' then GameTooltip:AddDoubleLine(k, '|cff11ddddFunction|r')
              else GameTooltip:AddDoubleLine(k, v)
              end;
           end;

           -- sort
           GameTooltip:AddLine(' ');
           GameTooltip:AddLine('|cffffffffSort Parameters|r')
           GameTooltip:AddDoubleLine("key",    type(RP_FriendsDB.sort.key) == 'string' and RP_FriendsDB.sort.key
                                            or type(RP_FriendsDB.sort.key) == 'function' and '|cff11ddddFunction|r'
                                            or "nil")
           GameTooltip:AddDoubleLine("dir",    RP_FriendsDB.sort.dir == true  and "|cff11dd11Down|r" 
                                            or RP_FriendsDB.sort.dir == false and "|cffdd11ddUp|r"
                                            or "|cffdd1111Unknown|r");
           GameTooltip:AddDoubleLine("index", RP_FriendsDB.sort.index or "|cffdd1111none|r")
           GameTooltip:AddDoubleLine("kind", RP_FriendsDB.sort.kind or "|cffdd1111none|r");

           -- category filters

           GameTooltip:AddLine(' ')
           GameTooltip:AddLine("|cffffffffCategory Filter|r");
           if Config.get("CAT_FILTER") == ""
           then GameTooltip:AddLine("No filter selected")
           else for i in Config.get("CAT_FILTER"):gmatch(".")
                do  GameTooltip:AddDoubleLine(i, Config.get("CAT" .. i));
                end;
           end;

           -- columns
           GameTooltip:AddLine(' ');
           GameTooltip:AddLine('|cffffffffColumn Config|r');
           for col, colData in pairs(RP_FRIENDS.grid.COLUMNS) 
           do  GameTooltip:AddDoubleLine(loc("CONFIG_COLUMN_" .. colData.index), Config.get("COLUMN_" .. colData.index) and "|cff11dd11On|r" or "|cffdd1111Off"); end;
           GameTooltip:AddLine(' ');

           -- icons
           GameTooltip:AddLine('|cffffffffIcon Config|r');
           for ico, icoData in pairs(RP_FRIENDS.grid.ICONS)
           do  GameTooltip:AddDoubleLine(loc("CONFIG_ICON_" .. icoData.index), loc("ICONPOS_" .. Config.get("ICON_" .. icoData.index))); end;
           GameTooltip:AddLine(' ');

           -- other
           GameTooltip:AddLine('|cffffffffOther Saved Variables|r');
           for k, v in pairs(RP_FriendsDB)
           do if   type(k) == 'string' 
              then GameTooltip:AddDoubleLine(k,    type(v) == 'string'   and '|cffffffff' .. v .. "|r"
                                                or type(v) == 'table'    and '|cffdd11ddTable|r'
                                                or type(v) == 'function' and '|cff11ddddFunction|r'
                                                or v)
              end;
           end;

           -- final debugging note
           GameTooltip:AddLine(' ');
           GameTooltip:AddLine("If you weren't expecting to see this, it's probably because you are holding down the " ..
                               (   IsShiftKeyDown() and "Shift" 
                                or IsControlKeyDown() and "Control"
                                or IsAltKeyDown() and "Alt"
                                or "Modifier") .. " key.", 0.7, 0.7, 0.7, true)
      else GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT"); 
           GameTooltip:AddLine(loc("APP_NAME") .. " " .. Utils.text.v()); 
           GameTooltip:AddLine(' ');
           GameTooltip:AddLine('Created by |cffbb00bbOraibi|r of the Moon Guard-US server.', nil, nil, nil, true);
           GameTooltip:AddLine(' ');
           GameTooltip:AddLine('Configure with the |cffdd9922/rpfriends|r command or using the golden gear to the right.', nil, nil, nil, true);
      end;
      GameTooltip:Show() end);
  friendslist.titleFrame:SetScript("OnLeave", function(self) GameTooltip:Hide() end);
  friendslist.titleFrame.statusButton = CreateFrame('Button', nil, friendslist.titleFrame);
  friendslist.titleFrame.statusButton:SetSize(12, 12);
  friendslist.titleFrame.statusButton:SetPoint("LEFT", friendslist.titleFrame, "RIGHT", 5, 0);
  friendslist.titleFrame.statusButton.icon = friendslist.titleFrame.statusButton:CreateTexture(nil, 'OVERLAY');
  friendslist.titleFrame.statusButton.icon:SetTexture("Interface\\" .. RP_FRIENDS.const.icons.STATUS);
  friendslist.titleFrame.statusButton.icon:SetAllPoints();
  friendslist.titleFrame.statusButton:SetNormalTexture(friendslist.titleFrame.statusButton.icon);
  friendslist.titleFrame.statusButton:SetScript("OnEnter",
    function(self) 
      local myStatus = tonumber(msp.my.FC) == 1 and "Out of Character"
                    or tonumber(msp.my.FC) == 2 and "In Character"
                    or tonumber(msp.my.FC) == 3 and "Looking for Contact"
                    or tonumber(msp.my.FC) == 4 and "Storyteller"
                    or msp.my.FC;
      if   myStatus
      then GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
           GameTooltip:ClearLines();
           GameTooltip:AddLine(myStatus, nil, nil, nil, true);
           GameTooltip:AddLine("Click to toggle between values.", 0.7, 0.7, 0.7, true);
           -- if state.mrp then GameTooltip:AddLine("Control-click to set a custom value.", 0.7, 0.7, 0.7, true); end;
           GameTooltip:Show();
      end;
    end);
  friendslist.titleFrame.statusButton:SetScript("OnLeave", function(self) GameTooltip:Hide() end);
  friendslist.titleFrame.statusButton:SetScript("OnClick", 
    function(self, btn) 
      if state.trp3
      then  TRP3_API.dashboard.switchStatus();
            if TRP3_API.dashboard.isPlayerIC() 
            then RP_FRIENDS.utils.text.notify("You are now |cff11dd11In Character|r.") 
            else RP_FRIENDS.utils.text.notify("You are now |cffdd1111Out of Character|r.");
            end;
      elseif state.mrp
      then if mrp.my.FC == "1" then mrp.Commands.ic() else mrp.Commands.ooc() end;
      end;
    end);
  -- ##

  friendslist.titleFrame.statusButton:SetShown(mrp or trp3);

  function friendslist:UpdateMyOwnStatus()
    if not state.trp3 and not state.mrp then self.titleFrame.statusButton:Hide() return end;

    if   tonumber(msp.my.FC) == 1 
    then self.titleFrame.statusButton:Show();
         self.titleFrame.statusButton.icon:SetVertexColor(0.9, 0.1, 0.1, 1);
         self.titleFrame.statusButton:SetNormalTexture(self.titleFrame.statusButton.icon)
    else self.titleFrame.statusButton:Show();
         self.titleFrame.statusButton.icon:SetVertexColor(0.1, 0.9, 0.1, 1);
         self.titleFrame.statusButton:SetNormalTexture(self.titleFrame.statusButton.icon)
    end;
  end;

  friendslist:SetResizable(true);
  if Config.get("SHOW_OTHER_BLIZZ_GAMES")
  then friendslist:SetMinResize(535, 165)
       friendslist:SetWidth(math.max(535, friendslist:GetWidth()))
  else friendslist:SetMinResize(340, 165)
  end;
  
  friendslist:SetMaxResize(UIParent:GetWidth() * 2 / 3, UIParent:GetHeight() * 2/3);
  friendslist.resizer = CreateFrame('Frame', nil, friendslist);
  friendslist.resizer:SetSize(16, 16);
  friendslist.resizer:SetPoint("BOTTOMRIGHT", friendslist, "BOTTOMRIGHT", -4, 4);

  friendslist.resizer.texture = friendslist.resizer:CreateTexture(nil, 'ARTWORK');
  friendslist.resizer.texture:SetTexture("Interface\\CHATFRAME\\UI-ChatIM-SizeGrabber-Up");
  friendslist.resizer.texture:SetAllPoints();
  friendslist.resizer:SetScript("OnMouseDown",
    function(self)
      self:GetParent():StartSizing("BOTTOMRIGHT");
      RP_FRIENDS.displayFrame:Hide();
      self:GetParent().statusBar:Hide();
      self:GetParent().buttonbar:Hide();
      self:GetParent().searchBox:Hide();
      self:GetParent().titleFrame:Hide();
      self:GetParent().resizingMessage:Show();
      SetCursor("UI_RESIZE_CURSOR")
    end);
  friendslist.resizer:SetScript("OnMouseUp",
    function(self)
      self:GetParent():StopMovingOrSizing();
      RP_FriendsDB.friendslistHeight = self:GetParent():GetHeight();
      RP_FriendsDB.friendslistWidth = self:GetParent():GetWidth();
      RP_FRIENDS.displayFrame:Update("showsizecolsdataoffset");
      RP_FRIENDS.displayFrame:Show();
      friendslist:ShrinkStatusBar()
      self:GetParent().statusBar:Show();
      self:GetParent().buttonbar:Show();
      self:GetParent().searchBox:Show();
      self:GetParent().titleFrame:Show();
      self:GetParent().resizingMessage:Hide();
      SetCursor(nil)

    end);

  friendslist.resizingMessage = friendslist:CreateFontString(nil, 'OVERLAY', 'GameFontNormalLarge');
  friendslist.resizingMessage:SetSize(300, 100);
  friendslist.resizingMessage:SetText('Drag the corner to resize the ' .. loc("APP_NAME") .. ' friendslist frame.');
  friendslist.resizingMessage:SetTextColor(0.1, 0.9, 0.1);
  friendslist.resizingMessage:SetPoint("CENTER", friendslist, "CENTER", 0, 0);
  friendslist.resizingMessage:Hide();

  -- friendslist.resizer:Hide();

    function friendslist:ShrinkStatusBar()
      if self:GetWidth() < 500
      then self.statusBar.bn:SetWidth(40);
           self.statusBar.bn.count:Hide();
           self.statusBar.server:SetWidth(40);
           self.statusBar.server.count:Hide();
           self.searchBox:SetPoint("LEFT", self.blizzardFLButton, "RIGHT", 10, 0);
           self.blizzardFLButton:SetPoint("LEFT", self.AddFriendButton, "RIGHT", 5, 0);
      else self.statusBar.bn:SetWidth(100);
           self.statusBar.bn.count:Show();
           self.statusBar.server:SetWidth(90);
           self.statusBar.server.count:Show();
           self.searchBox:SetPoint("LEFT", self.blizzardFLButton, "RIGHT", 20, 0);
           self.blizzardFLButton:SetPoint("LEFT", self.AddFriendButton, "RIGHT", 15, 0);
      end;
    end;
      

        friendslist.statusBar = CreateFrame("Frame", nil, friendslist);
        friendslist.statusBar:SetPoint("BOTTOMLEFT", friendslist, "BOTTOMLEFT", 8, 14);
        friendslist.statusBar:SetHeight(12);
        friendslist.statusBar:SetWidth(300);

        friendslist.statusBar.bn = CreateFrame("Frame", nil, friendslist.statusBar);
        friendslist.statusBar.bn:SetPoint("BOTTOMLEFT", friendslist.statusBar, "BOTTOMLEFT", 0, 0);
        friendslist.statusBar.bn:SetHeight(12)
        friendslist.statusBar.bn:SetWidth(100);

        friendslist.statusBar.bn:SetScript("OnEnter",
          function(self)
            GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT"); 
            GameTooltip:AddLine(BATTLENET_FONT_COLOR_CODE .. 'BattleNet Friends|r');
            GameTooltip:AddDoubleLine('Friends Online', friendslist.numBNFriendsOnline);
            GameTooltip:AddDoubleLine('Total Friends', friendslist.numBNFriends);
            GameTooltip:Show() end
            );
        friendslist.statusBar.bn:SetScript("OnLeave", function(self) GameTooltip:Hide() end);

        friendslist.statusBar.bn.deco = friendslist.statusBar.bn:CreateTexture(nil, 'OVERLAY');
        friendslist.statusBar.bn.deco:SetTexture('Interface\\FriendsFrame\\addfriend-logos');
        friendslist.statusBar.bn.deco:SetTexCoord(0, 0.8, 0, 0.4);
        friendslist.statusBar.bn.deco:SetSize(44, 22);
        friendslist.statusBar.bn.deco:SetPoint("BOTTOMLEFT", friendslist.statusBar.bn, "BOTTOMLEFT", 0, -5);

        friendslist.statusBar.bn.count = friendslist.statusBar.bn:CreateFontString(nil, 'OVERLAY', 'GameFontNormal');
        friendslist.statusBar.bn.count:SetWidth(65);
        friendslist.statusBar.bn.count:SetJustifyH("CENTER");
        friendslist.statusBar.bn.count:SetJustifyV("BOTTOM");
        friendslist.statusBar.bn.count:SetPoint("BOTTOMRIGHT", friendslist.statusBar.bn, "BOTTOMRIGHT", 0, 0);
        friendslist.statusBar.bn.count:SetTextColor(0.51, 0.733, 1);

        --
        friendslist.statusBar.server = CreateFrame("Frame", nil, friendslist.statusBar);
        friendslist.statusBar.server:SetPoint("BOTTOMLEFT", friendslist.statusBar.bn, "BOTTOMRIGHT", 0, 0);
        friendslist.statusBar.server:SetHeight(12)
        friendslist.statusBar.server:SetWidth(90);

        friendslist.statusBar.server.deco = friendslist.statusBar.server:CreateTexture(nil, 'OVERLAY');
        friendslist.statusBar.server.deco:SetTexture('Interface\\FriendsFrame\\addfriend-logos');
        friendslist.statusBar.server.deco:SetTexCoord(0, 0.8, 0.4, 0.8);
        friendslist.statusBar.server.deco:SetSize(44, 22);
        friendslist.statusBar.server.deco:SetPoint("BOTTOMLEFT", friendslist.statusBar.server, "BOTTOMLEFT", 0, -5);

        friendslist.statusBar.server:SetScript("OnEnter",
          function(self)
            GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT"); 
            GameTooltip:AddLine(friendslist.myServer .. " Friends");
            GameTooltip:AddDoubleLine('Friends Online', friendslist.numFriendsOnline);
            GameTooltip:AddDoubleLine('Total Friends', friendslist.numFriends);
            GameTooltip:Show() end
            );
        friendslist.statusBar.server:SetScript("OnLeave", function(self) GameTooltip:Hide() end);

        friendslist.statusBar.server.count = friendslist.statusBar.server:CreateFontString(nil, 'OVERLAY', 'GameFontNormal');
        friendslist.statusBar.server.count:SetWidth(65);
        friendslist.statusBar.server.count:SetJustifyH("CENTER");
        friendslist.statusBar.server.count:SetJustifyV("BOTTOM");
        friendslist.statusBar.server.count:SetPoint("BOTTOMRIGHT", friendslist.statusBar.server, "BOTTOMRIGHT", 0, 0);

  local AddFriendButton = CreateFrame('Button', nil, friendslist.statusBar);
  AddFriendButton:SetNormalTexture("Interface\\PaperDollInfoFrame\\Character-Plus");
  AddFriendButton:SetPoint("LEFT", friendslist.statusBar.server, "RIGHT", 0, 0)
  AddFriendButton:SetText("+");
  AddFriendButton:SetSize(18, 18);
  AddFriendButton:SetScript("OnClick", function(self) FriendsFrameAddFriendButton_OnClick(self) end);
  AddFriendButton:SetScript("OnEnter",
    function(self)
      GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
      GameTooltip:ClearLines();
      GameTooltip:AddLine("Add Friend");
      GameTooltip:AddLine("Click to add a new " .. BATTLENET_FONT_COLOR_CODE .. "BattleNet|r or " .. GetRealmName() .. " friend.", nil, nil, nil, true);
      GameTooltip:Show();
    end);
  AddFriendButton:SetScript("OnLeave", function(self) GameTooltip:Hide() end);
  friendslist.AddFriendButton = AddFriendButton;

  local blizzardFLButton = CreateFrame('Button', nil, friendslist.statusBar)
        blizzardFLButton.texture = blizzardFLButton:CreateTexture()
        blizzardFLButton.texture:SetTexture("Interface\\FriendsFrame\\PlusManz-BattleNet");
        blizzardFLButton.texture:SetAllPoints();
        blizzardFLButton:SetNormalTexture(blizzardFLButton.texture);
        blizzardFLButton:SetSize(28, 28);
        blizzardFLButton:SetPoint("LEFT", AddFriendButton, "RIGHT", 5, 0);
        friendslist.blizzardFLButton = blizzardFLButton;
        blizzardFLButton:SetScript("OnEnter",
          function(self) GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT"); 
            GameTooltip:AddLine('Default Friends List');
            GameTooltip:AddLine("Click to open the default Blizzard-style friends list.", 0.7, 0.7, 0.7, true);
            GameTooltip:Show() end);
        blizzardFLButton:SetScript("OnLeave", function(self) GameTooltip:Hide() end);
        blizzardFLButton:SetScript("OnClick",
          function(self)
            if not _G.FriendsFrame:IsShown() then ToggleFriendsFrame() end;
            self:GetParent():GetParent():Hide();
            end);
        -- button bar start
        friendslist.buttonbar = CreateFrame('Frame', nil, friendslist);
        friendslist.buttonbar:SetPoint("TOPRIGHT", friendslist, "TOPRIGHT", -4, -4);
        friendslist.buttonbar:SetSize(300, 32)
        friendslist.buttonbar:SetFrameLevel(friendslist:GetFrameLevel() + 1);

  function friendslist:InviteGlow()
    if BNGetNumFriendInvites() > 0 
        then local r, g, b = BATTLENET_FONT_COLOR:GetRGB();
             LCG.ButtonGlow_Start(self.blizzardFLButton, { r, g, b, 1} )
        else LCG.ButtonGlow_Stop(self.blizzardFLButton)
    end; 
  end;

  local closeButton = CreateFrame('Button', nil, friendslist.buttonbar);
        closeButton:SetSize(26, 28); 
        closeButton:SetPoint("TOPRIGHT", friendslist.buttonbar, "TOPRIGHT", 0, 0);
        closeButton:SetScript("OnClick", function(self) 
            if IsControlKeyDown()
              then friendslist:Hide();
                   RP_FRIENDS.displayFrame:Update("colsdatashowoffset")
              else friendslist:Hide(); 
              end; 
            end);
        closeButton:SetNormalTexture("Interface\\RAIDFRAME\\ReadyCheck-NotReady");
        closeButton:SetScript("OnEnter", 
          function(self) GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT"); 
            GameTooltip:AddLine('Close'); 
            GameTooltip:AddLine('Control-click to reload the friends list window. (This could solve some display problems.)', 0.7, 0.7, 0.7, true);
            GameTooltip:Show() end);
        closeButton:SetScript("OnLeave", function(self) GameTooltip:Hide() end);

  local optionsButton = CreateFrame('Button', nil, friendslist.buttonbar);
        optionsButton:SetSize(28, 28);
        optionsButton:SetPoint("RIGHT", closeButton, "LEFT", 0, 0);
        optionsButton:SetScript("OnClick", 
          function() 
            if   not InterfaceOptionsFrame:IsShown() 
            then InterfaceOptionsFrame_Show();
                 InterfaceOptionsFrame_OpenToCategory(RP_FRIENDS_Main_OptionsPanel)
            else InterfaceOptionsFrame:Hide(); 
            end;
            if   IsControlKeyDown() then RP_FRIENDS.friendslist:Hide() end;
          end);
        optionsButton:SetScript("OnEnter", 
          function(self) 
            GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT"); 
            GameTooltip:ClearLines();
            GameTooltip:AddLine(loc("APP_NAME") .. ' Options'); 
            GameTooltip:AddLine('Click to open options.', 0.7, 0.7, 0.7, true);
            GameTooltip:AddLine('Control-click to open options and close friends list.', 0.7, 0.7, 0.7, true);
            GameTooltip:Show() 
          end);
        optionsButton:SetScript("OnLeave", function(self) GameTooltip:Hide() end);

  local optionsTexture = optionsButton:CreateTexture(nil, "ARTWORK");
        optionsTexture:SetTexture("Interface\\WorldMap\\Gear_64");
        optionsTexture:SetTexCoord(0, 0.5, 0, 0.5);
        optionsTexture:SetAllPoints();

        optionsButton:SetNormalTexture(optionsTexture);

  local broadcastButton = CreateFrame('Button', nil, friendslist.buttonbar);
        broadcastButton:SetSize(24, 24);
        broadcastButton:SetPoint("RIGHT", optionsButton, "LEFT", 0, 0);

        broadcastButton.icon = broadcastButton:CreateTexture();
        broadcastButton.icon:SetTexture("Interface\\HELPFRAME\\ReportLagIcon-Chat");
         broadcastButton.icon:SetTexCoord(0.12, 0.88, 0.12, 0.88);
        broadcastButton.icon:SetAllPoints(broadcastButton);
        broadcastButton:SetNormalTexture(broadcastButton.icon);

        broadcastButton:SetScript("OnClick", function(self) self.window:SetShown(not(self.window:IsVisible())); end);
        broadcastButton:SetScript("OnEnter", function(self) GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT"); GameTooltip:SetText('Set Broadcast Message'); GameTooltip:Show() end);
        broadcastButton:SetScript("OnLeave", function(self) GameTooltip:Hide() end);

  local BroadcastWindow = CreateFrame('Frame', nil, friendslist.buttonbar);
        BroadcastWindow:SetBackdrop(RP_FRIENDS.const.BACKDROP.BLIZZTOOLTIPMED);
        
        BroadcastWindow:SetBackdropColor(0.130, 0.290, 0.5, 0.95); -- this is the BATTLENET color with s = 75%, h = 50%
        BroadcastWindow:SetSize(260, 85);
        BroadcastWindow:SetPoint("TOPLEFT", broadcastButton, "BOTTOM", -12, 0);
        BroadcastWindow:SetFrameStrata("DIALOG");
        broadcastButton.window = BroadcastWindow;
        BroadcastWindow:Hide();

        -- bnet

        BroadcastWindow.editbox = CreateFrame("EditBox", nil, BroadcastWindow);
        BroadcastWindow.editbox:SetMultiLine(true);
        BroadcastWindow.editbox:SetPoint("TOPLEFT", BroadcastWindow, "TOPLEFT", 0, -20);
        BroadcastWindow.editbox:SetPoint("BOTTOMRIGHT", BroadcastWindow, "BOTTOMRIGHT", 0, 0);
        BroadcastWindow.editbox:SetText("");
        BroadcastWindow.editbox:SetMaxLetters(127)
        BroadcastWindow.editbox:SetFontObject('GameFontNormalSmall');
        BroadcastWindow.editbox:SetAutoFocus(false)
        BroadcastWindow.editbox:SetScript("OnEscapePressed", function(self) self:ClearFocus() self:GetParent():Hide(); self:SetText(""); end);
        BroadcastWindow.editbox:SetScript("OnEnterPressed",  
          function(self) 
            self:ClearFocus() 
            self:GetParent():Hide() 
            local text = self:GetText();

            if Config.get("BCAST_BNET") then BNSetCustomMessage(text) end;

            if state.mrp and Config.get("BCAST_CURR")
            then 
                mrp:SaveField('CU', text);
                RP_FRIENDS.utils.text.notify("Currently set to '" .. text .. "'");
            elseif state.trp3 and Config.get("BCAST_CURR")
            then  -- shamelessly stolen from TammyMG's TRP3 Currently code
                local character = TRP3_API.profile.getData("player/character");
                local old = character.CU;
                character.CU = text;
                if old == character.CU then return end

                character.v = TRP3_API.utils.math.incrementNumber(character.v or 1, 2);
                TRP3_API.events.fireEvent(
                        TRP3_API.events.REGISTER_DATA_UPDATED,
                        TRP3_API.globals.player_id,
                        TRP3_API.profile.getPlayerCurrentProfileID(),
                        "character"
                );

                local context = TRP3_API.navigation.page.getCurrentContext()
                if context and context.isPlayer then
                        TRP3_RegisterMiscViewCurrentlyICScrollText:SetText( character.CU or "" )
                end

                RP_FRIENDS.utils.text.notify("Currently set to '" .. text .. "'");
            end;

            if state.mrp and Config.get("BCAST_INFO")
            then 
                mrp:SaveField('CO', text);
                RP_FRIENDS.utils.text.notify("OOC info set to '" .. text .. "'");

            elseif state.trp3 and Config.get("BCAST_INFO")
            then  -- shamelessly stolen from TammyMG's TRP3 Currently code
                local character = TRP3_API.profile.getData("player/character");
                local old = character.CO;
                character.CO = text;
                if old == character.CO then return end

                character.v = TRP3_API.utils.math.incrementNumber(character.v or 1, 2);
                TRP3_API.events.fireEvent(
                        TRP3_API.events.REGISTER_DATA_UPDATED,
                        TRP3_API.globals.player_id,
                        TRP3_API.profile.getPlayerCurrentProfileID(),
                        "character"
                );

                local context = TRP3_API.navigation.page.getCurrentContext()
                if context and context.isPlayer then
                        TRP3_RegisterMiscViewCurrentlyICScrollText:SetText( character.CO or "" )
                end
                RP_FRIENDS.utils.text.notify("OOC info set to '" .. text .. "'");
            end;
          end);
        BroadcastWindow.editbox:SetScript("OnTextChanged",
          function(self)
            local count = self:GetText():len();
            local r, g, b, _ = RP_FRIENDS.utils.color.hsvToRgb( 
              RP_FRIENDS.utils.color.redToGreenHue(count, 0, 127, true), 1, 1, 0.5);
            BroadcastWindow.letterCount:SetTextColor(r / 255, g / 255, b / 255, a);
            BroadcastWindow.letterCount:SetText(count .. "/127")
              
          end);
        BroadcastWindow.editbox:SetScript("OnShow", 
          function(self) 
            local _, _, _, currentBroadcast, _, _, _ = BNGetInfo()
            self:SetText(currentBroadcast)
            self:SetFocus() 
          end);
        BroadcastWindow.editbox:SetCursorPosition(0)
        BroadcastWindow.editbox:SetJustifyH("LEFT")
        BroadcastWindow.editbox:SetJustifyV("TOP")
        BroadcastWindow.editbox:SetTextInsets(7, 5, 0, 5);

        BroadcastWindow.editbox:SetScript("OnEnter",
          function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
            GameTooltip:ClearLines();
            GameTooltip:AddLine(BATTLENET_FONT_COLOR_CODE .. "Enter Your Broadcast" .. "|r");
            GameTooltip:AddLine("Type your BattleNet broadcast message in this box and then hit the 'Enter' key. " .. 
                                "\n\nIf you don't want to set your broadcast right now, hit the 'Escape' key instead.", 
                                0.7, 0.7, 0.7, true);
            GameTooltip:Show();
          end);
        BroadcastWindow.editbox:SetScript("OnLeave", function(self) GameTooltip:Hide() end);
        
        BroadcastWindow.bnet_frame = CreateFrame('Frame', nil, BroadcastWindow);
        BroadcastWindow.bnet_frame:SetPoint("TOPLEFT", BroadcastWindow, "TOPLEFT", 6, -7);
        BroadcastWindow.bnet_frame:SetWidth(65);
        BroadcastWindow.bnet_frame:SetHeight(12);

        BroadcastWindow.bnet_check = BroadcastWindow.bnet_frame:CreateTexture();
        BroadcastWindow.bnet_check:SetPoint("LEFT", BroadcastWindow.bnet_frame, "LEFT", 0, 0);
        BroadcastWindow.bnet_check:SetSize(12,12);

        BroadcastWindow.bnet_frame:SetScript("OnEnter",
          function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
            GameTooltip:ClearLines();
            GameTooltip:AddLine("BattleNet Broadcast");
            GameTooltip:AddLine("After you hit enter, the text you type here will be set as your BattleNet broadcast message.", 0.7, 0.7, 0.7, true);
            GameTooltip:Show();
          end);

        BroadcastWindow.bnet_frame:SetScript("OnLeave", function(self) GameTooltip:Hide() end);

        if   Config.get("BCAST_BNET") 
        then BroadcastWindow.bnet_check:SetTexture("Interface\\RAIDFRAME\\ReadyCheck-Ready");
        else BroadcastWindow.bnet_check:SetColorTexture(0, 0, 0, 0.3); 
        end; -- if

        BroadcastWindow.bnet_label = BroadcastWindow.bnet_frame:CreateFontString(nil, 'OVERLAY', 'GameFontNormalSmall');
        BroadcastWindow.bnet_label:SetPoint("RIGHT", BroadcastWindow.bnet_frame, "RIGHT", 0, 0);
        BroadcastWindow.bnet_label:SetTextColor(1, 1, 1, 1);
        BroadcastWindow.bnet_label:SetText("BattleNet");
        BroadcastWindow.bnet_label:SetWidth(50);
        BroadcastWindow.letterCountFrame = CreateFrame('Frame', nil, BroadcastWindow);
        BroadcastWindow.letterCountFrame:SetPoint("BOTTOMRIGHT", BroadcastWindow, "BOTTOMRIGHT", -5, 5)
        BroadcastWindow.letterCountFrame:SetWidth(50);
        BroadcastWindow.letterCountFrame:SetHeight(12);
        BroadcastWindow.letterCountFrame:SetFrameLevel(BroadcastWindow.editbox:GetFrameLevel() + 1);

        BroadcastWindow.letterCountFrame:SetScript("OnEnter",
          function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
            GameTooltip:ClearLines();
            GameTooltip:AddLine("Letter Count");
            GameTooltip:AddLine("There is a limit of 127 characters for BattleNet broadcasts.", 0.7, 0.7, 0.7, true);
            GameTooltip:Show();
          end);
        BroadcastWindow.letterCountFrame:SetScript("OnLeave", function(self) GameTooltip:Hide() end);
        
        BroadcastWindow.letterCount = BroadcastWindow.letterCountFrame:CreateFontString('nil', 'OVERLAY', 'GameFontWhiteTiny');
        BroadcastWindow.letterCount:SetJustifyH("RIGHT");
        BroadcastWindow.letterCount:SetJustifyV("BOTTOM");
        BroadcastWindow.letterCount:SetAllPoints(BroadcastWindow.letterCountFrame);
        BroadcastWindow.letterCount:SetText("0/127");
        BroadcastWindow.letterCount:SetTextColor(0, 1, 1, 0.75)

        -- curr
        BroadcastWindow.curr_frame = CreateFrame('Frame', nil, BroadcastWindow);
        BroadcastWindow.curr_frame:SetPoint("LEFT", BroadcastWindow.bnet_frame, "RIGHT", 5, 0);
        BroadcastWindow.curr_frame:SetWidth(65);
        BroadcastWindow.curr_frame:SetHeight(12);

        BroadcastWindow.curr_check = BroadcastWindow.curr_frame:CreateTexture();
        BroadcastWindow.curr_check:SetPoint("LEFT", BroadcastWindow.curr_frame, "LEFT", 0, 0);
        BroadcastWindow.curr_check:SetSize(12,12);

        if Config.get("BCAST_CURR") then BroadcastWindow.curr_check:SetTexture("Interface\\RAIDFRAME\\ReadyCheck-Ready");
                                    else BroadcastWindow.curr_check:SetColorTexture(0, 0, 0, 0.3); end;

        BroadcastWindow.curr_frame:SetScript("OnEnter",
          function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
            GameTooltip:ClearLines();
            GameTooltip:AddLine("Set Currently in " .. (state.mrp and "MyRolePlay" or state.trp3 and "Total Roleplay 3" or ""), nil, nil, nil, true);
            GameTooltip:AddLine("If you check this box, your broadcast message will also be set as your 'Currently' message.", 0.7, 0.7, 0.7, true);
            GameTooltip:Show();
          end);
        BroadcastWindow.curr_frame:SetScript("OnLeave", function(self) GameTooltip:Hide() end);

        BroadcastWindow.curr_label = BroadcastWindow.curr_frame:CreateFontString(nil, 'OVERLAY', 'GameFontNormalSmall');
        BroadcastWindow.curr_label:SetPoint("RIGHT", BroadcastWindow.curr_frame, "RIGHT", 0, 0);
        BroadcastWindow.curr_label:SetTextColor(1, 1, 1, 1);
        -- BroadcastWindow.curr_label:SetTextColor(0.5, 0.5, 0.5, 1);
        BroadcastWindow.curr_label:SetText("Currently");
        BroadcastWindow.curr_label:SetWidth(50);

        BroadcastWindow.curr_frame:SetScript("OnMouseDown",
          function(self)
            Config.set("BCAST_CURR", not Config.get("BCAST_CURR"))
            if Config.get("BCAST_CURR") then BroadcastWindow.curr_check:SetTexture("Interface\\RAIDFRAME\\ReadyCheck-Ready");
                                       else BroadcastWindow.curr_check:SetColorTexture(0, 0, 0, 0.3); end;
            end);
 
        -- info
        BroadcastWindow.info_frame = CreateFrame('Frame', nil, BroadcastWindow);
        BroadcastWindow.info_frame:SetPoint("LEFT", BroadcastWindow.curr_frame, "RIGHT", 5, 0);
        BroadcastWindow.info_frame:SetWidth(65);
        BroadcastWindow.info_frame:SetHeight(12);

        BroadcastWindow.info_check = BroadcastWindow.info_frame:CreateTexture();
        BroadcastWindow.info_check:SetPoint("LEFT", BroadcastWindow.info_frame, "LEFT", 0, 0);
        BroadcastWindow.info_check:SetSize(12,12);

        if Config.get("BCAST_INFO") then BroadcastWindow.info_check:SetTexture("Interface\\RAIDFRAME\\ReadyCheck-Ready");
                                    else BroadcastWindow.info_check:SetColorTexture(0, 0, 0, 0.3); end;

        BroadcastWindow.info_frame:SetScript("OnEnter",
          function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
            GameTooltip:ClearLines();
            GameTooltip:AddLine("Set OOC Info in " .. (state.mrp and "MyRolePlay" or state.trp3 and "Total Roleplay 3" or ""), nil, nil, nil, true);
            GameTooltip:AddLine("If you check this box, your broadcast message will also be set as your 'OOC Info' message.", 0.7, 0.7, 0.7, true);
            GameTooltip:Show();
          end);
        BroadcastWindow.info_frame:SetScript("OnLeave", function(self) GameTooltip:Hide() end);

        BroadcastWindow.curr_label = BroadcastWindow.curr_frame:CreateFontString(nil, 'OVERLAY', 'GameFontNormalSmall');
        BroadcastWindow.info_label = BroadcastWindow.info_frame:CreateFontString(nil, 'OVERLAY', 'GameFontNormalSmall');
        BroadcastWindow.info_label:SetPoint("RIGHT", BroadcastWindow.info_frame, "RIGHT", 0, 0);
        BroadcastWindow.info_label:SetTextColor(1, 1, 1, 1);
        -- BroadcastWindow.info_label:SetTextColor(0.5, 0.5, 0.5, 1);
        BroadcastWindow.info_label:SetText("OOC Info");
        BroadcastWindow.info_label:SetWidth(50);

        BroadcastWindow.info_frame:SetScript("OnMouseDown",
          function(self)
            Config.set("BCAST_INFO", not Config.get("BCAST_INFO"))
            if Config.get("BCAST_INFO") then BroadcastWindow.info_check:SetTexture("Interface\\RAIDFRAME\\ReadyCheck-Ready");
                                       else BroadcastWindow.info_check:SetColorTexture(0, 0, 0, 0.3); end;
            end);
 
        if not (state.mrp or state.trp3) then BroadcastWindow.curr_frame:Hide(); BroadcastWindow.info_frame:Hide() end;

        -- close ##
        BroadcastWindow.closeButton = CreateFrame('Button', nil, BroadcastWindow)
        BroadcastWindow.closeButton:SetPoint("TOPRIGHT", BroadcastWindow, "TOPRIGHT", -6, -7);
        BroadcastWindow.closeButton:SetNormalTexture("Interface\\RAIDFRAME\\ReadyCheck-NotReady");
        BroadcastWindow.closeButton:SetSize(12, 12);
        BroadcastWindow.closeButton:SetScript("OnClick", function(self) self:GetParent():Hide() BroadcastWindow.editbox:SetText(""); end);

  local CategoryFilter = CreateFrame('Button', nil, friendslist.buttonbar);
        CategoryFilter:SetSize(24, 24);
        CategoryFilter:SetPoint("RIGHT", broadcastButton, "LEFT", 0, 0);
        friendslist.CategoryFilter = CategoryFilter;

        -- CategoryFilter.iconOpen = CategoryFilter:CreateTexture();
        -- CategoryFilter.iconOpen:SetTexture('Interface\\LFGFRAME\\BattleNetWorking18')
        -- CategoryFilter.iconOpen:SetTexCoord(0.14, 0.86, 0.14, 0.86);
        -- CategoryFilter.iconOpen:SetAllPoints(CategoryFilter);
        -- CategoryFilter.iconOpen:Hide();

        -- CategoryFilter.iconClosed = CategoryFilter:CreateTexture();
        -- CategoryFilter.iconClosed:SetTexture('Interface\\LFGFRAME\\BattleNetWorking3');
        -- CategoryFilter.iconClosed:SetTexCoord(0.14, 0.86, 0.12, 0.86);
        -- CategoryFilter.iconClosed:SetAllPoints(CategoryFilter);
        -- CategoryFilter.iconClosed:Hide();
        
        CategoryFilter.icon = CategoryFilter:CreateTexture();
        CategoryFilter.icon:SetTexCoord(0.14, 0.86, 0.14, 0.86);
        CategoryFilter.icon:SetAllPoints(CategoryFilter);

        function CategoryFilter:SetEye(num) 
          local EYES = {   4,  3,  2,  1, 
                           0, 18, 17, 15, 
                          10,  9, 20, 11,
                          21, 23, 26, 27, 24, }; -- 0 to 16, so 17 values

          self.icon:SetTexture("Interface\\LFGFRAME\\BattleNetWorking" .. EYES[num+1]);
          self.icon:SetAllPoints(self);
          self:SetNormalTexture(self.icon);
          if num > 0 then LCG.AutoCastGlow_Stop(self); LCG.AutoCastGlow_Start(self, { 0.1, 1, 0.1, 0.75}, num )
          else LCG.AutoCastGlow_Stop(self)
          end;
        end;
        
        CategoryFilter:SetScript("OnClick",
          function(self)
            if IsControlKeyDown()
            then Config.set("CAT_FILTER", "");
                 RP_FRIENDS.friendslist.CategoryFilter:SetEye(0);
                 RP_FRIENDS.displayFrame.CategoryPicker:Hide();
                 RP_FRIENDS.displayFrame:Update("datashowicons");
            elseif RP_FRIENDS.displayFrame.CategoryPicker:IsShown()
            then   RP_FRIENDS.displayFrame.CategoryPicker:Hide()
            else RP_FRIENDS.displayFrame.CategoryPicker:SetTitle("Category Filter");
                 RP_FRIENDS.displayFrame.CategoryPicker:HiliteSelected(Config.get("CAT_FILTER"));

                 RP_FRIENDS.displayFrame.CategoryPicker.OnSelect   = 
                   function(self, hex, _) 
                     Config.set("CAT_FILTER", Config.get("CAT_FILTER")..hex); 
                     RP_FRIENDS.friendslist.CategoryFilter:SetEye(Config.get('CAT_FILTER'):len());
                   end;
                 RP_FRIENDS.displayFrame.CategoryPicker.OnUnselect = 
                   function(self, hex, _) 
                     Config.set("CAT_FILTER", Config.get("CAT_FILTER"):gsub(hex, "")); 
                     RP_FRIENDS.friendslist.CategoryFilter:SetEye(Config.get('CAT_FILTER'):len());
                   end;
                 RP_FRIENDS.displayFrame.CategoryPicker:Show();
            end;
          end);

        CategoryFilter:SetScript("OnEnter",
          function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
            GameTooltip:ClearLines();
            GameTooltip:AddLine("Category Filter")
            if   Config.get("CAT_FILTER"):len() > 0
            then GameTooltip:AddLine(' ');
                 GameTooltip:AddLine('Friends in |cff11dd11any|r of the following categories will be displayed.', nil, nil, nil, true);
                 GameTooltip:AddLine(' ');
                 for i in Config.get("CAT_FILTER"):gmatch("%x")
                 do  GameTooltip:AddLine(RP_FRIENDS.const.icons.SMALL[Config.get("CAT" .. i .. "_ICON")].icon .. " " .. Config.get("CAT" .. i .. "_DESC"), 
                                         nil, nil, nil, true);
                 end;
                 GameTooltip:AddLine(' ');
            end;
            GameTooltip:AddLine("Click an icon to include that friend category.", 0.7, 0.7, 0.7, true);
            GameTooltip:AddLine("Control-click to turn off all category filtering.", 0.7, 0.7, 0.7, true);
            GameTooltip:Show();
          end);
        CategoryFilter:SetScript("OnLeave", function(self) GameTooltip:Hide() end);

  local compassButton = CreateFrame('CheckButton', nil, friendslist.buttonbar);
        compassButton:SetSize(24, 24); -- this texture is a little large so reduce it compared to the others

        compassButton.setting = "ALSO_SHOW_OFF_SERVER";

        compassButton.checked = compassButton:CreateTexture(nil, 'OVERLAY');
        compassButton.checked:SetAtlas("islands-queue-prop-compass");
        compassButton.checked:SetAllPoints();

        compassButton:SetCheckedTexture(compassButton.checked);
        compassButton.unchecked = compassButton:CreateTexture(nil, 'BACKGROUND');
        compassButton.unchecked:SetAtlas("islands-queue-prop-compass")
        compassButton.unchecked:SetDesaturated(true);
        compassButton.unchecked:SetVertexColor(1, 1, 1, 0.75);
        compassButton.unchecked:SetAllPoints();
        compassButton:SetNormalTexture(compassButton.unchecked);
        
        compassButton:SetPoint("RIGHT", CategoryFilter, "LEFT", 0, 0);
        compassButton:SetScript("OnEnter", 
           function(self) 
             GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT"); 
             if   Config.get(self.setting) 
             then GameTooltip:AddLine(loc(self.setting .. "_ON"),  nil, nil, nil, true); 
                  GameTooltip:AddLine(loc(self.setting .. "_ON_TT"),  0.7, 0.7, 0.7, true); 
             else GameTooltip:AddLine(loc(self.setting .. "_OFF"), nil, nil, nil, true); 
                  GameTooltip:AddLine(loc(self.setting .. "_OFF_TT"), 0.7, 0.7, 0.7, true); 
             end;
             GameTooltip:Show() end);
        compassButton:SetScript("OnLeave", function(self) GameTooltip:Hide() end);
        compassButton:SetScript("OnClick", 
           function(self) local value = self:GetChecked(); Config.set(self.setting, value); RP_FRIENDS.displayFrame:Update("datashowoffset")
           end);
        compassButton:SetChecked(Config.get(compassButton.setting));

  local anchor, lastButton, relAnchor, xOffset, yOffset = "RIGHT", compassButton, "LEFT", 0, 0;
  for _, game in ipairs(Const.icons.CLIENTS._ORDER)

  do  local btn = CreateFrame('CheckButton', nil, friendslist.buttonbar)
            btn:SetSize(26, 26);
            btn.setting = "INCLUDE_" .. game;
      local texturePath = Const.icons.CLIENTS[game];
      local checkedButton = btn:CreateTexture(nil, "OVERLAY");
            checkedButton:SetTexture(texturePath);
            checkedButton:SetAllPoints(btn);
            btn:SetCheckedTexture(checkedButton);
      local uncheckedButton = btn:CreateTexture(nil, "BACKGROUND");
            uncheckedButton:SetTexture(texturePath);
            uncheckedButton:SetDesaturated(true);
            uncheckedButton:SetVertexColor(1, 1, 1, 0.75);
            -- uncheckedButton:SetVertexColor(0.7, 0.7, 0.7, 1);
            uncheckedButton:SetAllPoints();
            btn:SetNormalTexture(uncheckedButton);

            btn:SetPoint(anchor, lastButton, relAnchor, xOffset, yOffset);
            btn:SetScript("OnClick", 
              function(self, b) 
                if IsControlKeyDown()
                then for _, g in pairs(Const.icons.CLIENTS._ORDER) 
                     do Config.set("INCLUDE_" .. g, false); 
                        friendslist.buttonbar[g]:SetChecked(false);
                     end;
                     Config.set(self.setting, true);
                     self:SetChecked(true);
                else local value = self:GetChecked(); 
                     Config.set(self.setting, value); 
                end
                RP_FRIENDS.displayFrame:Update("datacolshowoffset");
              end);
      
            btn:SetScript("OnEnter", 
              function(self) 
                GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT"); 
                if Config.get(self.setting) 
                then GameTooltip:AddLine(loc(self.setting .. "_ON_TT"),  nil, nil, nil, true); 
                else GameTooltip:AddLine(loc(self.setting .. "_OFF_TT"), nil, nil, nil, true); 
              end;

              GameTooltip:AddLine(loc(self.setting .. "_CTRL_TT"), 0.7, 0.7, 0.7, true)
              GameTooltip:Show() end);
            btn:SetScript("OnLeave", function(self) GameTooltip:Hide() end);
            anchor, lastButton, relAnchor, xOffset, yOffset = "RIGHT", btn, "LEFT", 0, 0;
            btn:SetChecked(Config.get(btn.setting));
            friendslist.buttonbar[game] = btn;
  end;

  function friendslist:ShowButtonBar()
    if not RP_FRIENDS.cache.hiddenbytoolbar then RP_FRIENDS.cache.hiddenbytoolbar = {} end;
    for _, game in ipairs(Const.icons.CLIENTS._ORDER)
    do  if     game == "WOW" or game == "DISCONNECT" or game == "APP" or game == "BSAP"
        then   self.buttonbar[game]:Show();
        elseif Config.get("SHOW_OTHER_BLIZZ_GAMES")
        then   self.buttonbar[game]:Show();
               Config.set("INCLUDE_" .. game, RP_FRIENDS.cache.hiddenbytoolbar[game])
               RP_FRIENDS.cache.hiddenbytoolbar[game] = nil;
        else   self.buttonbar[game]:Hide();
               RP_FRIENDS.cache.hiddenbytoolbar[game] = Config.get("INCLUDE_" .. game)
               Config.set("INCLUDE_" .. game, false)
        end; -- if
    end; -- for
  end; -- function


  friendslist:SetScript("OnShow",
    function(self) 
      ShowFriends() 
      local r, g, b = RP_FRIENDS.utils.color.hexaToNumber(Config.get("COLOR_BACKDROP"));
      self:SetBackdropColor(r / 255, g / 255, b / 255, Config.get("ALPHA"));
      self:UpdateRPNotes();
      RP_FRIENDS.displayFrame:Update("datashown");
      self:InviteGlow();
      self.CategoryFilter:SetEye(Config.get('CAT_FILTER'):len());
    end);

  friendslist.searchBox = CreateFrame('Frame', nil, friendslist)
  friendslist.searchBox:SetPoint("BOTTOMRIGHT", friendslist, "BOTTOMRIGHT", -24, 5);
  friendslist.searchBox:SetPoint("LEFT", blizzardFLButton, "RIGHT", 10, 0);
  friendslist.searchBox.editbox = PC_Text:New(friendslist.searchBox, "", loc("SEARCH_TT"));
  friendslist.searchBox.editbox:SetBackdrop(RP_FRIENDS.const.BACKDROP.BLIZZTOOLTIPSEARCH);
  friendslist.searchBox.editbox:SetBackdropColor(0, 0, 0, 0);
  friendslist.searchBox.editbox.Middle:Hide();
  friendslist.searchBox.editbox.Left:Hide();
  friendslist.searchBox.editbox.Right:Hide();
  -- friendslist.searchBox.editbox:SetPoint("CENTER", friendslist.searchBox, "CENTER", 0, 0);
  friendslist.searchBox.editbox:SetPoint("LEFT", friendslist.searchBox, "LEFT", 0, 0);
  friendslist.searchBox.editbox:SetPoint("RIGHT", friendslist.searchBox, "RIGHT", 0, 0);
  -- friendslist.searchBox.editbox:SetWidth(200);
  friendslist.searchBox.editbox:SetScript("OnEditFocusGained", function(self) friendslist.searchBox.icon:Hide() return true end);
  friendslist.searchBox.editbox:SetScript("OnEditFocusLost",   
    function(self) if self:GetValue() == "" then friendslist.searchBox.icon:Show() end end);
  friendslist.searchBox.editbox.OnTextChanged = 
    function(self) 
      if self:GetValue():len() <3
      then 
        RP_FRIENDS.displayFrame.search = nil;
        RP_FRIENDS.displayFrame:Update("datashowoffset", "Searchbox OnTextChanged to ''")
      else
        RP_FRIENDS.displayFrame.search = self:GetValue();
        RP_FRIENDS.displayFrame:Update("datashowoffset", "Searchbox OnTextChanged to '" .. self:GetValue() .. "'");
      end;
    end;

  friendslist.searchBox.icon = friendslist.searchBox:CreateTexture();
  friendslist.searchBox.icon:SetTexture("Interface\\COMMON\\UI-Searchbox-Icon");
  friendslist.searchBox.icon:SetVertexColor(1, 1, 1, 0.75);
  friendslist.searchBox.icon:SetPoint("LEFT", friendslist.searchBox.editbox, "LEFT", 4, -2);

  local BlizzFriendsList = _G.FriendsListFrame;

  local rpFriendsButton = CreateFrame('Button', 'RP_FRIENDS_ButtonOnBlizzFriendsList', BlizzFriendsList, "UIPanelButtonTemplate");
  rpFriendsButton:SetPoint("BOTTOMRIGHT", FriendsFrameSendMessageButton, "BOTTOMLEFT",  0, 0);
  rpFriendsButton:SetPoint("TOPLEFT",  FriendsFrameAddFriendButton,   "TOPRIGHT", 0, 0);
  rpFriendsButton:SetPoint("CENTER", UIParent, "CENTER", 0, 0);
  rpFriendsButton.tooltipText = "Open " .. loc("APP_NAME");
  -- rpFriendsButton:SetText("|cffff00b3rp:|cff00ffbfF|r");
  rpFriendsButton:SetText(RP_FRIENDS.const.icons.APP_INLINE);
  rpFriendsButton:SetScript("OnClick", function(self) ToggleFriendsFrame(); if not friendslist:IsShown() then friendslist:Show(); end; end);
      
  rpFriendsButton:SetFrameLevel(503);
  rpFriendsButton:SetShown(Config.get("BUTTON_ON_FRIENDSLIST"));

  RP_FRIENDS.rpFriendsButton = rpFriendsButton;
  friendslist:SetScale(Config.get("SCALE"))

  friendslist:ShrinkStatusBar();
  friendslist:Hide();

  return "friendslist";
end);
