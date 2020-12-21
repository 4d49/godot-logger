# Godot-Log

Simple in-game logger for Godot 3.2.

![](https://i.imgur.com/LToP4Jg.png)

# Features
- Installed as plugin.
- Singletone Log.
- Write to log file.
- Disable log levels.
- Custom log levels.

# Installation:
1. Clone or download this project to `addons/godot-log` folder.
2. Enabled `Godot Log` in Plugins.
3. Add `LogContainer` node to the scene.
4. Profit.

# Usage:
## Calling default levels:
```gdscript
Log.info(text)
Log.debug(text)
Log.warning(text)
Log.error(text)
Log.fatal(text)
```

## Create a custom log level:
```gdscript
const CUSTOM = 1<<6 # Level integer.

func _ready() -> void:
	Log.add_level(CUSTOM, "CUSTOM")
```

## Calling a custom level:
```gdscript
Log.message(CUSTOM, "Something happened")
```

## Disable log level:
```gdscript
Log.set_level(Log.INFO, false)
```

## Enable log level:
```gdscript
Log.set_level(Log.INFO, true)
```

## License
Copyright © 2020 Mansur Isaev and contributors

Unless otherwise specified, files in this repository are licensed under the
MIT license. See [LICENSE.md](LICENSE.md) for more information.
