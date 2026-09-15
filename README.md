# Install

## Windows

Copy `vlc-delete.lua` to `%appdata%\vlc\lua\extensions\` and restart the VLC Media Player.

### Installation script (requires Windows 10/11 / curl)

```batch
mkdir "%appdata%\vlc\lua\extensions\"
curl -# -o "%appdata%\vlc\lua\extensions\vlc-delete.lua" "https://raw.githubusercontent.com/surrim/vlc-delete/master/vlc-delete.lua"
```

## Linux

Copy the `vlc-delete.lua` file to `~/.local/share/vlc/lua/extensions/` and restart the VLC Media Player.

### Installation script

```bash
EXTENSIONS_FOLDER="$HOME/.local/share/vlc/lua/extensions"
# EXTENSIONS_FOLDER="$HOME/.var/app/org.videolan.VLC/data/vlc/lua/extensions" # for Flatpak
# EXTENSIONS_FOLDER="$HOME/snap/vlc/current/.local/share/vlc/lua/extensions" # for Snap
# EXTENSIONS_FOLDER="$HOME/Library/Application Support/org.videolan.vlc/lua/extensions" # for Mac

mkdir -p "$EXTENSIONS_FOLDER"
curl -# -o "$EXTENSIONS_FOLDER/vlc-delete.lua" "https://raw.githubusercontent.com/surrim/vlc-delete/master/vlc-delete.lua"
```

Note: If [trash-cli](https://pypi.org/project/trash-cli/) is installed videos will be moved to the recycle bin instead of removing them directly.

## Hotkey (optional)

VLC extensions can't register shortcut keys, so the hotkey is a separate Lua interface script, `vlc-delete-hotkey.lua`.
It needs `vlc-delete.lua` installed as described above.

1. Copy `vlc-delete-hotkey.lua` to the `lua/intf` folder next to the `lua/extensions` folder, e.g. `~/.local/share/vlc/lua/intf/` on Linux or `%appdata%\vlc\lua\intf\` on Windows.

   ```bash
   INTF_FOLDER="$HOME/.local/share/vlc/lua/intf"
   mkdir -p "$INTF_FOLDER"
   curl -# -o "$INTF_FOLDER/vlc-delete-hotkey.lua" "https://raw.githubusercontent.com/surrim/vlc-delete/master/vlc-delete-hotkey.lua"
   ```

2. Enable the script in `Tools` → `Preferences` → `Show settings: All` → `Interface` → `Main interfaces`:
   - check `Lua interpreter`
   - in `Main interfaces` → `Lua`, set `Lua interface` to `vlc-delete-hotkey`

   Or add these lines to `vlcrc` (`~/.config/vlc/vlcrc` on Linux, `%appdata%\vlc\vlcrc` on Windows) while VLC is closed:

   ```ini
   extraintf=luaintf
   lua-intf=vlc-delete-hotkey
   ```

3. The default hotkey is `d`, which VLC already uses for `Toggle deinterlacing`.
   Clear that binding in `Tools` → `Preferences` → `Hotkeys` (or add `key-deinterlace=` to `vlcrc`), otherwise both actions run.
   To use another key, edit `HOTKEY` at the top of `vlc-delete-hotkey.lua`, e.g. `"Shift+Delete"` or `"Ctrl+Alt+x"`.

4. Restart VLC.

# Usage

When playing a video you can click on `View` → `Remove current file from playlist and disk`, or press the hotkey. Then the video will be removed and the next one is played.

# Known bugs and issues

- The hotkey doesn't work while the playlist has the keyboard focus. There `Delete` only removes the selected items from the playlist.
- Without `vlc-delete-hotkey.lua` there is no *fixed* shortcut key; it depends on the menu language.  
  For instance in English: Press and hold `Alt`  to activate the hotkey navigation, then press `i` (`Vi̲ew`), then `r` (`R̲emove current file from playlist and disk`).  
  ![Hotkeys animation](https://raw.githubusercontent.com/surrim/vlc-delete/master/hotkeys.webp)
  - For AutoHotKey v2 and English menus, you can use the following script.

```
#Requires AutoHotkey v2.0

#HotIf WinActive("ahk_exe vlc.exe")
^Delete:: {
    Send("{Blind}{Ctrl up}{Delete up}")
    Send("{Blind}{Alt down}{i down}{i up}{r down}{r up}{Alt up}")
}
#HotIf
```

Thanks for contributing [DanKaplanSES](https://github.com/DanKaplanSES), [abramter](https://github.com/abramter),
[saiqulhaq](https://github.com/saiqulhaq) and [Francisco Corrales Morales](https://github.com/franciscocorrales).

- Windows: UNC paths like `\SERVER\Share\File.mp4` are not working.  
  As a workaround, you could use `net use P: "\uncpath"` in the Windows terminal and open the file with a regular path.
  Thanks for contributing [Taomyn](https://github.com/Taomyn) and [freeload101](https://github.com/freeload101)
- Windows: Video can't be deleted if the file name contains emojis.  
  Thanks for contributing [Jonas1312](https://github.com/Jonas1312)
- Does not work with VLC portable edition
  Thanks for contributing [fun29](https://github.com/fun29)

If you create a new issue please include your VLC Version number and operating system. Otherwise it's hard to reproduce.  
The biggest help would be to contribute some Lua Code.

## Donations

[![liberapay](https://img.shields.io/liberapay/goal/surrim.svg?logo=liberapay)](https://liberapay.com/surrim/donate)
