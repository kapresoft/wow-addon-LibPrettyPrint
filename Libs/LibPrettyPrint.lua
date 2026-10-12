--- @type PrivateNamespace
local parent = select(2, ...)
--- @type LibPrettyPrint_Namespace
local ns = parent.LibPrettyPrint; if not ns then return end

--[[-----------------------------------------------------------------------------
LibPrettyPrint
Loads before the modules and gates them: an older or equal copy
clears its namespace, so its remaining files skip. Methods must
only use ns.O.* when called, never at load time.
-------------------------------------------------------------------------------]]
local MAJOR, MINOR = 'LibPrettyPrint-1.0', 6

--- @class LibPrettyPrintImpl-1.0 : LibPrettyPrint-1.0
local o = LibStub:NewLibrary(MAJOR, MINOR)
if not o then parent.LibPrettyPrint = nil; return end

--- @type LibPrettyPrint-1.0
LibPrettyPrint = o
LibPrettyPrint_Namespace = ns

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
--- @param config? LibPrettyPrint_PrinterConfig
--- @param predicateFn? LibPrettyPrint_PredicateFn
--- @return LibPrettyPrint_Printer
function o:Printer(config, predicateFn) return ns.O.Printer:New(config, predicateFn) end

--- @param config? LibPrettyPrint_FormatterConfig
--- @return LibPrettyPrint_Formatter
function o:Formatter(config) return ns.O.Formatter:New(config) end
