-- rp:Friends
-- by Oraibi, Moon Guard (US) server
-- ------------------------------------------------------------------------------
-- This work is licensed under the Creative Commons Attribution 4.0 International
-- (CC BY 4.0) license.

local RP_FRIENDS     = RP_FRIENDS;

table.insert(RP_FRIENDS.startup, function(state) -- startup function
  local Utils      = RP_FRIENDS.utils;
    
  if not RP_FRIENDS.cache then RP_FRIENDS.cache = {} end;
  if not Utils.config then Utils.config = {} end;
  if not Utils.help   then Utils.help   = {} end;

  local Config = Utils.config;
  local Const  = RP_FRIENDS.const;
  
  local loc         = Utils.locale.loc;
  local hi          = Utils.text.hilite;
  local notify      = Utils.text.notify;
  local version     = Utils.text.v(); -- yes, meant as a function call
  local ICONPOS     = { { text = loc("ICONPOS_LEFT"),   value = "LEFT"    },
                        { text = loc("ICONPOS_RIGHT"),  value = "RIGHT",  },
                        { text = loc("ICONPOS_HIDE"),   value = "HIDE",   },
                      };

  -- libraries
  --
  local PC_Dropdown = LibStub("PhanxConfig-Dropdown");
  local PC_Color    = LibStub("PhanxConfig-ColorPicker");
  local PC_Check    = LibStub("PhanxConfig-Checkbox");
  local PC_Text     = LibStub("PhanxConfig-EditBox");
  local PC_Slider   = LibStub("PhanxConfig-Slider");
  local LDBI        = LibStub("LibDBIcon-1.0");

  -- 
  local OptionsPanel  = CreateFrame("Frame", "RP_FRIENDS_Main_OptionsPanel"    ); 
  local ColumnsPanel  = CreateFrame("Frame", "RP_FRIENDS_Columns_OptionsPanel" );
  local IconsPanel    = CreateFrame("Frame", "RP_FRIENDS_Icons_OptionsPanel"   );
  local AboutPanel    = CreateFrame("Frame", "RP_FRIENDS_About_OptionsPanel"   );
  local CategoryPanel = CreateFrame("Frame", "RP_FRIENDS_Category_OptionsPanel");

  local function checkBoxOnValueChanged(self, value)
    Config.set(self.setting, value) 
    ColumnsPanel.refresh(ColumnsPanel);
    RP_FRIENDS.displayFrame:Update("colsdatashowsize");
  end;

  local function openConfigMenu(menu)
    if     menu == "main"      then InterfaceOptionsFrame_OpenToCategory(RP_FRIENDS_Main_OptionsPanel);
    elseif menu == "columns"   then InterfaceOptionsFrame_OpenToCategory(RP_FRIENDS_Columns_OptionsPanel);
    elseif menu == "icons"     then InterfaceOptionsFrame_OpenToCategory(RP_FRIENDS_Icons_OptionsPanel);
    elseif menu == "category"  then InterfaceOptionsFrame_OpenToCategory(RP_FRIENDS_Category_OptionsPanel);
    elseif menu == "about"     then InterfaceOptionsFrame_OpenToCategory(RP_FRIENDS_About_OptionsPanel);
    elseif menu == "keybind"   then KeyBindingFrame_LoadUI(); KeyBindingFrame.mode = 1; ShowUIPanel(KeyBindingFrame);
    end;
  end;

  StaticPopupDialogs["RP_FRIENDS_OPEN_URL"] = {
    OnShow     =
      function(self, data)
        self.text:SetFormattedText(hi("RP_FRIENDS Link Window\n\nCopy the following URL for " .. data.name .. " and paste it into your browser, then close this window."));
        self.editBox:SetText(data.url);                        self.editBox:SetAutoFocus(true);
        self.editBox:HighlightText();                          self.editBox:SetWidth(300);
        self.button1:SetPoint("RIGHT", self, "RIGHT", -12, 0); self.text:SetJustifyH("LEFT");
        self.text:SetSpacing(3);
      end,
    text      = "",       wide       = true, closeButton  = true,
    button1   = "Got it", exclusive  = true, timeout      = 60,
    whileDead = true,     hasEditBox = true, OnAccept     = function(self) self:Hide() end,
    enterClicksFirstButton           = true, hideOnEscape = true,
    EditBoxOnEnterPressed            = function(self) self:GetParent():Hide() end,
    EditBoxOnEscapePressed           = function(self) self:GetParent():Hide() end,
    };

  local function openUrl(site, url, name)
        if site and loc("URL_" .. site:upper()) ~= "" then url = loc("URL_" .. site:upper()) end;
        StaticPopup_Show("RP_FRIENDS_OPEN_URL", nil, nil, { url = url, name = name, });
  end;


  -- main panel --------------------------------------------------------------------------------------------------------------------
        OptionsPanel.name = loc("OPT_MENU_MAIN");
        OptionsPanel.widgets = {};
        OptionsPanel.columnWidgets = {};
        OptionsPanel.colorWidgets = {};
        RP_FRIENDS.cache.configPanel = OptionsPanel;
        InterfaceOptions_AddCategory(OptionsPanel);

  local OptionsTitle = OptionsPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge");
        OptionsTitle:SetPoint("TOPLEFT", 16, -16);
        OptionsTitle:SetJustifyH("LEFT");
        OptionsTitle:SetText(loc("OPT_PAGE_MAIN"));
        OptionsPanel.title = OptionsTitle;
        OptionsPanel.version = OptionsPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalTiny");
        OptionsPanel.version:SetPoint("TOPRIGHT", -16, -16);
        OptionsPanel.version:SetJustifyH("RIGHT");
        OptionsPanel.version:SetText(version);

        OptionsPanel.arrowLeft = CreateFrame('Button', nil, OptionsPanel);
        OptionsPanel.arrowLeft:SetNormalTexture("Interface\\ICONS\\misc_arrowleft");
        OptionsPanel.arrowLeft:SetSize(24, 24);
        OptionsPanel.arrowLeft:SetPoint("BOTTOMLEFT", OptionsPanel, "BOTTOMLEFT", 4, 4);

        OptionsPanel.arrowRight = CreateFrame('Button', nil, OptionsPanel);
        OptionsPanel.arrowRight:SetNormalTexture("Interface\\ICONS\\misc_arrowright");
        OptionsPanel.arrowRight:SetSize(24, 24);
        OptionsPanel.arrowRight:SetPoint("BOTTOMRIGHT", OptionsPanel, "BOTTOMRIGHT", -4, 4);

        OptionsPanel.arrowLeft.disable = OptionsPanel.arrowLeft:CreateTexture();
        OptionsPanel.arrowLeft.disable:SetTexture("Interface\\Icons\\misc_arrowleft");
        OptionsPanel.arrowLeft.disable:SetAllPoints();
        OptionsPanel.arrowLeft.disable:SetDesaturated(1);
        OptionsPanel.arrowLeft:SetNormalTexture(OptionsPanel.arrowLeft.disable);
        
        OptionsPanel.arrowRight:SetScript("OnClick", function(self) openConfigMenu("columns") end);
        OptionsPanel.arrowRight:SetScript("OnEnter", 
          function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
            GameTooltip:ClearLines();
            GameTooltip:AddLine("Columns")
            GameTooltip:Show();
          end);
        OptionsPanel.arrowRight:SetScript("OnLeave", function(self) GameTooltip:Hide(); end);

  local function CreateHTML(parent, text, anchorFrame, lines)
    local htmlFrame = CreateFrame('SimpleHTML', nil, parent);
    htmlFrame:SetJustifyH("LEFT");
    htmlFrame:SetJustifyV("TOP");
    htmlFrame:SetFontObject("p",  "GameFontNormal");
    htmlFrame:SetFontObject("h1", "GameFontHighlightLarge");
    htmlFrame:SetFontObject("h2", "GameFontHighlightHuge");
    htmlFrame:SetFontObject("h3", "GameFontNormalTiny");
    htmlFrame:SetSpacing("p", 2);
    htmlFrame:SetSize(575, lines * 12);
    htmlFrame:SetText(string.format(loc('FMT_HTML'), hi(text, true)));
    htmlFrame:SetScript("OnHyperlinkClick",
      function(f, link, text, button, ...)
        local  protocol =  link:match("^(%a+):");
        local  dest     =  link:match(":(.+)");
        if     protocol == "config"                      then      openConfigMenu(dest);
        elseif protocol == "http" or protocol == "https" then openUrl(dest, link, text);
        end;
      end) -- function
    htmlFrame:SetHyperlinksEnabled(true);
    htmlFrame:SetScript("OnHyperlinkEnter",
      function(f, link, text, button, ...)
        local  protocol = link:match("^(%a+):");
        local  dest     = link:match(":(.+)");
        if     protocol == "http"   or
               protocol == "https"  then   SetCursor("TAXI_CURSOR");
        elseif protocol == "config" then   SetCursor("INTERACT_CURSOR");
        end;
      end);
    htmlFrame:SetScript("OnHyperlinkLeave", function(f, link, text, button, ...) SetCursor(nil); end);
    htmlFrame:SetPoint("TOPLEFT", anchorFrame, "BOTTOMLEFT", 0, -16);
    return htmlFrame;
  end; -- ##

  OptionsPanel.instruct = CreateHTML(OptionsPanel, loc("INTRO_DESC"), OptionsTitle, 2);
  
  local KeybindButton = CreateFrame('Button', nil, OptionsPanel, 'UIPanelButtonTemplate');
        -- KeybindButton:SetPoint("BOTTOMRIGHT", OptionsPanel, "BOTTOMRIGHT", -16, 16);
        KeybindButton:SetPoint("TOPRIGHT", OptionsPanel, "BOTTOMLEFT", -4, -14);
        KeybindButton:SetWidth(96);
        KeybindButton:SetText("Keybinds");
        KeybindButton:SetScript("OnEnter",
          function(self)
            GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT");
            GameTooltip:AddLine("Open Keybindings");
            GameTooltip:AddLine("Keybindings for " .. loc("APP_NAME") .. " are found in the AddOns section.", nil, nil, nil, true);
            GameTooltip:Show();
          end);
        KeybindButton:SetScript("OnLeave", function(self) GameTooltip:Hide() end);
        KeybindButton:SetScript("OnClick",
          function(self)
            InterfaceOptionsFrame:Hide()
            KeyBindingFrame_LoadUI(); KeyBindingFrame.mode = 1; ShowUIPanel(KeyBindingFrame);
          end);

  local ShowLoginMessage = PC_Check:New(OptionsPanel, "Show Login Message", "Check to show the login message") 
        ShowLoginMessage:SetPoint("TOPLEFT", OptionsPanel.instruct, "BOTTOMLEFT", 0, -16);
        ShowLoginMessage.setting = "LOGIN_MESSAGE";
        ShowLoginMessage.Text:SetWidth(160);
        OptionsPanel.widgets.ShowLoginMessage = ShowLoginMessage;
        ShowLoginMessage.OnValueChanged = function(self, value) Config.set(self.setting, value); OptionsPanel.widgets.ShowChangesMessage:SetEnabled(value) end;

  local ShowChangesMessage = PC_Check:New(OptionsPanel, "Show Changes Message", "Check to show the changes message"); 
        ShowChangesMessage:SetPoint("LEFT", ShowLoginMessage.Text, "LEFT", 0,  0);
        ShowChangesMessage:SetPoint("TOP",  ShowLoginMessage, "BOTTOM", 0,  0);
        ShowChangesMessage.setting = "CHANGES_MESSAGE";
        ShowChangesMessage.Text:SetWidth(160);
        ShowChangesMessage.OnValueChanged = function(self, value) Config.set(self.setting, value); end;
        OptionsPanel.widgets.ShowChangesMessage = ShowChangesMessage;

  local ShowMinimapButton = PC_Check:New(OptionsPanel, 'Show Minimap Button', 'Check to show the ' .. loc("APP_NAME") .. ' button on the minimap.');
        ShowMinimapButton:SetPoint("TOP", ShowChangesMessage, "BOTTOM", 0, 0);
        ShowMinimapButton:SetPoint("LEFT", ShowLoginMessage, "LEFT", 0, 0);
        ShowMinimapButton.setting = "BUTTON";
        ShowMinimapButton.Text:SetWidth(160);
        ShowMinimapButton.OnValueChanged = 
          function(self, value) Config.set(self.setting, value)
            if value then LDBI:Show("rp:Friends") else LDBI:Hide("rp:Friends") end;
            end;
        OptionsPanel.widgets.ShowMinimapButton = ShowMinimapButton;

  local ButtonBarOtherBlizzApps = PC_Check:New(OptionsPanel, loc("CONFIG_SHOW_OTHER_BLIZZ_GAMES"), hi(loc("CONFIG_SHOW_OTHER_BLIZZ_GAMES_TT")));
        ButtonBarOtherBlizzApps:SetPoint("TOPLEFT", ShowMinimapButton, "BOTTOMLEFT", 0, 0);
        ButtonBarOtherBlizzApps.setting = "SHOW_OTHER_BLIZZ_GAMES";
        ButtonBarOtherBlizzApps.Text:SetWidth(360);
        OptionsPanel.widgets.ButtonBarOtherBlizzApps = ButtonBarOtherBlizzApps;
        ButtonBarOtherBlizzApps.OnValueChanged = 
          function(self, value) 
            Config.set(self.setting, value); 
            if value then RP_FRIENDS.friendslist:SetMinResize(535, 165);
                          RP_FRIENDS.friendslist:SetWidth(math.max(535, RP_FRIENDS.friendslist:GetWidth()));
            else RP_FRIENDS.friendslist:SetMinResize(320, 165);
            end;
            RP_FRIENDS.friendslist:ShowButtonBar();
            RP_FRIENDS.displayFrame:Update("datashowoffsetcols");
          end;

  local ButtonOnBlizzFriendsList = PC_Check:New(OptionsPanel, 'rp:F Button on Friendslist', 'Show a button for ' .. loc("APP_NAME") .. " on the default Blizzard friendslist.");
        ButtonOnBlizzFriendsList:SetPoint("TOPLEFT", ButtonBarOtherBlizzApps, "BOTTOMLEFT", 0, 0);
        ButtonOnBlizzFriendsList.setting = "BUTTON_ON_FRIENDSLIST";
        ButtonOnBlizzFriendsList.Text:SetWidth(180)
        ButtonOnBlizzFriendsList.OnValueChanged =
          function(self, value)
            Config.set(self.setting, value);
            RP_FRIENDS_ButtonOnBlizzFriendsList:SetShown(value)
          end;
        OptionsPanel.widgets.ButtonOnBlizzFriendsList = ButtonOnBlizzFriendsList;

  local AlphaSlider = PC_Slider:New(OptionsPanel, loc("CONFIG_ALPHA"), hi(loc("CONFIG_ALPHA_TT")), 0, 1, 0.05, true, true);
        AlphaSlider.setting = "ALPHA";
        AlphaSlider.OnValueChanged = function(self, value) 
          Config.set(self.setting, value); 
          local r, g, b = RP_FRIENDS.utils.color.hexaToNumber(Config.get("COLOR_BACKDROP"));
          RP_FRIENDS.friendslist:SetBackdropColor(r / 255, g / 255, b / 255, value);
          end;
        AlphaSlider:SetWidth(175);
        AlphaSlider:SetValue(Config.get("ALPHA"))
        AlphaSlider:SetPoint("TOPLEFT", ButtonOnBlizzFriendsList, "BOTTOMLEFT", 0, -16);
        OptionsPanel.widgets.AlphaSlider = AlphaSlider;

  local FriendslistScale = PC_Slider:New(OptionsPanel, loc("CONFIG_SCALE"), hi(loc("CONFIG_SCALE_TT")), 0.25, 2, 0.05, true, true)
        FriendslistScale:SetPoint("LEFT", AlphaSlider, "RIGHT", 25, 0);
        FriendslistScale.setting = "SCALE";
        FriendslistScale:SetWidth(175);
        FriendslistScale.OnValueChanged =
          function(self, value)
            Config.set(self.setting, value);
            RP_FRIENDS.friendslist:SetScale(value)
          end; -- function
        FriendslistScale:SetValue(Config.get("SCALE"));
        OptionsPanel.widgets.FriendslistScale = FriendslistScale;

  local IconZoomSlider = PC_Slider:New(OptionsPanel, loc("CONFIG_ICON_ZOOM"), hi(loc("CONFIG_ICON_ZOOM_TT")), 1, 8, 0.5, false, true)
        IconZoomSlider:SetPoint("LEFT", FriendslistScale, "RIGHT", 25, 0);
        IconZoomSlider.setting = "ICON_ZOOM";
        IconZoomSlider:SetWidth(175);
        IconZoomSlider.OnValueChanged =
          function(self, value)
            Config.set(self.setting, value);
            RP_FRIENDS.displayFrame.popup:SetSize(32 * value, 32 * value)
          end;
        IconZoomSlider:SetValue(Config.get("ICON_ZOOM"));
        OptionsPanel.widgets.IconZoomSlider = IconZoomSlider;

  local ColorsHeading = OptionsPanel:CreateFontString(nil, 'OVERLAY', 'GameFontNormalLarge');
        ColorsHeading:SetPoint("TOP", IconZoomSlider, "BOTTOM", 0, -16);
        ColorsHeading:SetPoint("LEFT", AlphaSlider, "LEFT", 0, 0);
        ColorsHeading:SetJustifyH('LEFT');
        ColorsHeading:SetJustifyV('TOP');
        ColorsHeading:SetText(loc("H1_COLORS"));

  OptionsPanel.instruct_color = CreateHTML(OptionsPanel, loc("INTRO_COLORS"), ColorsHeading, 3);
  
  local BackdropColor = PC_Color:New(OptionsPanel, loc("CONFIG_COLOR_BACKDROP"), hi(loc("CONFIG_COLOR_BACKDROP_TT")));
        BackdropColor.setting = "COLOR_BACKDROP";
        BackdropColor:SetPoint("TOPLEFT", OptionsPanel.instruct_color, "BOTTOMLEFT", 0, -16)
        BackdropColor:SetWidth(135);
        OptionsPanel.colorWidgets.BackdropColor = BackdropColor;
        BackdropColor.OnValueChanged =
         function(self, r, g, b) 
           local color = RP_FRIENDS.utils.color.colorCode(r * 255, g * 255, b * 255); 
                 
                 color = color:gsub("^|cff", "");
                 Config.set(self.setting, color);
                 RP_FRIENDS.friendslist:SetBackdropColor(r, g, b, Config.get("ALPHA"));
         end; -- function

  local DefaultColor = PC_Color:New(OptionsPanel, loc("CONFIG_COLOR_DEFAULT"), hi(loc("CONFIG_COLOR_DEFAULT_TT")));
        DefaultColor.setting = "COLOR_DEFAULT";
        DefaultColor:SetPoint("LEFT", BackdropColor, "RIGHT", 15, 0)
        DefaultColor:SetWidth(135);
        OptionsPanel.colorWidgets.DefaultColor = DefaultColor;
        DefaultColor.OnValueChanged =
         function(self, r, g, b) 
           local color = RP_FRIENDS.utils.color.colorCode(r * 255, g * 255, b * 255); 
                 color = color:gsub("^|cff", "");
                 Config.set(self.setting, color);
                 RP_FRIENDS.displayFrame:Update("tintcolsshowdata");
                 for c, col in pairs(ColumnsPanel.columnWidgets) do  col.Text:SetTextColor(RP_FRIENDS.utils.color.hexaToFloat(Config.get("COLOR_" .. col.color))) end;
         end; -- function

  local RoleplayingColor = PC_Color:New(OptionsPanel, loc("CONFIG_COLOR_RP"), hi(loc("CONFIG_COLOR_RP_TT")));
        RoleplayingColor.setting = "COLOR_RP";
        RoleplayingColor:SetPoint("LEFT", DefaultColor, "RIGHT", 15, 0)
        RoleplayingColor:SetWidth(135);
        OptionsPanel.colorWidgets.RoleplayingColor = RoleplayingColor;
        RoleplayingColor.OnValueChanged =
         function(self, r, g, b) 
           local color = RP_FRIENDS.utils.color.colorCode(r * 255, g * 255, b * 255); 
                 
                 color = color:gsub("^|cff", "");
                 Config.set(self.setting, color);
                 RP_FRIENDS.displayFrame:Update("tintcolsshowdata");
                 for c, col in pairs(ColumnsPanel.columnWidgets) do  col.Text:SetTextColor(RP_FRIENDS.utils.color.hexaToFloat(Config.get("COLOR_" .. col.color))) end;
         end; -- function

  local BattleNetColor = PC_Color:New(OptionsPanel, loc("CONFIG_COLOR_BN"), hi(loc("CONFIG_COLOR_BN_TT")));
        BattleNetColor.setting = "COLOR_BN";
        BattleNetColor:SetPoint("LEFT", RoleplayingColor, "RIGHT", 15, 0)
        BattleNetColor:SetWidth(135);
        OptionsPanel.colorWidgets.BattleNetColor = BattleNetColor;
        BattleNetColor.OnValueChanged =
         function(self, r, g, b) 
           local color = RP_FRIENDS.utils.color.colorCode(r * 255, g * 255, b * 255); 
                 
                 color = color:gsub("^|cff", "");
                 Config.set(self.setting, color);
                 RP_FRIENDS.displayFrame:Update("tintcolsshowdata");
                 for c, col in pairs(ColumnsPanel.columnWidgets) do  col.Text:SetTextColor(RP_FRIENDS.utils.color.hexaToFloat(Config.get("COLOR_" .. col.color))) end;
         end; -- function

  OptionsPanel.header_reset = OptionsPanel:CreateFontString(nil, 'OVERLAY', 'GameFontNormalLarge');
  OptionsPanel.header_reset:SetPoint("TOPLEFT", BackdropColor, "BOTTOMLEFT", 0, -16);
  OptionsPanel.header_reset:SetJustifyH("LEFT");
  OptionsPanel.header_reset:SetJustifyV("TOP");
  OptionsPanel.header_reset:SetText('Reset');
  OptionsPanel.instruct_reset = CreateHTML(OptionsPanel, loc("INTRO_RESET"), OptionsPanel.header_reset, 2);

  -- -- columns panel -----------------------------------------------------------------------------------------------------------------------------------
        ColumnsPanel.name = "Columns to Show";
        ColumnsPanel.parent = OptionsPanel.name;
        InterfaceOptions_AddCategory(ColumnsPanel);
        ColumnsPanel.widgets = {};
        ColumnsPanel.colorWidgets = {};
        ColumnsPanel.columnWidgets = {};

        ColumnsPanel.version = ColumnsPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalTiny");
        ColumnsPanel.version:SetPoint("TOPRIGHT", -16, -16);
        ColumnsPanel.version:SetJustifyH("RIGHT");
        ColumnsPanel.version:SetText(version);

        ColumnsPanel.arrowLeft = CreateFrame('Button', nil, ColumnsPanel);
        ColumnsPanel.arrowLeft:SetNormalTexture("Interface\\ICONS\\misc_arrowleft");
        ColumnsPanel.arrowLeft:SetSize(24, 24);
        ColumnsPanel.arrowLeft:SetPoint("BOTTOMLEFT", ColumnsPanel, "BOTTOMLEFT", 4, 4);

        ColumnsPanel.arrowRight = CreateFrame('Button', nil, ColumnsPanel);
        ColumnsPanel.arrowRight:SetNormalTexture("Interface\\ICONS\\misc_arrowright");
        ColumnsPanel.arrowRight:SetSize(24, 24);
        ColumnsPanel.arrowRight:SetPoint("BOTTOMRIGHT", ColumnsPanel, "BOTTOMRIGHT", -4, 4);

        ColumnsPanel.arrowRight.disable = ColumnsPanel.arrowRight:CreateTexture();
        ColumnsPanel.arrowRight.disable:SetTexture("Interface\\Icons\\misc_arrowright");
        ColumnsPanel.arrowRight.disable:SetAllPoints();
        ColumnsPanel.arrowRight:SetNormalTexture(ColumnsPanel.arrowRight.disable);
        
        ColumnsPanel.arrowRight:SetScript("OnClick", function(self) openConfigMenu("icons") end);
        ColumnsPanel.arrowRight:SetScript("OnEnter", 
          function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
            GameTooltip:ClearLines();
            GameTooltip:AddLine("Icons")
            GameTooltip:Show();
          end);
        ColumnsPanel.arrowRight:SetScript("OnLeave", function(self) GameTooltip:Hide(); end);

        ColumnsPanel.arrowLeft:SetScript("OnClick", function(self) openConfigMenu("main") end);
        ColumnsPanel.arrowLeft:SetScript("OnEnter", 
          function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
            GameTooltip:ClearLines();
            GameTooltip:AddLine("Options")
            GameTooltip:Show();
          end);
        ColumnsPanel.arrowLeft:SetScript("OnLeave", function(self) GameTooltip:Hide(); end);

  local ColumnsHeading = ColumnsPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge");
        ColumnsHeading:SetPoint("TOPLEFT", ColumnsPanel, "TOPLEFT", 16, -16);
        ColumnsHeading:SetJustifyH("LEFT");
        ColumnsHeading:SetJustifyV("TOP");
        ColumnsHeading:SetText('Columns to Display');

  ColumnsPanel.instruct = CreateHTML(ColumnsPanel, loc("INTRO_COLUMNS"), ColumnsHeading, 2);

  local anchor, lastElement, relAnchor, xOffset, yOffset = "TOPLEFT", ColumnsPanel.instruct, "BOTTOMLEFT", 0, -16;
  local lastLine;

  local colCount = 1;
  local function createColumnCheckbox(colData)
    local checkbox = PC_Check:New(ColumnsPanel, loc("CONFIG_COLUMN_" .. colData.index), hi(loc("CONFIG_COLUMN_" .. colData.index .. "_TT")));
    checkbox:SetPoint(anchor, lastElement, relAnchor, xOffset, yOffset);
    checkbox.setting = "COLUMN_" .. colData.index;
    checkbox.color = colData.group;
    checkbox.colWidth = colData.width;
    checkbox.Text:SetWidth(120);
    checkbox.Text:SetTextColor(RP_FRIENDS.utils.color.hexaToFloat(Config.get("COLOR_" .. colData.group)));
    checkbox.OnValueChanged = checkBoxOnValueChanged;
    ColumnsPanel.columnWidgets["Show_" .. colData.index] = checkbox;
    if colCount % 4 == 0
    then lastElement = lastLine;      anchor = "TOP";  relAnchor = "BOTTOM"; xOffset = 0; yOffset = -8;
    else lastElement = checkbox.Text; anchor = "LEFT"; relAnchor = "RIGHT";  xOffset = 5; yOffset = 0;
         if colCount % 4 == 1 then lastLine = checkbox; end;
    end; -- if
    colCount = colCount + 1;
  end;
    
  anchor, lastElement, relAnchor, xOffset, yOffset = "TOPLEFT", ColumnsPanel.instruct, "BOTTOMLEFT", 0, -16;
  for _, colData in pairs(RP_FRIENDS.grid.COLUMNS) do createColumnCheckbox(colData) end; 

  ColumnsPanel.header_reset = ColumnsPanel:CreateFontString(nil, 'OVERLAY', 'GameFontNormalLarge');
  ColumnsPanel.header_reset:SetPoint("TOP", lastElement, "BOTTOM", 0, -24);
  ColumnsPanel.header_reset:SetPoint("LEFT", ColumnsPanel, "LEFT", 16, 0);
  ColumnsPanel.header_reset:SetJustifyH("LEFT");
  ColumnsPanel.header_reset:SetJustifyV("TOP");
  ColumnsPanel.header_reset:SetText('Reset');
  ColumnsPanel.instruct_reset = CreateHTML(ColumnsPanel, loc("INTRO_RESET"), ColumnsPanel.header_reset, 2);

  local KeybindButton2 = CreateFrame('Button', nil, ColumnsPanel, 'UIPanelButtonTemplate');
  KeybindButton2:SetPoint("TOPRIGHT", ColumnsPanel, "BOTTOMLEFT", -4, -14);
  KeybindButton2:SetWidth(96);
  KeybindButton2:SetText("Keybinds");
  KeybindButton2:SetScript("OnEnter",
    function(self)
      GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT");
      GameTooltip:AddLine("Open Keybindings");
      GameTooltip:AddLine("Keybindings for " .. loc("APP_NAME") .. " are found in the AddOns section.", nil, nil, nil, true);
      GameTooltip:Show();
    end);
  KeybindButton2:SetScript("OnLeave", function(self) GameTooltip:Hide() end);
  KeybindButton2:SetScript("OnClick",
    function(self)
      InterfaceOptionsFrame:Hide()
      KeyBindingFrame_LoadUI(); KeyBindingFrame.mode = 1; ShowUIPanel(KeyBindingFrame);
    end);

  -- -- Icons panel   -----------------------------------------------------------------------------------------------------------------------------------
  IconsPanel.name = "Icons to Show";
  IconsPanel.parent = OptionsPanel.name;
  InterfaceOptions_AddCategory(IconsPanel);
  IconsPanel.widgets = {};
  IconsPanel.colorWidgets = {};
  IconsPanel.columnWidgets = {};
  IconsPanel.iconWidgets = {};

  IconsPanel.version = IconsPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalTiny");
  IconsPanel.version:SetPoint("TOPRIGHT", -16, -16);
  IconsPanel.version:SetJustifyH("RIGHT");
  IconsPanel.version:SetText(version);

  IconsPanel.arrowLeft = CreateFrame('Button', nil, IconsPanel);
  IconsPanel.arrowLeft:SetNormalTexture("Interface\\ICONS\\misc_arrowleft");
  IconsPanel.arrowLeft:SetSize(24, 24);
  IconsPanel.arrowLeft:SetPoint("BOTTOMLEFT", IconsPanel, "BOTTOMLEFT", 4, 4);

  IconsPanel.arrowRight = CreateFrame('Button', nil, IconsPanel);
  IconsPanel.arrowRight:SetNormalTexture("Interface\\ICONS\\misc_arrowright");
  IconsPanel.arrowRight:SetSize(24, 24);
  IconsPanel.arrowRight:SetPoint("BOTTOMRIGHT", IconsPanel, "BOTTOMRIGHT", -4, 4);

  IconsPanel.arrowLeft:SetScript("OnClick", function(self) openConfigMenu("columns") end);
  IconsPanel.arrowLeft:SetScript("OnEnter", 
    function(self)
      GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
      GameTooltip:ClearLines();
      GameTooltip:AddLine("Columns")
      GameTooltip:Show();
    end);
  IconsPanel.arrowLeft:SetScript("OnLeave", function(self) GameTooltip:Hide(); end);

  IconsPanel.arrowRight:SetScript("OnClick", function(self) openConfigMenu("category") end);
  IconsPanel.arrowRight:SetScript("OnEnter", 
    function(self)
      GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
      GameTooltip:ClearLines();
      GameTooltip:AddLine("Friend Categories")
      GameTooltip:Show();
    end);
  IconsPanel.arrowRight:SetScript("OnLeave", function(self) GameTooltip:Hide(); end);

  local KeybindButton3 = CreateFrame('Button', nil, IconsPanel, 'UIPanelButtonTemplate');
  KeybindButton3:SetPoint("TOPRIGHT", IconsPanel, "BOTTOMLEFT", -4, -14);
  KeybindButton3:SetWidth(96);
  KeybindButton3:SetText("Keybinds");
  KeybindButton3:SetScript("OnEnter",
    function(self)
      GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT");
      GameTooltip:AddLine("Open Keybindings");
      GameTooltip:AddLine("Keybindings for " .. loc("APP_NAME") .. " are found in the AddOns section.", nil, nil, nil, true);
      GameTooltip:Show();
    end);
  KeybindButton3:SetScript("OnLeave", function(self) GameTooltip:Hide() end);
  KeybindButton3:SetScript("OnClick",
    function(self)
      InterfaceOptionsFrame:Hide()
      KeyBindingFrame_LoadUI(); KeyBindingFrame.mode = 1; ShowUIPanel(KeyBindingFrame);
    end);

  local IconsHeading = IconsPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge");
  IconsHeading:SetPoint("TOPLEFT", IconsPanel, "TOPLEFT", 16, -16);
  IconsHeading:SetJustifyH("LEFT");
  IconsHeading:SetJustifyV("TOP");
  IconsHeading:SetText('Icons to Display');

  IconsPanel.instruct = CreateHTML(IconsPanel, loc("INTRO_ICONS"), IconsHeading, 2);

  local function IconDropdownOnValueChanged(self, value)
    Config.set(self.setting, value);
    RP_FRIENDS.displayFrame:Update("colsdataicons");

  end;

  local icoCount = 1;
  local function createIconChoicebox(icoData)
    local dropdown = PC_Dropdown:New(IconsPanel, loc("CONFIG_ICON_"    .. icoData.index), 
                                           hi(loc("CONFIG_ICON_" .. icoData.index .. "_TT")),
                                           ICONPOS);
    dropdown:SetPoint(anchor, lastElement, relAnchor, xOffset, yOffset);
    dropdown.setting = "ICON_" .. icoData.index;
    dropdown.icoWidth = icoData.width;
    dropdown:SetWidth(135);
    dropdown.OnValueChanged = IconDropdownOnValueChanged;
     IconsPanel.iconWidgets["ICON_" .. icoData.index] = dropdown;
     if icoCount % 4 == 0
     then lastElement = lastLine; anchor = "TOPLEFT"; relAnchor = "BOTTOMLEFT"; xOffset = 0; yOffset = -16; 
     else lastElement = dropdown; anchor = "LEFT";    relAnchor = "RIGHT";      xOffset = 15; yOffset =  0;
    if icoCount % 4 == 1 then lastLine = dropdown; end;
     end; -- if
     icoCount = icoCount + 1;
  end;
    
  anchor, lastElement, relAnchor, xOffset, yOffset = "TOPLEFT", IconsPanel.instruct, "BOTTOMLEFT", 0, -16;
  for _, icoData in pairs(RP_FRIENDS.grid.ICONS) do createIconChoicebox(icoData) end; -- for icoData

  IconsPanel.header_reset = IconsPanel:CreateFontString(nil, 'OVERLAY', 'GameFontNormalLarge');
  IconsPanel.header_reset:SetPoint("TOP", lastElement, "BOTTOM", 0, -24);
  IconsPanel.header_reset:SetPoint("LEFT", IconsPanel, "LEFT", 16, 0);
  IconsPanel.header_reset:SetJustifyH("LEFT");
  IconsPanel.header_reset:SetJustifyV("TOP");
  IconsPanel.header_reset:SetText('Reset');
  IconsPanel.instruct_reset = CreateHTML(IconsPanel, loc("INTRO_RESET"), IconsPanel.header_reset, 2);

  -- categories ----------------------------------------------------------------------------------------------------------------------------------------

  CategoryPanel.name          = "Friend Categories";
  CategoryPanel.parent        = OptionsPanel.name;
  InterfaceOptions_AddCategory(CategoryPanel);
  CategoryPanel.textWidgets = {};
  CategoryPanel.iconWidgets = {};
  CategoryPanel.countWidgets = {};

  CategoryPanel.title = CategoryPanel:CreateFontString(nil, 'OVERLAY', 'GameFontNormalLarge');
  CategoryPanel.title:SetPoint("TOPLEFT", CategoryPanel, "TOPLEFT", 16, -16);
  CategoryPanel.title:SetText('Friend Categories');

  CategoryPanel.instruct = CreateHTML(CategoryPanel, loc("INTRO_CATEGORY"), CategoryPanel.title, 2);

  local SmallIconPicker = CreateFrame('Frame', nil, CategoryPanel);
  SmallIconPicker:SetSize(286, 16 + 27 * math.ceil(#RP_FRIENDS.const.icons.SMALL / 10));
  SmallIconPicker.value = 1;
  SmallIconPicker:SetBackdrop(RP_FRIENDS.const.BACKDROP.BLIZZTOOLTIPTHIN);
  SmallIconPicker:SetBackdropColor(0, 0, 0, 0.8);
  SmallIconPicker:SetFrameStrata('DIALOG');
  SmallIconPicker.icons = {};
  SmallIconPicker:SetScript("OnEnter", function(self) end);
  SmallIconPicker.closeButton = CreateFrame('Button', nil, SmallIconPicker);
  SmallIconPicker.closeButton:SetNormalTexture("Interface\\FriendsFrame\\UI-Toast-CloseButton-Up");
  SmallIconPicker.closeButton:SetSize(12, 12);
  SmallIconPicker.closeButton:SetPoint("TOPRIGHT", SmallIconPicker, "TOPRIGHT", -2, -2);
  SmallIconPicker.closeButton:SetScript("OnClick", function(self) self:GetParent():Hide() end);
  SmallIconPicker.closeButton:SetScript("OnEnter",
    function(self)
      GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
      GameTooltip:ClearLines();
      GameTooltip:AddLine("Close");
      GameTooltip:Show();
      end);
  SmallIconPicker.closeButton:SetScript("OnLeave", function(self) GameTooltip:Hide() end);

  local function CategoryIconOnChange(self, value)
    RP_FRIENDS.displayFrame:Update("datashowncolsoffset", "Category " .. self.hex .. " Icon value changed");
    self.text:SetText(RP_FRIENDS.const.icons.SMALL[value].icon);
    Config.set(self.setting, value);
  end;

  local function CategoryNameOnChange(self, value)
    RP_FRIENDS.displayFrame:Update("datashowncolsoffset", "Category " .. self.hex .. " Name value changed");
    Config.set(self.setting, value);
  end;

  local function CategoryDescOnChange(self, value)
    RP_FRIENDS.displayFrame:Update("datashowncolsoffset", "Category " .. self.hex .. " Desc value changed");
    Config.set(self.setting, value);
  end;

  anchor, lastElement, relAnchor, xOffset, yOffset, lastLine = "TOPLEFT", SmallIconPicker, "TOPLEFT", 8, -8, SmallIconPicker;

  for ico, icoData in ipairs(RP_FRIENDS.const.icons.SMALL)
  do  local icoButton = CreateFrame('Frame', nil, SmallIconPicker);
      icoButton:SetSize(24, 24);
      icoButton.text = icoButton:CreateFontString(nil, 'OVERLAY', 'GameFontNormalHuge');
      icoButton.text:SetText(icoData.icon);
      icoButton.text:SetAllPoints(icoButton);
      icoButton.value = ico;
      icoButton.bg = icoButton:CreateTexture();
      icoButton.bg:SetColorTexture(1, 1, 1, 0.25);
      icoButton.bg:SetAllPoints(icoButton);
      icoButton:SetPoint(anchor, lastElement, relAnchor, xOffset, yOffset);
      table.insert(SmallIconPicker.icons, icoButton);

      if ico % 10 == 0
      then anchor, lastElement, relAnchor, xOffset, yOffset = "TOPLEFT", lastLine, "BOTTOMLEFT", 0, -3;
      elseif ico % 10 == 1
      then  anchor, lastElement, relAnchor, xOffset, yOffset = "LEFT", icoButton, "RIGHT", 3, 0;
            lastLine = icoButton;
      else  anchor, lastElement, relAnchor, xOffset, yOffset = "LEFT", icoButton, "RIGHT", 3, 0;
      end;
      icoButton:SetScript("OnMouseDown", 
        function(self) 
          CategoryIconOnChange(self:GetParent().ref, self.value)
          self:GetParent():Hide();
          end);
  end;

  function SmallIconPicker:Open(hex, frame)
    self:SetFrameStrata(frame:GetFrameStrata());
    self:SetFrameLevel(frame:GetFrameLevel() + 1);
    self.value = Config.get("CAT" .. hex .. "_ICON");
    self.hex = hex;
    self.ref = frame;
    self.setting = "CAT" .. hex .. "_ICON";
    self:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", 5, -5);
    for ico, icoButton in ipairs(self.icons) do if ico == self.value then icoButton.bg:Show() else icoButton.bg:Hide() end; end;
    self:Show();
  end;

  CategoryPanel.SmallIconPicker = SmallIconPicker;

  CategoryPanel:SetScript("OnHide", function(self) self.SmallIconPicker:Hide() end);

  CategoryPanel.version = CategoryPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalTiny");
  CategoryPanel.version:SetPoint("TOPRIGHT", -16, -16);
  CategoryPanel.version:SetJustifyH("RIGHT");
  CategoryPanel.version:SetText(version);

  CategoryPanel.arrowLeft = CreateFrame('Button', nil, CategoryPanel);
  CategoryPanel.arrowLeft:SetNormalTexture("Interface\\ICONS\\misc_arrowleft");
  CategoryPanel.arrowLeft:SetSize(24, 24);
  CategoryPanel.arrowLeft:SetPoint("BOTTOMLEFT", CategoryPanel, "BOTTOMLEFT", 4, 4);

  CategoryPanel.arrowRight = CreateFrame('Button', nil, CategoryPanel);
  CategoryPanel.arrowRight:SetNormalTexture("Interface\\ICONS\\misc_arrowright");
  CategoryPanel.arrowRight:SetSize(24, 24);
  CategoryPanel.arrowRight:SetPoint("BOTTOMRIGHT", CategoryPanel, "BOTTOMRIGHT", -4, 4);

  CategoryPanel.arrowRight.disable = CategoryPanel.arrowRight:CreateTexture();
  CategoryPanel.arrowRight.disable:SetTexture("Interface\\Icons\\misc_arrowright");
  CategoryPanel.arrowRight.disable:SetAllPoints();
  CategoryPanel.arrowRight.disable:SetDesaturated(1);
  CategoryPanel.arrowRight:SetNormalTexture(CategoryPanel.arrowRight.disable);
  
  CategoryPanel.arrowLeft:SetScript("OnClick", function(self) openConfigMenu("icons") end);
  CategoryPanel.arrowLeft:SetScript("OnEnter", 
    function(self)
      GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
      GameTooltip:ClearLines();
      GameTooltip:AddLine("Icons")
      GameTooltip:Show();
    end);
  CategoryPanel.arrowLeft:SetScript("OnLeave", function(self) GameTooltip:Hide(); end);

  function createCategoryConfigBox(hex, i)
    local frame = CreateFrame('Frame', nil, CategoryPanel);
    frame:SetPoint(anchor, lastElement, relAnchor, xOffset, yOffset);
    frame:SetPoint("RIGHT", CategoryPanel, "RIGHT", -16, 0);
    frame:SetHeight(25);

    local icoButton = CreateFrame('Frame', nil, frame);
    icoButton:SetSize(20, 20);
    icoButton:SetPoint("LEFT", frame, "LEFT", 0, 0);
    icoButton.text = icoButton:CreateFontString(nil, 'OVERLAY', 'GameFontNormalLarge');
    icoButton.text:SetText(RP_FRIENDS.const.icons.SMALL[Config.get("CAT" .. hex .. "_ICON")].icon);
    icoButton.text:SetAllPoints(icoButton);
    icoButton.setting = "CAT" .. hex .. "_ICON";
    icoButton.hex = hex;
    icoButton:SetScript("OnMouseDown", function(self) SmallIconPicker:Open(self.hex, self) end);
    icoButton:SetScript("OnEnter", 
      function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
        GameTooltip:ClearLines();
        GameTooltip:AddLine("Icon");
        GameTooltip:AddLine("Click to change this category's icon.", 0.7, 0.7, 0.7, true);
        GameTooltip:Show();
      end);
    icoButton:SetScript("OnLeave", function(self) GameTooltip:Hide(); end);

    function icoButton:SetIcon()
      self.text:SetText(RP_FRIENDS.const.icons.SMALL[Config.get("CAT" .. self.hex .. "_ICON")].icon);
    end;

    CategoryPanel.iconWidgets["CAT" .. hex .. "_ICON"] = icoButton;

    local nameField = PC_Text:New(frame, "", "Enter the category name.");
    nameField:SetPoint("LEFT", icoButton, "RIGHT", 10, 0);
    nameField:SetValue(Config.get("CAT" .. hex));
    nameField.setting = "CAT" .. hex;
    nameField:SetWidth(100);
    nameField:SetCursorPosition(0);
    nameField.hex = hex;
    nameField.OnValueChanged = CategoryNameOnChange;
    CategoryPanel.textWidgets["CAT" .. hex .. "_NAME"] = nameField;

    local descField = PC_Text:New(frame, "", "Enter the category description.");
    descField:SetPoint("LEFT", nameField, "RIGHT", 10, 0);
    descField:SetValue(Config.get("CAT" .. hex .. "_DESC"));
    descField.setting = "CAT" .. hex .. "_DESC";
    descField:SetWidth(250);
    descField:SetCursorPosition(0);
    descField.hex = hex;
    descField.OnValueChanged = CategoryDescOnChange;
    CategoryPanel.textWidgets["CAT" .. hex .. "_DESC"] = descField;

    local CountField = CreateFrame('Frame', nil, frame);
    CountField:SetPoint("LEFT", descField, "RIGHT", 10, 0);
    CountField:SetSize(50, 20);
    CountField:SetScript("OnEnter",
      function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
        GameTooltip:ClearLines();
        GameTooltip:AddLine(RP_FRIENDS.const.icons.SMALL[Config.get("CAT" .. self.hex .. "_ICON")].icon .. " " .. Config.get("CAT" .. self.hex));

        if   self.bn and self.bn > 0 
        then GameTooltip:AddLine(' ');
             GameTooltip:AddDoubleLine(BATTLENET_FONT_COLOR_CODE .. "BattleNet|r Friends", self.bn);
        end;
        if   self.server and self.server > 0
        then GameTooltip:AddLine(' ');
             GameTooltip:AddDoubleLine("|cff11dd11" .. GetRealmName() .. "|r Friends", self.server);
        end;
        if   self.bn ~= nil and self.server ~= nil and self.bn + self.server > 0 
        then GameTooltip:AddLine(' ');
             local friendsFound = RP_FRIENDS.friendslist:FindCategory(self.hex, 12);
             for _, f in ipairs(friendsFound) do GameTooltip:AddLine(f, nil, nil, nil, true) end;
             if self.bn + self.server > 12 then GameTooltip:AddLine("... and " .. self.bn + self.server - 12 .. " more.") end;
             GameTooltip:Show(); 
        end
      end);
    CountField:SetScript("OnHide", function(self) GameTooltip:Hide() end);
             
        
    CountField.text = frame:CreateFontString(nil, 'OVERLAY', 'GameFontNormal');
    CountField.text:SetAllPoints(CountField);
    CountField.bn, CountField.server, CountField.string = RP_FRIENDS.friendslist:CategoryCount(hex);
    CountField.text:SetText(CountField.string);
    CountField.hex = hex;
    CategoryPanel.countWidgets["CAT" .. hex .. "_COUNT"] = CountField;

    function CountField:SetCount()
      self.bn, self.server, self.string = RP_FRIENDS.friendslist:CategoryCount(self.hex);
      self.text:SetText(self.string);
    end;

    anchor, lastElement, relAnchor, xOffset, yOffset = "TOPLEFT", frame, "BOTTOMLEFT", 0, 0;
  end;

  CategoryPanel.headers = CreateFrame('Frame', nil, CategoryPanel);
  CategoryPanel.headers:SetPoint("TOPLEFT", CategoryPanel.instruct, "BOTTOMLEFT", 0, -16);
  CategoryPanel.headers:SetPoint("RIGHT", CategoryPanel, "RIGHT", -16, 0);
  CategoryPanel.headers:SetHeight(25);

  CategoryPanel.headers.icon = CategoryPanel.headers:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight');
  CategoryPanel.headers.icon:SetText('Icon');
  CategoryPanel.headers.icon:SetWidth(30);
  CategoryPanel.headers.icon:SetPoint("LEFT", CategoryPanel.headers, "LEFT", 0, 0);
  CategoryPanel.headers.icon:SetJustifyH("CENTER");

  CategoryPanel.headers.name = CategoryPanel.headers:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight');
  CategoryPanel.headers.name:SetText('Category');
  CategoryPanel.headers.name:SetWidth(100);
  CategoryPanel.headers.name:SetPoint("LEFT", CategoryPanel.headers.icon, "RIGHT", 5, 0);
  CategoryPanel.headers.name:SetJustifyH("LEFT");

  CategoryPanel.headers.desc = CategoryPanel.headers:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight');
  CategoryPanel.headers.desc:SetText('Description');
  CategoryPanel.headers.desc:SetWidth(250);
  CategoryPanel.headers.desc:SetPoint("LEFT", CategoryPanel.headers.name, "RIGHT", 10, 0);
  CategoryPanel.headers.desc:SetJustifyH("LEFT");

  CategoryPanel.headers.count = CategoryPanel.headers:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight');
  CategoryPanel.headers.count:SetText('Count');
  CategoryPanel.headers.count:SetWidth(50);
  CategoryPanel.headers.count:SetPoint("LEFT", CategoryPanel.headers.desc, "RIGHT", 10, 0);
  CategoryPanel.headers.count:SetJustifyH("CENTER");

  anchor, lastElement, relAnchor, xOffset, yOffset = "TOPLEFT", CategoryPanel.headers, "BOTTOMLEFT", 5, 0;
  for i = 0, 15 do createCategoryConfigBox(string.format("%x", i):upper(), i) end;

  StaticPopupDialogs["RP_FRIENDS_CLEAR_CATEGORY_DATA"] = {
    showAlert = true,
    text = '|cffdd1111Alert!|r This will clear all category tags set on your ' .. BATTLENET_FONT_COLOR_CODE .. "BattleNet|r friends and " ..
           "your friends on |cff11dd11" .. GetRealmName() .. "|r. |cffdd1111This cannot be undone.|r \n\nAre you sure this is what you want to do?",
    button1 = "Yes, I'm Sure",
    button2 = "Maybe Not",
    exclusive = true,
    whileDead = true,
    hideOnEscape = true,
    timeout = 60,
    OnAccept = function() RP_FRIENDS.friendslist:ClearAllCategories() end,
  };

  CategoryPanel.clearCategoryData = CreateFrame('Button', nil, CategoryPanel, 'UIPanelButtonTemplate');
  CategoryPanel.clearCategoryData:SetWidth(192);
  CategoryPanel.clearCategoryData:SetPoint("BOTTOM", CategoryPanel, "BOTTOM", 0, 16);
  CategoryPanel.clearCategoryData:SetText("Clear Category Data");
  CategoryPanel.clearCategoryData:SetScript("OnEnter",
    function(self)
      GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
      GameTooltip:ClearLines();
      GameTooltip:AddLine("Clear Category Data", 0.9, 0.1, 0.1);
      GameTooltip:AddLine(" ");
      GameTooltip:AddLine("|cffdd1111Warning!|r This button will clear all category tags set on your " .. BATTLENET_FONT_COLOR_CODE .. "BattleNet|r friends and " ..
                          "your friends on |cff11dd11" .. GetRealmName() .. "|r. This cannot be undone. Use this option very carefully.", 0.7, 0.7, 0.7, true);
      GameTooltip:AddLine(" ");
      GameTooltip:AddLine("This setting is intended to be used if you decide to stop using " .. loc("APP_NAME") .. " and wish to clear out the category tags it stores in " ..
                          "your friend notes.", 0.7, 0.7, 0.7, true);
      GameTooltip:AddLine(" ");
      GameTooltip:AddLine("We are not responsible for any loss of data due to using this feature. |cffdd1111Use with caution!|r", 0.7, 0.7, 0.7, true);
      GameTooltip:Show();
    end);
  CategoryPanel.clearCategoryData:SetScript("OnLeave", function(self) GameTooltip:Hide() end);
  CategoryPanel.clearCategoryData:SetScript("OnClick", function(self) StaticPopup_Show("RP_FRIENDS_CLEAR_CATEGORY_DATA"); end);

  local KeybindButton4 = CreateFrame('Button', nil, CategoryPanel, 'UIPanelButtonTemplate');
  KeybindButton4:SetPoint("TOPRIGHT", CategoryPanel, "BOTTOMLEFT", -4, -14);
  KeybindButton4:SetWidth(96);
  KeybindButton4:SetText("Keybinds");
  KeybindButton4:SetScript("OnEnter",
    function(self)
      GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT");
      GameTooltip:AddLine("Open Keybindings");
      GameTooltip:AddLine("Keybindings for " .. loc("APP_NAME") .. " are found in the AddOns section.", nil, nil, nil, true);
      GameTooltip:Show();
    end);
  KeybindButton4:SetScript("OnLeave", function(self) GameTooltip:Hide() end);
  KeybindButton4:SetScript("OnClick",
    function(self)
      InterfaceOptionsFrame:Hide()
      KeyBindingFrame_LoadUI(); KeyBindingFrame.mode = 1; ShowUIPanel(KeyBindingFrame);
    end);

           
  -- refresh / default ---------------------------------------------------------------------------------------------------------------------------------
  OptionsPanel.refresh = 
    function(self)
      -- update the current values
      for _, widget in pairs(self.widgets)       do widget:SetValue(Config.get(widget.setting)); end;
      for _, widget in pairs(self.columnWidgets) do widget:SetValue(Config.get(widget.setting)); end;
      for _, widget in pairs(self.colorWidgets)  do widget:SetValue( RP_FRIENDS.utils.color.hexaToFloat(Config.get(widget.setting))); end;
      self.widgets.ShowChangesMessage:SetEnabled(Config.get("LOGIN_MESSAGE"))
      self.colorWidgets.BattleNetColor:Disable();
    end;

  OptionsPanel.default =
    function(self)
      for _, widget in pairs(self.widgets) do RP_FRIENDS.utils.config.reset(widget.setting) end;
      for _, widget in pairs(self.columnWidgets) do RP_FRIENDS.utils.config.reset(widget.setting) end;
      for _, widget in pairs(self.colorWidgets) do RP_FRIENDS.utils.config.reset(widget.setting) end;
      RP_FRIENDS.displayFrame:Update("datashowncolsoffset", "Options Reset to Default")
      notify("OPTIONS_ARE_RESET");
    end;
      
  ColumnsPanel.refresh = 
    function(self)
      -- update the current values
      for _, widget in pairs(self.widgets)       do widget:SetValue(Config.get(widget.setting)) end;
      for _, widget in pairs(self.columnWidgets) do widget:SetValue(Config.get(widget.setting)); end;
      for _, widget in pairs(self.colorWidgets)  do local r, g, b = RP_FRIENDS.utils.color.hexaToNumber(Config.get(widget.setting)); 
                                                    widget:SetValue(r / 255, g / 255, b / 255, 1); end;
    end;

  ColumnsPanel.default =
    function(self)
      for _, widget in pairs(self.widgets) do RP_FRIENDS.utils.config.reset(widget.setting) end;
      for _, widget in pairs(self.columnWidgets) do RP_FRIENDS.utils.config.reset(widget.setting) end;
      for _, widget in pairs(self.colorWidgets) do RP_FRIENDS.utils.config.reset(widget.setting) end;
      RP_FRIENDS.displayFrame:Update("datashowncolsoffset", "Options Reset to Default")
      notify("OPTIONS_ARE_RESET");
    end;

  IconsPanel.refresh = 
    function(self)
      -- update the current values
      for _, widget in pairs(self.iconWidgets)   do widget:SetValue(loc("ICONPOS_" .. Config.get(widget.setting))) end;
    end;

  IconsPanel.default =
    function(self)
      for _, widget in pairs(self.iconWidgets)       do RP_FRIENDS.utils.config.reset(widget.setting) end;
      RP_FRIENDS.displayFrame:Update("datashowncolsoffset", "Options Reset to Default")
      notify("OPTIONS_ARE_RESET");
    end;

  CategoryPanel.refresh =
    function(self)
      for _, widget in pairs(self.textWidgets)  do widget:SetValue(Config.get(widget.setting)); end;
      for _, widget in pairs(self.countWidgets) do widget:SetCount();                           end;
      for _, widget in pairs(self.iconWidgets)  do widget:SetIcon();                            end;
    end;

  CategoryPanel.default = 
    function(self)
      for _, widget in pairs(self.textWidgets)  do RP_FRIENDS.utils.config.reset(widget.setting) end;
      for _, widget in pairs(self.countWidgets) do RP_FRIENDS.utils.config.reset(widget.setting) end;
      for _, widget in pairs(self.iconWidgets)  do RP_FRIENDS.utils.config.reset(widget.setting) end;
      RP_FRIENDS.displayFrame:Update("datashowncolsoffset", "Options Reset to Default")
      notify("OPTIONS_ARE_RESET");
    end;
  return "options"
      
end); -- startup function


