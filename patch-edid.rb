#!/usr/bin/ruby
# Create display override file to force macOS to use RGB mode for the display.
# Original: http://embdev.net/topic/284710

require 'base64'

data=`ioreg -l -w0 -d0 -r -c AppleDisplay`

edids=data.scan(/IODisplayEDID.*?<([a-z0-9]+)>/i).flatten
vendorids=data.scan(/DisplayVendorID.*?([0-9]+)/i).flatten
productids=data.scan(/DisplayProductID.*?([0-9]+)/i).flatten

displays = []
edids.each_with_index do |edid, i|
	disp = { "edid_hex"=>edid, "vendorid"=>vendorids[i].to_i, "productid"=>productids[i].to_i }
	displays.push(disp)
end

# Process all displays
if displays.length > 1
	puts "Found %d displays! You should only install the override file for the one which" % displays.length
	puts "is giving you problems.\n"
end
displays.each do |disp|
	# Retrieve monitor model from EDID data
	monitor_name=[disp["edid_hex"].match(/000000fc00(.*?)0a/){|m|m[1]}.to_s].pack("H*")
	if monitor_name.empty?
		monitor_name = "Display"
	end

	puts "Found display: #{monitor_name} (VendorID #{disp["vendorid"]}, ProductID #{disp["productid"]})"
	puts "EDID: #{disp["edid_hex"].upcase}"

	bytes=disp["edid_hex"].scan(/../).map{|x|Integer("0x#{x}")}.flatten

	puts "Setting color support to RGB 4:4:4 only..."
	bytes[24] &= ~(0b11000)

	puts "Number of extension blocks: #{bytes[126]}"
	puts "Removing extension block..."
	bytes = bytes[0..127]
	bytes[126] = 0

	bytes[127] = (0x100-(bytes[0..126].reduce(:+) % 256)) % 256
	puts "Recalculated checksum: 0x%x" % bytes[127]
	puts "New EDID: #{bytes.map{|b|"%02X"%b}.join.upcase}"

	Dir.mkdir("DisplayVendorID-%x" % disp["vendorid"]) rescue nil
	name = "DisplayVendorID-%x/DisplayProductID-%x" % [disp["vendorid"], disp["productid"]]
	f = File.open(name, 'w')
	f.write '<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">'
	f.write "
	<dict>
		<key>DisplayProductName</key>
		<string>#{monitor_name} - forced RGB mode (EDID override)</string>
		<key>IODisplayEDID</key>
		<data>#{Base64.encode64(bytes.pack('C*'))}</data>
		<key>DisplayVendorID</key>
		<integer>#{disp["vendorid"]}</integer>
		<key>DisplayProductID</key>
		<integer>#{disp["productid"]}</integer>
	</dict>
</plist>"
	f.close
	puts "Created: #{name}\n"
end
