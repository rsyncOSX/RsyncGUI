all: release
debug:
	xcodebuild -derivedDataPath $(PWD) -configuration Debug -scheme RsyncGUI
release:
	xcodebuild -derivedDataPath $(PWD) -configuration Release -scheme RsyncGUI
clean:
	rm -Rf Build
	rm -Rf ModuleCache.noindex
	rm -Rf info.plist
	rm -Rf Logs
