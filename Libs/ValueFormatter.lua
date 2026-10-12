--- @type LibPrettyPrint_Namespace
local ns = select(2, ...).LibPrettyPrint; if not ns then return end

--[[-------------------------------------------------------------------
Types
---------------------------------------------------------------------]]
--- @alias LibPrettyPrint_ValueFormatFn fun(val:any, colors:LibPrettyPrint_KeyValueColors): string

--[[-------------------------------------------------------------------
Library: ValueFormatter
---------------------------------------------------------------------]]
--- Formats a key/value entry's value, by type()
--- @class LibPrettyPrint_ValueFormatter
local o = {}; ns:register(ns.M.ValueFormatter, o)

--[[-------------------------------------------------------------------
Support Functions
---------------------------------------------------------------------]]
--- @param text string
--- @return string
local function identity(text) return text end

--- Colors the tostring() of {val} by its type
--- @param val any
--- @param colors LibPrettyPrint_KeyValueColors
--- @return string
local function plainValue(val, colors)
  local colorFn = colors.values[type(val)] or identity
  return colorFn(tostring(val))
end

--- `<function>`, `<table>` like DevTools_Dump; addresses are noise
--- @param val any
--- @param colors LibPrettyPrint_KeyValueColors
--- @return string
local function typeTag(val, colors)
  local t = type(val)
  local colorFn = colors.values[t] or identity
  return colorFn('<' .. t .. '>')
end

--- @type table<string, LibPrettyPrint_ValueFormatFn>
local formatters = {
  ['string'] = function(val, colors)
    local text = colors.quote and ("'" .. val .. "'") or val
    local colorFn = colors.values['string'] or identity
    return colorFn(text)
  end,
  ['number'] = plainValue,
  ['function'] = typeTag,
  ['table'] = typeTag,
}

--[[-------------------------------------------------------------------
Methods
---------------------------------------------------------------------]]
--- @param val any
--- @param colors LibPrettyPrint_KeyValueColors
--- @return string
function o:Format(val, colors)
  local formatter = formatters[type(val)] or plainValue
  return formatter(val, colors)
end
