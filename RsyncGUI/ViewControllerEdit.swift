//
//  ViewControllerEdit.swift
//  RsyncGUIver30
//
//  Created by Thomas Evensen on 05/09/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//

import Cocoa
import Foundation

class ViewControllerEdit: NSViewController, SetConfigurations, SetDismisser, Index, Delay {
    @IBOutlet var localCatalog: NSTextField!
    @IBOutlet var offsiteCatalog: NSTextField!
    @IBOutlet var offsiteUsername: NSTextField!
    @IBOutlet var offsiteServer: NSTextField!
    @IBOutlet var backupID: NSTextField!
    @IBOutlet var sshport: NSTextField!
    @IBOutlet var stringlocalcatalog: NSTextField!
    @IBOutlet var stringremotecatalog: NSTextField!

    var index: Int?
    var singleFile: Bool = false

    // Close and dismiss view
    @IBAction func close(_: NSButton) {
        self.dismissview(viewcontroller: self, vcontroller: .vctabmain)
    }

    // Update configuration, save and dismiss view
    @IBAction func update(_: NSButton) {
        var config: [Configuration] = self.configurations!.getConfigurations()
        if self.localCatalog.stringValue.hasSuffix("/") == false, self.singleFile == false {
            self.localCatalog.stringValue += "/"
        }
        config[self.index!].localCatalog = self.localCatalog.stringValue
        if self.offsiteCatalog.stringValue.hasSuffix("/") == false {
            self.offsiteCatalog.stringValue += "/"
        }
        config[self.index!].offsiteCatalog = self.offsiteCatalog.stringValue
        config[self.index!].offsiteServer = self.offsiteServer.stringValue
        config[self.index!].offsiteUsername = self.offsiteUsername.stringValue
        config[self.index!].backupID = self.backupID.stringValue
        let port = self.sshport.stringValue
        if port.isEmpty == false {
            if let port = Int(port) {
                config[self.index!].sshport = port
            }
        } else {
            config[self.index!].sshport = nil
        }
        let dict = ConvertOneConfig(config: config[self.index!]).dict
        guard Validatenewconfigs(dict: dict, Edit: true).validated == true else { return }
        self.configurations!.updateConfigurations(config[self.index!], index: self.index!)
        self.dismissview(viewcontroller: self, vcontroller: .vctabmain)
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        self.localCatalog.stringValue = ""
        self.offsiteCatalog.stringValue = ""
        self.offsiteUsername.stringValue = ""
        self.offsiteServer.stringValue = ""
        self.backupID.stringValue = ""
        self.sshport.stringValue = ""
        self.index = self.index()
        let config: Configuration = self.configurations!.getConfigurations()[self.index!]
        self.localCatalog.stringValue = config.localCatalog
        if self.localCatalog.stringValue.hasSuffix("/") == false {
            self.singleFile = true
        } else {
            self.singleFile = false
        }
        self.offsiteCatalog.stringValue = config.offsiteCatalog
        self.offsiteUsername.stringValue = config.offsiteUsername
        self.offsiteServer.stringValue = config.offsiteServer
        self.backupID.stringValue = config.backupID
        if let port = config.sshport {
            self.sshport.stringValue = String(port)
        }
    }

    private func changelabels() {
        let config: Configuration = self.configurations!.getConfigurations()[self.index!]
        switch config.task {
        case ViewControllerReference.shared.syncremote:
            self.stringlocalcatalog.stringValue = "Source catalog:"
            self.stringremotecatalog.stringValue = "Destination catalog:"
        default:
            self.stringlocalcatalog.stringValue = "Local catalog:"
            self.stringremotecatalog.stringValue = "Remote catalog:"
        }
    }
}
