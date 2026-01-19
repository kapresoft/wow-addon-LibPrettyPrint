--- @type LibPrettyPrint_Namespace
local ns           = select(2, ...)
--- @type LibStub
local LibStub      = LibStub

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type LibPrettyPrint_FormatterConfig
local DEFAULT_CONFIG = {
    multiline_tables = false, show_all = true, depth_limit = 1,
}
--[[-----------------------------------------------------------------------------
Library: LibPrettyPrint
-------------------------------------------------------------------------------]]
local MAJOR, MINOR = 'LibPrettyPrint-1.0', 1

--- @class LibPrettyPrint_Formatter
--- @field config LibPrettyPrint_FormatterConfig
--- @field private pprint LibPrettyPrint_pprint
local S = {}; ns:register(ns.M.Formatter, S)

--- @class LibPrettyPrint_PrettyPrintWrapper
local pformatWrapper = { pprint = ns.O.pprint }
local pformat        = pformatWrapper

local o  = S;
o.pprint = ns.O.pprint
o.mt = {
    __type = 'LibPrettyPrint_Formatter',
    __call = function(self, ...) return self:format(...) end
}

--- Note: Indent only matters if multiline_tables = true; otherwise set indent_size to 1
local pprint = o.pprint

--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]

--- @default
--- Create a new formatter with default configuration.
---
--- Default Configuration is:
--- local defaultConfig = {
---    multiline_tables = true,
---    wrap_string = true,
---    level_width = 80,
---    sort_keys   = true,
---    show_all    = false,
---    depth_limit = false,
--- }
--- ### Examples
--- ```
---  # Given
---  local val = { a=1, b=2, note='Hello World', callme=function() print('hello world, again.') end }
---
---  local pf = LibPrettyPrint_Formatter:New()
---  print('Val:', val)
---
---  # change setup to use newlines
---  local pf = LibPrettyPrint_Formatter:Compact()
---  print('Val:', val)
---
--- ```
--- @public
--- @param config LibPrettyPrint_FormatterConfig|nil Optional per-instance config; merged with library defaults at format time
--- @return LibPrettyPrint_Formatter
function o:New(config)
    local obj = CreateAndInitFromMixin(o, config or DEFAULT_CONFIG)
    return setmetatable(obj, o.mt)
end

--- @private
--- @param config LibPrettyPrint_FormatterConfig|nil
function o:Init(config) self.config = config end

--- @protected
--- @param configAdditive LibPrettyPrint_FormatterConfig
--- @return LibPrettyPrint_Formatter
function o:Derive(configAdditive)
    assert(configAdditive, "The additive config is required.")
    local config = ns:CopyTable(self.config or {})
    if configAdditive then ns:MergeTable(config, configAdditive) end
    return self:New(config)
end

--- Create a new formatter with compact option option
--- ### Example
--- ```
--- local fmt = LibPrettyPrint_Formatter:New() -- use defaults
--- local fmtc = fmt:Compact()
--- print('Val 1:', fmt(val))  -- has newlines
--- print('Val 2:', fmtc(val)) -- compact
--- ```
--- ### Similar behavior to calling:
--- ```
--- local fmt = LibPrettyPrint_Formatter:New({ multiline_tables = false })
--- print('Val:', fmt(val))
--- ```
--- @public
--- @return LibPrettyPrint_Formatter
function o:Compact() return self:Derive({ multiline_tables = false }) end

--- Create a new formatter with multi-line option
--- @public
--- @return LibPrettyPrint_Formatter
function o:MultiLine() return self:Derive({ multiline_tables = true }) end

--- @alias
--- @see LibPrettyPrint_PrettyPrintWrapper#A()
--- @return LibPrettyPrint_PrettyPrintWrapper
function o:Default() return self:A() end

--- @alias
--- @see LibPrettyPrint_PrettyPrintWrapper#B()
--- @return LibPrettyPrint_PrettyPrintWrapper
function o:Indent() return self:B() end

--- Pretty-format all arguments and return them as varargs
--- @param ... any
--- @return any
function o:format(...)
    local out = {}
    for i = 1, select("#", ...) do
        out[i] = self:pformat(select(i, ...))
    end
    return unpack(out)
end

--- @private
--- @return string
function o:pformat(obj) return pprint.pformat(obj, self.config) end

function o.dump(msg) DevTools_DumpCommand(msg) end
function o.dumpv(any)
    local tmp = {}
    print('Dump Value:')
    table.insert(tmp, any)
    DevTools_Dump(tmp)
end

