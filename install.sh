#!/bin/bash
set -euo pipefail

override_dir="/Library/Displays/Contents/Resources/Overrides"
sudo mkdir -p "$override_dir"

for id in DisplayVendorID-*; do
	sudo mkdir -p "$override_dir/$id"

	for pl in "$id"/*.plist; do
		echo "${pl%.plist}"
		target="$override_dir/${pl%.plist}"
		sudo cp "$pl" "$target"
		sudo chown root:wheel "$target"
		sudo chmod 0664 "$target"
	done
done

print "Enabling DisplayResolution in /Library/Preferences/com.apple.windowserver..."
sudo defaults write /Library/Preferences/com.apple.windowserver DisplayResolutionEnabled -bool YES
sudo defaults delete /Library/Preferences/com.apple.windowserver DisplayResolutionDisabled >/dev/null 2>&1
