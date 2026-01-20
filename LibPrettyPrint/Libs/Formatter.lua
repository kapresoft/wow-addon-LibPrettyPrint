--- @type LibPrettyPrint_Namespace
local ns           = select(2, ...)

--[[-------------------------------------------------------------------
Local Vars
---------------------------------------------------------------------]]
--- @type LibPrettyPrint_FormatterConfig
local DEFAULT_CONFIG = {
    multiline_tables = false, show_all = true, depth_limit = 1,
}
--[[-------------------------------------------------------------------
Library: Formatter
---------------------------------------------------------------------]]

--- @class LibPrettyPrint_Formatter
--- @field config LibPrettyPrint_FormatterConfig
--- @field private pprint LibPrettyPrint_pprint
local S = {}; ns:register(ns.M.Formatter, S)
S.__index = S
S.__type  = 'LibPrettyPrint_Formatter'
--- @param self LibPrettyPrint_Formatter
S.__call = function(self, ...) return self:format(...) end

-- static field
S.pprint = ns.O.pprint

--[[-------------------------------------------------------------------
Support Functions
---------------------------------------------------------------------]]
local o  = S;

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
--- @param config LibPrettyPrint_FormatterConfig|nil @Optional per-instance config; merged with defaults at construction time.
--- @return LibPrettyPrint_Formatter
function o:New(config)
    --- @type LibPrettyPrint_Formatter
    local f = setmetatable({}, o); f:__Init(config)
    return f
end

--- @private
--- @param config LibPrettyPrint_FormatterConfig|nil
function o:__Init(config)
    if config then
        self.config = ns:CopyTable(config, false)
        ns:ApplyTableDefaults(self.config, DEFAULT_CONFIG)
        return
    end
    self.config = ns:CopyTable(DEFAULT_CONFIG, false)
end

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

--- Pretty-format all arguments and return them as varargs
--- @private
--- @param ... any
--- @return any
function o:format(...)
    local out = {}
    for i = 1, select("#", ...) do
        out[i] = self:pformat(select(i, ...))
    end
    return unpack(out)
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

