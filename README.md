# Dynamically Control Opacity

## Install

*Note:* `*path*` *is the path to this repository.*

### Normal Installation

```
kpackagetool5 --type KWin/Script -i *path*
mkdir -p ~/.local/share/kservices5
cd ~/.local/share/kservices5
ln -s *path*/metadata.desktop kwin-script-opacity-control.desktop 
```

### Local Installation (Advanced)

```
mkdir -p ~/.local/share/kwin/scripts/opacity-control
cd ~/.local/share/kwin/scripts/opacity-control
ln -s *path*/contents contents
ln -s *path*/metadata.desktop metadata.desktop
mkdir -p ~/.local/share/kservices5
cd ~/.local/share/kservices5
ln -s *path*/metadata.desktop kwin-script-opacity-control.desktop 
```

*Note: You can replace `ln -s` for `cp`, if you prefer to copy and not have it linked to your cloned repository (if you do this then you're pretty much manually doing what `kpackagetool5` does), using `ln` instead of `cp` will result in an automatic update when you pull the latest changes*

### System Installation

*replace `~/.local/share` for `/usr/share` in Local Installation (Advanced) Method*

## Uninstall  

Delete the linked or copied files that you created during installation. To remove installed scripts by `kpackagetool5`, run the same command again but this time with `-r` instead of `-i` to remove (see manual of `kpackagetool5` for more info)

## Functionality
- toggle per client `Opacity-Control: Toggle Active`
- toggle all `Opacity-Control: Toggle All`
- set the opacity `opacity`
- set opacity default state
- set blur

## Recommended Setup
- set shortcut `Opacity-Control: Toggle Active` to `Meta+O`
- set shortcut `Opacity-Control: Toggle All` to `Ctrl+Meta+O`
