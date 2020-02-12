//
//  ViewControllerUserconfiguration.swift
//  RsyncGUIver30
//
//  Created by Thomas Evensen on 30/08/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//
// swiftlint:disable line_length

import Cocoa
import Foundation

class ViewControllerUserconfiguration: NSViewController, NewRsync, SetDismisser, Delay, ChangeTemporaryRestorePath {
    var dirty: Bool = false
    weak var reloadconfigurationsDelegate: Createandreloadconfigurations?
    var oldmarknumberofdayssince: Double?
    var reload: Bool = false

    @IBOutlet var rsyncPath: NSTextField!
    @IBOutlet var version3rsync: NSButton!
    @IBOutlet var detailedlogging: NSButton!
    @IBOutlet var noRsync: NSTextField!
    @IBOutlet var restorePath: NSTextField!
    @IBOutlet var fulllogging: NSButton!
    @IBOutlet var minimumlogging: NSButton!
    @IBOutlet var nologging: NSButton!
    @IBOutlet var marknumberofdayssince: NSTextField!
    @IBOutlet var statuslightpathrsync: NSImageView!
    @IBOutlet var statuslighttemppath: NSImageView!
    @IBOutlet var savebutton: NSButton!
    @IBOutlet var useGUIbutton: NSButton!
    @IBOutlet var haltonerror: NSButton!

    @IBAction func togglehaltonerror(_: NSButton) {
        if ViewControllerReference.shared.haltonerror {
            self.haltonerror.state = .off
            ViewControllerReference.shared.haltonerror = false
        } else {
            self.haltonerror.state = .on
            ViewControllerReference.shared.haltonerror = true
        }
        self.setdirty()
    }

    @IBAction func toggleversion3rsync(_: NSButton) {
        if self.version3rsync.state == .on {
            ViewControllerReference.shared.rsyncVer3 = true
            if self.rsyncPath.stringValue == "" {
                ViewControllerReference.shared.rsyncPath = nil
            } else {
                self.setRsyncPath()
            }
        } else {
            ViewControllerReference.shared.rsyncVer3 = false
        }
        self.newrsync()
        self.setdirty()
        self.verifyrsync()
    }

    @IBAction func toggleDetailedlogging(_: NSButton) {
        if self.detailedlogging.state == .on {
            ViewControllerReference.shared.detailedlogging = true
        } else {
            ViewControllerReference.shared.detailedlogging = false
        }
        self.setdirty()
    }

    @IBAction func togglerestorepath(_: NSButton) {
        self.filemanager()
    }

    @IBAction func close(_: NSButton) {
        if self.dirty {
            // Before closing save changed configuration
            self.setRsyncPath()
            self.setRestorePath()
            self.setmarknumberofdayssince()
            _ = PersistentStorageUserconfiguration().saveuserconfiguration()
            if self.reload {
                self.reloadconfigurationsDelegate?.createandreloadconfigurations()
            }
            self.changetemporaryrestorepath()
        }
        if (self.presentingViewController as? ViewControllerMain) != nil {
            self.dismissview(viewcontroller: self, vcontroller: .vctabmain)
        } else if (self.presentingViewController as? ViewControllerNewConfigurations) != nil {
            self.dismissview(viewcontroller: self, vcontroller: .vctabmain)
        } else if (self.presentingViewController as? ViewControllerRestore) != nil {
            self.dismissview(viewcontroller: self, vcontroller: .vcrestore)
        } else if (self.presentingViewController as? ViewControllerSsh) != nil {
            self.dismissview(viewcontroller: self, vcontroller: .vcssh)
        } else if (self.presentingViewController as? ViewControllerVerify) != nil {
            self.dismissview(viewcontroller: self, vcontroller: .vcverify)
        } else if (self.presentingViewController as? ViewControllerLoggData) != nil {
            self.dismissview(viewcontroller: self, vcontroller: .vcloggdata)
        }
        _ = RsyncVersionString()
    }

    @IBAction func logging(_: NSButton) {
        if self.fulllogging.state == .on {
            ViewControllerReference.shared.fulllogging = true
            ViewControllerReference.shared.minimumlogging = false
        } else if self.minimumlogging.state == .on {
            ViewControllerReference.shared.fulllogging = false
            ViewControllerReference.shared.minimumlogging = true
        } else if self.nologging.state == .on {
            ViewControllerReference.shared.fulllogging = false
            ViewControllerReference.shared.minimumlogging = false
        }
        self.setdirty()
    }

    private func setdirty() {
        self.dirty = true
        self.savebutton.title = "Save"
    }

    private func setmarknumberofdayssince() {
        if let marknumberofdayssince = Double(self.marknumberofdayssince.stringValue) {
            self.oldmarknumberofdayssince = ViewControllerReference.shared.marknumberofdayssince
            ViewControllerReference.shared.marknumberofdayssince = marknumberofdayssince
            if self.oldmarknumberofdayssince != marknumberofdayssince {
                self.reload = true
            }
        }
    }

