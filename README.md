# Godot Class Reference
[<img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" alt="Buy Me A Coffee" height="60" width="217" >](https://www.buymeacoffee.com/fengjiongmax)

Class reference for Godot Engine on both iOS and Android.

[<img src="google-play-badge.png" height="50">](https://play.google.com/store/apps/details?id=com.fengjiongmax.godotclassreference)
[<img src="appstore-badge.png" height="50">](https://apps.apple.com/qa/app/godot-class-reference/id1523486419)

## Getting Started
[flutter online documentation](https://flutter.dev/docs)

## Update Godot docs
* get the [official Godot repository](https://github.com/godotengine/godot):
```bash
git clone https://github.com/godotengine/godot.git
```
* install required python package
```bash
pip install GitPython polib
# Or in Ubuntu 24.04:
sudo apt install python3-git python3-polib
``` 
* run the python script,which will update docs and svg files for published Godot versions(2.0 to 3.4)
```bash
cd scripts # must enter scripts folder
./godot_repo.py --godot_path [your godot repo path]
```

