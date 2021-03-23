-- rp:Friends
-- by Oraibi, Moon Guard (US) server
-- ------------------------------------------------------------------------------
-- This work is licensed under the Creative Commons Attribution 4.0 International
-- (CC BY 4.0) license.

local RP_FRIENDS     = RP_FRIENDS;

table.insert(RP_FRIENDS.startup, function(state) -- startup function
  local Utils      = RP_FRIENDS.utils;
  
  if not Utils.text then Utils.text = {}; end;
  local Text = Utils.text;
  
  local loc     = Utils.locale.loc;
  local Config  = Utils.config;
  
        -- function to split a string based on a pattern
  local function split(str, pat)
        local t          = {};
        local fpat       = "(.-)" .. pat;
        local last_end   = 1;
        local s, e, cap  = str:find(fpat, 1)
        while s do if s ~= 1 or cap ~= ""
                      then table.insert(t,cap);
                   end -- if
                   last_end  = e+1;
                   s, e, cap = str:find(fpat, last_end);
                end -- while/do
        if last_end <= #str
           then cap = str:sub(last_end);
                table.insert(t, cap);
           end -- if
        return t;
  end; 
  
        -- matching function
  local function match(s, p) 
        if not s or not p then return false; end;
        return string.find(string.lower(s), string.lower(p)); 
  end; 
  
        -- check if it's a number
  local function isNumber(s) 
        return (tonumber(s) ~= nil); 
  end; 
  
        -- from http://lua-users.org/wiki/StringRecipes
  local function titleCase(str)
        local function tchelper(first, rest) return first:upper()..rest:lower() end
        
         -- Add extra characters to the pattern if you need to. _ and ' are
         --  found in the middle of identifiers and English words.
         -- We must also put %w_' into [%w_'] to make it handle normal stuff
         -- and extra stuff the same.
         -- This also turns hex numbers into, eg. 0Xa7d4
        if not str then return "" end;
        return str:gsub("(%a)([%w_']*)", tchelper)
  end;
  
  local function textTruncate(text, maxLength)
        local ellipse;
  
        if Config("REAL_ELLIPSES") 
           then ellipse = "…" 
           else ellipse = "..." 
           end; -- if
  
        if text:len() > maxLength 
           then text = text:sub(1, maxLength) .. ellipse 
           end; -- if
  
        return text 
  end;
  -- ---------------------------------------------------------------------------------------------------------------------
  
        -- changes multiple [[[these]]] into hilited text
  local function hiliteTags(s, forHTML)
        if not s then return "" end;
        local reset = "|r";
  
        s = s:gsub("%[%[%[",    "|cffdd9922");
        s = s:gsub("%]%]%]",    reset);
        s = s:gsub("%[%[",      RP_FRIENDS.const.RP_COLOR);
        s = s:gsub("%]%]",      reset);

        if forHTML
           then s = s:gsub("(<a [^>]+>.-</a>)", "%[|cff11dd11%1|r%]");
                s = s:gsub("\n\n", "<h3>&nbsp;</h3>");
                s = s:gsub("&nbsp;", RP_FRIENDS.const.NBSP);

           else s = s:gsub("%[", "[" .. RP_FRIENDS.const.APP_COLOR);
                s = s:gsub("%]",        reset .. "]");
        end;

        s = s:gsub("RP_FRIENDS",    loc("APP_NAME"));
        return s;
  end

  
        -- changes normal text into HTML
  local function toHtml(title, body)
        local htmlout;
        body = body:gsub("%[%[%[",""):gsub("%]%]%]",""):gsub("%[%[","|cff00dddd"):gsub("%]%]","|r"):gsub("%[","[|cffdddd00"):gsub("%]","|r]"):gsub("RP_FRIENDS", loc("APP_NAME")):gsub("RPUF", loc("RPUF_NAME")):gsub("\n", "<br/>");
  
        if title then htmlout = string.format("<html><body>><h2>%s</h2><br/><p>%s</p></body></html>", title, body);
                 else htmlout = string.format("<html><body><p>%s</p></body></html>",                   body); end; -- if
        return htmlout;
  end;
  
  -- ---------------------------------------------------------------------------------------------------
  -- 
  -- Function encrypts and decrypts using ROT13
  -- source: https://gist.github.com/obikag/7035680
  --
  local function rot13(str)
    local cipher = { A="N",B="O",C="P",D="Q",E="R",F="S",G="T",H="U",I="V",J="W",K="X",L="Y",M="Z",
                     N="A",O="B",P="C",Q="D",R="E",S="F",T="G",U="H",V="I",W="J",X="K",Y="L",Z="M",
                     a="n",b="o",c="p",d="q",e="r",f="s",g="t",h="u",i="v",j="w",k="x",l="y",m="z",
                     n="a",o="b",p="c",q="d",r="e",s="f",t="g",u="h",v="i",w="j",x="k",y="l",z="m" }
    local estr = ""
    for c in str:gmatch(".") do if (c:match("%a")) then estr = estr..cipher[c] else estr = estr..c end end
    return estr
  end 
  -- ---------------------------------------------------------------------------------------------------
  local function vText()
    return "v" .. RP_FRIENDS.const.VERSION 
  end;

  local function versionText() return 
        string.format(loc("FMT_APP_LOAD"), vText(), loc("APP_SLASH")) end;
  local function changesText() return "v" .. RP_FRIENDS.const.VERSION .. " " .. loc("CHANGES") .. ": " .. loc("APP_CHANGES")                                   end;
  
  local function notify(message)
    local localized = loc(message);
    if localized ~= "" then message = localized end;
    print("[" .. loc("APP_NAME") .. "] " .. hiliteTags(message));
  end;

  -- Utilities available under RP_FRIENDS.utils.text
  --
  Text.hilite    = hiliteTags;
  Text.isnum     = isNumber;
  Text.match     = match;
  Text.rot13     = rot13;
  Text.split     = split;
  Text.html      = toHtml;
  Text.truncate  = textTruncate;
  Text.titlecase = titleCase;
  Text.notify    = notify;
  Text.version   = versionText;
  Text.v         = vText;
  Text.changes   = changesText;

  return "utils-text"

end); -- startup function
