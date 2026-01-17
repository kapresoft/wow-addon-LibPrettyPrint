--- @type LibPrettyPrint_Namespace
local ns = select(2, ...)

--[[-----------------------------------------------------------------------------
Types
-------------------------------------------------------------------------------]]
--- @class LibPrettyPrint_PrinterColor
--- @field hex string
--- @field c ColorMixin
--- @field w fun(text:string) : string

--- @class LibPrettyPrint_LogColor
--- @field LOG_NAME LibPrettyPrint_PrinterColor
--- @field MOD_PREFIX LibPrettyPrint_PrinterColor
--- @field KEY LibPrettyPrint_PrinterColor
--- @field VALUE LibPrettyPrint_PrinterColor

--[[-----------------------------------------------------------------------------
Lua Vars
-------------------------------------------------------------------------------]]
local sformat, date, unpack, _print = string.format, date, unpack, print
local DevTools_Dump = DevTools_Dump
--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
local COLORS                        = {
  LOG_NAME   = 'ff32CF21',
  MOD_PREFIX = 'ff9CFF9C',
  KEY        = 'ffB8BA00',
  VALUE      = 'ffFFFFFF',
}

--- Color Definitions
(function()
  --- @param hex string
  local function Methods(hex)
    local o = {};
    o.hex   = hex
    o.c     = CreateColorFromHexString(o.hex)
    assert(o.c, sformat('Invalid hex color: %s', tostring(hex)))
    function o.w(text) return o.c:WrapTextInColorCode(text) end
    return o
  end;
  for c, hexColor in pairs(COLORS) do COLORS[c] = Methods(hexColor) end
end)()

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

--- @type LibPrettyPrint_PrinterConfig
local DEFAULT_CONFIG = { use_newline = false, show_all = true }

--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]
--- @return table|nil Returns a shallow copy of `t`; returns nil if `t` is nil
function tbl_shallow_copy(t)
  if t == nil then return nil end
  local t2 = {}
  for k,v in pairs(t) do t2[k] = v end
  return t2
end

--- @param s string
--- @return string|nil
local function str_trim(s)
  return type(s) == "string" and s:match("^%s*(.-)%s*$") or s
end

--- @param ... vararg
local function _SafePack(...)
  local tbl = { ... };
  tbl.n     = select("#", ...)
  return tbl
end

--- Unpacks a table that was constructed using SafePack.
--- @param tbl table
--- @param startIndex number
local function _SafeUnpack(tbl, startIndex) return unpack(tbl, startIndex or 1, tbl.n) end

--- @param sub_prefix Name The log sub prefix name
--- @param predicateFn LibPrettyPrint_PredicateFn Function that evaluates a condition and returns true or false
--- @return LibPrettyPrint_PrintFn Printer function that accepts any values and outputs formatted text; behaves like print
local function NewDumpPrintFn(prefix, sub_prefix, predicateFn)
  assert(type(sub_prefix) == "string", "Prefix name must be a string.")

  local _p = DevTools_Dump
  local finalPrefix = sformat("{{%s::%s}}:",
                              COLORS.LOG_NAME.w(prefix),
                              COLORS.MOD_PREFIX.w(sub_prefix))
  return function(...)
    local args = _SafePack(...)
    for i = 1, args.n do
      _p(args[i])
    end
  end
end

--[[-----------------------------------------------------------------------------
Methods:Printer
-------------------------------------------------------------------------------]]

--- @param config LibPrettyPrint_PrinterConfig|nil @Optional printer config
--- @param formatter LibPrettyPrint_Formatter|nil @Optional formatter instance
--- @return LibPrettyPrint_Printer
function o:New(config, formatter)

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
  -- todo and prefixColor, subPrefixColor to config

  self.metatable = { __call = function(self, ...) self.printFn(self.tag, ...) end }
end

--- @param sub_prefix string The new subPrefix name
--- @return LibPrettyPrint_PrintFn
function o:WithSubPrefix(sub_prefix)
  assert(type(sub_prefix) == 'string' and #str_trim(sub_prefix) > 0,
         'Invalid sub_prefix; expected string, but got): ' .. tostring(sub_prefix))

  self.config.sub_prefix = sub_prefix
  local newConfig = tbl_shallow_copy(self.config)

  return o:New(newConfig, self.formatter)
end

--- @protected
--- @param predicateFn LibPrettyPrint_PredicateFn Function that evaluates a condition and returns true or false
--- @return LibPrettyPrint_PrintFn Printer function that accepts any values and outputs formatted text; behaves like print
function o:NewPrintFn(predicateFn)
  --- prefix, sub_prefix, formatter, predicateFn
  --local finalPrefix = sformat("{{%s::%s}}:",
  --                            COLORS.LOG_NAME.w(prefix),
  --                            COLORS.MOD_PREFIX.w(subPrefix))

  self.tag = self:CreatTag()
  print('NewPrintFn::tag:', self.tag)

  --- @type LibPrettyPrint_PrintFn
  local fn = function(...)
    local args = _SafePack(...)
    for i = 1, args.n do
      if type(args[i]) == "table" then
        args[i] = self.formatter(args[i])
      end
    end

    _print("[" .. date("%H:%M:%S") .. "]", _SafeUnpack(args))
  end
  return fn
end

--- @private
--- @return string
function o:CreatTag()
  local t = sformat("{{%s}}:", self:CreateCombinedPrefix())
  return t
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
  assert(c, 'Printer config is required.')

  local p_color = COLORS.LOG_NAME.w
  local s_color = COLORS.MOD_PREFIX.w

  local p = str_trim(c.prefix) or ''
  local s = str_trim(c.sub_prefix) or ''
  if #p == 0 then return nil end
  if #s == 0 then return p_color(p) end

  return p_color(p) .. '::' .. s_color(s)
end
