--- @type LibPrettyPrint_Namespace
local ns           = select(2, ...)
--- @type LibStub
local LibStub      = LibStub
--[[-----------------------------------------------------------------------------
Type Def
-------------------------------------------------------------------------------]]
--- @class LibPrettyPrint_FormatterConfig
--- @field use_newline boolean        @Use newlines for each element.                            default=false
--- @field show_function boolean      @Limit show functions.                                     default=true
--- @field depth_limit boolean|number @If set to number N, then limit table recursion to N deep. default=1
--- @field wrap_string boolean        @Wrap string when it's longer than level_width.            default= true
--- @field indent_size number         @Indent size when using newlines.                          default=2
--- @field sort_keys boolean          @Sort table keys.                                          default=true
--- @field show_all boolean           @Show all value types.                                     default=false
--- @field level_width number         @Max line width before wrapping.                           default=80
--- @field show_metatable boolean     @Show metatable.                                           default=false

--- @class LibPrettyPrint_PrinterConfig
--- @field prefix string The main prefix in {{ PREFIX::SUBPREFIX }} : <Message>
--- @field sub_prefix string The sub-prefix {{ PREFIX::SUBPREFIX }} : <Message>
--- @field use_dump_tool boolean @Use Blizzard's Dump Tool for printing
--- @field formatterConfig LibPrettyPrint_FormatterConfig @Optional formatter config

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
o.mt = { __call = function(self, ...) return self:format(...) end }

--- Note: Indent only matters if use_newline = true; otherwise set indent_size to 1
local pprint = o.pprint

--- @default
--- Create a new formatter with default configuration.
---
--- Default Configuration is:
--- local defaultConfig = {
---    use_newline = true,
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
    --print('xx config:', pprint.pformat(config))
    local obj = CreateAndInitFromMixin(o, config)
    return setmetatable(obj, o.mt)
end

--- @private
--- @param config LibPrettyPrint_FormatterConfig|nil
function o:Init(config) self.config = config end

--- Format the given object using a compact (single-line) formatter.
--- ### Example
--- ```
--- local fmt = LibPrettyPrint_Formatter:New() -- use defaults
--- local fmtc = fmt:Compact()
--- print('Val 1:', fmt(val))  -- has newlines
--- print('Val 2:', fmtc(val)) -- compact
--- ```
--- ### Similar behavior to calling:
--- ```
--- local fmt = LibPrettyPrint_Formatter:New({ use_newline = false })
--- print('Val:', fmt(val))
--- ```
--- @public
--- @return LibPrettyPrint_Formatter
function o:Compact()
    local config = CopyTable(self.config or {}, true)
    config.use_newline = false
    return self:New(config)
end

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

--fmt = o:New()
--fmr = o:New({ use_newline = false })
--print('xxx fmr:', fmr({}))

