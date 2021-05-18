## RsyncGUI

![](icon/rsyncosx.png)

[The changelog](https://rsyncosx.netlify.app/post/rsyncguichangelog/).

This project is archived and there is no further development. There will be released a Sandboxed version of [RsyncUI](https://github.com/rsyncOSX/RsyncUI) later in 2021 to replace RsyncGUI. The app will be avaliable for download on Apple Mac Store until a replacement is released.

This repository is the source code for the macOS app RsyncGUI. RsyncGUI is a sandboxed macOS app compiled with support for macOS Catalina 10.15 - macOS Big Sur 11.01. The application is implemented in pure Swift 5 (Cocoa and Foundation). RsyncGUI is not depended upon any third party binary distributions. Rsync is a file-based synchronization and backup tool. There is no custom solution for the backup archive. You can quit utilizing RsyncGUI (and rsync) at any time and still have access to all synchronized files.

<a href="https://apps.apple.com/us/app/rsyncgui/id1449707783?mt=12">
  <img alt="Download on the Mac App Store" src="icon/appstore.svg">
</a>

The app was [released](https://itunes.apple.com/us/app/rsyncgui/id1449707783?l=nb&ls=1&mt=12) on Mac App Store as version 1.0.0 of `RsyncGUI` 24 January 2019.

### Apple App Sandboxing technology

Apple has the [App Sandboxing technology](https://developer.apple.com/app-sandboxing/) for protecting the user for malicious software. To release a macOS app on Apple Mac App Store require the app to execute inside a sandbox. This repository is a fork of RsyncOSX to enable RsyncGUI to execute inside a sandbox to be released on the Mac App Store. The name of the app is due to Apple naming conventions for apps released on the Mac App Store. Some of the work on sandbox is based upon [Sandbox code](https://github.com/regexident/Sandbox).

### Some words about RsyncGUI

RsyncGUI is not developed to be an easy synchronize and backup tool. The main purpose is to ease the use of `rsync` and synchronize files on your Mac to remote FreeBSD and Linux servers. And of course restore files from remote servers. The UI might also be difficult to understand or complex if you don't know what `rsync` is. It is not required to know `rsync` but it will ease the use and understanding of RsyncGUI. But it is though, possible to use RsyncGUI by just adding a source and remote backup catalog using default parameters.

If your plan is to use RsyncGUI as your main tool for backup of files, please investigate and understand the limits of it. RsyncGUI is quite powerful, but it is might not the primary backup tool for the average user of macOS.

### --delete parameter

```
Caution about RsyncGUI and the `--delete` parameter. The `--delete` is a default parameter.
The parameter instructs rsync to keep the source and destination synchronized (in sync).
The parameter instructs rsync to delete all files in the destination which are not present
in the source.

Every time you add a new task to RsyncGUI, execute an estimation run (--dry-run) and inspect
the result before executing a real run. If you by accident set an empty catalog as source
RsyncGUI (rsync) will delete all files in the destination.
```
To save deleted and changes files utilize [the --backup parameter](https://rsyncosx.netlify.app/post/userparameters/). The --delete parameter and other default parameters might be deleted if wanted.

### Main view

Some views of RsyncGUI. The last view shows which catalogs are approved for access. Approval for access is part of the Apple Sandbox features. The first row (in last view) is the `.ssh` catalog because `rsync` has to read the private ssh certificates. The second row is the Documents catalog. The remote catalog is remote and not required for RsyncGUI to know about regarding the Sandbox.

Here are [some samples of screenshots](https://github.com/rsyncOSX/RsyncGUI/blob/master/Views/Views.md).

### Application icon

The application icon is created by [Zsolt Sándor](https://github.com/graphis). All rights reserved to Zsolt Sándor.

### Compile

To compile the code, install Xcode and open the RsyncOSX project file. Before compiling, open in Xcode the `RsyncGUI/General` preference page and replace with your own credentials in `Signing`, or disable Signing.
