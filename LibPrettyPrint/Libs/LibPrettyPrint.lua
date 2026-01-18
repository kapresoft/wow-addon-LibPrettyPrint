--- @type LibPrettyPrint_Namespace
local ns           = select(2, ...)
--- @type LibStub
local LibStub      = LibStub
--[[-----------------------------------------------------------------------------
LibPrettyPrint
-------------------------------------------------------------------------------]]
local MAJOR, MINOR = 'LibPrettyPrint-1.0', 1

--- @class LibPrettyPrint
local S = LibStub:NewLibrary(MAJOR, MINOR); if not S then return end
LibPrettyPrint = S; ns.LibPrettyPrint = S

--- @type LibPrettyPrint
local o = S
--[[-----------------------------------------------------------------------------
Utility Functions
-------------------------------------------------------------------------------]]
function o.CopyTable(settings, shallow)
    local copy = {};
    for k, v in pairs(settings) do
        if type(v) == "table" and not shallow then
            copy[k] = CopyTable(v);
        else
            copy[k] = v;
        end
    end
    return copy;
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
--- @param printerConfig LibPrettyPrint_PrinterConfig|nil @Optional
--- @return LibPrettyPrint_Printer
--- @param formatter LibPrettyPrint_Formatter
function o:Printer(printerConfig, formatter)
    local f = formatter or self:Formatter(printerConfig.formatter)
    return ns.O.Printer:New(printerConfig, f)
end

--- @param formatterConfig LibPrettyPrint_FormatterConfig|nil
--- @return LibPrettyPrint_Formatter
function o:Formatter(formatterConfig)
    return ns.O.Formatter:New(formatterConfig)
end
