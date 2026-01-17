local addon, ns = ...
local O, GC, M, LibStub = ns.O, ns.GC, ns.M, ns.LibStub

--- @class Developer
local o = {}; lpp_dev = o

C_Timer.After(1, function()
    print(('xxx %s::Developer loaded...'):format(addon))
end)

function o:test()
    local lpp = LibPrettyPrint
    --- @type LibPrettyPrint_PrinterConfig
    local pc1 = { prefix ="P", sub_prefix = "S", show_all = true,
                  use_dump_tool = false, formatterConfig = pcf }
    --- @type LibPrettyPrint_PrinterConfig
    local pc2 = { prefix="P2", sub_prefix="S2"  }
    local fc = { use_newline = true }

    f1 = lpp:Formatter(fc)
    p1 = lpp:Printer(pc1)
    --f2 = lpp:Formatter()
    --p2 = lpp:Printer(pc2)
    p3 = p1:WithSubPrefix('NewSub')
end
