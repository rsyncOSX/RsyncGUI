//
//  ViewControllerNew.swift
//  Rsync
//
//  Created by Thomas Evensen on 13/02/16.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//
//  swiftlint:disable trailing_comma

import Cocoa
import Foundation

enum Typebackup {
    case synchronize
    case syncremote
}

class ViewControllerNewConfigurations: NSViewController, SetConfigurations, Delay, Index, VcMain, Checkforrsync, Help {
    var newconfigurations: NewConfigurations?
    var tabledata: [NSMutableDictionary]?
    let archive: String = "--archive"
    let verbose: String = "--verbose"
    let compress: String = "--compress"
    let delete: String = "--delete"
    let eparam: String = "-e"
    let ssh: String = "ssh"
    let dryrun: String = "--dry-run"
    var outputprocess: OutputProcess?
    var index: Int?
    // Reference to rsync parameters to use in combox
    var comboBoxValues = [ViewControllerReference.shared.synchronize,
                          ViewControllerReference.shared.syncremote]
    var backuptypeselected: Typebackup = .synchronize
    var editlocalcatalog: Bool = true
    var diddissappear: Bool = false

    @IBOutlet var addtable: NSTableView!
    @IBOutlet var viewParameter1: NSTextField!
    @IBOutlet var viewParameter2: NSTextField!
    @IBOutlet var viewParameter3: NSTextField!
    @IBOutlet var viewParameter4: NSTextField!
    @IBOutlet var viewParameter5: NSTextField!
    @IBOutlet var localCatalog: NSTextField!
    @IBOutlet var offsiteCatalog: NSTextField!
    @IBOutlet var offsiteUsername: NSTextField!
    @IBOutlet var offsiteServer: NSTextField!
    @IBOutlet var backupID: NSTextField!
    @IBOutlet var profilInfo: NSTextField!
    @IBOutlet var backuptype: NSComboBox!
    @IBOutlet var useGUIbutton: NSButton!
    @IBOutlet var stringlocalcatalog: NSTextField!
    @IBOutlet var stringremotecatalog: NSTextField!

    @IBAction func totinfo(_: NSButton) {
        guard self.checkforrsync() == false else { return }
        globalMainQueue.async { () -> Void in
            self.presentAsSheet(self.viewControllerRemoteInfo!)
        }
    }

    @IBAction func quickbackup(_: NSButton) {
        guard self.checkforrsync() == false else { return }
        self.openquickbackup()
    }

    @IBAction func automaticbackup(_: NSButton) {
        self.presentAsSheet(self.viewControllerEstimating!)
    }

    // Selecting profiles
    @IBAction func profiles(_: NSButton) {
        self.presentAsModalWindow(self.viewControllerProfile!)
    }

    // Userconfiguration button
    @IBAction func userconfiguration(_: NSButton) {
        self.presentAsModalWindow(self.viewControllerUserconfiguration!)
    }

    @IBAction func showHelp(_: AnyObject?) {
        self.help()
    }

    @IBAction func useGUI(_: NSButton) {
        guard self.useGUIbutton.state == .on else { return }
        let filepath = FileDialog()
        let path = filepath.urlpath?.path ?? ""
        if self.editlocalcatalog == true {
            self.localCatalog.stringValue = path
        } else {
            self.offsiteCatalog.stringValue = path
        }
    }

    @IBAction func cleartable(_: NSButton) {
        self.newconfigurations = nil
        self.newconfigurations = NewConfigurations()
        globalMainQueue.async { () -> Void in
            self.addtable.reloadData()
            self.resetinputfields()
        }
    }

    private func changelabels() {
        switch self.backuptype.indexOfSelectedItem {
        case 1:
            self.stringlocalcatalog.stringValue = "Source catalog:"
            self.stringremotecatalog.stringValue = "Destination catalog:"
        default:
            self.stringlocalcatalog.stringValue = "Local catalog:"
            self.stringremotecatalog.stringValue = "Remote catalog:"
        }
    }

