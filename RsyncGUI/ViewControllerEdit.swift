//
//  ViewControllerEdit.swift
//  RsyncGUIver30
//
//  Created by Thomas Evensen on 05/09/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//

import Cocoa
import Foundation

protocol CloseEdit: Any {
    func closeview()
}

class ViewControllerEdit: NSViewController, SetConfigurations, SetDismisser, Index, Delay {
    @IBOutlet var localCatalog: NSTextField!
    @IBOutlet var offsiteCatalog: NSTextField!
    @IBOutlet var offsiteUsername: NSTextField!
    @IBOutlet var offsiteServer: NSTextField!
    @IBOutlet var backupID: NSTextField!
    @IBOutlet var stringlocalcatalog: NSTextField!
    @IBOutlet var stringremotecatalog: NSTextField!

    var index: Int?

    // Close and dismiss view
    @IBAction func close(_: NSButton) {
        self.view.window?.close()
    }

    // Update configuration, save and dismiss view
    @IBAction func update(_: NSButton) {
        var config: [Configuration] = self.configurations?.getConfigurations() ?? []
        guard config.count > 0 else { return }
        if self.localCatalog.stringValue.hasSuffix("/") == false {
            self.localCatalog.stringValue += "/"
        }
        if let index = self.index() {
            config[self.index!].localCatalog = self.localCatalog.stringValue
            if self.offsiteCatalog.stringValue.hasSuffix("/") == false {
                self.offsiteCatalog.stringValue += "/"
            }
            config[index].offsiteCatalog = self.offsiteCatalog.stringValue
            config[index].offsiteServer = self.offsiteServer.stringValue
            config[index].offsiteUsername = self.offsiteUsername.stringValue
            config[index].backupID = self.backupID.stringValue
            let dict = ConvertOneConfig(config: config[index]).dict
            guard Validatenewconfigs(dict: dict, Edit: true).validated == true else { return }
            self.configurations?.updateConfigurations(config[index], index: index)
            self.view.window?.close()
        }
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        // Check if there is another view open, if yes close it..
        if let view = ViewControllerReference.shared.getvcref(viewcontroller: .vcedit) as? ViewControllerEdit {
            weak var closeview: ViewControllerEdit?
            closeview = view
            closeview?.closeview()
        }
        ViewControllerReference.shared.setvcref(viewcontroller: .vcedit, nsviewcontroller: self)
        self.localCatalog.stringValue = ""
        self.offsiteCatalog.stringValue = ""
        self.offsiteUsername.stringValue = ""
        self.offsiteServer.stringValue = ""
        self.backupID.stringValue = ""
        if let index = self.index() {
            self.index = index
            if let config: Configuration = self.configurations?.getConfigurations()[index] {
                self.localCatalog.stringValue = config.localCatalog
                self.offsiteCatalog.stringValue = config.offsiteCatalog
                self.offsiteUsername.stringValue = config.offsiteUsername
                self.offsiteServer.stringValue = config.offsiteServer
                self.backupID.stringValue = config.backupID
                self.changelabels()
            }
        }
    }

    override func viewDidDisappear() {
        super.viewDidDisappear()
        ViewControllerReference.shared.setvcref(viewcontroller: .vcedit, nsviewcontroller: nil)
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

extension ViewControllerEdit: CloseEdit {
    func closeview() {
        self.view.window?.close()
    }
}