    private func setRsyncPath() {
        if self.rsyncPath.stringValue.isEmpty == false {
            if rsyncPath.stringValue.hasSuffix("/") == false {
                rsyncPath.stringValue += "/"
                ViewControllerReference.shared.rsyncPath = rsyncPath.stringValue
            }
        } else {
            ViewControllerReference.shared.rsyncPath = nil
        }
        self.setdirty()
    }

    private func setRestorePath() {
        if self.restorePath.stringValue.isEmpty == false {
            if restorePath.stringValue.hasSuffix("/") == false {
                restorePath.stringValue += "/"
                ViewControllerReference.shared.restorepath = self.restorePath.stringValue
            } else {
                ViewControllerReference.shared.restorepath = self.restorePath.stringValue
            }
            _ = AppendSequrityscopedURLs(path: ViewControllerReference.shared.restorepath!)
        } else {
            ViewControllerReference.shared.restorepath = nil
        }
        self.setdirty()
    }

    private func verifyrsync() {
        var rsyncpath: String?
        if self.rsyncPath.stringValue.isEmpty == false {
            self.statuslightpathrsync.isHidden = false
            if self.rsyncPath.stringValue.hasSuffix("/") == false {
                rsyncpath = self.rsyncPath.stringValue + "/" + ViewControllerReference.shared.rsync
            } else {
                rsyncpath = self.rsyncPath.stringValue + ViewControllerReference.shared.rsync
            }
        } else {
            rsyncpath = nil
        }
        // use stock rsync
        guard self.version3rsync.state == .on else {
            ViewControllerReference.shared.norsync = false
            return
        }
        self.statuslightpathrsync.isHidden = false
        if verifypatexists(pathorfilename: rsyncpath) {
            self.noRsync.isHidden = true
            ViewControllerReference.shared.norsync = false
            self.statuslightpathrsync.image = #imageLiteral(resourceName: "green")
        } else {
            self.noRsync.isHidden = false
            ViewControllerReference.shared.norsync = true
            self.statuslightpathrsync.image = #imageLiteral(resourceName: "red")
        }
    }

    private func verifypatexists(pathorfilename: String?) -> Bool {
        let fileManager = FileManager.default
        var path: String?
        if pathorfilename == nil {
            path = ViewControllerReference.shared.usrlocalbinrsync
        } else {
            path = pathorfilename
        }
        guard fileManager.fileExists(atPath: path ?? "") else { return false }
        return true
    }

    func filemanager() {
        guard self.useGUIbutton.state == .on else { return }
        self.useGUIbutton.state = .off
        let filepath = FileDialog()
        if let path = filepath.urlpath?.path {
            self.restorePath.stringValue = path
            self.setdirty()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.rsyncPath.delegate = self
        self.restorePath.delegate = self
        self.marknumberofdayssince.delegate = self
        self.nologging.state = .on
        self.reloadconfigurationsDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllerMain
        // Sandbox constraints
        self.version3rsync.isEnabled = false
        self.rsyncPath.isEnabled = false
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        self.dirty = false
        self.useGUIbutton.state = .off
        self.checkUserConfig()
        self.verifyrsync()
        self.marknumberofdayssince.stringValue = String(ViewControllerReference.shared.marknumberofdayssince)
        self.reload = false
        self.statuslighttemppath.isHidden = true
        self.statuslightpathrsync.isHidden = true
    }

    // Function for check and set user configuration
    private func checkUserConfig() {
        if ViewControllerReference.shared.rsyncVer3 {
            self.version3rsync.state = .on
        } else {
            self.version3rsync.state = .off
        }
        if ViewControllerReference.shared.detailedlogging {
            self.detailedlogging.state = .on
        } else {
            self.detailedlogging.state = .off
        }
        if ViewControllerReference.shared.rsyncPath != nil {
            self.rsyncPath.stringValue = ViewControllerReference.shared.rsyncPath!
        } else {
            self.rsyncPath.stringValue = ""
        }
        if ViewControllerReference.shared.restorepath != nil {
            self.restorePath.stringValue = ViewControllerReference.shared.restorepath!
        } else {
            self.restorePath.stringValue = ""
        }
        if ViewControllerReference.shared.minimumlogging {
            self.minimumlogging.state = .on
        }
        if ViewControllerReference.shared.fulllogging {
            self.fulllogging.state = .on
        }
        if ViewControllerReference.shared.haltonerror {
            self.haltonerror.state = .on
        } else {
            self.haltonerror.state = .off
        }
    }
}

extension ViewControllerUserconfiguration: NSTextFieldDelegate {
    func controlTextDidBeginEditing(_ notification: Notification) {
        delayWithSeconds(0.5) {
            self.setdirty()
            switch (notification.object as? NSTextField)! {
            case self.rsyncPath:
                if self.rsyncPath.stringValue.isEmpty == false {
                    self.version3rsync.state = .on
                }
                self.verifyrsync()
                self.newrsync()
            case self.restorePath:
                self.filemanager()
            case self.marknumberofdayssince:
                return
            default:
                return
            }
        }
    }
}
