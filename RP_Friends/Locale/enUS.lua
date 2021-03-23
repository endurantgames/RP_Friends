-- ------------------------------------------------------------------------------
-- rp:Friends
-- by Oraibi, Moon Guard (US) server
--
-- Ora's twitter: http://twitter.com/oraibimoonguard
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

--Notices:

--You do not have to comply with the license for elements of the material
--in the public domain or where your use is permitted by an applicable
--exception or limitation.

--No warranties are given. The license may not give you all of the
--permissions necessary for your intended use. For example, other rights
--such as publicity, privacy, or moral rights may limit how you use the material.
-- ------------------------------------------------------------------------------
-- localization done on

local RP_FRIENDS = RP_FRIENDS;

table.insert(RP_FRIENDS.startup, function(state) -- startup function
  local Const  = RP_FRIENDS.const;
  local T_     = Const.icons.T_;
  local _t     = Const.icons._t;
  local Icon   = Const.icons;

  local ICON = "|A:Mobile-Inscription:0:0|a ";

  local Locale = RP_FRIENDS.locale;
  local lang = "enUS";

  local RP               = "rp:";
  local NOCOLOR          = "|r";
  local FRIENDS          = "Friends";

  local APP_COLOR        = Const.APP_COLOR;
  local COLOR_RP         = APP_COLOR .. RP;
  local APP_NAME         = Const.RP_COLOR .. RP .. NOCOLOR .. Const.APP_COLOR .. FRIENDS .. NOCOLOR;

  local FADED = ":0::0:0:64:64:0:64:0:64:64:64:64:0|t"

  local RAINBOW_COLORS   = "|cffff0000C|cffff9900o|cffffff00l|cff00ff00o|cff00ffffr|cffff00ffs|r";

    -- US English localization ------------------------------------------------------------------------------
  Locale[lang] = {
    APP_DESC              = "",
    APP_COLOR_RP          = COLOR_RP,
    APP_NAME              = APP_NAME,
    APP_SLASH             = "/rpfriends",
    APP_SLASH_SHORT       = "/rpfriend",
    APP_SLASH_SHORTER     = "/rpf",
    APP_ID                = Const.APP_ID,
    APP_VERSION           = Const.VERSION,
    APP_CREATOR           = Const.ORAIBI,
    APP_CHANGES           = "Fixed an error where friends wouldn't be properly marked as off WoW; fixed a bug that mistook mobile for desktop and vice versa. [[[Previously:]]] Friend categories added; configure through options.",
    -- APP_CHANGES           = "[[[Friend Categories]]] are stored in your friend notes as tags such as [rp:0123]. Configure through options; set custom name, description, icons. [[Previously:]] Bug fixes.",
    -- APP_CHANGES           = "[[Beta Feature:]] Categories; stored in friend notes. [[[Previously:]]] Bug fix.",
    -- APP_CHANGES           = "Bug fix. [[[Previously:]]] Icons now are located either on the left or the right, or hidden, at the user's option.",
    -- APP_CHANGES           = "Icons now are located either on the left or the right, or hidden, at the user's option. [[[Previously:]]] Added support for favorites, updated for WoW 8.2",
    -- APP_CHANGES           = "Added support for favorites. Hearts, though, not stars. [[[Previously:]]] Updated for WoW 8.20, fixed problems with libraries, made icon magnification level user-set, fixed problem with search, made Blizzard FL button glow if you have a waiting BNet request.",
    -- APP_CHANGES           = "Fixed a bug. [[[Previously:]]] Updated for WoW 8.20, fixed problems with libraries, made icon magnification level user-set, fixed problem with search, made Blizzard FL button glow if you have a waiting BNet request.",
    -- APP_CHANGES           = "Fixed bug related to trp3. [[[Previously:]]] Updated for WoW 8.20, fixed problems with libraries, made icon magnification level user-set, fixed problem with search, made Blizzard FL button glow if you have a waiting BNet request.",
    -- APP_CHANGES           = "Updated for WoW 8.20, fixed problems with libraries, made icon magnification level user-set, fixed problem with search, made Blizzard FL button glow if you have a waiting BNet request. [[[Previously:]]] Bug fixes.",
    --                      "[[[Previously:]]] Added minimap button; customized " .. RAINBOW_COLORS:lower() .. ", improved options screen. ",
    --                      "[[[Previously:]]] Set friendslist color, scale; clickable columns; BNet broadcast editor; bug fixes.",
    -- APP_CHANGES           = "Set friendslist color and scale; a lot more clickable columns, e.g., control-click icon to open profile; improved BNet broadcast editor; bug fixes. [[Previously:]] Added click-to-open-profile, added click-to-see-icon, added IC/OOC toggle, fixed sorting bug, fixed window-closing bugs.",
    -- APP_CHANGES           = "Added control-click-to-hide-column, added click-to-set-note, minor bug fixes. [[Previously:]] Added click-to-open-profile, added click-to-see-icon, added IC/OOC toggle, fixed sorting bug, fixed window-closing bugs.",
    -- APP_CHANGES           = "Added click-to-open-profile, added click-to-see-icon, added IC/OOC toggle, fixed sorting bug, fixed window-closing bugs. [[Previously:]] 'Add Friend' button, added resizing-by-drag, fixed searching, made the size collapse better, behind-the-scenes changes, line highlighted on mouseover, display additional selected fields in tooltip, bug fixes.",
    -- APP_CHANGES           = "Fixed sorting bug, fixed window-closing bugs. [[Previously:]] 'Add Friend' button, added resizing-by-drag, fixed searching, made the size collapse better, behind-the-scenes changes, line highlighted on mouseover, display additional selected fields in tooltip, bug fixes.",
    -- APP_CHANGES           = "'Add Friend' button, added resizing-by-drag, fixed searching, made the size collapse better, fixed sorting, behind-the-scenes changes, line highlighted on mouseover, display additional selected fields in tooltip, bug fixes.",
    -- APP_CHANGES           = "First public beta release! RP fields, searching, icons, etc, all works. [[[To Do:]]] 'Add Friend' button, some bug fixes, explanation text on options page, improvements to broadcast frame.",

    -- APP_CHANGES           = "Searching completed. [[To Do:]] RP field support, appearance customization.",
    -- APP_CHANGES           = "Updated to include server-level friends and not just BattleNet; bug fixes. [[[To Do:]]] RP field support, searching, appearance customization. [[Previously:]] Newly created!",

    -- ------------------ -
    CHANGES               = "Changes",

    OPT_MENU_MAIN      = APP_NAME,
    OPT_PAGE_MAIN      = APP_NAME .." General Settings",
    OPT_DESC_MAIN      = "These options control the basic functionality of RP_FRIENDS.",

    OPT_MENU_COLUMNS   = APP_NAME .. " Columns",
    OPT_PAGE_COLUMNS   = APP_NAME .. " Columns",
    OPT_DESC_MAIN      = [===[
<html>
  <body>
    <h1>Options</h1>

    <p>These options let you choose how you want RP_FRIENDS to display your friendslist, as well as additional choices such as login messages
       and buttons.
    </p>

    <h1>Colors</h1>

    <p>There are two content colors you can set; one is for columns specifically related to roleplaying, and the other is for more mundane columns such as
       OOC character name. (BattleNet fields are always displayed in |cff82c5ffBattleNet Blue|r.)
    </p>

    <h1>Columns</h1>

    <p>On the <a href="config:columns">next options page</a>, you can set which columns you want to be displayed.
    </p>

    <p>Columns which only display icons are noted with a (|A:Mobile-Inscription:0:0|a) symbol, although you can still mouseover the icons to read the 
       information in the tooltips.</p>

    <h1>Resetting Options</h1>

    <p>You can reset the options shown on each page by clicking on the red 'Defaults' button in the lower left corner.</p>

    <h1>Getting Help</h1>

    <p>If you need help, you can contact |cffbb00bbOraibi|r on the Moon Guard server,
       or visit <a href="http://discord.gg/zGPP9x9">our Discord server</a>. Oraibi's
       twitter is <a href="http://twitter.com/oraibimoonguard">@OraibiMoonGuard</a>.</p>

  </body>
</html>
]===],
    H1_COLORS             = RAINBOW_COLORS,
    FMT_APP_LOAD          = "%s loaded. Type [[[%s]]] for options.",
    KEYBIND_OPEN_EDITOR   = "Open " .. APP_NAME .. " Editor",
    -- bar textures         -
    BLANK                 = "Blank",
    SHADED                = "Shaded",
    SOLID                   = "Solid",
    BAR                     = "Progress Bar",
    SKILLS                  = "Skills Bar",
    RAID                    = "Raid Bar",
    -- alignment
    TOPLEFT                 = "Top Left",
    TOPRIGHT                = "Top Right",
    BOTTOMRIGHT             = "Bottom Right",
    BOTTOMLEFT              = "Bottom Left",
    TOP                     = "Top",
    BOTTOM                  = "Bottom",
    CENTER                  = "Center",
    LEFT                    = "Left",
    RIGHT                   = "Right",
    HORIZONTAL              = "Horizontal",
    VERTICAL                = "Vertical",
    CONTEXT_MENU_TITLE      = "Choose an Option",
    CANCEL                  = "Cancel",
    RESET                   = "Reset Now",
    MORE                    = "More ...",

    FMT_HTML                = "<html><body><p>%s</p></body></html>",
    INTRO_DESC              = "These options let you choose how you want RP_FRIENDS to display your friendslist, " ..
                              "as well as additional choices such as login messages and buttons.",
    INTRO_COLORS            = "There are two content colors you can set; one is for columns specifically related to roleplaying, " ..
                              "and the other is for more mundane columns such as OOC character name. " ..
                              "(BattleNet fields are always displayed in |cff82c5ffBattleNet Blue|r.)",
    INTRO_COLUMNS           = "You can select which columns you would like to display. They are displayed in the same order as these checkboxes.",
    INTRO_ICONS             = "You can select which icons you would like to display. Icons displayed on the left are shown before other columns, and " ..
                              "icons displayed on the right are shown after other columns.",
    INTRO_RESET             = "You can reset the options shown on each page by clicking on the red 'Defaults' button in the lower left corner.",
    INTRO_HELP              = "If you need help, you can contact |cffbb00bbOraibi|r on the Moon Guard server, " ..
                              "or visit <a href='http://discord.gg/zGPP9x9'>our Discord server</a>. Oraibi's "  ..
                              "twitter is <a href='http://twitter.com/oraibimoonguard'>@OraibiMoonGuard</a>.",

    INTRO_CATEGORY          = "You can assign your friends to various categories. These options let you change the icons, names, and descriptions of " ..
                              "all categories. Press enter to save your text entries.", 
    ABOUT_TEXT              = [===[
<h1>About RPFRIENDS</h1>

<p>If you need help, you can contact |cffbb00bbOraibi|r on the Moon Guard server, 
   or visit <a href='http://discord.gg/zGPP9x9'>our Discord server</a>. Oraibi's 
   twitter is <a href='http://twitter.com/oraibimoonguard'>@OraibiMoonGuard</a>.
</p>
]===],
    H1_BATTLENET            = BATTLENET_FONT_COLOR_CODE .. "BattleNet" .. "|r",
    H1_NAME                 = "Names",
    H1_STATUS               = "Status",
    H1_SERVER               = "Server",
    H1_FACTION              = "Faction",
    H1_RACE_CLASS           = "Race and Class",
    H1_MISC                 = "Other Columns",
    H1_NOTES                = "Notes",

    CONFIG_SHOW_OTHER_BLIZZ_GAMES = "Show Other Blizzard Games on Toolbar",
    CONFIG_SHOW_OTHER_BLIZZ_GAMES_TT = "Check to show buttons for other games -- Overwatch, Diablo III, etc. -- on the RP_FRIENDS toolbar. If you disable this button, you won't see any BattleNet friends playing those games.",

    CONFIG_ALPHA               = "Transparency",
    CONFIG_ALPHA_TT            = "Set the transparency of the friendslist background.",
    CONFIG_COLOR_BACKDROP      = "Background",
    CONFIG_COLOR_BACKDROP_TT   = "Set the background color of the friendslist.",
    CONFIG_COLOR_DEFAULT       = "Default Color",
    CONFIG_COLOR_DEFAULT_TT    = "Set the color used for game fields, such as OOC name.",
    CONFIG_COLOR_RP            = "Roleplay Color",
    CONFIG_COLOR_RP_TT         = "Set the color used for roleplaying fields, such as IC name.",
    CONFIG_COLOR_BN            = "BattleNet Color",
    CONFIG_COLOR_BN_TT         = "The BattleNet color is fixed and can't be changed. Sorry!",
    CONFIG_SCALE               = "Frame Scale",
    CONFIG_SCALE_TT            = "Set the scaling of the friendlist frame.\n\n|cffdd1111Note:|r Changing this option will most likely move your friendslist window around on your screen. This is harmless; just move it back where you want it to be.",

    CONFIG_ICON_ZOOM           = "Icon Zoom",
    CONFIG_ICON_ZOOM_TT        = "Choose the magnification factor when you click to view an icon.",

--  CONFIG_COLUMN_AGE             = "Age",
--  CONFIG_COLUMN_AGE_TT          = "The character's age. (RP)",
    CONFIG_COLUMN_BATTLETAG       = "BattleTag",
    CONFIG_COLUMN_BATTLETAG_TT    = "The player's BattleNet ID.",
    CONFIG_COLUMN_BTAG_BROADCAST  = "Broadcast",
    CONFIG_COLUMN_BTAG_BROADCAST_TT  = "The player's BattleNet broadcast message.",
    CONFIG_COLUMN_BTAG_NOTE       = "Friend Note",
    CONFIG_COLUMN_BTAG_NOTE_TT    = "The note that you set on the character or the player.",
    CONFIG_COLUMN_CLASS           = "RP Class",
    CONFIG_COLUMN_CLASS_TT        = "The character's class. (RP)",
    CONFIG_COLUMN_CATEGORY        = "Category",
    CONFIG_COLUMN_CATEGORY_TT     = "The first category to which you have assigned this friend.",
    CONFIG_COLUMN_CURR            = "Currently",
    CONFIG_COLUMN_CURR_TT         = "What the character is currently doing. (RP)",
    CONFIG_COLUMN_FACTION         = "Faction Name",
    CONFIG_COLUMN_FACTION_TT      = "Alliance or Horde.",
    CONFIG_COLUMN_GAME            = "Blizzard Game",
    CONFIG_COLUMN_GAME_TT         = "The game that your friend is currently playing.",
    CONFIG_COLUMN_GAMECLASS       = "Class",
    CONFIG_COLUMN_GAMECLASS_TT    = "The character's class. (Non-RP)",
    CONFIG_COLUMN_GAMENAME        = "Name",
    CONFIG_COLUMN_GAMENAME_TT     = "The character's name. (Non-RP)",
    CONFIG_COLUMN_GAMERACE        = "Race",
    CONFIG_COLUMN_GAMERACE_TT     = "The character's race. (Non-RP)",
    CONFIG_COLUMN_HONORIFIC       = "Honorific",
    CONFIG_COLUMN_HONORIFIC_TT    = "The character's 'honorific' or title, such as Dr., Ser, Lady, etc.",
    CONFIG_COLUMN_LEVEL           = "Level",
    CONFIG_COLUMN_LEVEL_TT        = "The character's level. (Non-RP)",
    CONFIG_COLUMN_LOCATION        = "Zone",
    CONFIG_COLUMN_LOCATION_TT     = "The in-game location of the character.",
    CONFIG_COLUMN_NAME            = "Character Name",
    CONFIG_COLUMN_NAME_TT         = "The name of the character. (RP)",
    CONFIG_COLUMN_NICKNAME        = "Nickname",
    CONFIG_COLUMN_NICKNAME_TT     = "The character's nickname. (RP)",
    CONFIG_COLUMN_NOTE            = "Friend Note",
    CONFIG_COLUMN_NOTE_TT         = "The note that you set on the character or the player.",
    CONFIG_COLUMN_OOCINFO         = "OOC Info",
    CONFIG_COLUMN_OOCINFO_TT      = "Out-of-character information about the character. (RP)",
    CONFIG_COLUMN_RACE            = "RP Race",
    CONFIG_COLUMN_RACE_TT         = "The character's race. (RP)",
    CONFIG_COLUMN_SERVER_NAME     = "Server Name",
    CONFIG_COLUMN_SERVER_NAME_TT  = "The name of the server.",
    CONFIG_COLUMN_SERVER_TYPE     = "Server Type",
    CONFIG_COLUMN_SERVER_TYPE_TT  = "RP or PVE.",
    CONFIG_COLUMN_STATUS          = "RP Status",
    CONFIG_COLUMN_STATUS_TT       = "IC or OOC. (RP)",
    CONFIG_COLUMN_TITLE           = "Title",
    CONFIG_COLUMN_TITLE_TT        = "The character's long title, such as 'Stormwind Fashion Icon' or 'Warchief of the Horde'. (RP)",

    CONFIG_ICON_BTAG_BROADCAST    = ICON .. "Broadcast",
    CONFIG_ICON_BTAG_BROADCAST_TT = "An icon if the player has their BattleNet broadcast message set.",
    CONFIG_ICON_CURR              = ICON .. "Currently",
    CONFIG_ICON_CURR_TT           = "An icon indicating that someone has a 'Currently' (green) or 'OOC Info' set (blue), or both (violet).",
    CONFIG_ICON_FACTION           = ICON .. "Faction",
    CONFIG_ICON_FACTION_TT        = "Alliance or Horde.",
    CONFIG_ICON_FAVORITE          = ICON .. "Favorite",
    CONFIG_ICON_FAVORITE_TT       = "An icon if you have designed the player as one of your favorites.",
    CONFIG_ICON_GAME              = ICON .. "Game",
    CONFIG_ICON_GAME_TT           = "The game that your friend is currently playing.",
    CONFIG_ICON_GAMECLASS         = ICON .. "Class",
    CONFIG_ICON_GAMECLASS_TT      = "Icon for the character's class. (Non-RP)",
    CONFIG_ICON_GAMESTATUS        = ICON .."Game Status",
    CONFIG_ICON_GAMESTATUS_TT     = "An icon if your friend is AFK or DND, otherwise blank.",
    CONFIG_ICON_GENDER            = ICON .. "Gender",
    CONFIG_ICON_GENDER_TT         = "An icon showing the character's gender. (RP)",
    CONFIG_ICON_ICON              = ICON .. "Profile",
    CONFIG_ICON_ICON_TT           = "The character's custom icon. (RP)",
    CONFIG_ICON_NOTE              = ICON .. "Friend Note",
    CONFIG_ICON_NOTE_TT           = "An icon to indicate if you've set a note on the character or player.",
    CONFIG_ICON_SERVER            = ICON .. "Server",
    CONFIG_ICON_SERVER_TT         = "An icon representing whether the character's server is RP or PVE.",
    CONFIG_ICON_STATUS            = ICON .. "RP Status",
    CONFIG_ICON_STATUS_TT         = "An icon representing IC or OOC. (RP)",
    CONFIG_ICON_CATEGORY          = ICON .. "Category",
    CONFIG_ICON_CATEGORY_TT       = "The icon for the first category that this friend belongs to.",

    OPTIONS_ARE_RESET = "All RP_FRIENDS options have been reset to their default values.",

    ICONPOS_LEFT    = "|cff66ddddLeft|r",
    ICONPOS_INLINE  = "|cff11dd66Middle|r",
    ICONPOS_RIGHT   = "|cffdddd66Right|r",
    ICONPOS_HIDE    = "|cffdd9911Don't Show|r",

--  COL_AGE         = "Age",
    COL_BATTLETAG   = "BattleTag",
    COL_BTAG_BROADCAST = "Broadcast",
    COL_CATEGORY    = "Category",
    COL_CLASS       = "Class",
    COL_CURR        = "Currently",
    COL_FACTION     = "Faction",
    COL_GAME        = "Game",
    COL_GAMECLASS   = "Class",
    COL_GAMENAME    = "Name",
    COL_GAMERACE    = "Race",
    COL_HONORIFIC   = "",
    COL_LEVEL       = "Level",
    COL_LOCATION    = "Zone",
    COL_NAME        = "Name",
    COL_NICKNAME    = "Nickname",
    COL_NOTE        = "Friend Note",
    COL_OOCINFO     = "OOC Info",
    COL_RACE        = "Race",
    COL_SERVER_NAME = "Server",
    COL_SERVER_TYPE = "Type",
    COL_STATUS      = "Status",
    COL_TITLE       = "Title",

    -- Client names
    CLIENT_WOW      = "WoW",
    CLIENT_BSAP     = "Mobile",
    CLIENT_APP      = "BattleNet",
    CLIENT_S2       = "StarCraft2",
    CLIENT_S1       = "StarCraft",
    CLIENT_D3       = "Diablo3",
    CLIENT_WTCG     = "WTCG",
    CLIENT_PRO      = "Overwatch",
    CLIENT_CLNT     = "CLNT",
    CLIENT_DST2     = "Destiny2",
    CLIENT_VIPR     = "CoD 4",
    CLIENT_HERO     = "HotS",
    CLIENT_DISCONNECT = "Offline",

    INCLUDE_WOW_ON_TT      = "Click to |cffdd2222hide|r friends playing World of Warcraft",
    INCLUDE_APP_ON_TT      = "Click to |cffdd2222hide|r friends on the Mobile BattleNet client",
    INCLUDE_BSAP_ON_TT     = "Click to |cffdd2222hide|r friends on the Desktop BattleNet client",
    INCLUDE_S2_ON_TT       = "Click to |cffdd2222hide|r Battlenet Friends playing StarCraft2",
    INCLUDE_S1_ON_TT       = "Click to |cffdd2222hide|r BattleNet Friends playing StarCraft",
    INCLUDE_D3_ON_TT       = "Click to |cffdd2222hide|r BattleNet Friends playing Diablo3",
    INCLUDE_WTCG_ON_TT     = "Click to |cffdd2222hide|r BattleNet Friends playing Hearthstone",
    INCLUDE_PRO_ON_TT      = "Click to |cffdd2222hide|r BattleNet Friends playing Overwatch",
    INCLUDE_CLNT_ON_TT     = "Click to |cffdd2222hide|r BattleNet Friends playing CLNT",
    INCLUDE_DST2_ON_TT     = "Click to |cffdd2222hide|r BattleNet Friends playing Destiny 2",
    INCLUDE_VIPR_ON_TT     = "Click to |cffdd2222hide|r BattleNet Friends playing Call of Duty",
    INCLUDE_HERO_ON_TT     = "Click to |cffdd2222hide|r BattleNet Friends playing Heroes of the Storm",
    INCLUDE_DISCONNECT_ON_TT = "Click to |cffdd2222hide|r Offline Friends",
    -- ##

    INCLUDE_WOW_OFF_TT      = "Click to |cff22dd22show|r friends playing World of Warcraft",
    INCLUDE_APP_OFF_TT      = "Click to |cff22dd22show|r friends on the Mobile BattleNet client",
    INCLUDE_BSAP_OFF_TT     = "Click to |cff22dd22show|r friends on the Desktop BattleNet client",
    INCLUDE_S2_OFF_TT       = "Click to |cff22dd22show|r Battlenet Friends playing StarCraft2",
    INCLUDE_S1_OFF_TT       = "Click to |cff22dd22show|r BattleNet Friends playing StarCraft",
    INCLUDE_D3_OFF_TT       = "Click to |cff22dd22show|r BattleNet Friends playing Diablo3",
    INCLUDE_WTCG_OFF_TT     = "Click to |cff22dd22show|r BattleNet Friends playing Hearthstone",
    INCLUDE_PRO_OFF_TT      = "Click to |cff22dd22show|r BattleNet Friends playing Overwatch",
    INCLUDE_CLNT_OFF_TT     = "Click to |cff22dd22show|r BattleNet Friends playing CLNT",
    INCLUDE_DST2_OFF_TT     = "Click to |cff22dd22show|r BattleNet Friends playing Destiny 2",
    INCLUDE_VIPR_OFF_TT     = "Click to |cff22dd22show|r BattleNet Friends playing Call of Duty",
    INCLUDE_HERO_OFF_TT     = "Click to |cff22dd22show|r BattleNet Friends playing Heroes of the Storm",
    INCLUDE_DISCONNECT_OFF_TT = "Click to |cff22dd22show|r Offline Friends",

    INCLUDE_WOW_CTRL_TT      = "Control-click to show friends playing World of Warcraft and hide all other friends",
    INCLUDE_APP_CTRL_TT      = "Control-click to show friends on the Mobile Battlenet client and hide all other friends",
    INCLUDE_BSAP_CTRL_TT     = "Control-click to show friends on the Desktop Battlenet client and hide all other friends",
    INCLUDE_S2_CTRL_TT       = "Control-click to show friends playing StarCraft2 and hide all other friends",
    INCLUDE_S1_CTRL_TT       = "Control-click to show friends playing StarCraft and hide all other friends",
    INCLUDE_D3_CTRL_TT       = "Control-click to show friends playing Diablo3 and hide all other friends",
    INCLUDE_WTCG_CTRL_TT     = "Control-click to show friends playing Hearthstone and hide all other friends",
    INCLUDE_PRO_CTRL_TT      = "Control-click to show friends playing Overwatch and hide all other friends",
    INCLUDE_CLNT_CTRL_TT     = "Control-click to show friends playing CLNT and hide all other friends",
    INCLUDE_DST2_CTRL_TT     = "Control-click to show friends playing Destiny 2 and hide all other friends",
    INCLUDE_VIPR_CTRL_TT     = "Control-click to show friends playing Call of Duty and hide all other friends",
    INCLUDE_HERO_CTRL_TT     = "Control-click to show friends playing Heroes of the Storm and hide all other friends",
    INCLUDE_DISCONNECT_CTRL_TT = "Control-click to show offline friends and hide all other friends",
    --

    ALSO_SHOW_OFF_SERVER_ON = "All Servers",
    ALSO_SHOW_OFF_SERVER_ON_TT = "Click to restrict to |cffdd2222only|r show friends on this server.",
    ALSO_SHOW_OFF_SERVER_OFF = "Only This Server",
    ALSO_SHOW_OFF_SERVER_OFF_TT = "Click to show friends from |cff22dd22all|r servers.",

    SEARCH = "SEARCH",
    SEARCH_TT = "Enter at least three characters to do a full-text search of your friends. RP fields will only be searched for online friends.",
    --
    -- ##
    KEYBIND_FRIENDSLIST = "Open rp:FriendsList",
    KEYBIND_OPTIONS = "Options Page",

    -- other addons
    ADDON_MRP             = "MyRolePlay",
    ADDON_TRP3            = "Total RP 3",
    ADDON_XRP             = "XRP",

    -- Defaults for Categories
    CAT0 = "Friend",        CAT0_ICON = 33, CAT0_DIGIT = "0", CAT0_DESC = "In-character friend", 
    CAT1 = "Acquainted",    CAT1_ICON = 34, CAT1_DIGIT = "1", CAT1_DESC = "In-character acquaintance", 
    CAT2 = "Enemy",         CAT2_ICON = 35, CAT2_DIGIT = "2", CAT2_DESC = "In-character enemy",
    CAT3 = "Family",        CAT3_ICON = 13, CAT3_DIGIT = "3", CAT3_DESC = "In-character family member",
    CAT4 = "Business",      CAT4_ICON =  2, CAT4_DIGIT = "3", CAT4_DESC = "In-character business contact",

    CAT5 = "Storyteller",   CAT5_ICON = 37, CAT5_DIGIT = "5", CAT5_DESC = "Roleplay organizer",
    CAT6 = "IRL",           CAT6_ICON =  7, CAT6_DIGIT = "6", CAT6_DESC = "Friend from real life",
    CAT7 = "Raider",        CAT7_ICON = 38, CAT7_DIGIT = "7", CAT7_DESC = "Friend from raiding",
    CAT8 = "PVPer",         CAT8_ICON = 29, CAT8_DIGIT = "8", CAT8_DESC = "Friend from PVP",
    CAT9 = "Quester",       CAT9_ICON = 41, CAT9_DIGIT = "9", CAT9_DESC = "Friend from questing",

    CATA = "Crafting",      CATA_ICON = 40, CATA_DIGIT = "a", CATA_DESC = "Crafter",
    CATB = "Custom 1",      CATB_ICON = 42, CATB_DIGIT = "b", CATB_DESC = "Custom field",
    CATC = "Custom 2",      CATC_ICON = 43, CATC_DIGIT = "c", CATC_DESC = "Custom field",
    CATD = "Custom 3",      CATD_ICON = 44, CATD_DIGIT = "d", CATD_DESC = "Custom field",
    CATE = "Custom 4",      CATE_ICON = 45, CATE_DIGIT = "e", CATE_DESC = "Custom field",

    CATF = "Custom 5",      CATF_ICON = 46, CATF_DIGIT = "f", CATF_DESC = "Custom field",
  }


  return "enUS";
end); -- startup function
