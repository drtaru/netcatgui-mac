APP      = NetcatGUI
BUNDLE   = $(APP).app
BINARY   = .build/universal/$(APP)
ARM_BIN  = .build/arm64-apple-macosx/release/$(APP)
X86_BIN  = .build/x86_64-apple-macosx/release/$(APP)
ICON_DIR = Resources/AppIcon.appiconset
ICON_SRC = $(ICON_DIR)/1024-mac.png
ICON_OUT = Resources/AppIcon.icns
ICONSET  = /tmp/$(APP).iconset

.PHONY: all run clean icons

all: $(BUNDLE)

$(BUNDLE): $(BINARY) $(ICON_OUT)
	@rm -rf $@
	@mkdir -p $@/Contents/MacOS $@/Contents/Resources
	cp $(BINARY)           $@/Contents/MacOS/
	cp Resources/Info.plist $@/Contents/
	cp $(ICON_OUT)          $@/Contents/Resources/
	@echo "Built $@"

$(BINARY):
	swift build -c release --arch arm64
	swift build -c release --arch x86_64
	@mkdir -p .build/universal
	lipo -create $(ARM_BIN) $(X86_BIN) -output $(BINARY)

$(ICON_OUT): $(ICON_SRC)
	@rm -rf $(ICONSET) && mkdir -p $(ICONSET)
	@for size in 16 32 64 128 256 512 1024; do \
		sips -s format png -z $$size $$size "$<" \
			--out "$(ICONSET)/icon_$${size}x$${size}.png" >/dev/null; \
	done
	@cp $(ICONSET)/icon_32x32.png   $(ICONSET)/icon_16x16@2x.png
	@cp $(ICONSET)/icon_64x64.png   $(ICONSET)/icon_32x32@2x.png
	@cp $(ICONSET)/icon_256x256.png $(ICONSET)/icon_128x128@2x.png
	@cp $(ICONSET)/icon_512x512.png $(ICONSET)/icon_256x256@2x.png
	@cp $(ICONSET)/icon_1024x1024.png $(ICONSET)/icon_512x512@2x.png
	iconutil -c icns -o $@ $(ICONSET)
	@rm -rf $(ICONSET)
	@echo "Generated $@"

run: all
	@pkill -x $(APP) 2>/dev/null || true
	open $(BUNDLE)

clean:
	swift package clean
	rm -rf $(BUNDLE) $(ICON_OUT) .build/universal