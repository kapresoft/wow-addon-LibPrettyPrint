--- @type LibPrettyPrint_Namespace
local ns = select(2, ...).LibPrettyPrint; if not ns then return end
local ValueFormatter = ns.O.ValueFormatter

--[[-------------------------------------------------------------------
Local Vars
---------------------------------------------------------------------]]
--- @type LibPrettyPrint_FormatterConfig
local DEFAULT_CONFIG = {
  multiline_tables = false,
  show_all = true,
  depth_limit = 1,
  key_values = false,
  key_values_type_colors = true,
}
local EMPTY_TABLE = '{}'
local KEY_RANK = { ['number'] = 1, ['string'] = 2 }
local OTHER_KEY_RANK = 3
--- Event Trace's argument colors, by type()
local TYPE_COLORS = {
  ['string'] = '1AFF1A', -- GREEN_FONT_COLOR
  ['number'] = 'FF8040', -- ORANGE_FONT_COLOR
  ['boolean'] = '00CCFF', -- BRIGHTBLUE_FONT_COLOR
  ['table'] = 'FFFF99', -- LIGHTYELLOW_FONT_COLOR
  ['function'] = 'FFFFFF', -- HIGHLIGHT_FONT_COLOR
  ['userdata'] = 'FFFFFF', -- HIGHLIGHT_FONT_COLOR
}
--[[-------------------------------------------------------------------
Library: Formatter
---------------------------------------------------------------------]]

--- @class LibPrettyPrint_KeyValueColors
--- @field key fun(text:string): string
--- @field values table<string, fun(text:string): string> @By type()
--- @field quote boolean                                 @Quote string values

--- @class LibPrettyPrint_FormatterImpl : LibPrettyPrint_FormatterInterface
--- @field private pprint LibPrettyPrint_pprint
local S = {}; ns:register(ns.M.Formatter, S)
S.__index = S
S.__type = 'LibPrettyPrint_Formatter'
--- @param self LibPrettyPrint_Formatter
S.__call = function(self, ...) return self:format(...) end

-- static field
S.pprint = ns.O.pprint

--[[-------------------------------------------------------------------
Support Functions
---------------------------------------------------------------------]]
--- @param k any
--- @return number
local function keyRank(k) return KEY_RANK[type(k)] or OTHER_KEY_RANK end

--- Number keys first, then strings, then any other key type
--- @return boolean
local function compareKeys(a, b)
  local ra, rb = keyRank(a), keyRank(b)
  if ra ~= rb then return ra < rb end
  if ra == OTHER_KEY_RANK then return tostring(a) < tostring(b) end
  return a < b
end

