--[[-------------------------------------------------------------------
Public Interface
---------------------------------------------------------------------]]
--- The global `LibPrettyPrint`, also LibStub('LibPrettyPrint-1.0')
--- @class LibPrettyPrint-1.0
--- @field Printer fun(self:LibPrettyPrint-1.0, config?:LibPrettyPrint_PrinterConfig, predicateFn?:LibPrettyPrint_PredicateFn) : LibPrettyPrint_Printer
--- @field Formatter fun(self:LibPrettyPrint-1.0, config?:LibPrettyPrint_FormatterConfig) : LibPrettyPrint_Formatter

--- @alias LibPrettyPrint_Printer LibPrettyPrint_PrinterInterface | fun(...) : void
--- @alias LibPrettyPrint_Formatter LibPrettyPrint_FormatterInterface | fun(...) : void

-- Basic Examples:

--- @type LibPrettyPrint_Formatter
local fmt = LibPrettyPrint:Formatter()
print('hello:', fmt({ 1, 2, 3 }))

--- @type LibPrettyPrint_Printer
local p = LibPrettyPrint:Printer()
p('hello:', { 1, 2, 3 })

--[[-----------------------------------------------------------------------------
Type Defs
-------------------------------------------------------------------------------]]
--- @alias LibPrettyPrint_PrintFn fun(...: any) : void Printer function that accepts any values and outputs formatted text; behaves like print
--- @alias LibPrettyPrint_PrintFnDelayed fun(...: any) : void Delayed printer function that accepts any values and outputs formatted text; behaves like print
--- @alias LibPrettyPrint_PredicateFn fun() : boolean Function that evaluates a condition and returns true or false
--- @alias LibPrettyPrint_RGBHex string The 6-char RGBHex color string, i.e. EFEFEF

--- @class LibPrettyPrint_PrinterInterface
--- @field WithSubPrefix fun(self:LibPrettyPrint_Printer, sub_prefix:string) : LibPrettyPrint_Printer
--- @field New fun(self:LibPrettyPrint_Printer, config?:LibPrettyPrint_PrinterConfig, predicateFn?:LibPrettyPrint_PredicateFn) : LibPrettyPrint_Printer

--- @class LibPrettyPrint_FormatterInterface
--- @field Compact fun(self:LibPrettyPrint_Formatter) : LibPrettyPrint_Formatter
--- @field MultiLine fun(self:LibPrettyPrint_Formatter) : LibPrettyPrint_Formatter
--- @field KeyValues fun(self:LibPrettyPrint_Formatter, color?:colorRGBA|LibPrettyPrint_RGBHex) : LibPrettyPrint_Formatter
--- @field New fun(self:LibPrettyPrint_Formatter, config?:LibPrettyPrint_FormatterConfig) : LibPrettyPrint_Formatter

--- @class LibPrettyPrint_FormatterConfig
--- @field multiline_tables? boolean                 @Add newlines to tables for each element.                    default=false
--- @field show_function? boolean                    @Limit show functions.                                       default=true
--- @field depth_limit? boolean|number               @If set to number N, then limit table recursion to N deep.   default=1
--- @field wrap_string? boolean                      @Wrap string when it's longer than level_width.              default=true
--- @field indent_size? number                       @Indent size when using newlines.                            default=2
--- @field sort_keys? boolean                        @Sort table keys.                                            default=true
--- @field show_all? boolean                         @Show all value types. Also shows metatables if enabled.     default=false
--- @field level_width? number                       @Max line width before wrapping.                             default=80
--- @field show_metatable? boolean                   @Show metatables.                                            default=false
--- @field key_values? boolean                       @Expand table args into sorted key=value varargs.            default=false
--- @field key_values_type_colors? boolean           @KeyValues: Event Trace colors, quoted strings; false=plain. default=true
--- @field table_key_color? LibPrettyPrint_RGBHex    @Keys
--- @field table_ref_color? LibPrettyPrint_RGBHex    @Function values
--- @field table_cutoff_color? LibPrettyPrint_RGBHex @Depth cutoff marker; KeyValues: nested tables

--- @class LibPrettyPrint_PrinterConfig
--- @field prefix? string                            @The main prefix in {{ PREFIX::SUBPREFIX }} : <Message>
--- @field prefix_color? LibPrettyPrint_RGBHex
--- @field sub_prefix? string                        @The sub-prefix {{ PREFIX::SUBPREFIX }} : <Message>
--- @field sub_prefix_color? LibPrettyPrint_RGBHex
--- @field table_key_color? LibPrettyPrint_RGBHex    @Overrides the formatter's
--- @field table_ref_color? LibPrettyPrint_RGBHex    @Overrides the formatter's
--- @field table_cutoff_color? LibPrettyPrint_RGBHex @Overrides the formatter's
--- @field show_timestamp? boolean                   @Shows timestamp for every print; default=true
--- @field formatter? LibPrettyPrint_FormatterConfig|LibPrettyPrint_Formatter
--- @field predicateFn? LibPrettyPrint_PredicateFn

--- @class LibPrettyPrint_PrinterColorDefs
--- @field prefix string The 8-char hex string, i.e. ffEFEFEF
--- @field sub_prefix string The 8-char hex string, i.e. ffEFEFEF

--- @class LibPrettyPrint_FormatterColorDefs
--- @field table_key string The 8-char hex string, .e. 32CF21
--- @field table_value string The 8-char hex string, .e. A8ECFF
