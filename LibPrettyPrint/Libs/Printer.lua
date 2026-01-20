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
local DEFAULT_TAG = '>>'

--[[-----------------------------------------------------------------------------
Type: Printer
-------------------------------------------------------------------------------]]
--- @class LibPrettyPrint_Printer
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

--[[-----------------------------------------------------------------------------
Methods:Printer
-------------------------------------------------------------------------------]]
--- @param config LibPrettyPrint_PrinterConfig|nil @Optional printer config
--- @param formatter LibPrettyPrint_Formatter|nil @Optional formatter instance
--- @param predicateFn LibPrettyPrint_PredicateFn|nil @Optional
--- @return LibPrettyPrint_Printer
function o:New(config, formatter, predicateFn)

  -- todo next: predicateFn

  --- @type LibPrettyPrint_Printer
  local pr = setmetatable({}, o)
  pr:__Init(config, formatter, predicateFn)

  return pr
end

--- @private
--- @param config LibPrettyPrint_PrinterConfig|nil @Optional printer config
--- @param formatter LibPrettyPrint_Formatter|nil @Optional formatter instance
function o:__Init(config, formatter, predicateFn)
  self.config = self:__InitConfig(config)
  self.formatter = formatter or ns.O.Formatter:New()
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
  else ns:TableDefaults(c, DEFAULT_CONFIG) end
  return c
end

--- @param sub_prefix string The new subPrefix name
--- @return LibPrettyPrint_PrintFn
function o:WithSubPrefix(sub_prefix)
  assert(type(sub_prefix) == 'string' and #ns:str_trim(sub_prefix) > 0,
         'Invalid sub_prefix; expected string, but got): ' .. tostring(sub_prefix))

  local newConfig = ns:CopyTable(self.config, false)
  newConfig.sub_prefix = sub_prefix

  return o:New(newConfig, self.formatter)
end

--- @protected
--- @param predicateFn LibPrettyPrint_PredicateFn Function that evaluates a condition and returns true or false
--- @return LibPrettyPrint_PrintFn Printer function that accepts any values and outputs formatted text; behaves like print
function o:NewPrintFn(predicateFn)
  if predicateFn and not predicateFn() then return function() end end

  self.tag = self:CreatTag()

  --- @type LibPrettyPrint_PrintFn
  local fn = function(...)
    local args = ns:SafePack(...)
    for i = 1, args.n do
      if type(args[i]) == "table" then
        args[i] = self.formatter(args[i])
      end
    end
    if self.config.show_timestamp then
      return _print("[" .. date("%H:%M:%S") .. "]", ns:SafeUnpack(args))
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
