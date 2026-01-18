local addon, ns = ...
local O, GC, M, LibStub = ns.O, ns.GC, ns.M, ns.LibStub
local devst = DEV_SUITE

--- @class Developer
local o = {}; lpp_dev = o

C_Timer.After(1, function()
    print(('xxx %s::Developer loaded...'):format(addon))
end)

function o:clear()
    devst:BINDING_DEVS_CLEAR_DEBUG_CONSOLE()
    return devst and devst:BINDING_DEVS_CLEAR_DEBUG_CONSOLE()
end

--- @return LibPrettyPrint_Formatter
function o:formatterTest()
    local lpp = LibPrettyPrint

    --- @type LibPrettyPrint_FormatterConfig
    local fc1 = { multiline_tables = false, depth_limit = 3, }

    --- @type LibPrettyPrint_FormatterConfig
    local fc2 = { multiline_tables = true, depth_limit = 3,
                  table_key_color = '88CCFF' }

    local f1 = lpp:Formatter(fc1)
    local f2 = lpp:Formatter(fc2)

    --- @type LibPrettyPrint_PrinterConfig
    local pc1 = { prefix= "MacroPlus", sub_prefix = "Options", show_all = true,
                  prefix_color = 'FF95A8', sub_prefix_color = 'FFFA0E',
                  use_dump_tool = false, }
    --- @type LibPrettyPrint_PrinterConfig
    local pc2 = { prefix="Gears", sub_prefix="Namespace"  }

    local val = {
        {
            hello='world', level=12, helper=function() end,
            handler = {
                name = 'mouseEventHandler', callback= function()  end
            },
            values = {1, 2, 3}
        }
    }
    local p1 = lpp:Printer(pc1, f1)
    local p2 = lpp:Printer(pc2, f2)
    return f1, f2, p1, p2, val
end


