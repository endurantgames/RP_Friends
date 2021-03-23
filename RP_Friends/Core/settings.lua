-- rp:Friends
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
  local CYAN              = "ff3399";
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

  local RESET             = "|r";
  local MALE              = 2;
  local NEUTER            = 1;
  local FEMALE            = 3 ;
  local THEY              = 8675309; -- this is a custom number used internally
  local GENDER_UNKNOWN    = 5552368; -- also a custom number
  local GENDER_DEFAULT    = NEUTER;

  local loc               = RP_FRIENDS.utils.locale.loc;
  
  RP_FRIENDS.const.CONFIG = { 
    DEFAULTS = {  
      COLOR_DEFAULT      = "fff2bf",
      COLOR_BN           = "82c5ff",
      COLOR_RP           = "1ae61a",
      COLOR_BACKDROP     = "000000",
      ALPHA              = 0.65,
      SCALE              = 1,
      BUTTON             = true, -- on by default
      CHANGES_MESSAGE    = true, -- on by default
      LOGIN_MESSAGE      = true, -- on by default
      ICON_ZOOM          = 3,

      -- --------------- - Things we can get from bnet
        --

      COLUMN_AGE            = false,
      COLUMN_BATTLETAG      = true,  -- shown by default
      COLUMN_BTAG_BROADCAST = false,
      COLUMN_BTAG_NOTE      = false,
      COLUMN_CLASS          = false,
      COLUMN_CATEGORY       = false,
      COLUMN_CURR           = false,
      COLUMN_FACTION        = true,  -- shown by default
      COLUMN_GAME           = false,
      COLUMN_GAMECLASS      = false,
      COLUMN_GAMENAME       = false,
      COLUMN_GAMERACE       = false,
      COLUMN_HONORIFIC      = false,
      COLUMN_LEVEL          = true,  -- shown by default
      COLUMN_LOCATION       = false,
      COLUMN_NAME           = true,  -- shown by default
      COLUMN_NICKNAME       = false,
      COLUMN_NOTE           = false,
      COLUMN_OOCINFO        = false,
      COLUMN_RACE           = false,
      COLUMN_SERVER_NAME    = true,  -- shown by default
      COLUMN_SERVER_TYPE    = false,
      COLUMN_STATUS         = false,
      COLUMN_TITLE          = false,

      -- Icons
      ICON_FAVORITE         = "LEFT",
      ICON_BTAG_BROADCAST   = "RIGHT",
      ICON_CURR             = "RIGHT",
      ICON_FACTION          = "HIDE",
      ICON_GAME             = "LEFT",
      ICON_GAMECLASS        = "HIDE",
      ICON_GAMESTATUS       = "HIDE",
      ICON_GENDER           = "HIDE",
      ICON_ICON             = "HIDE",
      ICON_NOTE             = "RIGHT",
      ICON_SERVER           = "HIDE",
      ICON_STATUS           = "HIDE",
      ICON_CATEGORY         = "LEFT",

      -- ---------------- - configuration for the button bar
      SHOW_OTHER_BLIZZ_GAMES = false,

      INCLUDE_WOW         = true,  -- included by default
      INCLUDE_BSAP        = false, 
      INCLUDE_APP         = false,
      INCLUDE_DISCONNECT  = false,
      INCLUDE_D3          = false,
      INCLUDE_PRO         = false,
      INCLUDE_VIPR        = false,
      INCLUDE_S2          = false,
      INCLUDE_S1          = false,
      INCLUDE_WTCG        = false,
      INCLUDE_HERO        = false,
      INCLUDE_DST2        = false,

      BUTTON_ON_FRIENDSLIST = true,  -- shown by default

      ALSO_SHOW_OFF_SERVER = true,   -- included by default

      -- ---------------- - broadcast bar
      BCAST_BNET          = true,
      BCAST_CURR          = false,
      BCAST_INFO          = false,

      -- categories
      CAT0                = loc("CAT0"), CAT0_DESC = loc("CAT0_DESC"), CAT0_ICON = loc("CAT0_ICON"),
      CAT1                = loc("CAT1"), CAT1_DESC = loc("CAT1_DESC"), CAT1_ICON = loc("CAT1_ICON"),
      CAT2                = loc("CAT2"), CAT2_DESC = loc("CAT2_DESC"), CAT2_ICON = loc("CAT2_ICON"),
      CAT3                = loc("CAT3"), CAT3_DESC = loc("CAT3_DESC"), CAT3_ICON = loc("CAT3_ICON"),
      CAT4                = loc("CAT4"), CAT4_DESC = loc("CAT4_DESC"), CAT4_ICON = loc("CAT4_ICON"),
      CAT5                = loc("CAT5"), CAT5_DESC = loc("CAT5_DESC"), CAT5_ICON = loc("CAT5_ICON"),
      CAT6                = loc("CAT6"), CAT6_DESC = loc("CAT6_DESC"), CAT6_ICON = loc("CAT6_ICON"),
      CAT7                = loc("CAT7"), CAT7_DESC = loc("CAT7_DESC"), CAT7_ICON = loc("CAT7_ICON"),
      CAT8                = loc("CAT8"), CAT8_DESC = loc("CAT8_DESC"), CAT8_ICON = loc("CAT8_ICON"),
      CAT9                = loc("CAT9"), CAT9_DESC = loc("CAT9_DESC"), CAT9_ICON = loc("CAT9_ICON"),
      CATA                = loc("CATA"), CATA_DESC = loc("CATA_DESC"), CATA_ICON = loc("CATA_ICON"),
      CATB                = loc("CATB"), CATB_DESC = loc("CATB_DESC"), CATB_ICON = loc("CATB_ICON"),
      CATC                = loc("CATC"), CATC_DESC = loc("CATC_DESC"), CATC_ICON = loc("CATC_ICON"),
      CATD                = loc("CATD"), CATD_DESC = loc("CATD_DESC"), CATD_ICON = loc("CATD_ICON"),
      CATE                = loc("CATE"), CATE_DESC = loc("CATE_DESC"), CATE_ICON = loc("CATE_ICON"),
      CATF                = loc("CATF"), CATF_DESC = loc("CATF_DESC"), CATF_ICON = loc("CATF_ICON"),

      CAT_FILTER          = "",

    }, 
  } -- config

  return "settings";
end);  -- startup function
