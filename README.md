# Godot-Log

Simple in-game logger for Godot 4.0.

![](https://user-images.githubusercontent.com/8208165/144706770-e4fda4c0-249b-4851-b7a8-8d0bc3d278bc.png)

# Features
- Installed as plugin.
- Singleton Log.
- Write to log file.
- Disable log levels.
- Custom log levels.

# Installation:
1. Clone or download this repository to `addons` folder.
2. Enable `Godot Log` in Plugins.
3. Add `LogOutput` node to the scene.
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
# main.gd
const CUSTOM = Log.MAX << 1 # Bitwise left shift the MAX value for a custom level.

func _ready() -> void:
	Log.add_level(CUSTOM, "Level Name")
```

## Calling the custom level:
```gdscript
Log.message(CUSTOM, "Something happened")
```

## Disable log level:
```gdscript
Log.set_level(Log.INFO, false) # Disable built-in level.
Log.set_level(CUSTOM, false) # Disable custom level.
```

## Enable log level:
```gdscript
Log.set_level(Log.DEBUG, true) # Enable built-in level.
Log.set_level(CUSTOM, true) # Enable custom level.
```

# License
Copyright (c) 2020-2024 Mansur Isaev and contributors

Unless otherwise specified, files in this repository are licensed under the
MIT license. See [LICENSE.md](LICENSE.md) for more information.
