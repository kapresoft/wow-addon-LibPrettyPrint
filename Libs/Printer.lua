--- @type LibPrettyPrint_Namespace
local ns = select(2, ...).LibPrettyPrint; if not ns then return end

--[[-----------------------------------------------------------------------------
Types
-------------------------------------------------------------------------------]]
--- @class LibPrettyPrint_PrinterColor
--- @field hex string
--- @field c ColorMixin
--- @field w fun(text:string) : string

--[[-----------------------------------------------------------------------------
Lua Vars
-------------------------------------------------------------------------------]]
local sformat, date, _print = string.format, date, print
local DevTools_Dump = DevTools_Dump
--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type LibPrettyPrint_PrinterConfig
local DEFAULT_CONFIG = {
  multiline_tables = false,
  show_all = true,
  prefix_color = '3AFFFD',
  sub_prefix_color = 'FFF57D',
  show_timestamp = true,
}

local COLOR_KEYS = { 'table_key_color', 'table_ref_color', 'table_cutoff_color' }

local TIMESTAMP_COLOR = 'BCBCBC'
local tsC = ns:colorFn(TIMESTAMP_COLOR)
local DEFAULT_TAG = '>>'

--[[-----------------------------------------------------------------------------
Type: Printer
-------------------------------------------------------------------------------]]
--- @class LibPrettyPrint_PrinterImpl : LibPrettyPrint_PrinterInterface
--- @field config? LibPrettyPrint_PrinterConfig
--- @field formatter? LibPrettyPrint_Formatter
--- @field printFn LibPrettyPrint_PrintFn
--- @field predicateFn LibPrettyPrint_PredicateFn
local S = {}; if not S then return end; ns:register(ns.M.Printer, S)
S.__index = S
S.__type = 'LibPrettyPrint_Printer'
--- @param self LibPrettyPrint_Printer
S.__call = function(self, ...) self.printFn(self.tag, ...) end

local o = S

--[[-------------------------------------------------------------------
Support Functions
---------------------------------------------------------------------]]
--- @param config? LibPrettyPrint_PrinterConfig
local function assertConfig(config)
  if config == nil then return end

  assert(
    type(config) == 'table',
    'Invalid printer config. Expected type[LibPrettyPrint_PrinterConfig], but got: ' .. type(config)
  )

  if config.formatter then
    assert(
      type(config.formatter) == 'table',
      'Invalid config.formatter instance or config. Expected type[LibPrettyPrint_Formatter or LibPrettyPrint_FormatterConfig], but got: '
        .. type(config.formatter)
    )
  end
end

--- @param predicateFn? LibPrettyPrint_PredicateFn
local function assertPredicate(predicateFn)
  if predicateFn == nil then return end

  local pt = type(predicateFn)
  assert(
    pt == 'function',
    ('Expected predicateFn type to be a function, but got type=[%s] instead.'):format(pt)
  )
end

--- @param predicateFn? LibPrettyPrint_PredicateFn
--- @return boolean
local function evalPredicate(predicateFn)
  if predicateFn == nil then return true end

  local rv = predicateFn()
  local rvt = type(rv)
  assert(
    rvt == 'boolean',
    ('Expected predicate function to return a boolean value, but got type=[%s] instead.'):format(
      rvt
    )
  )
  return rv
end

--- @param out LibPrettyPrint_PackedArgs
--- @param ... any
local function append(out, ...)
  for i = 1, select('#', ...) do
    out.n = out.n + 1
    out[out.n] = (select(i, ...))
  end
end

--- Formats table args; keeps every value a formatter returns
--- @param formatter LibPrettyPrint_Formatter
--- @param ... any
--- @return LibPrettyPrint_PackedArgs
local function formatArgs(formatter, ...)
  local args = ns:SafePack(...)
  local out = ns:SafePack()
  for i = 1, args.n do
    if type(args[i]) == 'table' then
      append(out, formatter(args[i]))
    else
      append(out, args[i])
    end
  end
  return out
end

--- @param config LibPrettyPrint_PrinterConfig
--- @return LibPrettyPrint_FormatterConfig? @nil if no color is set
local function colorConfig(config)
  local colors
  for _, k in ipairs(COLOR_KEYS) do
    if config[k] then
      colors = colors or {}
      colors[k] = config[k]
    end
  end
  return colors
end

--- From config.formatter (a config or an instance), plus the
--- top-level colors, which override the formatter's own.
--- @param config LibPrettyPrint_PrinterConfig
--- @return LibPrettyPrint_Formatter
local function resolveFormatter(config)
  local formatter = config.formatter
  if not ns:IsType(formatter, ns.O.Formatter) then formatter = ns.O.Formatter:New(formatter) end
  local colors = colorConfig(config)
  if not colors then return formatter --[[@as LibPrettyPrint_Formatter ]] end
  return formatter:Derive(colors)
