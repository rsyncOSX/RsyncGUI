//
//  userconfiguration.swift
//  RsyncGUIver30
//
//  Created by Thomas Evensen on 24/08/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//
// swiftlint:disable line_length cyclomatic_complexity

import Foundation

// Reading userconfiguration from file into RsyncGUI
struct Userconfiguration {

    weak var rsyncchangedDelegate: RsyncIsChanged?

    private func readUserconfiguration(dict: NSDictionary) {
        // Another version of rsync
        if let version3rsync = dict.value(forKey: "version3Rsync") as? Int {
            if version3rsync == 1 {
                ViewControllerReference.shared.rsyncVer3 = true
            } else {
                ViewControllerReference.shared.rsyncVer3 = false
            }
        }
        // Detailed logging
        if let detailedlogging = dict.value(forKey: "detailedlogging") as? Int {
            if detailedlogging == 1 {
                ViewControllerReference.shared.detailedlogging = true
            } else {
                ViewControllerReference.shared.detailedlogging = false
            }
        }
        // Optional path for rsync
        if let rsyncPath = dict.value(forKey: "rsyncPath") as? String {
            ViewControllerReference.shared.rsyncPath = rsyncPath
        }
        // Temporary path for restores single files or directory
        if let restorePath = dict.value(forKey: "restorePath") as? String {
            if restorePath.count > 0 {
                ViewControllerReference.shared.restorePath = restorePath
                // Sandbox
                _ = AppendSequrityscopedURLs(path: restorePath)
                // Sandbox
            } else {
                ViewControllerReference.shared.restorePath = nil
            }
        }
        // Mark tasks
        if let marknumberofdayssince = dict.value(forKey: "marknumberofdayssince") as? String {
            if Double(marknumberofdayssince)! > 0 {
                let oldmarknumberofdayssince = ViewControllerReference.shared.marknumberofdayssince
                ViewControllerReference.shared.marknumberofdayssince = Double(marknumberofdayssince)!
                if oldmarknumberofdayssince != ViewControllerReference.shared.marknumberofdayssince {
                    weak var reloadconfigurationsDelegate: Createandreloadconfigurations?
                    reloadconfigurationsDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllerMain
                    reloadconfigurationsDelegate?.createandreloadconfigurations()
                }
            }
        }
        // No logging, minimum logging or full logging
        if let minimumlogging = dict.value(forKey: "minimumlogging") as? Int {
            if minimumlogging == 1 {
                ViewControllerReference.shared.minimumlogging = true
            } else {
                ViewControllerReference.shared.minimumlogging = false
            }
        }
        if let fulllogging = dict.value(forKey: "fulllogging") as? Int {
            if fulllogging == 1 {
                ViewControllerReference.shared.fulllogging = true
            } else {
                ViewControllerReference.shared.fulllogging = false
            }
        }
    }

    init (userconfigRsyncGUI: [NSDictionary]) {
        if userconfigRsyncGUI.count > 0 {
            self.readUserconfiguration(dict: userconfigRsyncGUI[0])
        }
        // If userconfiguration is read from disk update info in main view
        self.rsyncchangedDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllerMain
        self.rsyncchangedDelegate?.rsyncischanged()
        // Check for rsync and set rsync version string in main view
        _ = Setrsyncpath()
        _ = RsyncVersionString()
    }
}
