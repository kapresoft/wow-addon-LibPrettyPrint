# LibPrettyPrint
> Because staring at raw Lua tables shouldn’t hurt in World of Warcraft.

### Who is this for?
>Intended for addon developers who want safer, more readable debug output during development.

LibPrettyPrint is a lightweight utility library for readable, safe table inspection and debugging in World of Warcraft. It pretty-prints Lua values with configurable depth limits, key sorting, and flexible formatting, safely handles cyclic tables, and is designed for development and debugging use without impacting runtime performance.

Based on [jagt/pprint.lua][1], which is itself a reimplementation of [inspect.lua][2].
Adapted and extended for World of Warcraft.

## Interface Definition File
> Defines the public API and type annotations.
- [Interface.lua](LibPrettyPrint/Libs/Developer/Interface.lua)

## Usage Examples

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

* `:Compact()` and `:MultiLine()` return **new formatter instances** -- see also [Interface.lua](LibPrettyPrint/Libs/Developer/Interface.lua)
* The original formatter remains unchanged
* Useful for creating formatting variants (compact vs verbose)
* Derived formatters can be safely reused or shared

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