--- @param tbl table
--- @return any[]
local function sortedKeys(tbl)
  local keys = {}
  for k in pairs(tbl) do
    keys[#keys + 1] = k
  end
  table.sort(keys, compareKeys)
  return keys
end

--- @param out LibPrettyPrint_PackedArgs
--- @param val any
local function push(out, val)
  out.n = out.n + 1
  out[out.n] = val
end

--- @param text string
--- @return string
local function identity(text) return text end

--- @param hex? LibPrettyPrint_RGBHex
--- @return fun(text:string): string
local function colorFnOrIdentity(hex)
  if not hex then return identity end
  return ns:colorFn(hex)
end

--- Type colors if enabled; table_ref/cutoff colors override them
--- @param config LibPrettyPrint_FormatterConfig
--- @return table<string, fun(text:string): string>
local function valueColors(config)
  local hexByType = {}
  if config.key_values_type_colors then
    for t, hex in pairs(TYPE_COLORS) do
      hexByType[t] = hex
    end
  end
  hexByType['function'] = config.table_ref_color or hexByType['function']
  hexByType['table'] = config.table_cutoff_color or hexByType['table']

  local colors = {}
  for t, hex in pairs(hexByType) do
    colors[t] = ns:colorFn(hex)
  end
  return colors
end

--- @param out LibPrettyPrint_PackedArgs
--- @param tbl table
--- @param colors LibPrettyPrint_KeyValueColors
local function pushKeyValues(out, tbl, colors)
  local keys = sortedKeys(tbl)
  if #keys == 0 then return push(out, EMPTY_TABLE) end
  for _, k in ipairs(keys) do
    push(out, colors.key(tostring(k)) .. '=' .. ValueFormatter:Format(tbl[k], colors))
  end
end

--- @param c number @0 to 1
--- @return number  @0 to 255
local function toByte(c) return math.floor(c * 255 + 0.5) end

--- @param color? colorRGBA|LibPrettyPrint_RGBHex
--- @return LibPrettyPrint_RGBHex?
local function toRGBHex(color)
  if type(color) ~= 'table' then return color end
  return ('%02X%02X%02X'):format(toByte(color.r), toByte(color.g), toByte(color.b))
end

local o = S

--- @default
--- Create a new formatter with default configuration.
---
--- local config = {
---    multiline_tables = true, depth_limit = 3
--- }
--- ### Examples
--- ```
---  # Given
---  local val = { a=1, b=2, note='Hello World', callme=function() print('hello world, again.') end }
---
---  Basic Example: Without Config; Uses default settings
---  local pf = LibPrettyPrint_Formatter:New()
---  print('Val:', val)
---
---  Example: With Config
---  local pf = LibPrettyPrint_Formatter:New(config)
---  print('Val:', val)
---
---  # Example: Change setup to use newlines
---  local pf = LibPrettyPrint_Formatter:MultiLine()
---  print('Val:', val)
---  # Example: Change setup to avoid newlines
---  local pf = LibPrettyPrint_Formatter:Compact()
---  print('Val:', val)
---
--- ```
--- @public
--- @param config? LibPrettyPrint_FormatterConfig @Merged with defaults at construction time
--- @return LibPrettyPrint_Formatter
function o:New(config)
  --- @type LibPrettyPrint_Formatter
  local f = setmetatable({}, o)
  f:__Init(config)
  return f
end

--- @private
--- @param config? LibPrettyPrint_FormatterConfig
function o:__Init(config) self.config = ns:Table_MergeWithDefaults(DEFAULT_CONFIG, config or {}) end

--- @protected
--- @param configAdditive LibPrettyPrint_FormatterConfig
--- @return LibPrettyPrint_Formatter
function o:Derive(configAdditive)
  assert(type(configAdditive) == 'table', 'The additive config is required.')
  local config = ns:Table_MergeWithDefaults(self.config, configAdditive or {})
  return self:New(config)
end

--- Create a new formatter with compact option option
--- ### Example
--- ```
--- local fmt = LibPrettyPrint_Formatter:New({ multiline_tables = true })
--- local fmtC = fmt:Compact()
--- print('Val 1:', fmt(val))  -- has newlines
--- print('Val 2:', fmtC(val)) -- compact
--- ```
--- @public
--- @return LibPrettyPrint_Formatter
function o:Compact() return self:Derive({ multiline_tables = false }) end

--- Create a new formatter with multi-line option
--- ### Example
--- ```
--- local fmtC = LibPrettyPrint_Formatter:New({ multiline_tables = false })
--- local fmt = fmt:MultiLine()
--- print('Val 1:', fmtC(val)) -- compact
--- print('Val 2:', fmt(val))  -- has newlines
--- ```
--- @public
--- @return LibPrettyPrint_Formatter
function o:MultiLine() return self:Derive({ multiline_tables = true }) end

--- Create a new formatter that expands each table arg into sorted
--- `key=value` strings, one level deep.
--- ### Example
--- ```
--- local kv = LibPrettyPrint:Formatter():KeyValues()
--- print(kv({ name = 'Tony', level = 80, [1] = 'a' }))
--- -- 1='a'  level=80  name='Tony'  (values in type colors)
---
--- local kvW = LibPrettyPrint:Formatter():KeyValues(WHITE_FONT_COLOR)
--- local kvH = LibPrettyPrint:Formatter():KeyValues('EFEFEF')
---
--- -- Function values and nested tables, via config
--- local kvC = LibPrettyPrint:Formatter({
---   table_ref_color = 'AAAAAA', table_cutoff_color = 'FF8080',
--- }):KeyValues()
--- ```
--- @public
--- @param color? colorRGBA|LibPrettyPrint_RGBHex @Key color; sets table_key_color
--- @return LibPrettyPrint_Formatter
function o:KeyValues(color)
  return self:Derive({ key_values = true, table_key_color = toRGBHex(color) })
end

--- Pretty-format all arguments and return them as varargs
--- @private
--- @param ... any
--- @return any
function o:format(...)
  if self.config.key_values then return self:formatKeyValues(...) end
  local out = {}
  for i = 1, select('#', ...) do
    out[i] = self:pformat(select(i, ...))
  end
  return unpack(out)
end

--- Expand table args into `key=value` strings; others pass through
--- @private
--- @param ... any
--- @return any
function o:formatKeyValues(...)
  local args = ns:SafePack(...)
  local out = ns:SafePack()
  local colors = self:keyValueColors()
  for i = 1, args.n do
    local val = args[i]
    if type(val) == 'table' then
      pushKeyValues(out, val, colors)
    else
      push(out, val)
    end
  end
  return ns:SafeUnpack(out) --[[@as any ]]
end

--- @private
--- @return LibPrettyPrint_KeyValueColors
function o:keyValueColors()
  local c = self.config
  return {
    key = colorFnOrIdentity(c.table_key_color),
    values = valueColors(c),
    quote = c.key_values_type_colors == true,
  }
end

--- Format {obj}
--- @private
--- @return string
function o:pformat(obj) return self.pprint.pformat(obj, self.config) end

function o.dump(msg) DevTools_DumpCommand(msg) end
function o.dumpv(any)
  local tmp = {}
  print('Dump Value:')
  table.insert(tmp, any)
  DevTools_Dump(tmp)
end
