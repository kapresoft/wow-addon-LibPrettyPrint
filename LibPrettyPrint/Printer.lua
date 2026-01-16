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

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
local ADDON_LOG_NAME   = 'GRS'

local COLORS = {
    LOG_NAME   = 'ff32CF21',
    MOD_PREFIX = 'ff9CFF9C',
    KEY        = 'ffB8BA00',
    VALUE      = 'ffFFFFFF',
}

--- Color Definitions
(function()
    --- @param hex string
    local function Methods(hex)
        local o = {}; o.hex   = hex
        o.c = CreateColorFromHexString(o.hex)
        assert(o.c, sformat('Invalid hex color: %s', tostring(hex)))
        function o.w(text) return o.c:WrapTextInColorCode(text) end
        return o
    end;
    for c, hexColor in pairs(COLORS) do COLORS[c] = Methods(hexColor) end
end)()

--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]
--- @param ... vararg
local function _SafePack(...)
    local tbl = { ... }; tbl.n = select("#", ...)
    return tbl
end

--- Unpacks a table that was constructed using SafePack.
--- @param tbl table
--- @param startIndex number
local function _SafeUnpack(tbl, startIndex) return unpack(tbl, startIndex or 1, tbl.n) end

--- @type LibPrettyPrint_PrinterColor
local C = COLORS
local logName = C.LOG_NAME.w(ADDON_LOG_NAME)

local function tpack(...) return { n = select("#", ...), ... } end
local function valToStr(tbl)
    if tbl == nil then return "nil" end
    if type(tbl) ~= "table" then return tostring(tbl) end
    if next(tbl) == nil then return "{}" end

    local out = {}
    for k, v in pairs(tbl) do
        local key   = C.KEY.w(tostring(k))
        local value = C.VALUE.w(tostring(v))
        out[#out + 1] = key .. "=" .. value
    end

    return "{ " .. table.concat(out, ", ") .. " }"
end
local formatter = ns.O.Formatter:New() or valToStr

--- Creates a scoped logger function with a fixed prefix.
--- The returned function behaves like `print`, but automatically
--- prefixes all output with the provided name.
---
--- ### Usage
--- ```
--- local p = ns:Log('Gears')
--- p('Selected:', val)
--- local tbl = { ['hello']='there'}
--- p('Table Val:', pformat(tbl))
--- ```
--- @param prefix Name The log prefix name
--- @return LibPrettyPrint_PrinterFn LoggerFn A callable logger function, behaves like print
local function NewLoggerXXOLD(prefix)
    assert(type(prefix) == "string", "Prefix name must be a string.")

    local sPrefix = sformat("{{%s::%s}}:", logName, C.MOD_PREFIX.w(prefix))

    return function(...)
        local args = _SafePack(...)
        for i = 1, args.n do
            if type(args[i]) == "table" then
                args[i] = formatter(args[i])
            end
        end

        print("[" .. date("%H:%M:%S") .. "]", sPrefix, _SafeUnpack(args))
    end
end

--[[

]]

--- @param subPrefix Name The log sub prefix name
--- @param predicateFn LibPrettyPrint_PredicateFn Function that evaluates a condition and returns true or false
--- @return LibPrettyPrint_PrinterFn Printer function that accepts any values and outputs formatted text; behaves like print
local function NewPrinter(prefix, subPrefix, formatter, predicateFn)
    assert(type(subPrefix) == "string", "Prefix name must be a string.")

    local finalPrefix = sformat("{{%s::%s}}:",
                                C.LOG_NAME.w(prefix),
                                C.MOD_PREFIX.w(subPrefix))
    return function(...)
        local args = SafePack(...)
        for i = 1, args.n do
            if type(args[i]) == "table" then
                args[i] = formatter(args[i])
            end
        end

        _print("[" .. date("%H:%M:%S") .. "]", finalPrefix, SafeUnpack(args))
    end
end

--- @param subPrefix Name The log sub prefix name
--- @param predicateFn LibPrettyPrint_PredicateFn Function that evaluates a condition and returns true or false
--- @return LibPrettyPrint_PrinterFn Printer function that accepts any values and outputs formatted text; behaves like print
local function NewDumpPrinter(prefix, subPrefix, predicateFn)
    assert(type(subPrefix) == "string", "Prefix name must be a string.")

    local _p = DevTools_Dump
    local finalPrefix = sformat("{{%s::%s}}:",
                                C.LOG_NAME.w(prefix),
                                C.MOD_PREFIX.w(subPrefix))
    return function(...)
        local args = SafePack(...)
        for i = 1, args.n do
            _p(args[i])
            --if type(args[i]) == "table" then
            --end
        end

        --_print("[" .. date("%H:%M:%S") .. "]", finalPrefix, SafeUnpack(args))
        --DevTools_Dump("[" .. date("%H:%M:%S") .. "]", finalPrefix, SafeUnpack(args))
    end
end

--[[-----------------------------------------------------------------------------
Methods:Printer
-------------------------------------------------------------------------------]]
--- @class LibPrettyPrint_Printer
local S = {}
if not S then return end; ns:register(ns.M.Printer, S)

--- @type LibPrettyPrint_Printer
local o = S

--- @type LibPrettyPrint_FormatterConfig
local DEFAULT_CONFIG = { use_newline = false, show_all = true }

---@param config LibPrettyPrint_FormatterConfig|nil
function o:New(config)
    --- @type LibPrettyPrint_FormatterConfig
    local _config = config or DEFAULT_CONFIG
    local fmt = ns.O.Formatter:New(_config)
    --DEVTOOLS_DEPTH_CUTOFF = 2
    --return NewDumpPrinter(ns.name, ns.M.Printer, fmt)
    return NewPrinter(ns.name, ns.M.Printer, fmt)
end

local function log(e)
    --- @type LibPrettyPrint_FormatterConfig
    local cfg = { show_metatable = true, depth_limit = 1, use_newline = true }
    local fmt = ns.O.Formatter:New(cfg)

    local p1 = NewPrinter(ns.name, ns.M.Printer, fmt)
    local p2 = NewDumpPrinter(ns.name, ns.M.Printer)

    local fnType = function()  end
    ns[fnType] = 'hello world'
    p2('Namespace::', ns)
    DEVTOOLS_DEPTH_CUTOFF = cfg.depth_limit
    --p2('Namespace Objects:', ns.O)

    e:LogEvent('LIBPRETTYPRINT:NAMESPACE', 'name=' .. ns.name, 'modules=' .. tostring(ns.M))
    --DEVTOOLS_DEPTH_CUTOFF = 1
    --local Namespace = {}
    --table.insert(Namespace, ns)
    --print('Dump Value:')
    --DevTools_Dump(ns)

    --function()
    --    local e = EventTrace
    --    --e:LogMessage('[100] ABP hello')
    --    e:LogEvent("ACTIONBARPLUS:ONMOUSEOVER", "player")
    --end
end

--C_Timer.After(2, function()
--    print('xx  EventTrace:Show()')
--    EventTrace:Show()
--    log(EventTrace)
--end)

--local loaded = IsAddOnLoaded("Blizzard_EventTrace")
--if not loaded then
--    LoadAddOn("Blizzard_EventTrace")
--end