end

--[[-----------------------------------------------------------------------------
Methods:Printer
-------------------------------------------------------------------------------]]
--- @param config? LibPrettyPrint_PrinterConfig
--- @param predicateFn? LibPrettyPrint_PredicateFn
--- @return LibPrettyPrint_Printer
function o:New(config, predicateFn)
  assertConfig(config)
  assertPredicate(predicateFn)

  --- @type LibPrettyPrint_Printer
  local pr = setmetatable({}, o)
  pr:__Init(config, predicateFn)

  return pr
end

--- @private
--- @param config? LibPrettyPrint_PrinterConfig
--- @param predicateFn? LibPrettyPrint_PredicateFn
function o:__Init(config, predicateFn)
  self.config = self:__InitConfig(config)
  self.predicateFn = predicateFn

  self.config.formatter = resolveFormatter(self.config)

  if not self.config.use_dump_tool then
    self.printFn = self:NewPrintFn(predicateFn)
  else
    DEVTOOLS_DEPTH_CUTOFF = 2
    self.printFn = self:NewDumpPrintFn(predicateFn)
  end
end

--- @private
--- @param config? LibPrettyPrint_PrinterConfig
--- @return LibPrettyPrint_PrinterConfig
function o:__InitConfig(config)
  local merged = ns:Table_MergeWithDefaults(DEFAULT_CONFIG, config or {}) --[[@as LibPrettyPrint_PrinterConfig ]]
  local formatter = config and config.formatter
  -- The merge deep-copies tables, dropping the metatable
  if ns:IsType(formatter, ns.O.Formatter) then merged.formatter = formatter end
  return merged
end

--- @param sub_prefix string The new subPrefix name
--- @return LibPrettyPrint_Printer
function o:WithSubPrefix(sub_prefix)
  assert(
    type(sub_prefix) == 'string' and #ns:str_trim(sub_prefix) > 0,
    'Invalid sub_prefix; expected string, but got): ' .. tostring(sub_prefix)
  )

  local newConfig = ns:Table_MergeWithDefaults(self.config, { sub_prefix = sub_prefix })
  newConfig.sub_prefix = sub_prefix
  newConfig.formatter = self.config.formatter

  return o:New(newConfig, self.predicateFn)
end

--- @protected
--- @param predicateFn LibPrettyPrint_PredicateFn Function that evaluates a condition and returns true or false
--- @return LibPrettyPrint_PrintFn Printer function that accepts any values and outputs formatted text; behaves like print
function o:NewPrintFn(predicateFn)
  self.tag = self:CreateTag()

  --- @type LibPrettyPrint_PrintFn
  local fn = function(...)
    if not evalPredicate(predicateFn) then return end
    local formatter = self.config.formatter --[[@as LibPrettyPrint_Formatter]]
    local args = formatArgs(formatter, ...)
    if self.config.show_timestamp then
      local ts = tsC('[' .. date('%H:%M:%S') .. ']')
      return _print(ts, ns:SafeUnpack(args))
    end
    return _print(ns:SafeUnpack(args))
  end
  return fn
end

--- @param predicateFn LibPrettyPrint_PredicateFn Function that evaluates a condition and returns true or false
--- @return LibPrettyPrint_PrintFn Printer function that accepts any values and outputs formatted text; behaves like print
function o:NewDumpPrintFn(predicateFn)
  self.tag = self:CreateTag()

  local _p = DevTools_Dump
  return function(...)
    if not evalPredicate(predicateFn) then return end
    _print(self.tag)
    local args = ns:SafePack(...)
    for i = 1, args.n do
      _p(args[i])
    end
  end
end

--- @private
--- @return string
function o:CreateTag()
  local prefix = self:CreateCombinedPrefix()
  if not prefix then
    local p_color = ns:colorFn(self.config.prefix_color)
    return p_color(DEFAULT_TAG)
  end
  return sformat('{{%s}}', prefix)
end

--- Generates the combined prefix/sub_prefix resulting in one of:
--- ```
--- Possible return values:
--- with prefix and sub_prefix: '<prefix>::<sub_prefix>'
--- with prefix only '<prefix>'
--- with no prefix, with suffix: nil
--- with no prefix, no suffix: nil
--- ```
--- @private
--- @return string? @Joined by '::', e.g. 'MyAddOn::Module'; nil without a prefix
function o:CreateCombinedPrefix()
  local c = self.config

  local p_color = ns:colorFn(c.prefix_color)
  local s_color = ns:colorFn(c.sub_prefix_color)

  local p = ns:str_trim(c.prefix) or ''
  if #p == 0 then return nil end

  local s = ns:str_trim(c.sub_prefix) or ''
  if #s == 0 then return p_color(p) end

  return p_color(p) .. '::' .. s_color(s)
end
