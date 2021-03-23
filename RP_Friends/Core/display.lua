local RP_FRIENDS = RP_FRIENDS;

table.insert(RP_FRIENDS.startup, function(state)

  local loc         = RP_FRIENDS.utils.locale.loc;
  local Config      = RP_FRIENDS.utils.config;
  local friendslist = RP_FRIENDS.friendslist;
  local Grid        = RP_FRIENDS.grid;

  local displayFrame = CreateFrame('Frame', 'RP_FRIENDS_DisplayFrame', friendslist);
  RP_FRIENDS.displayFrame = displayFrame;
  
  function displayFrame:Initialize()
    RP_FRIENDS.cache.updateLog = {};
    self.rows        = {};
    self.headers     = {};
    self.nextRow     = { anchor = "TOPLEFT", last = self, relAnchor = "TOPLEFT", xOffset = 7, yOffset = -7 };
    self.ROW_HEIGHT  = 16;
    self.COL_PADDING = 0;
    self:SetBackdrop(RP_FRIENDS.const.BACKDROP.BLIZZTOOLTIPTHIN);
    self:SetBackdropColor(0, 0, 0, 0);
    self:SetPoint("TOPLEFT",     friendslist.title, "BOTTOMLEFT",  -4, -32);
    self:SetPoint("BOTTOMRIGHT", friendslist,       "BOTTOMRIGHT", -8,  36);
    self:CreatePopup();

    if not RP_FriendsDB.sort then RP_FriendsDB.sort = { kind  = "col", dir = true, index = 3, }; end;

    if RP_FriendsDB.sort.dir   == nil then RP_FriendsDB.sort.dir   =  true;                                      end;
    if RP_FriendsDB.sort.kind  == nil then RP_FriendsDB.sort.kind  = "col"; RP_FriendsDB.sort.index = 3;         end;
    if RP_FriendsDB.sort.index == nil then RP_FriendsDB.sort.index =     2;                                      end;
    if RP_FriendsDB.sort.key   == nil and  RP_FriendsDB.sort.kind == "col"
                                      then RP_FriendsDB.sort.key   = Grid.COLUMNS[RP_FriendsDB.sort.index].sort; end;
    if RP_FriendsDB.sort.key   == nil and  RP_FriendsDB.sort.kind == "ico"
                                      then RP_FriendsDB.sort.key   = Grid.ICONS[RP_FriendsDB.sort.index].sort;   end;


    self.search   = nil;
    self.myServer = GetRealmName();
    self.offset = 0;
    self.friendCount = 0;
    self:EnableMouseWheel(true);
    self:SetScript("OnMouseWheel",
      function(self, delta)
        if     self.friendCount <= self.listCapacity
        then   self.offset = 0; self:SetScrollBar(false); return;
        elseif delta == -1 then self.offset = math.min(self.offset + ((IsModifierKeyDown() and self.listCapacity) or 1), self.friendCount - self.listCapacity); 
        elseif delta ==  1 then self.offset = math.max(self.offset - ((IsModifierKeyDown() and self.listCapacity) or 1), 0); 
        end;
        self:Update("datashow", "OnMouseWheel")
      end);
    self:SetDimensions();
    self:CreateHeaders();
    self:CreateScrollBar();
    self:LoadHeaders();
    self:LoadData();
  end; -- :Initialize

  function displayFrame:ShowProfile(f)
    if f.bnet_client == "DISCONNECT" or f.acct_client == "DISCONNECT" then return
    elseif state.mrp  and msp.char[f.unitID] then SlashCmdList.MYROLEPLAY("show " .. f.unitID);
    elseif state.trp3 and msp.char[f.unitID] then SlashCmdList.TOTALRP3("open " .. f.unitID)
    end;
  end;

  function displayFrame:CreatePopup()
    if   not self.popup
    then self.popup = CreateFrame('Frame', 'RP_FRIENDS_displayFrame_popup', self)
         self.popup.what = nil;
         self.popup:SetSize(32 * Config.get("ICON_ZOOM"), 32 * Config.get("ICON_ZOOM"));
         self.popup:SetPoint("CENTER", self, "CENTER", 0, 0);
         self.popup:SetMovable(true);
         self.popup:EnableMouse(true);
         self.popup:RegisterForDrag("LeftButton");
         self.popup:SetScript("OnDragStart", function(self) self:StartMoving() SetCursor("UI_MOVE_CURSOR") GameTooltip:Hide() end);
         self.popup:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() SetCursor(nil) end);
         self.popup:SetClampedToScreen(true);
         tinsert(UISpecialFrames, 'RP_FRIENDS_displayFrame_popup');

         self:SetScript("OnHide", function(self) self.popup:Hide() end);
         self.popup.icon = self.popup:CreateTexture(nil, 'ARTWORK')
         self.popup.icon:SetAllPoints();
         self.popup.close = CreateFrame('Button', nil, self.popup, 'UIPanelCloseButton');
         self.popup.close:SetScript("OnClick", function(self) displayFrame.popup:Hide() end);
         self.popup.close:SetPoint("TOPRIGHT", self.popup, "TOPRIGHT", 5, 5)
         self.popup:SetFrameStrata('DIALOG');
         self.popup:SetScript("OnEnter",
           function(self)
             if   self.what 
             then GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                  GameTooltip:ClearLines();
                  for _, w in ipairs(self.what) do GameTooltip:AddLine(w, nil, nil, nil, true) end;
                  GameTooltip:Show();
             end end);
         self.popup:SetScript("OnLeave", function(self) GameTooltip:Hide() end);
    end;
  end;

  function displayFrame:PopupIcon(icon, what)
    self.popup:SetSize(32 * Config.get("ICON_ZOOM"), 32 * Config.get("ICON_ZOOM"));
    local iconFilename, _ = "|cff999999" .. icon:gsub("^.+\\", "") .. "|r";
    if not what then what = {} else table.insert(what, " ") end;
    table.insert(what, iconFilename);
    self.popup.what = what;
    self.popup.icon:SetTexture(icon);
    self.popup:Show();
  end;

  function displayFrame:SetDimensions()
    self.listCapacity = math.floor((friendslist:GetHeight() - 96)/self.ROW_HEIGHT);
    self.maxWidth = friendslist:GetWidth() - 60;
    if #self.rows < self.listCapacity then for r = #self.rows + 1, self.listCapacity do table.insert(self.rows, self:CreateRow()) end; end;
  end;

  -- create the scrollbar
  function displayFrame:CreateScrollBar()
    self.scrollBar = CreateFrame('Slider', "RP_FRIENDS_DisplayFrame_ScrollBar", self);
    self.scrollBar:SetPoint("TOPRIGHT",    self, "TOPRIGHT",   -2, 0);
    self.scrollBar:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT",-2, 0);
    self.scrollBar:SetWidth(6);
    self.scrollBar:SetOrientation('VERTICAL')
    self.scrollBar:SetMinMaxValues(0, 100);
    self.scrollBar.bg = self:CreateTexture(nil, 'BACKGROUND');
    self.scrollBar.bg:SetColorTexture(1, 1, 1, 0.25); 
    self.scrollBar.bg:SetPoint("TOPLEFT", self.scrollBar, "TOPLEFT", 0, -2);
    self.scrollBar.bg:SetPoint("BOTTOMRIGHT", self.scrollBar, "BOTTOMRIGHT", 0, 2);
    self.scrollBar.thumb = self.scrollBar:CreateTexture();
    self.scrollBar.thumb:SetTexture("Interface\\Buttons\\UI-SliderBar-Button-Vertical");
    
    self.scrollBar:SetThumbTexture(self.scrollBar.thumb)
    self.scrollBar.thumb:SetTexCoord(0, 1, 0.25, 0.75)
    self.scrollBar.thumb:SetSize(32, 16)
    self.scrollBar:SetValue(0);

    self.scrollBar:Hide();
    self.scrollBar.bg:Hide();

    self.scrollBar:SetScript("OnValueChanged", 
      function(self, value)
        displayFrame.offset = 
          math.floor( 0.5 + (self:GetParent().friendCount - self:GetParent().listCapacity) * value / 100)
        displayFrame:Update("showndata");
      end);
  end;  -- :CreateScrollBar

  function displayFrame:SetScrollBar(value) 
    self.scrollBar:SetShown(value) 
    self.scrollBar.bg:SetShown(value) 
    self.scrollBar:SetValue( ((self.friendCount <= self.listCapacity) and 0) or (100 * self.offset/(self.friendCount - self.listCapacity)))
  end; -- :SetScrollBar

  -- Create the column headers
  function displayFrame:CreateHeaders()
    local headerFrame = CreateFrame('Frame', nil, self)
          headerFrame:SetPoint("BOTTOMLEFT",  self, "TOPLEFT",   7, 2);
          headerFrame:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", -7, 2);
          headerFrame:SetHeight(self.ROW_HEIGHT);
          headerFrame.icons = {};
          headerFrame.IconFrame = { left  = CreateFrame('Frame', nil, headerFrame),
                                    right = CreateFrame('Frame', nil, headerFrame) };

          headerFrame.IconFrame.left:SetHeight(self.ROW_HEIGHT);
          headerFrame.IconFrame.left:SetPoint( "BOTTOMLEFT",  headerFrame, "BOTTOMLEFT",   0,  0);

          headerFrame.IconFrame.right:SetPoint("BOTTOMRIGHT", headerFrame, "BOTTOMRIGHT", -23, 0);
          headerFrame.IconFrame.right:SetHeight(self.ROW_HEIGHT);

          self.headerFrame = headerFrame;

    -- create icon frames
    --
    for i, icoData in ipairs(Grid.ICONS) 
    do local icoFrame = CreateFrame('Frame', nil, headerFrame);
       icoFrame.icoData = icoData;
       icoFrame:SetSize(self.ROW_HEIGHT, self.ROW_HEIGHT);
       icoFrame.text = icoFrame:CreateFontString(nil, 'OVERLAY', 'GameFontNormalSmall');
       icoFrame.text:SetJustifyV("BOTTOM");
       icoFrame.text:SetJustifyH("CENTER");
       icoFrame.text:SetAllPoints(icoFrame);
       icoFrame.text:SetText("X");
       icoFrame.index = i;
       headerFrame.icons[icoData.index] = icoFrame;
       icoFrame.text:SetText("|A:Mobile-Inscription:0:0|a");
       icoFrame.text:Hide();

       icoFrame:SetScript("OnMouseDown",
         function(self, btn)
           if     IsControlKeyDown()
           then   Config.set("ICON_" .. self.icoData.index, "HIDE")
           elseif RP_FriendsDB.sort.index == self.index
              and RP_FriendsDB.sort.kind  == "ico"
           then   RP_FriendsDB.sort.dir   = not RP_FriendsDB.sort.dir;
           else   RP_FriendsDB.sort.index = self.index; 
                  RP_FriendsDB.sort.key   = self.icoData.sort;
                  RP_FriendsDB.sort.dir   = true;
                  RP_FriendsDB.sort.kind  = "ico";
           end; --## 
           displayFrame:Update("tintcolsshowoffsetdatasizeicons", "OnMouseDown icon header " .. self.index);
         end);

       icoFrame:SetScript("OnEnter",
         function(self)
           GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
           GameTooltip:ClearLines();
           GameTooltip:AddLine(loc("CONFIG_ICON_" .. self.icoData.index));
           GameTooltip:AddLine(loc("CONFIG_ICON_" .. self.icoData.index .. "_TT"), 1, 1, 1, true);
           GameTooltip:AddLine(' ');
           GameTooltip:AddLine('Click to sort on this column.', 0.7, 0.7, 0.7, true);
           GameTooltip:AddLine('Control-click to |cffdd1111hide|r this column.', 0.7, 0.7, 0.7, true);
           GameTooltip:Show()
           self.text:Show();
         end);
       icoFrame:SetScript("OnLeave", function(self) self.text:Hide(); GameTooltip:Hide() end);

       anchor, last, relAnchor, xOffset, yOffset = "LEFT", header, "RIGHT", self.COL_PADDING, 0;

    end; -- i, icoData

    anchor, last, relAnchor, xOffset, yOffset = "LEFT", headerFrame.IconFrame.left, "RIGHT", 2, 0;

    for col, colData in pairs(Grid.COLUMNS)
    do local header = CreateFrame('Frame', nil, headerFrame)
             header:SetHeight(self.ROW_HEIGHT);
             header:SetWidth(0);
             header:SetPoint(anchor, last, relAnchor, xOffset, yOffset);
             header.col = col;
             header.colData = colData;

             header.text = headerFrame:CreateFontString(nil, 'OVERLAY', 'GameFontNormalSmall');
             header.text:SetText(nil);
             header.text:SetJustifyH(colData.align);
             header.text:SetJustifyV("BOTTOM");
             header.text:SetAllPoints(header);

             local color = Config.get("COLOR_" .. colData.group);
             header.text:SetTextColor(RP_FRIENDS.utils.color.hexaToFloat(color));

             header:SetScript("OnMouseDown",
               function(self, btn)
                 if     IsControlKeyDown()
                 then   Config.set("COLUMN_" .. self.colData.index, false)
                 elseif RP_FriendsDB.sort.index == self.col
                    and RP_FriendsDB.sort.kind  == "col"
                 then   RP_FriendsDB.sort.dir   = not RP_FriendsDB.sort.dir;
                 else   RP_FriendsDB.sort.index = self.col; 
                        RP_FriendsDB.sort.key   = self.colData.sort;
                        RP_FriendsDB.sort.dir   = true;
                        RP_FriendsDB.sort.kind  = "col";
                 end;
                 displayFrame:Update("tintcolsshowoffsetdatasizeicons", "OnMouseDown header " .. self.col);
               end);

             header:SetScript("OnEnter",
               function(self)
                 GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
                 GameTooltip:ClearLines();
                 GameTooltip:AddLine(loc("CONFIG_COLUMN_" .. self.colData.index));
                 GameTooltip:AddLine(loc("CONFIG_COLUMN_" .. self.colData.index .. "_TT"), 1, 1, 1, true);
                 GameTooltip:AddLine(' ');
                 GameTooltip:AddLine('Click to sort on this column.', 0.7, 0.7, 0.7, true);
                 GameTooltip:AddLine('Control-click to |cffdd1111hide|r this column.', 0.7, 0.7, 0.7, true);
                 GameTooltip:Show()
              end);
             header:SetScript("OnLeave", function(self) GameTooltip:Hide() end);

             anchor, last, relAnchor, xOffset, yOffset = "LEFT", header, "RIGHT", self.COL_PADDING, 0;
             table.insert(self.headers, header);
    end; -- for col, colData
  end; -- :CreateHeaders

  function displayFrame:UpdateIcons()
    self.icons = { left = {}, right = {}, inline = {}, hide = {}, };

    for ico, icoData in ipairs(Grid.ICONS)
    do  table.insert(self.icons[Config.get("ICON_" .. icoData.index):lower()], icoData.index);
    end;

    self.headerFrame.IconFrame.left:SetWidth(1 + #self.icons.left * 20);

    local anchor, last, relAnchor, xOffset, yOffset = "LEFT", self.headerFrame.IconFrame.left, "LEFT", 2, 0;

    if #self.icons.left > 0
    then for _, index in ipairs(self.icons.left)   
         do  self.headerFrame.icons[index]:Show();
             self.headerFrame.icons[index]:ClearAllPoints();
             self.headerFrame.icons[index]:SetPoint(anchor, last, relAnchor, xOffset, yOffset);
             last, relAnchor, xOffset = self.headerFrame.icons[index], "RIGHT", 4;
    end; end;

    self.headerFrame.IconFrame.right:SetWidth(1 + #self.icons.right * 20);

    anchor, last, relAnchor, xOffset, yOffset = "RIGHT", self.headerFrame.IconFrame.right, "RIGHT", 0, 0;
    if #self.icons.right > 0
    then for _, index in ipairs(self.icons.right)   
         do  self.headerFrame.icons[index]:Show();
             self.headerFrame.icons[index]:SetPoint(anchor, last, relAnchor, xOffset, yOffset);
             last, relAnchor, xOffset = self.headerFrame.icons[index], "LEFT", -4;
         end;
    end;

    if #self.icons.hide > 0 then for _, index in ipairs(self.icons.hide) do self.headerFrame.icons[index]:Hide(); end; end;

    for _, row in pairs(self.rows)
    do row:UpdateIcons()
    end;

    -- ##
  end;
    
  function displayFrame:LoadHeaders()

    self:SetDimensions();
    self:UpdateIcons();


    local maxWidth = self.maxWidth - #self.icons.left * 20 - #self.icons.right * 20;
    local currWidth = 0;
    local full = false;
    for h, header in ipairs(self.headers)
    do if not Config.get("COLUMN_" .. header.colData.index) 
       then   header.text:SetText(nil);
              header:SetWidth(0.001);
       elseif full
       then   header.text:SetText(nil);
              header:SetWidth(0.001);
              local anchor, relTo, relAnchor, xOffset, yOffset = header:GetPoint(1);
              header:SetPoint(anchor, relTo, relAnchor, 0, yOffset);
              header.hidden = true;
       elseif currWidth + header.colData.width > maxWidth
       then   full = true;
              header.text:SetText(nil);
              header:SetWidth(0.001)
              local anchor, relTo, relAnchor, xOffset, yOffset = header:GetPoint(1);
              header:SetPoint(anchor, relTo, relAnchor, 0, yOffset);
              header.hidden = true;
       else   header.text:SetText(loc("COL_" .. header.colData.index)
                    .. (RP_FriendsDB.sort.index == h and RP_FriendsDB.sort.kind == "col" and RP_FriendsDB.sort.dir and RP_FRIENDS.const.icons.DOWNTICK
                    or  RP_FriendsDB.sort.index == h and RP_FriendsDB.sort.kind == "col"                           and RP_FRIENDS.const.icons.UPTICK
                    or ""));
              header:SetWidth(header.colData.width);
              local anchor, relTo, relAnchor, xOffset, yOffset = header:GetPoint(1);
              header:SetPoint(anchor, relTo, relAnchor, self.COL_PADDING, yOffset);
              currWidth = currWidth + header.colData.width;
       end;
    end;
  end;
    
  -- Creates one row ----------------------------------------------------------------------------------------------------------------------------------------------------
  function displayFrame:CreateRow()
    local anchor, last, relAnchor, xOffset, yOffset;
    local rowFrame = CreateFrame('Frame', nil, self);
    rowFrame:SetHeight(self.ROW_HEIGHT);
    rowFrame:SetPoint("RIGHT", self, "RIGHT", -10, 0);
    rowFrame:SetPoint(self.nextRow.anchor, self.nextRow.last, self.nextRow.relAnchor, self.nextRow.xOffset, self.nextRow.yOffset)

    rowFrame.cols = {};
    rowFrame.icons = {};
    rowFrame.IconFrame = {};
    rowFrame.IconFrame.left = CreateFrame('Frame', nil, rowFrame);
    rowFrame.IconFrame.left:SetPoint("TOPLEFT", rowFrame, "TOPLEFT", 0, 0);
    rowFrame.IconFrame.left:SetHeight(self.ROW_HEIGHT);

    rowFrame.IconFrame.right = CreateFrame('Frame', nil, rowFrame);
    rowFrame.IconFrame.right:SetPoint("TOP",        rowFrame, "TOP", 0, 0);
    rowFrame.IconFrame.right:SetPoint("RIGHT",      self, "RIGHT", -30, 0);
    rowFrame.IconFrame.right:SetHeight(self.ROW_HEIGHT);

    -- create icon frames
    --
    for _, icoData in ipairs(Grid.ICONS) 
    do local icoFrame = CreateFrame('Frame', nil, rowFrame);
       icoFrame.icoData = icoData;
       icoFrame:SetSize(self.ROW_HEIGHT, self.ROW_HEIGHT);
       icoFrame.text = icoFrame:CreateFontString(nil, 'OVERLAY', 'GameFontNormalSmall');
       icoFrame.text:SetJustifyV("TOP");
       icoFrame.text:SetJustifyH("CENTER");
       icoFrame.text:SetAllPoints(icoFrame);
       icoFrame.func = icoData.icon;

       rowFrame.icons[icoData.index] = icoFrame;

       function icoFrame:SetValue(f) if not f then self.text:SetText(nil); self.value = nil; else self.value = self.func(f) self.text:SetText(self.value) end; end;

       -- context menu
       icoFrame:SetScript("OnMouseUp",
         function(self, button) 
           local mod = IsControlKeyDown() and 'CONTROL'
                    or IsShiftKeyDown()   and 'SHIFT'
                    or IsAltKeyDown()     and 'ALT'
                    or nil;
           if     button == "RightButton" and self:GetParent().f
           then   if     self:GetParent().f.bnet_battleTag     
                  then   _G.FriendsFrame_ShowBNDropdown(self:GetParent().f.bnet_accountName , true, nil, nil, nil, true, self:GetParent().f.bnet_bnetIDAccount)
                  elseif self:GetParent().f.acct_characterName then _G.FriendsFrame_ShowDropdown(self:GetParent().f.acct_characterName, true, nil, nil, nil, true) 
                  end;
           elseif button == "LeftButton" and self.icoData.click and self:GetParent().f then self.icoData.click(self:GetParent().f, self, mod) end;
         end);
       -- tooltip
       icoFrame:SetScript("OnEnter",
         function(self)
           if not self:GetParent().f then return end;
           GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
           GameTooltip:ClearLines();
           GameTooltip:AddLine(rowFrame:FriendIdentifier(), nil, nil, nil, true);
           if     type(self.icoData.alt) == 'string'
           then   GameTooltip:AddLine(self:GetParent().f[self.icoData.alt], nil, nil, nil, true)
           elseif type(self.icoData.alt) == 'function' 
           then   GameTooltip:AddLine(self.icoData.alt(self:GetParent().f), nil, nil, nil, true)
           elseif self.value or self.icoData.showalt
           then   GameTooltip:AddLine(self.value, nil, nil, nil, true)
           end;
           GameTooltip:Show();
           self:GetParent().background:Show();
         end);
       icoFrame:SetScript("OnLeave", function(self) GameTooltip:Hide() self:GetParent().background:Hide() end)
    end;

    -- rowFrame.IconFrame.left:SetSize( 1 + (20 * #rowFrame.icons.left ), self.ROW_HEIGHT);
    -- anchor, last, relAnchor, xOffset, yOffset = "LEFT", rowFrame.IconFrame.left, "LEFT", 2, 0;
    -- for _, icoFrame in ipairs(rowFrame.icons.left) do icoFrame:SetPoint(anchor, last, relAnchor, xOffset, yOffset); last, relAnchor, xOffset = icoFrame, "RIGHT", 4; end;

    -- rowFrame.IconFrame.right:SetSize(1 + (20 * #rowFrame.icons.right), self.ROW_HEIGHT);
    -- anchor, last, relAnchor, xOffset, yOffset = "RIGHT", rowFrame.IconFrame.right, "RIGHT", 0, 0;
    -- for _, icoFrame in ipairs(rowFrame.icons.right) do icoFrame:SetPoint(anchor, last, relAnchor, xOffset, yOffset); last, relAnchor, xOffset = icoFrame, "LEFT", -4; end;
    
    anchor, last, relAnchor, xOffset, yOffset = "LEFT", rowFrame.IconFrame.left, "RIGHT", 2, 0;

    function rowFrame:FriendIdentifier()
      return self.f.rp_name                   and self.f.rp_name            ~= "" and "|cff" .. Config.get("COLOR_RP")      .. self.f.rp_name            .. "|r"
          or self.f.acct_characterName        and self.f.acct_characterName ~= "" and "|cff" .. Config.get("COLOR_DEFAULT") .. self.f.acct_characterName .. "|r" 
          or self.f and self.f.bnet_battleTag and self.f.bnet_battleTag     ~= "" and BATTLENET_FONT_COLOR_CODE             .. self.f.bnet_battleTag     .. "|r"
    end;

    for col, colData in ipairs(Grid.COLUMNS)
    do local cellFrame = CreateFrame('Frame', nil, rowFrame);
             cellFrame:SetSize(colData.width, self.ROW_HEIGHT);
             cellFrame:SetPoint(anchor, last, relAnchor, xOffset, yOffset);

             cellFrame.text = cellFrame:CreateFontString(nil, 'OVERLAY', 'GameFontNormalSmall');
             cellFrame.text:SetText(nil);
             cellFrame.text:SetJustifyH(colData.align);
             cellFrame.text:SetJustifyV("TOP");
             cellFrame.text:SetAllPoints(cellFrame);

             local color = Config.get("COLOR_" .. colData.group);
             cellFrame.text:SetTextColor(RP_FRIENDS.utils.color.hexaToFloat(color));

             cellFrame.colData = colData;

             if     type(cellFrame.colData.field) == 'string'   then cellFrame.func = 
               function(f) 
                 return f[cellFrame.colData.field] 
               end;
             elseif type(cellFrame.colData.field) == 'function' then cellFrame.func = cellFrame.colData.field;                      end;

             function cellFrame:SetValue(f)
               if   not f 
               then self.text:SetText(nil); 
                    self.value = nil; 
               else self.value = self.func(f) 
                    self.text:SetText(self.value) 
               end;
             end;

             -- context menu
             cellFrame:SetScript("OnMouseUp",
               function(self, button) 
                 local mod =    IsControlKeyDown() and 'CONTROL'
                             or IsShiftKeyDown() and 'SHIFT'
                             or IsAltKeyDown() and 'ALT'
                             or nil;
                 if button == "RightButton" and self:GetParent().f
                 then if     self:GetParent().f.bnet_battleTag     
                      then   _G.FriendsFrame_ShowBNDropdown(self:GetParent().f.bnet_accountName , true, nil, nil, nil, true, self:GetParent().f.bnet_bnetIDAccount)
                      elseif self:GetParent().f.acct_characterName then _G.FriendsFrame_ShowDropdown(self:GetParent().f.acct_characterName, true, nil, nil, nil, true) 
                      end;
                 elseif button == "LeftButton" and self.colData.click and self:GetParent().f then self.colData.click(self:GetParent().f, self, mod) end;
               end);

             -- tooltip
             cellFrame:SetScript("OnEnter",
               function(self)
                 if not self:GetParent().f then return end;
                 GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
                 GameTooltip:ClearLines();
                 GameTooltip:AddLine(rowFrame:FriendIdentifier(), nil, nil, nil, true);
                 if     type(self.colData.alt) == 'string'   
                 then   GameTooltip:AddLine(self:GetParent().f[self.colData.alt], nil, nil, nil, true)
                 elseif type(self.colData.alt) == 'function' 
                 then   GameTooltip:AddLine(self.colData.alt(self:GetParent().f), nil, nil, nil, true)
                 elseif self.value or self.colData.showalt
                 then   GameTooltip:AddLine(self.value, nil, nil, nil, true)
                 end;
                 GameTooltip:Show();
                 self:GetParent().background:Show();
               end);
             cellFrame:SetScript("OnLeave", function(self) GameTooltip:Hide() self:GetParent().background:Hide() end)
             anchor, last, relAnchor, xOffset, yOffset = "LEFT", cellFrame, "RIGHT", self.COL_PADDING, 0;
             table.insert(rowFrame.cols, cellFrame);
    end; -- for col, colData

    rowFrame.background = rowFrame:CreateTexture(nil, 'BACKGROUND');
    rowFrame.background:SetColorTexture(1, 1, 1, 0.10);
    rowFrame.background:SetPoint("TOPLEFT", rowFrame, "TOPLEFT", -5, 3);
    rowFrame.background:SetPoint("BOTTOMRIGHT", rowFrame, "BOTTOMRIGHT", 7, 3);

    rowFrame.background:Hide();

    function rowFrame:UpdateIcons()
      self.IconFrame.left:SetWidth(1 + #RP_FRIENDS.displayFrame.icons.left * 20);
      local anchor, last, relAnchor, xOffset, yOffset = "LEFT", self.IconFrame.left, "LEFT", 2, 0;
      for _, index in ipairs(RP_FRIENDS.displayFrame.icons.left)
      do  self.icons[index]:Show();
          self.icons[index]:ClearAllPoints();
          self.icons[index]:SetPoint(anchor, last, relAnchor, xOffset, yOffset);
          last, relAnchor, xOffset = self.icons[index], "RIGHT", 4;
          self.icons[index]:SetValue(self.f);
      end;

      self.IconFrame.right:SetWidth(1 + #RP_FRIENDS.displayFrame.icons.right * 20);
      local anchor, last, relAnchor, xOffset, yOffset = "RIGHT", self.IconFrame.right, "RIGHT", 0, 0;
      for _, index in ipairs(RP_FRIENDS.displayFrame.icons.right)
      do  self.icons[index]:Show();
          self.icons[index]:ClearAllPoints();
          self.icons[index]:SetPoint(anchor, last, relAnchor, xOffset, yOffset);
          last, relAnchor, xOffset = self.icons[index], "LEFT", -4;
          self.icons[index]:SetValue(self.f);
      end;

      for _, index in ipairs(RP_FRIENDS.displayFrame.icons.hide) 
      do self.icons[index]:Hide();
         self.icons[index]:SetValue(self.f);
      end;
    end;

    rowFrame:SetScript("OnEnter",
      function(self)
        GameTooltip:SetOwner(self, "ANCHOR_CURSOR", 16, 16);
        GameTooltip:ClearLines();
        GameTooltip:AddLine(rowFrame:FriendIdentifier(), nil, nil, nil, true);
        GameTooltip:Show();
        self.background:Show();
      end);
    rowFrame:SetScript("OnLeave", function(self) GameTooltip:Hide(); self.background:Hide() end)

    rowFrame.overflow = CreateFrame('Frame', nil, rowFrame);
    rowFrame.overflow:SetSize(self.ROW_HEIGHT, self.ROW_HEIGHT);
    rowFrame.overflow:SetPoint("RIGHT", rowFrame, "RIGHT", 0, 0);
    rowFrame.overflow.arrow = rowFrame.overflow:CreateTexture(nil, 'OVERLAY');
    rowFrame.overflow.arrow:SetTexture("Interface\\MONEYFRAME\\Arrow-Right-Up");
    rowFrame.overflow.arrow:SetAlpha(0.5)
    rowFrame.overflow.arrow:SetAllPoints(rowFrame.overflow);
    rowFrame.overflow:SetScript("OnEnter",
      function(self)
        self:GetParent().background:Show();
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT", 12, 16);
        GameTooltip:ClearLines();
        local tip = {}
        for col, cell in ipairs(self:GetParent().cols)
        do  if Config.get("COLUMN_" .. cell.colData.index) and cell.hidden
            then 
                 local value;
                 local  key = cell.colData.alt;
                 if     key and type(key) == 'string'   then value = cell:GetParent().f[key]
                 elseif key and type(key) == 'function' then value = key(cell:GetParent().f)
                 end;
                 if     not value and type(cell.colData.field) == 'string'   then value = cell:GetParent().f[cell.colData.field]
                 elseif not value and type(cell.colData.field) == 'function' then value = cell.colData.field(cell:GetParent().f)
                 end;
                 if   value 
                 then value = value:gsub("\n*|cff999999.+$", "")
                      value = value:gsub("|cff%x%x%x%x%x%x%s*|r","");
                      if   value ~= "" and not value:match("^%s*$")
                      then table.insert(tip, "|cff" .. Config.get("COLOR_" .. cell.colData.group) .. loc("CONFIG_COLUMN_" .. cell.colData.index) .. ":|r " ..  value) 
                      end;
                 end;
                      
            end;
        end;
        local values = table.concat(tip, "\n\n");
        if values and values ~= "" 
           then GameTooltip:AddLine("|cff" .. Config.get("COLOR_DEFAULT") .. "Additional Fields|r");
                GameTooltip:AddLine(values, nil, nil, nil, true)
                GameTooltip:Show();
           else GameTooltip:AddLine("No additional fields to show.", nil, nil, nil, true)
                GameTooltip:Show();
           end;
        self.arrow:SetAlpha(1);
      end);
    rowFrame.overflow:SetScript("OnLeave", function(self) GameTooltip:Hide() self:GetParent().background:Hide() self.arrow:SetAlpha(0.5) end);

    function rowFrame:LoadFriend(f) 
      local anchor, last, relAnchor, xOffset, yOffset;
      local currWidth = 0;
      local full = false;
      local hidden = false;
      self.f = f;

      self:UpdateIcons();

      local maxWidth = displayFrame.maxWidth - #RP_FRIENDS.displayFrame.icons.left * 20 - #RP_FRIENDS.displayFrame.icons.right * 20;

      for  col, cell in ipairs(self.cols)
      do -- cell.f = f;
         if not Config.get("COLUMN_" .. cell.colData.index)
         then   cell:SetValue(nil);
                cell:SetWidth(0.001);
         elseif full
         then   cell:SetValue(nil);
                cell:SetWidth(0.001);
                cell.hidden = true;
                hidden = true;
         elseif currWidth + cell.colData.width > maxWidth
         then   full = true;
                cell:SetValue();
                cell:SetWidth(0.001);
                hidden = true;
                cell.hidden = true;
         else   cell:SetValue(f)
                cell:SetWidth(cell.colData.width);
                currWidth = currWidth + cell.colData.width;
                cell.hidden = false;
         end;
       end;

       rowFrame.overflow:SetShown(hidden);

       -- self.IconFrame.left:SetWidth(1 + #self.icons.left * 20);
       -- anchor, last, relAnchor, xOffset, yOffset = "LEFT", self.IconFrame.left, "LEFT", 2, 0;
       -- for i, icon in ipairs(self.icons.left)   
       -- do  icon:SetValue(f) 
       --     icon:Show();
       --     icon:SetPoint(anchor, last, relAnchor, xOffset, yOffset);
       --     last, relAnchor, xOffset = icon, "RIGHT", 4;
       -- end;

       -- self.IconFrame.right:SetWidth(1 + #self.icons.right * 20);
       -- anchor, last, relAnchor, xOffset, yOffset = "RIGHT", self.IconFrame.right, "RIGHT", -2, 0;
       -- for i, icon in ipairs(self.icons.right)   
       -- do  icon:SetValue(f)
       --     icon:Show();
       --     icon:SetPoint(anchor, last, relAnchor, xOffset, yOffset);
       --     last, relAnchor, xOffset = icon, "LEFT", -4;
       -- end;


    end; -- :LoadFriend()

    self.nextRow  = { anchor = "TOPLEFT", last = rowFrame, relAnchor = "BOTTOMLEFT", xOffset   = 0, yOffset = 0 };
    return rowFrame;
  end; -- :CreateRow

  function displayFrame:IsSearchMatch(f, s) if not s or s:len() < 3 then return true end;
    for col, colData in ipairs(Grid.COLUMNS)
    do if  colData.search
           and Config.get("COLUMN_" .. colData.index)
           and (   (type(colData.search) == 'string'   and f[colData.search] and f[colData.search]:lower():match(s:gsub("%W", ""):lower()))
                or (type(colData.search) == 'function' and colData.search(f, s:gsub("%W", "")))
               ) 
       then return true;
       end;
    end;
    return false;
  end; -- :IsSearchMatch

  function displayFrame:ColorColumns()
    for col, colData in ipairs(RP_FRIENDS.grid.COLUMNS)
        do local color = Config.get("COLOR_" .. colData.group);
           self.headers[col].text:SetTextColor(RP_FRIENDS.utils.color.hexaToFloat(color));
           for r, row in ipairs(self.rows) 
           do row.cols[col].text:SetTextColor(RP_FRIENDS.utils.color.hexaToFloat(color));
           end;
        end; 
  end;
          
  function displayFrame:IsCategoryMatch(f, s) 
    if not s or s == "" then return true end;
    return string.match(RP_FRIENDS.friendslist:GetCategories(f), "[" .. s .. "]")
  end;

  function displayFrame:Filter(f)
    local searchMatch = (not self.search or self.search:len() < 3) and true
                        or self:IsSearchMatch(f, self.search);
    local categoryMatch = Config.get("CAT_FILTER") == "" and true or self:IsCategoryMatch(f, Config.get("CAT_FILTER"));
    return Config.get("INCLUDE_" .. (f.acct_client and f.acct_client:upper() or (f.bnet_client and not f.acct_client) and f.bnet_client:upper() or "DISCONNECT"))
      and (Config.get("ALSO_SHOW_OFF_SERVER") or (f.acct_realmName == self.myServer) or (f.realm_name == self.myServer)) 
      and searchMatch
      and categoryMatch
  end; -- :Filter

  function displayFrame:LoadData()
    local friendsToDisplay = {}
    for friendID, f in pairs(RP_FRIENDS.friendDB) 
    do if self:Filter(f) then table.insert(friendsToDisplay, f) end; end;

    table.sort(friendsToDisplay,
      function(a, b)
       local valueA = RP_FriendsDB.sort.key(a):lower(); 
       local valueB = RP_FriendsDB.sort.key(b):lower();
        if RP_FriendsDB.sort.dir then return valueA < valueB else return valueA > valueB end;
      end);

    local friendCount = #friendsToDisplay;
    
    self:SetDimensions();
    local offset;

    self.friendCount = friendCount; -- store for later

    if friendCount < self.listCapacity
    then offset = 0;
         self:SetScrollBar(false);
         for friendIndex, row in ipairs(self.rows)
         do  if   friendIndex > friendCount 
             then row:Hide()
             else row:Show(); row:LoadFriend(friendsToDisplay[friendIndex]) 
             end; -- if
         end; -- for friendindex
    else offset = math.max(self.offset, self.listCapacity - friendCount)
         self:SetScrollBar(true);
         for rowIndex, row in ipairs(self.rows)
         do  
             if rowIndex > self.listCapacity
             then row:Hide()
             else row:LoadFriend(friendsToDisplay[rowIndex + offset])
                  row:Show()
             end;
         end;-- for rowindex
    end; -- if
  end; -- :ShowData()
    
  local CategoryPicker = CreateFrame('Frame', 'RP_FRIENDS_CategoryPicker', displayFrame)
  CategoryPicker:SetSize(307, 109);
  CategoryPicker:SetBackdrop(RP_FRIENDS.const.BACKDROP.BLIZZTOOLTIPTHIN);
  CategoryPicker:SetBackdropColor(0, 0, 0, 0.75);
  CategoryPicker.categories = {};
  CategoryPicker:SetFrameStrata('DIALOG');

  CategoryPicker.title = CategoryPicker:CreateFontString(nil, 'OVERLAY', 'GameFontNormalLarge');
  CategoryPicker.title:SetText(' ');
  CategoryPicker.title:SetPoint("TOPLEFT", CategoryPicker, "TOPLEFT", 8, -8);
  CategoryPicker.title:SetPoint("TOPRIGHT", CategoryPicker, "TOPRIGHT", -58, -8);
  CategoryPicker.title:SetWordWrap(false);
  CategoryPicker.title:SetJustifyH("LEFT");
  CategoryPicker.title:SetJustifyV("TOP");
  
  CategoryPicker.closeButton = CreateFrame('Frame', nil, CategoryPicker);
  CategoryPicker.closeButton.texture = CategoryPicker.closeButton:CreateTexture();
  CategoryPicker.closeButton.texture:SetTexture("Interface\\RAIDFRAME\\ReadyCheck-Ready");
  CategoryPicker.closeButton.texture:SetAllPoints(CategoryPicker.closeButton);
  CategoryPicker.closeButton:SetScript("OnMouseDown", function(self) RP_FRIENDS.displayFrame.CategoryPicker:Hide() end);
  CategoryPicker.closeButton:SetScript("OnEnter",
    function(self)
      GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
      GameTooltip:ClearLines();
      GameTooltip:AddLine("|cff11dd11Finished|r");
      GameTooltip:AddLine("Click the checkmark when you are done setting categories.", 0.7, 0.7, 0.7, true)
      GameTooltip:Show();
    end);
  CategoryPicker.closeButton:SetScript("OnLeave", function(self) GameTooltip:Hide() end);
  CategoryPicker.closeButton:SetSize(24, 24);
  CategoryPicker.closeButton:SetPoint("TOPRIGHT", CategoryPicker, "TOPRIGHT", -4, -4);


  anchor, lastElement, relAnchor, xOffset, yOffset = "TOPLEFT", CategoryPicker.title, "BOTTOMLEFT", 0, -8;
  for cat = 0, 15
  do  local hex = string.format("%x", cat):upper();
      local CategoryFrame = CreateFrame('Frame', nil, CategoryPicker);
      CategoryFrame:SetSize(32, 32);
      CategoryFrame.text = CategoryFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge3");
      CategoryFrame.text:SetAllPoints(CategoryFrame);
      CategoryFrame.text:SetText(hex);
      CategoryFrame:SetPoint(anchor, lastElement, relAnchor, xOffset, yOffset);
      if     cat % 8 == 7
      then   anchor, lastElement, relAnchor, xOffset, yOffset = "TOPLEFT", lastLine, "BOTTOMLEFT", 0, -5;
      elseif cat % 8 == 0
      then   anchor, lastElement, relAnchor, xOffset, yOffset = "LEFT", CategoryFrame, "RIGHT", 5, 0;
             lastLine = CategoryFrame;
      else  anchor, lastElement, relAnchor, xOffset, yOffset = "LEFT", CategoryFrame, "RIGHT", 5, 0;
      end;
      CategoryFrame.hex = hex;
      CategoryPicker.categories[hex] = CategoryFrame;
      CategoryFrame.bg = CategoryPicker:CreateTexture();
      CategoryFrame.bg:SetColorTexture(1, 1, 1, 0.25);
      CategoryFrame.bg:SetAllPoints(CategoryFrame);
      CategoryFrame:SetScript("OnMouseDown",
        function(self)
          if   self.value 
          then self:GetParent().OnUnselect(self:GetParent(), self.hex, self:GetParent().f);
               self.bg:Hide();
               self.value = false;
          else self:GetParent().OnSelect(self:GetParent(), self.hex, self:GetParent().f);
               self.bg:Show();
               self.value = true;
          end;
          RP_FRIENDS.displayFrame:Update("datashowicons")
        end);
      CategoryFrame:SetScript("OnEnter",
        function(self)
          GameTooltip:SetOwner(self, "AMCHOR_RIGHT");
          GameTooltip:ClearLines();
          GameTooltip:AddLine(Config.get("CAT" .. self.hex));
          GameTooltip:AddLine(Config.get("CAT" .. self.hex .. "_DESC"), 1, 1, 1, true);
          GameTooltip:AddLine(' ');
          GameTooltip:AddLine('Click to display all friends in this category.', 0.7, 0.7, 0.7, true);
          GameTooltip:AddLine('Control-click to display |cffdd1111only|r friends in this category.', 0.7, 0.7, 0.7, true);
          GameTooltip:Show()
        end);
      CategoryFrame:SetScript("OnLeave", function(self) GameTooltip:Hide() end);
  end;

  displayFrame.CategoryPicker = CategoryPicker;

  CategoryPicker:SetMovable(true);
  CategoryPicker:SetPoint("CENTER", displayFrame, "CENTER", 0, 0);
  CategoryPicker:EnableMouse(true);
  CategoryPicker:RegisterForDrag("LeftButton");
  CategoryPicker:SetScript("OnDragStart", function(self) self:StartMoving() SetCursor("UI_MOVE_CURSOR") GameTooltip:Hide() end);
  CategoryPicker:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() SetCursor(nil) end);
  CategoryPicker:SetClampedToScreen(true);
  tinsert(UISpecialFrames, 'RP_FRIENDS_CategoryPicker');

  function CategoryPicker:SetTitle(title) self.title:SetText(title) end;

  function CategoryPicker:HiliteSelected(cats)
    for hex, CategoryFrame in pairs(self.categories)
    do  CategoryFrame.text:SetText(RP_FRIENDS.const.icons.SMALL[Config.get("CAT" .. hex:upper() .. "_ICON")].icon)
        if   cats:upper():match(hex:upper())
        then CategoryFrame.bg:Show(); CategoryFrame.value = true;
        else CategoryFrame.bg:Hide(); CategoryFrame.value = false; end;
    end;
  end;

  CategoryPicker:SetScript("OnHide", function(self) self.f = nil; end);

  function displayFrame:SetFriendCategory(f)
    self.CategoryPicker.title:SetText(
         f.bnet_battleTag     and (BATTLENET_FONT_COLOR_CODE             .. f.bnet_battleTag     .. "|r")
      or f.rp_name            and ("|cff" .. Config.get("COLOR_RP")      .. f.rp_name            .. "|r")
      or f.acct_characterName and ("|cff" .. Config.get("COLOR_DEFAULT") .. f.acct_characterName .. "|r")
      or "Friend");
    self.CategoryPicker.f = f;
  
    self.CategoryPicker:HiliteSelected(RP_FRIENDS.friendslist:GetCategories(f))
    self.CategoryPicker.OnSelect   = function(self, hex, f) RP_FRIENDS.friendslist:AddCategory(f, hex); end;
    self.CategoryPicker.OnUnselect = function(self, hex, f) RP_FRIENDS.friendslist:RemoveCategory(f, hex); end;
       
    self.CategoryPicker:Show();
  end;

  function displayFrame:ResetOffset() 
    self.offset = 0; 
    self:SetScrollBar(self.friendCount > self.listCapacity); 
  end; -- :ResetOffset()

  function displayFrame:Update(request, from)
    table.insert(RP_FRIENDS.cache.updateLog, time() .. ": " .. request .. " from " .. (from or "") );
    if request:match("size")   then self:SetDimensions() end;
    if request:match("tint")   then self:ColorColumns()  end;
    if request:match("cols")   then self:LoadHeaders();  end;
    if request:match("icons")  then self:UpdateIcons();  end;
    if request:match("data")   or   request:match("show") then self:LoadData();     end;
    if request:match("offset") then self:ResetOffset();  end;

  end; -- :Update()
  displayFrame:Initialize()

  return "display";
end);  
