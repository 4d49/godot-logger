# Godot-Log

Simple in-game logger for Godot 3.2.

![](https://i.imgur.com/LToP4Jg.png)

# Features
- Installed as plugin.
- Singletone Log.
- Write to log file.

# Installation:
1. Clone or download this project to `addons/godot-log` folder.
2. Enabled `Godot Log` in Plugins.
3. Add `LogContainer` node to the scene.
4. Profit.

# Usage:
## Calling methods without a tag:
```gdscript
func _ready() -> void:
	Log.info(text)
	Log.debug(text)
	Log.warning(text)
	Log.error(text)
```

## Calling methods with a tag:
```gdscript
func _ready() -> void:
	Log.info(text, tag)
	Log.debug(text, tag)
	Log.warning(text, tag)
	Log.error(text, tag)
```

## Calling methods with a custom bit mask:
```gdscript
func _ready() -> void:
	Log.message(text, CUSTOM_BIT, tag)
```

## Disable log level:
```gdscript
func _ready() -> void:
	Log.set_level_bit(Log.INFO, false)
```

## License
Copyright © 2020 Mansur Isaev and contributors

Unless otherwise specified, files in this repository are licensed under the
MIT license. See [LICENSE.md](LICENSE.md) for more information.
