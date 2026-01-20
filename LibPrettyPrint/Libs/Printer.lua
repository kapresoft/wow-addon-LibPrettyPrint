--- @type LibPrettyPrint_Namespace
local ns = select(2, ...)

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
local sformat, date, unpack, _print = string.format, date, unpack, print
local DevTools_Dump = DevTools_Dump
--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type LibPrettyPrint_PrinterConfig
local DEFAULT_CONFIG = {
  multiline_tables = false, show_all = true,
  prefix_color     = '3AFFFD',
  sub_prefix_color = 'FFF57D',
  show_timestamp   = true,
}

local TIMESTAMP_COLOR = 'BCBCBC'; local tsC = ns:colorFn(TIMESTAMP_COLOR)
local DEFAULT_TAG = '>>'

--[[-----------------------------------------------------------------------------
Type: Printer
-------------------------------------------------------------------------------]]
--- @class LibPrettyPrint_PrinterImpl : LibPrettyPrint_PrinterInterface
--- @field config LibPrettyPrint_PrinterConfig|nil @Optional printer config
--- @field formatter LibPrettyPrint_Formatter|nil @Optional formatter instance
--- @field printFn LibPrettyPrint_PrintFn
local S = {}; if not S then return end ; ns:register(ns.M.Printer, S)
S.__index = S
S.__type = 'LibPrettyPrint_Printer'
--- @param self LibPrettyPrint_Printer
S.__call = function(self, ...) self.printFn(self.tag, ...) end

--- @type LibPrettyPrint_Printer
local o = S

--[[-------------------------------------------------------------------
Support Functions
---------------------------------------------------------------------]]
--- @param config LibPrettyPrint_PrinterConfig|nil @Optional printer config
local function assertConfig(config)
  if config == nil then return end

  assert(type(config) == 'table', "Invalid printer config. Expected type[LibPrettyPrint_PrinterConfig], but got: " .. type(config))

  if config.formatter then
    assert(type(config.formatter) == 'table', "Invalid config.formatter instance or config. Expected type[LibPrettyPrint_Formatter or LibPrettyPrint_FormatterConfig], but got: " .. type(config.formatter))
  end
end

--- @param predicateFn LibPrettyPrint_PredicateFn|nil @Optional
local function assertPredicate(predicateFn)
  if predicateFn == nil then return end

  local pt = type(predicateFn)
  assert( pt == 'function', ('Expected predicateFn type to be a function, but got type=[%s] instead.'):format(pt))
end

--- @param predicateFn LibPrettyPrint_PredicateFn|nil @Optional
--- @return boolean
local function evalPredicate(predicateFn)
  if predicateFn == nil then return true end

  local rv = predicateFn(); local rvt = type(rv)
  assert(rvt == 'boolean', ('Expected predicate function to return a boolean value, but got type=[%s] instead.'):format(rvt))
  return rv
end

--[[-----------------------------------------------------------------------------
Methods:Printer
-------------------------------------------------------------------------------]]
--- @param config LibPrettyPrint_PrinterConfig|nil @Optional printer config
--- @param predicateFn LibPrettyPrint_PredicateFn|nil @Optional
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
--- @param config LibPrettyPrint_PrinterConfig|nil @Optional printer config
--- @param predicateFn LibPrettyPrint_PredicateFn|nil @Optional
function o:__Init(config, predicateFn)
  self.config = self:__InitConfig(config)

  -- formatter can be a config or an instance of Formatter
  if not ns:IsType(self.config.formatter, ns.O.Formatter) then
    self.config.formatter = ns.O.Formatter:New(self.config.formatter)
  end

  if not self.config.use_dump_tool then
    self.printFn = self:NewPrintFn(predicateFn)
  else
    DEVTOOLS_DEPTH_CUTOFF = 2
    self.printFn = self:NewDumpPrintFn(predicateFn)
  end
end

--- @private
--- @param config LibPrettyPrint_PrinterConfig|nil
--- @return LibPrettyPrint_PrinterConfig
function o:__InitConfig(config)
  local c = config
  if not c then c = ns:CopyTable(DEFAULT_CONFIG, false)
  else ns:ApplyTableDefaults(c, DEFAULT_CONFIG) end
  return c
end

--- @param sub_prefix string The new subPrefix name
--- @return LibPrettyPrint_PrintFn
function o:WithSubPrefix(sub_prefix)
  assert(type(sub_prefix) == 'string' and #ns:str_trim(sub_prefix) > 0,
         'Invalid sub_prefix; expected string, but got): ' .. tostring(sub_prefix))

  local newConfig = ns:CopyTable(self.config, false)
  newConfig.sub_prefix = sub_prefix

  return o:New(newConfig)
end

--- @protected
--- @param predicateFn LibPrettyPrint_PredicateFn Function that evaluates a condition and returns true or false
--- @return LibPrettyPrint_PrintFn Printer function that accepts any values and outputs formatted text; behaves like print
function o:NewPrintFn(predicateFn)
  if not evalPredicate(predicateFn) then return function() end end

  self.tag = self:CreatTag()

  --- @type LibPrettyPrint_PrintFn
  local fn = function(...)
    local args = ns:SafePack(...)
    for i = 1, args.n do
      if type(args[i]) == "table" then
        args[i] = self.config.formatter(args[i])
      end
    end
    if self.config.show_timestamp then
      local ts = tsC("[" .. date("%H:%M:%S") .. "]")
      return _print(ts, ns:SafeUnpack(args))
    end
    return _print(ns:SafeUnpack(args))
  end
  return fn
end

--- @param sub_prefix Name The log sub prefix name
--- @param predicateFn LibPrettyPrint_PredicateFn Function that evaluates a condition and returns true or false
--- @return LibPrettyPrint_PrintFn Printer function that accepts any values and outputs formatted text; behaves like print
function o:NewDumpPrintFn(predicateFn)
  if predicateFn and not predicateFn() then return function() end end

  self.tag = self:CreatTag()

  _print(self.tag)

  local _p = DevTools_Dump
  return function(...)
    local args = ns:SafePack(...)
    for i = 1, args.n do
      _p(args[i])
    end
  end
end

--- @private
--- @return string
function o:CreatTag()
  local prefix = self:CreateCombinedPrefix()
  if not prefix then
    local p_color = ns:colorFn(self.config.prefix_color)
    return p_color(DEFAULT_TAG)
  end
  return sformat("{{%s}}", prefix)
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
--- @return string|nil The combined prefix separated with '::', example: 'MyAddOn::Module'
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
