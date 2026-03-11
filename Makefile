APP     = DynamicNotch
BUILD   = build
CC      = clang
FLAGS   = -fobjc-arc -fmodules -framework Cocoa -mmacosx-version-min=13.0

SOURCES = main.m \
          AppDelegate.m

all:
	mkdir -p $(BUILD)/$(APP).app/Contents/MacOS
	$(CC) $(FLAGS) $(SOURCES) -o $(BUILD)/$(APP).app/Contents/MacOS/$(APP)
	cp Info.plist $(BUILD)/$(APP).app/Contents/Info.plist

run: all
	open $(BUILD)/$(APP).app/Contents/MacOS/$(APP)

clean:
	rm -rf $(BUILD)
