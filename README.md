# Godot-Log

Simple in-game logger for Godot 3.2.

![](https://i.imgur.com/LToP4Jg.png)

# Features
- Installed as plugin.
- Singleton Log.
- Write to log file.
- Disable log levels.
- Custom log levels.

# Installation:
1. Clone or download this project to `addons/godot-log` folder.
2. Enable `Godot Log` in Plugins.
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
const LOG_AI = Log.FATAL << 1 # Increase the value for a custom level.

func _ready() -> void:
	Log.add_level(LOG_AI, "AI")
```

## Calling the custom level:
```gdscript
Log.message(LOG_AI, "Something happened")
```

## Disable log level:
```gdscript
Log.set_level(Log.INFO, false)
```

## Enable log level:
```gdscript
Log.set_level(Log.DEBUG, true)
```

# License
Copyright © 2020 Mansur Isaev and contributors

Unless otherwise specified, files in this repository are licensed under the
MIT license. See [LICENSE.md](LICENSE.md) for more information.
