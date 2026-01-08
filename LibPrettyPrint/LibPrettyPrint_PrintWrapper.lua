--- @type Kapresoft_Base_Namespace
local _, ns   = ...
--- @type LibStub
local LibStub = LibStub

--- @type LibPrettyPrint_PrettyPrint
local LIB     = LibStub('LibPrettyPrint-1.0'); if not LIB then return end

--- @class LibPrettyPrint_PrettyPrintWrapper
local pformatWrapper = { pprint = LIB.pprint }
LIB.pformat          = pformatWrapper

--- Note: Indent only matters if use_newline = true; otherwise set indent_size to 1
do
    local o = pformatWrapper
    local pprint = o.pprint

    --- @alias
    --- @see LibPrettyPrint_PrettyPrintWrapper#A()
    --- @return LibPrettyPrint_PrettyPrintWrapper
    function o:Default() return self:A() end

    --- @alias
    --- @see LibPrettyPrint_PrettyPrintWrapper#B()
    --- @return LibPrettyPrint_PrettyPrintWrapper
    function o:Indent() return self:B() end

    --- @default
    --- Show functions, Single line, Compact.
    --- Sticky setup. Can call only once or chain it.
    --- ### Examples
    --- ```
    ---  # Given
    ---  local val = { a=1, b=2, note='Hello World'}
    ---
    ---  local pf = L.pformat -- default; same as L.pformat:A()
    ---  print('Val:', val)
    ---
    ---  # change setup to use newlines
    ---  local pf = L.pformat:B()
    ---  print('Val:', pf(val)
    ---
    ---  # chain the call with change setup to use newlines
    ---  local pf = L.pformat
    ---  print('Val:', pf(val), 'Val with Newlines:', pf:B()(val))
    --- ```
    --- @return LibPrettyPrint_PrettyPrintWrapper
    function o:A()
        pprint.setup({ use_newline = false, wrap_string = true, indent_size=1, sort_keys=true,
                       level_width=120, show_all=false, depth_limit = true })
        return self;
    end

    --- Show All, New Lines, Compact
    --- Sticky setup. Can call only once or chain it.
    --- ### Examples
    --- ```
    ---  # Given
    ---  local val = { a=1, b=2, note='Hello World'}
    ---
    ---  local pf = L.pformat -- default; same as L.pformat:A()
    ---  print('Val:', val)
    ---
    ---  # change setup to use newlines
    ---  local pf = L.pformat:B()
    ---  print('Val:', pf(val)
    ---
    ---  # chain the call with change setup to use newlines
    ---  local pf = L.pformat
    ---  print('Val:', pf(val), 'Val with Newlines:', pf:B()(val))
    --- ```
    --- @return LibPrettyPrint_PrettyPrintWrapper
    function o:B()
        pprint.setup({ use_newline = true, wrap_string = true, indent_size=2, sort_keys=true,
                       level_width=120, show_all=true, show_function = true, depth_limit = true })
        return self;
    end

    --- ```
    ---  # Given
    ---  local val = { a=1, b=2, note='Hello World'}
    ---
    ---  local pf = L.pformat -- default; same as L.pformat:A()
    ---  print('Val:', val)
    ---
    ---  # change setup to use newlines
    ---  local pf = L.pformat:B()
    ---  print('Val:', pf(val)
    ---
    ---  # chain the call with change setup to use newlines
    ---  local pf = L.pformat
    ---  print('Val:', pf(val), 'Val with Newlines:', pf:B()(val))
    --- ```
    --- @return string
    function o:pformat(obj, option, printer)
        return pprint.pformat(obj, option, printer)
    end

    o.mt = { __call = function (_, ...) return o.pformat(o, ...) end }
    setmetatable(o, o.mt)

    -- default setup
    o:Default()
end

do
    local o = LIB
    function o.dump(msg) DevTools_DumpCommand(msg) end
    function o.dumpv(any)
        local tmp = {}
        print('Dump Value:')
        table.insert(tmp, any)
        DevTools_Dump(tmp)
    end
end
