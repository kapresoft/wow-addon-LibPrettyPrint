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
  sub_prefix_color = 'FFF57D'
}

--[[-----------------------------------------------------------------------------
Type: Printer
-------------------------------------------------------------------------------]]
--- @class LibPrettyPrint_Printer
--- @field config LibPrettyPrint_PrinterConfig|nil @Optional printer config
--- @field formatter LibPrettyPrint_Formatter|nil @Optional formatter instance
--- @field printFn LibPrettyPrint_PrintFn
local S = {}; if not S then return end ; ns:register(ns.M.Printer, S)

--- @type LibPrettyPrint_Printer
local o = S

--[[-----------------------------------------------------------------------------
Methods:Printer
-------------------------------------------------------------------------------]]
--- @param config LibPrettyPrint_PrinterConfig|nil @Optional printer config
--- @param formatter LibPrettyPrint_Formatter|nil @Optional formatter instance
--- @return LibPrettyPrint_Printer
function o:New(config, formatter)

  -- todo next: include_timestamp option
  -- todo next: predicateFn

  --- @type LibPrettyPrint_Printer
  local pr = CreateAndInitFromMixin(o, config, formatter)
  --DEVTOOLS_DEPTH_CUTOFF = 2
  --return NewDumpPrinter(ns.name, ns.M.Printer, fmt)
  if not pr.config.use_dump_tool then
    pr.printFn = pr:NewPrintFn()
  else
    --pr.printFn = NewDumpPrintFn(ns.name, ns.M.Printer, self.formatter)
  end
  setmetatable(pr, pr.metatable)

  return pr
end


--- @private
--- @param config LibPrettyPrint_PrinterConfig|nil @Optional printer config
--- @param formatter LibPrettyPrint_Formatter|nil @Optional formatter instance
function o:Init(config, formatter)
  self.config    = config or DEFAULT_CONFIG
  self.formatter = formatter or ns.O.Formatter:New()
  self.metatable = { __call = function(self, ...) self.printFn(self.tag, ...) end }
end

--- @param sub_prefix string The new subPrefix name
--- @return LibPrettyPrint_PrintFn
function o:WithSubPrefix(sub_prefix)
  assert(type(sub_prefix) == 'string' and #ns:str_trim(sub_prefix) > 0,
         'Invalid sub_prefix; expected string, but got): ' .. tostring(sub_prefix))

  self.config.sub_prefix = sub_prefix
  local newConfig = ns:tbl_shallow_copy(self.config)

  return o:New(newConfig, self.formatter)
end

--- @param tbl table
function o:PrintTable(tbl)
  if not type(tbl) == "table" then _print(tbl) end

  for key, val in pairs(tbl) do
    _print(" ", self.formatter(val))
  end
end

--- @protected
--- @param predicateFn LibPrettyPrint_PredicateFn Function that evaluates a condition and returns true or false
--- @return LibPrettyPrint_PrintFn Printer function that accepts any values and outputs formatted text; behaves like print
function o:NewPrintFn(predicateFn)
  self.tag = self:CreatTag()

  --- @type LibPrettyPrint_PrintFn
  local fn = function(...)
    local args = ns:SafePack(...)
    for i = 1, args.n do
      if type(args[i]) == "table" then
        args[i] = self.formatter(args[i])
      end
    end

    _print("[" .. date("%H:%M:%S") .. "]", ns:SafeUnpack(args))
  end
  return fn
end

--- @param sub_prefix Name The log sub prefix name
--- @param predicateFn LibPrettyPrint_PredicateFn Function that evaluates a condition and returns true or false
--- @return LibPrettyPrint_PrintFn Printer function that accepts any values and outputs formatted text; behaves like print
function o:NewDumpPrintFn(prefix, sub_prefix, predicateFn)
  assert(type(sub_prefix) == "string", "Prefix name must be a string.")

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
  return sformat("{{%s}}:", self:CreateCombinedPrefix())
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
--- @return string The combined prefix separated with '::', example: 'MyAddOn::Module'
function o:CreateCombinedPrefix()
  local c = self.config

  local prefix_color = c.prefix_color or DEFAULT_CONFIG.prefix_color
  local sub_prefix_color = c.sub_prefix_color or DEFAULT_CONFIG.sub_prefix_color
  local p_color = ns:colorFn(prefix_color)
  local s_color = ns:colorFn(sub_prefix_color)

  local p = ns:str_trim(c.prefix) or ''
  local s = ns:str_trim(c.sub_prefix) or ''
  if #p == 0 then return nil end
  if #s == 0 then return p_color(p) end

  return p_color(p) .. '::' .. s_color(s)
end
