# LibPrettyPrint
> Because staring at raw Lua tables shouldn’t hurt in World of Warcraft.


LibPrettyPrint is a lightweight utility library for readable, safe table inspection and debugging in World of Warcraft. It pretty-prints Lua values with configurable depth limits, key sorting, and flexible formatting, safely handles cyclic tables, and is designed for development and debugging use without impacting runtime performance.

Based on [jagt/pprint.lua][1], which is itself a reimplementation of [inspect.lua][2].
Adapted and extended for World of Warcraft.

## License

[The Unlicense][3]

[1]: https://github.com/jagt/pprint.lua
[2]: https://github.com/kikito/inspect.lua
[3]: https://unlicense.org
