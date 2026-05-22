APP      = NetcatGUI
BUNDLE   = $(APP).app
ICON_DIR = Resources/AppIcon.appiconset
ICON_OUT = Resources/AppIcon.icns
ICONSET  = /tmp/NetcatGUI.iconset

.PHONY: all run clean icons

all: $(BUNDLE)

$(BUNDLE): .build/release/$(APP) $(ICON_OUT)
	@mkdir -p $(BUNDLE)/Contents/MacOS
	@mkdir -p $(BUNDLE)/Contents/Resources
	cp .build/release/$(APP) $(BUNDLE)/Contents/MacOS/
	cp Resources/Info.plist $(BUNDLE)/Contents/
	cp $(ICON_OUT) $(BUNDLE)/Contents/Resources/
	@echo "Built $(BUNDLE)"

.build/release/$(APP):
	swift build -c release

icons: $(ICON_OUT)

$(ICON_OUT): $(ICON_DIR)/1024-mac.png
	@rm -rf $(ICONSET) && mkdir -p $(ICONSET)
	sips -s format png -z 16  16  "$(ICON_DIR)/1024-mac.png" --out "$(ICONSET)/icon_16x16.png"      >/dev/null
	sips -s format png -z 32  32  "$(ICON_DIR)/1024-mac.png" --out "$(ICONSET)/icon_16x16@2x.png"   >/dev/null
	sips -s format png -z 32  32  "$(ICON_DIR)/1024-mac.png" --out "$(ICONSET)/icon_32x32.png"      >/dev/null
	sips -s format png -z 64  64  "$(ICON_DIR)/1024-mac.png" --out "$(ICONSET)/icon_32x32@2x.png"   >/dev/null
	sips -s format png -z 128 128 "$(ICON_DIR)/1024-mac.png" --out "$(ICONSET)/icon_128x128.png"    >/dev/null
	sips -s format png -z 256 256 "$(ICON_DIR)/1024-mac.png" --out "$(ICONSET)/icon_128x128@2x.png" >/dev/null
	sips -s format png -z 256 256 "$(ICON_DIR)/1024-mac.png" --out "$(ICONSET)/icon_256x256.png"    >/dev/null
	sips -s format png -z 512 512 "$(ICON_DIR)/1024-mac.png" --out "$(ICONSET)/icon_256x256@2x.png" >/dev/null
	sips -s format png -z 512 512 "$(ICON_DIR)/1024-mac.png" --out "$(ICONSET)/icon_512x512.png"    >/dev/null
	sips -s format png -z 1024 1024 "$(ICON_DIR)/1024-mac.png" --out "$(ICONSET)/icon_512x512@2x.png" >/dev/null
	iconutil -c icns -o $(ICON_OUT) $(ICONSET)
	@rm -rf $(ICONSET)
	@echo "Generated $(ICON_OUT)"

run: all
	open $(BUNDLE)

clean:
	swift package clean
	rm -rf $(BUNDLE)
