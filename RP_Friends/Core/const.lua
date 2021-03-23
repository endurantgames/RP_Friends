-- RP Friends
-- by Oraibi, Moon Guard (US) server
-- ------------------------------------------------------------------------------
-- This work is licensed under the Creative Commons Attribution 4.0 International
-- (CC BY 4.0) license. 
--
local RP_FRIENDS = RP_FRIENDS;

table.insert(RP_FRIENDS.startup, function(state) -- startup function
  
  local GetAddOnMetadata = GetAddOnMetadata;
  
    -- ----------------- - Temporary values that are used later in rptags.globals
    --  
  local CFF               = "|cff";

  local BLACK             = "000000";
  local CYAN              = "33ff99";
  local GREEN             = "33ff33";
  local GREY              = "999999";
  local LIGHT_ORANGE      = "dd9933";
  local LITE_BLUE         = "00bbbb";
  local LITE_GREY         = "bbbbbb";
  local ORANGE            = "ff9966"; 
  local ORA_COLOR         = "bb00bb";
  local PINK              = "ff66ff";
  local RED               = "ff3333";
  local VIOLET            = "dd33aa";
  local WHITE             = "ffffff";
  local YELLOW            = "ffff66";
  local TEAL              = "33bb99";

  local RGBA_BN          = { r = 0.5, g = 0.5, b = 1.0, a = 1 };
  local RGBA_WHITE       = { r = 1,   g = 1,   b = 1,   a = 1 };
  local RGBA_YELLOW      = { r = 0.7, g = 0.7, b = 0,   a = 1 };
  
  local ICON_WIDTH       =  20;
  local SHORTTEXT_WIDTH  =  50;
  local TEXT_WIDTH       =  80;
  local LONGTEXT_WIDTH   = 110;
  local WIDETEXT_WIDTH   = 150;

  local RESET             = "|r";
  local MALE              = 2;
  local NEUTER            = 1;
  local FEMALE            = 3 ;
  local THEY              = 8675309; -- this is a custom number used internally
  local GENDER_UNKNOWN    = 5552368; -- also a custom number
  local GENDER_DEFAULT    = NEUTER;
  
  RP_FRIENDS.const = { 
    -- ------------- - addon details
    APP_ID           = "rpfriends",
    RP_COLOR         = CFF .. VIOLET,
    APP_COLOR        = CFF .. TEAL,
    ORAIBI           = CFF .. ORA_COLOR .. "Oraibi" .. RESET,
    VERSION          = GetAddOnMetadata(RP_FRIENDS.addOnName, "Version"),
    BACKDROP = {
      BLIZZTOOLTIP = { bgFile =  "Interface\\ChatFrame\\ChatFrameBackground",
                     edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
                     tileSize = 16, edgeSize = 16,
                     insets   = { left = 5, right = 5, top = 5, bottom = 4} }, 
      BLIZZTOOLTIPSEARCH = { -- bgFile =  "Interface\\ChatFrame\\ChatFrameBackground",
                     edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
                     tileSize = 16, edgeSize = 12,
                     -- insets   = { left = 2, right = 2, top = 2, bottom = 1} }, 
                     },
      BLIZZTOOLTIPMED = { bgFile =  "Interface\\ChatFrame\\ChatFrameBackground",
                     edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
                     tileSize = 16, edgeSize = 12,
                     insets   = { left = 2, right = 2, top = 2, bottom = 1} }, 
      BLIZZTOOLTIPTHIN = { bgFile =  "Interface\\ChatFrame\\ChatFrameBackground",
                     edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
                     tileSize = 16, edgeSize = 8,
                     insets   = { left = 2, right = 2, top = 2, bottom = 2} }, 
      ORIGINAL   = { bgFile =  "Interface\\ChatFrame\\ChatFrameBackground",
                       insets   = {top = -1, bottom = -1, left = -1, right = -1} },
      BAR = { bgFile = "Interface\\TargetingFrame\\UI-StatusBar", 
                    insets   = {top = 0, bottom = 0, left = 0, right = 0} },
      SKILLS = { bgFile = "Interface\\PaperDollInfoFrame\\UI-Character-Skills-Bar", 
                    insets   = {top = 0, bottom = 0, left = 0, right = 0} },
      BLANK = { bgFile =  "Interface\\ChatFrame\\ChatFrameBackground",
                    insets   = {top = 0, bottom = 0, left = 0, right = 0} },
      SHADED = { bgFile =  "Interface\\ChatFrame\\ChatFrameBackground",
                    insets   = {top = 0, bottom = 0, left = 0, right = 0} },
      SOLID = { bgFile = "Interface\\Buttons\\White8x8",
                    insets   = {top = 0, bottom = 0, left = 0, right = 0} },
      RAID = { bgFile = "Interface\\RaidFrame\\Raid-Bar-Hp-Fill",
                    insets   = {top = 0, bottom = 0, left = 0, right = 0} },
      }, -- statusbar
    STATUSBAR_ALPHA = { BLANK = 0, SHADED = 0.5, SKILLS = 0.75, BAR = 0.75, SOLID = 1, },
  ALIGN = {
    LEFT       = { H = "LEFT", V = "MIDDLE", }, CENTER = { H = "CENTER", V = "MIDDLE", }, RIGHT       = { H = "RIGHT", V = "MIDDLE", },
    TOPLEFT    = { H = "LEFT", V = "TOP",    }, TOP    = { H = "CENTER", V = "TOP",    }, TOPRIGHT    = { H = "RIGHT", V = "TOP",    },
    BOTTOMLEFT = { H = "LEFT", V = "BOTTOM", }, BOTTOM = { H = "CENTER", V = "BOTTOM", }, BOTTOMRIGHT = { H = "RIGHT", V = "BOTTOM", },
  }, 
  icons = {
    FAVORITE    = "PVPFrame\\PVP-BANNER-EMBLEM-4",
    DOWN_ARROW  = "|TInterface\\Buttons\\Arrow-Down-Down:0|t",
    T_          = "|TInterface\\",
    _t          = ":0|t",
    APP         = "Interface\\AddOns\\RP_Friends\\resources\\Graphics\\rpfriends-logo-256x256",
    APP_INLINE  = "|TInterface\\AddOns\\RP_Friends\\resources\\Graphics\\rpfriends-logo-transparent:20:40:0:-1:|t",
    BUTTON      =   "Interface\\AddOns\\RP_Friends\\resources\\Graphics\\rpfriends-person-2",
    COLORWHEEL  = "|TInterface\\OptionsFrame\\ColorblindSettings:0::0:0:256:256:0:148:0:148|t",
    ALLIANCE    = "ICONS\\UI_AllianceIcon-round",
    HORDE       = "ICONS\\UI_HordeIcon-round",
    TEST = "|TInterface\\HELPFRAME\\HelpIcon-Suggestion:0|t",
    PVE = "WorldMap\\UI-World-Icon",
    RP = "FriendsFrame\\UI-Toast-ChatInviteIcon",
    STATUS = "RAIDFRAME\\UI-RaidFrame-Threat",
    NOTE = "FriendsFrame\\UI-FriendsFrame-Note",
    CURR = "COMMON\\mini-hourglass",
    DOWNTICK = "|TInterface\\Buttons\\Arrow-Down-Down:0::0:-6:64:64:0:64:0:64:0|t",
    UPTICK   = "|TInterface\\Buttons\\Arrow-Up-Down:0::0:0:64:64:0:64:0:64:0|t",
    PARAMS    = { 
                  DEFAULT   = "0::0:0:64:64:0:64:0:64"   ,
                  CROPPED   = "0::0:0:64:64:12:52:12:52" ,
                  FAVORITE  = "0::0:0:64:64:8:40:8:40" ,
                  HOURGLASS = "0::0:0:64:64:10:54:10:54" ,
                  MEDIAN    = "0::0:0:64:64:8:56:8:56"   ,
                  STATUS    = "0::0:0:64:64:4:60:4:60"   ,
                  MALE      = "0::0:0:128:64:0:64:0:64"  ,
                  FEMALE    = "0::0:0:128:64:64:128:0:64",
                  },
    CLIENTS = { 
      _ORDER = { "DISCONNECT", "APP", "BSAP", "WOW", "DST2", "VIPR", "S1", "PRO", "HERO", "WTCG", "S2", "D3", },
      WOW    = "Interface\\CHATFRAME\\UI-ChatIcon-WoW",
      S2     = "Interface\\CHATFRAME\\UI-ChatIcon-SC2",
      D3     = "Interface\\CHATFRAME\\UI-ChatIcon-D3",
      WTCG   = "Interface\\CHATFRAME\\UI-ChatIcon-WTCG",
      HERO   = "Interface\\CHATFRAME\\UI-ChatIcon-HotS",
      PRO    = "Interface\\CHATFRAME\\UI-ChatIcon-Overwatch",
      CLNT   = "Interface\\CHATFRAME\\UI-ChatIcon-Battlenet",
      S1     = "Interface\\CHATFRAME\\UI-ChatIcon-SC",
      DST2   = "Interface\\CHATFRAME\\UI-ChatIcon-Destiny2",
      VIPR   = "Interface\\CHATFRAME\\UI-ChatIcon-CallOfDutyBlackOps4",
      APP    = "Interface\\CHATFRAME\\UI-ChatIcon-Battlenet",
      BSAP   = "Interface\\CHATFRAME\\UI-ChatIcon-Share",
      DISCONNECT = "Interface\\Buttons\\UI-GroupLoot-Pass-Down", -- too light
   },
    SMALL =
    {  -- 1-5
      { id = "COIN",         icon = "|TInterface\\Buttons\\UI-GroupLoot-Coin-Up:0|t", },
      { id = "COINS",        icon = "|TInterface\\GossipFrame\\auctioneerGossipIcon:0|t", },
      { id = "BANKER",       icon = "|TInterface\\GossipFrame\\BankerGossipIcon:0|t", },
      { id = "SACK",         icon = "|TInterface\\GossipFrame\\VendorGossipIcon:0|t", },
      { id = "DICE",         icon = "|TInterface\\Buttons\\UI-GroupLoot-Dice-Up:0|t", },

      -- 6-10
      { id = "HORN",         icon = "|TInterface\\Buttons\\UI-GuildButton-MOTD-Up:0|t", },
      { id = "HOME",         icon = "|TInterface\\Buttons\\UI-HomeButton:0|t", },
      { id = "BUBBLE",       icon = "|TInterface\\CHATFRAME\\UI-ChatWhisperIcon:0|t", },
      { id = "CONVO",        icon = "|TInterface\\CHATFRAME\\UI-ChatConversationIcon:0|t", },
      { id = "ARMORY",       icon = "|TInterface\\CHATFRAME\\UI-ChatIcon-ArmoryChat:0|t", },

      -- 11-15
      { id = "HUMANFIST",    icon = "|TInterface\\COMMON\\friendship-FistHuman:0::0:0:64:64:16:48:12:44:0|t", },
      { id = "ORCFIST",      icon = "|TInterface\\COMMON\\friendship-FistOrc:0::0:0:64:64:16:48:12:44:0|t", },
      { id = "HEART",        icon = "|TInterface\\COMMON\\friendship-heart:0::0:0:64:64:14:50:10:46:0|t", },
      { id = "PURPLEBALL",   icon = "|TInterface\\COMMON\\friendship-manaorb:0::0:0:64:64:16:48:12:44:0|t", },
      { id = "GRAYDOT",      icon = "|TInterface\\COMMON\\Indicator-Gray:0::0:0:64:64:8:56:8:56:0|t", },

      -- 16-20
      { id = "GREENDOT",     icon = "|TInterface\\COMMON\\Indicator-Green:0::0:0:64:64:8:56:8:56:0|t", },
      { id = "REDDOT",       icon = "|TInterface\\COMMON\\Indicator-Red:0::0:0:64:64:8:56:8:56:0|t", },
      { id = "YELLOWDOT",    icon = "|TInterface\\COMMON\\Indicator-Yellow:0::0:0:64:64:8:56:8:56:0|t", },
      { id = "SPEAKER",      icon = "|TInterface\\COMMON\\VoiceChat-Speaker-Small:0|t", },
      { id = "CROSSHAIRS",   icon = "|TInterface\\CURSOR\\Crosshairs:0|t", },

      -- 21-25
      { id = "THUMB",        icon = "|TInterface\\CURSOR\\thumbsup:0|t", },
      { id = "THUMBDOWN",    icon = "|TInterface\\CURSOR\\Unablethumbsdown:0|t", },
      { id = "ALERT",        icon = "|TInterface\\DialogFrame\\DialogIcon-AlertNew-16:0|t", },
      { id = "INFO",         icon = "|TInterface\\FriendsFrame\\InformationIcon:0|t", },
      { id = "GREENDROP",    icon = "|TInterface\\Garrison\\orderhall-missions-mechanic1:0|t", },

      -- 26-30
      { id = "FLAME",        icon = "|TInterface\\HELPFRAME\\HotIssueIcon:0|t", },
      { id = "PURPLEFLAME",  icon = "|TInterface\\Garrison\\orderhall-missions-mechanic3:0|t", },
      { id = "HOURGLASS",    icon = "|TInterface\\Garrison\\orderhall-missions-mechanic5:0|t", },
      { id = "SWORDS",       icon = "|TInterface\\Garrison\\orderhall-missions-mechanic10:0|t", },
      { id = "WHIRLWIND",    icon = "|TInterface\\Garrison\\orderhall-missions-mechanic7:0|t", },

      -- 31-35
      { id = "TIRED",        icon = "|TInterface\\CHARACTERFRAME\\UI-Player-PlayTimeTired:0::0:0:64:64:6:58:6:58:0|t", },
      { id = "UNHEALTHY",    icon = "|TInterface\\CHARACTERFRAME\\UI-Player-PlayTimeUnhealthy:0::0:0:64:64:6:58:6:58:0|t", },
      { id = "HAPPYFACE",    icon = "|TInterface\\PetPaperDollFrame\\UI-PetHappiness:0::0:0:128:64:0:23:0:23:0|t", },
      { id = "OKAYFACE",     icon = "|TInterface\\PetPaperDollFrame\\UI-PetHappiness:0::0:0:128:64:24:47:0:23:0|t", },
      { id = "SADFACE",      icon = "|TInterface\\PetPaperDollFrame\\UI-PetHappiness:0::0:0:128:64:48:71:0:23:0|t", },

      -- 36-40
      { id = "PAPER",        icon = "|TInterface\\GossipFrame\\WorkOrderGossipIcon:0|t", },
      { id = "CROWN",        icon = "|TInterface\\GROUPFRAME\\UI-Group-LeaderIcon:0|t", },
      { id = "SHIELD",       icon = "|TInterface\\GROUPFRAME\\UI-GROUP-MAINTANKICON:0|t", },
      { id = "HELM",         icon = "|TInterface\\GUILDFRAME\\GuildLogo-NoLogoSm:0|t", },
      { id = "HAMMER",       icon = "|TInterface\\MINIMAP\\TrapInactive_HammerGold:0|t", },

      -- 41-45
      { id = "QUEST",        icon = "|A:QuestNormal:0:0:|a", },
      { id = "BLUEMEEPLE",   icon = "|TInterface\\FriendsFrame\\UI-Toast-FriendOnlineIcon:0::0:0:64:64:14:50:14:50:16:128:255:0|t", },
      { id = "GREENMEEPLE",  icon = "|TInterface\\FriendsFrame\\UI-Toast-FriendOnlineIcon:0::0:0:64:64:14:50:14:50:16:255:16:0|t", },
      { id = "YELLOWMEEPLE", icon = "|TInterface\\FriendsFrame\\UI-Toast-FriendOnlineIcon:0::0:0:64:64:14:50:14:50:255:255:16:0|t", }, 
      { id = "ORANGEMEEPLE", icon = "|TInterface\\FriendsFrame\\UI-Toast-FriendOnlineIcon:0::0:0:64:64:14:50:14:50:255:128:16:0|t", },

      -- 46-50
      { id = "REDMEEPLE",    icon =  "|TInterface\\FriendsFrame\\UI-Toast-FriendOnlineIcon:0::0:0:64:64:14:50:14:50:255:16:16:0|t", },
      { id = "VIOLETMEEPLE", icon =  "|TInterface\\FriendsFrame\\UI-Toast-FriendOnlineIcon:0::0:0:64:64:14:50:14:50:235:16:235:0|t", },

      { id = "RAINBOWMEEPLE", icon = "|TInterface\\FriendsFrame\\UI-Toast-FriendOnlineIcon:0:0.17:-1:0:64:64:14:19:14:50:16:128:255:0|t"     -- blue 
                                  .. "|TInterface\\FriendsFrame\\UI-Toast-FriendOnlineIcon:0:0.17:-2:0:64:64:20:25:14:50:16:255:16:0|t"     -- green
                                  .. "|TInterface\\FriendsFrame\\UI-Toast-FriendOnlineIcon:0:0.17:-3:0:64:64:26:31:14:50:255:255:16:0|t"    -- yellow
                                  .. "|TInterface\\FriendsFrame\\UI-Toast-FriendOnlineIcon:0:0.17:-4:0:64:64:32:37:14:50:255:128:16:0|t"    -- orange
                                  .. "|TInterface\\FriendsFrame\\UI-Toast-FriendOnlineIcon:0:0.17:-5:0:64:64:38:43:14:50:255:16:16:0|t"     -- red
                                  .. "|TInterface\\FriendsFrame\\UI-Toast-FriendOnlineIcon:0:0.17:-6:0:64:64:44:50:14:50:235:16:235:0|t" }, -- violet


      -- Add new  icons at the end ##

    }, -- /small
    DEFAULT_SMALL = "|TInterface\\FriendsFrame\\UI-Toast-FriendRequestIcon:0::0:0:64:64:14:50:14:50:96:96:96|t",

  }, -- /icons
  COLOR_GREEN = GREEN,
  COLOR_RED   = RED,
  NBSP = "|TInterface\\Store\\ServicesAtlas:0::0:0:1024:1024:1023:1024:1023:1024|t",
  } -- Const

  return "const";
end);  -- startup function