    @IBAction func setbackuptype(_: NSComboBox) {
        switch self.backuptype.indexOfSelectedItem {
        case 0:
            self.backuptypeselected = .synchronize
        case 1:
            self.backuptypeselected = .syncremote
        default:
            self.backuptypeselected = .synchronize
        }
        self.changelabels()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.newconfigurations = NewConfigurations()
        self.addtable.delegate = self
        self.addtable.dataSource = self
        self.localCatalog.delegate = self
        self.offsiteCatalog.delegate = self
        self.localCatalog.toolTip = "By using Finder drag and drop filepaths."
        self.offsiteCatalog.toolTip = "By using Finder drag and drop filepaths."
        ViewControllerReference.shared.setvcref(viewcontroller: .vcnewconfigurations, nsviewcontroller: self)
        self.initcombox(combobox: self.backuptype, index: 0)
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        self.backuptypeselected = .synchronize
        self.backuptype.selectItem(at: 0)
        self.useGUIbutton.state = .off
        self.editlocalcatalog = true
        self.index = self.index()
        guard self.diddissappear == false else { return }
        self.viewParameter1.stringValue = self.archive
        self.viewParameter2.stringValue = self.verbose
        self.viewParameter3.stringValue = self.compress
        self.viewParameter4.stringValue = self.delete
        self.viewParameter5.stringValue = self.eparam + " " + self.ssh
        self.changelabels()
    }

    override func viewDidDisappear() {
        super.viewDidDisappear()
        self.diddissappear = true
    }

    private func initcombox(combobox: NSComboBox, index: Int) {
        combobox.removeAllItems()
        combobox.addItems(withObjectValues: self.comboBoxValues)
        combobox.selectItem(at: index)
    }

    private func resetinputfields() {
        self.localCatalog.stringValue = ""
        self.offsiteCatalog.stringValue = ""
        self.offsiteUsername.stringValue = ""
        self.offsiteServer.stringValue = ""
        self.backupID.stringValue = ""
    }

    @IBAction func addConfig(_: NSButton) {
        let dict: NSMutableDictionary = [
            "task": ViewControllerReference.shared.synchronize,
            "backupID": backupID.stringValue,
            "localCatalog": localCatalog.stringValue,
            "offsiteCatalog": offsiteCatalog.stringValue,
            "offsiteServer": offsiteServer.stringValue,
            "offsiteUsername": offsiteUsername.stringValue,
            "parameter1": self.archive,
            "parameter2": self.verbose,
            "parameter3": self.compress,
            "parameter4": self.delete,
            "parameter5": self.eparam,
            "parameter6": self.ssh,
            "dryrun": self.dryrun,
            "dateRun": "",
        ]
        guard Validatenewconfigs(dict: dict).validated == true else { return }
        if self.localCatalog.stringValue.hasSuffix("/") == false {
            self.localCatalog.stringValue += "/"
            dict.setValue(self.localCatalog.stringValue, forKey: "localCatalog")
        }
        if self.offsiteCatalog.stringValue.hasSuffix("/") == false {
            self.offsiteCatalog.stringValue += "/"
            dict.setValue(self.offsiteCatalog.stringValue, forKey: "offsiteCatalog")
        }
        if self.backuptypeselected == .syncremote {
            guard self.offsiteServer.stringValue.isEmpty == false else { return }
            dict.setValue(ViewControllerReference.shared.syncremote, forKey: "task")
        }
        self.configurations?.addNewConfigurations(dict: dict)
        self.newconfigurations?.appendnewConfigurations(dict: dict)
        self.tabledata = self.newconfigurations?.getnewConfigurations()
        globalMainQueue.async { () -> Void in
            self.addtable.reloadData()
        }
        self.resetinputfields()
    }
}

extension ViewControllerNewConfigurations: NSTableViewDataSource {
    func numberOfRows(in _: NSTableView) -> Int {
        return self.newconfigurations?.newConfigurationsCount() ?? 0
    }
}

extension ViewControllerNewConfigurations: NSTableViewDelegate {
    func tableView(_: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        if let object: NSMutableDictionary = self.newconfigurations?.getnewConfigurations()![row] {
            return object[tableColumn!.identifier] as? String
        } else {
            return nil
        }
    }
}

extension ViewControllerNewConfigurations: DismissViewController {
    func dismiss_view(viewcontroller: NSViewController) {
        self.dismiss(viewcontroller)
    }
}

extension ViewControllerNewConfigurations: SetProfileinfo {
    func setprofile(profile: String, color: NSColor) {
        globalMainQueue.async { () -> Void in
            self.profilInfo.stringValue = profile
            self.profilInfo.textColor = color
        }
    }
}

extension ViewControllerNewConfigurations: NSTextFieldDelegate {
    func controlTextDidEndEditing(_ notification: Notification) {
        if (notification.object as? NSTextField)! == self.localCatalog {
            self.editlocalcatalog = true
        } else {
            self.editlocalcatalog = false
        }
        self.useGUIbutton.state = .off
    }
}

extension ViewControllerNewConfigurations: OpenQuickBackup {
    func openquickbackup() {
        globalMainQueue.async { () -> Void in
            self.presentAsSheet(self.viewControllerQuickBackup!)
        }
    }
}
