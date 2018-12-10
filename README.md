# Display Overrides for macOS

This is for display overrides to make (my) monitors work better on macOS.

Goals:

- Force HiDPI modes for screens that are not supported (by macOS)
- Force picture modes on misbehaving screens
- Fix displays detected as TVs
- Make sure Night Shift works on external displays

## Usage

1. Create overrides (`DisplayVendorID-*/DisplayProductID-*.plist`) or use the existing ones
2. Boot into recovery
3. Mount `Macintosh HD`
4. Open Terminal and run `./install.sh` from the project folder (`/Volumes/Macintosh HD/path/to/project`)
5. Reboot

## Notes

- Since macOS Mojave we no longer seem to need RGB edid overrides, they are ineffective

## Dumping display EDID

Create a dump for each display connected to your Mac.

```bash
n=0; \
ioreg -lw0 | grep "IODisplayEDID" \
	| while read line; do \
		(( n++ )); \
		name=display-${n}.edid; \
		sed "/[^<]*</s///" <<<"$line" | xxd -p -r > $name; \
		echo "Created $name"; \
	done
```

## Resources

- [Display Override PropertyList File Parser and Generator with HiDPI support](https://comsysto.github.io/Display-Override-PropertyList-File-Parser-and-Generator-with-HiDPI-Support-For-Scaled-Resolutions/)
- [edid-decode](https://git.linuxtv.org/edid-decode.git/)
