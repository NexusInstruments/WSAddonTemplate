local PackageName, Major, Minor, Patch = "SimpleUtils", 2, 0, 0
local PkgMajor, PkgMinor = PackageName, tonumber(string.format("%02d%02d%02d", Major, Minor, Patch))
local Pkg = Apollo.GetPackage(PkgMajor)
if Pkg and (Pkg.nVersion or 0) >= PkgMinor then
  return -- no upgrade needed
end


-- Set a reference to the actual package or create an empty table
local SimpleUtils = Pkg and Pkg.tPackage or {}

function SimpleUtils:new(args)
   local new = { }

   if args then
      for key, val in pairs(args) do
         new[key] = val
      end
   end

   return setmetatable(new, SimpleUtils)
end

function string:split(inSplitPattern, outResults)
   if not outResults then
      outResults = { }
   end
   local theStart = 1
   local theSplitStart, theSplitEnd = string.find( self, inSplitPattern, theStart )
   while theSplitStart do
      table.insert( outResults, string.sub( self, theStart, theSplitStart-1 ) )
      theStart = theSplitEnd + 1
      theSplitStart, theSplitEnd = string.find( self, inSplitPattern, theStart )
   end
   table.insert( outResults, string.sub( self, theStart ) )
   return outResults
end

function string:tohexstring(spacer)
  return (
    string.gsub(self,"(.)",
      function (c)
        return string.format("%02X%s",string.byte(c), spacer or "")
      end
    )
  )
end

function shallowcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in pairs(orig) do
            copy[orig_key] = orig_value
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function SimpleUtils:cprint(string)
  ChatSystemLib.PostOnChannel(ChatSystemLib.ChatChannel_Command, string, "")
end

function SimpleUtils:debug(string)
  debugprint(string)
end

function debugprint(string)
  ChatSystemLib.PostOnChannel(ChatSystemLib.ChatChannel_Debug, string, "")
end


function SimpleUtils:pprint(string)
  for _,channel in pairs(ChatSystemLib.GetChannels()) do
    if channel:GetType() == ChatSystemLib.ChatChannel_Party then
      channel:Send(string)
    end
  end
end

-- Print contents of `tbl`, with indentation.
-- `indent` sets the initial level of indentation.
function vardump (tbl, indent)
  if not indent then indent = 0 end
  for k, v in pairs(tbl) do
    formatting = string.rep("  ", indent) .. k .. ": "
    if type(v) == 'table' then
      debugprint(formatting)
      vardump(v, indent+1)
    elseif type(v) == 'boolean' then
      debugprint(formatting .. tostring(v))
    else
      debugprint(formatting .. v)
    end
  end
end

-- Print contents of `tbl`, with indentation to a string
-- `indent` sets the initial level of indentation.
function svardump (tbl, indent)
  local str = ""
  if not indent then indent = 0 end
  for k, v in pairs(tbl) do
    formatting = string.rep("  ", indent) .. k .. ": "
    if type(v) == 'table' then
      str = str .. formatting .. svardump(v, indent+1) .. "\n"
    elseif type(v) == 'boolean' then
      str = str .. formatting .. tostring(v) .. "\n"
    else
      str = str .. formatting .. v .. "\n"
    end
  end
  return str
end

Apollo.RegisterPackage(SimpleUtils, PkgMajor, PkgMinor, {})
