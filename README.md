[![Release Build](https://github.com/kapresoft/wow-addon-LibPrettyPrint/actions/workflows/release-build.yml/badge.svg?event=push)](https://github.com/kapresoft/wow-addon-LibPrettyPrint/actions/workflows/release-build.yml)

# LibPrettyPrint :: Because staring at raw Lua tables shouldn’t hurt in World of Warcraft. 

![download-count](https://cf.way2muchnoise.eu/full_1424095_downloads.svg?badge_style=for_the_badge) ![supported-wow-versions](https://cf.way2muchnoise.eu/versions/World%20of%20Warcraft%20Versions_1424095_all.svg?badge_style=for_the_badge)

### Who is this for?
>Intended for addon developers who want safer, more readable debug output during development.

LibPrettyPrint is a lightweight utility library for readable, safe table inspection and debugging in World of Warcraft. It pretty-prints Lua values with configurable depth limits, key sorting, and flexible formatting, safely handles cyclic tables, and is designed for development and debugging use without impacting runtime performance.

Based on [jagt/pprint.lua][1], which is itself a reimplementation of [inspect.lua][2].
Adapted and extended for World of Warcraft.

## Interface Definition File
> Defines the public API and type annotations.
- [LibPrettyPrint-Annotations.lua](Libs/Annotations/LibPrettyPrint-Annotations.lua)

## Usage Examples

### Obtaining an instance of LibPrettyFormat

When the library is loaded, it exposes a global reference named `LibPrettyPrint`.
This global always points to the latest registered version of the library.
 
```lua
print('LibPrettyPrint:', type(LibPrettyPrint))
```
If you prefer to retrieve the library explicitly via `LibStub`, you can do so using its major version:

```lua
local lpp = LibStub('LibPrettyPrint-1.0')
print('LibPrettyPrint:', type(lpp))
```

#### Notes:
- Both approaches return the same instance
- LibStub always resolves to the newest minor version of a given major
- Older versions cannot be retrieved once a newer one is registered


> A formatter converts Lua values into readable formatted strings.

### Formatter
```lua
local fmt = LibPrettyPrint:Formatter()

local val = { a = 1, b = { c = 2 } }
print('Values:', fmt(val))
```

#### Deriving a formatter (non-mutating)

```lua
local baseFormatter = LibPrettyPrint:Formatter({
  multiline_tables = true,
})

local compact = baseFormatter:Compact()
print('Values:', compact(val))

-- Or vice-versa:

local baseFormatter = LibPrettyPrint:Formatter({
  multiline_tables = false, -- default
})

local multi = baseFormatter:MultiLine()
print('Values:', multi(val))
```

#### Notes

* `:Compact()` and `:MultiLine()` return **new formatter instances** -- see also [LibPrettyPrint-Annotations.lua](Libs/Annotations/LibPrettyPrint-Annotations.lua)
* The original formatter remains unchanged
* Useful for creating formatting variants (compact vs verbose)
* Derived formatters can be safely reused or shared

#### Key/value formatter

`:KeyValues()` returns a formatter that expands each table argument into one sorted `key=value` string per entry, returned as separate values. This suits outputs that show each argument on its own row, such as Blizzard's Event Trace (`/etrace`).

```lua
local kv = LibPrettyPrint:Formatter():KeyValues()

print(kv({ name = 'Tony', level = 80, active = false, [1] = 'a' }))
-- 1='a'  active=false  level=80  name='Tony'
```

By default each value is colored by type with Event Trace's colors (strings green, numbers orange, booleans blue, tables light yellow) and string values are single-quoted. Set `key_values_type_colors = false` for plain text, e.g. output where color codes don't render:

```lua
local plain = LibPrettyPrint:Formatter({ key_values_type_colors = false }):KeyValues()
print(plain({ name = 'Tony', level = 80 }))
-- level=80  name=Tony
```

Pass an optional color to color each key, either a Blizzard color or a 6-char hex string:

```lua
local kvWhite = LibPrettyPrint:Formatter():KeyValues(WHITE_FONT_COLOR)
local kvHex   = LibPrettyPrint:Formatter():KeyValues('EFEFEF')
```

The formatter's color options also apply. `table_ref_color` and `table_cutoff_color` override the type colors for function values and nested tables.

```lua
local kv = LibPrettyPrint:Formatter({
  table_key_color    = 'FFD100', -- keys (same as the KeyValues() color)
  table_ref_color    = 'AAAAAA', -- function values
  table_cutoff_color = 'FF8080', -- nested tables (not expanded)
}):KeyValues()
```

* One level deep; nested tables show as `<table>` and functions as `<function>`, like `DevTools_Dump`
* Other values show via `tostring()`
* Number keys first (numerically), then string keys (alphabetically)
* An empty table returns `{}`
* Non-table arguments pass through unchanged; several tables flatten in order
* Lua only expands a call's results when it's the **last** argument: in `print(kv(a), 'x')` only the first entry of `a` shows

### Printer

> A printer formats values and sends them directly to output (e.g. chat frame).
> 
```lua
local p   = LibPrettyPrint:Printer()

-- use like print()
p('Hello', 'World')
p('Values:', { a = 1, b = { c = 2 } })
```

## Custom Configuration Examples

### Printer with Default Formatter
> By default, printers create and manage their own formatter.
> 
```lua
--- @type LibPrettyPrint_PrinterConfig
local config = {
  prefix = 'MyAddOn', sub_prefix = 'ModuleA'
}
local p = LibPrettyPrint:Printer(config)
p('Values:', { foo = { bar = { baz = 123 } } })
```
Output:
`[Timestamp] {{MyAddon::ModuleA}} Values: { ... }`

### Printer with Custom Formatter

A printer’s `formatter` field may be **either**:

* a **formatter configuration table**, or
* an existing **`LibPrettyPrint_Formatter` instance**

#### Formatter as configuration

```lua
--- @type LibPrettyPrint_FormatterConfig
local formatter = {
  depth_limit = 3,
  multiline_tables = true,
}
```

#### Formatter as an instance

```lua
--- @type LibPrettyPrint_Formatter
local formatter = LibPrettyPrint:Formatter({
  depth = 3,
  multiline_tables = true,
})
```

#### Using the formatter in a printer

```lua
local printerConfig = {
  prefix = 'MyAddOn',
  sub_prefix = 'ModuleA',
  formatter = formatter, -- config table or formatter instance
}

local p = LibPrettyPrint:Printer(printerConfig)
p('Values:', { foo = { bar = { baz = 123 } } })
```

#### Colors on the printer

`table_key_color`, `table_ref_color` and `table_cutoff_color` may also be set on the printer itself. They apply to its formatter, whether a config or an instance, and override the formatter's own colors.

```lua
local p = LibPrettyPrint:Printer({
  prefix          = 'MyAddOn',
  table_key_color = '7C750C',
  formatter       = LibPrettyPrint:Formatter():KeyValues(),
})
```

## Deriving a Printer (Sub-Prefixes)

### Use case

>Create scoped loggers for different addon modules while sharing the same base configuration.

### Example

```lua
-- Create a base printer for your addon
--- @type LibPrettyPrint_Printer
local printer = LibPrettyPrint:Printer({
  prefix = "MyAddOn",
})

printer("Entering...")
-- Output:
-- [Timestamp] {{MyAddOn}}: Entering
```

### Deriving a module-specific printer

```lua
-- Create a derived printer with an additional sub-prefix
local eventPrinter = printer:WithSubPrefix("EventHandler")

eventPrinter("Entering...")
-- Output:
-- [Timestamp] {{MyAddOn::EventHandler}}: Entering
```
#### Why this is useful

* Keeps logs **consistent and structured**
* Avoids repeating configuration across modules
* Derived printers **inherit config** but remain isolated
* Ideal for large addons with multiple subsystems

**Tip:** You can safely chain sub-prefixes (`A::B::C`) without mutating the original printer.

## Including a Predicate in a Printer

A printer may be created with an optional **predicate function** that controls whether output is emitted.
The predicate is evaluated **at print time** and must return `true` for output to occur.

This is useful for:

* Development-only logging
* Feature-flagged diagnostics
* Conditional debug output without scattering `if` checks

### Example: Development-only printer

```lua
-- Given a function: settings:IsDev() that returns a boolean

--- @type LibPrettyPrint_Printer
local printer = LibPrettyPrint:Printer({
  prefix = "MyAddOn",
}, function() return settings:IsDev() end)

printer("This will only print in dev mode")
```

If the predicate returns `false`, the printer becomes a **no-op** and produces no output.

### How predicates work

* The predicate is a function returning `boolean`
* It is evaluated **each time the printer is invoked**
* No formatting or allocation occurs when the predicate fails

All derived printers inherit the predicate automatically.

### When to use predicates

* Toggle verbose logging without code changes
* Avoid runtime overhead in production
* Centralize debug-mode logic

### Notes

* Predicates are optional
* Prefer predicates over manual `if` checks around print calls
* Predicate functions should be **fast and side-effect free**


## License

[The Unlicense][3]

[1]: https://github.com/jagt/pprint.lua
[2]: https://github.com/kikito/inspect.lua
[3]: https://unlicense.org

### Donations

If LibPrettyPrint has made your gameplay or addon development easier, consider supporting its development:

- **[Paypal&trade; Donation](https://www.paypal.com/donate/?hosted_button_id=AX58YP3GSGXVU)**
- **[Bitcoin Donation](https://www.blockchain.com/btc/address/3QQVAwJGkKHMM2oq6CLVWYgfx83TFVwp39)**

## About

- About the Author [(Tony Lagnada)](https://tony.resume.lagnada.com/)
- My AddOn Portfolio Can Be Found Here [Curse Forge/Kapresoft](https://www.curseforge.com/members/kapresoft/projects)