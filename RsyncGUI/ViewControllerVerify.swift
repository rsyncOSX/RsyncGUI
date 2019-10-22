//
//  ViewControllerVerify.swift
//  RsyncGUI
//
//  Created by Thomas Evensen on 26.07.2018.
//  Copyright © 2018 Thomas Evensen. All rights reserved.
//
// swiftlint:disable line_length

import Foundation
import Cocoa

class ViewControllerVerify: NSViewController, SetConfigurations, Index, Connected, VcMain, Checkforrsync {

    @IBOutlet weak var outputtable: NSTableView!
    var outputprocess: OutputProcess?
    var index: Int?
    var lastindex: Int?
    var estimatedindex: Int?
    var gotremoteinfo: Bool = false
    private var numbers: NSMutableDictionary?
    private var complete: Bool = false
    private var processRefererence: ProcessCmd?

    @IBOutlet weak var working: NSProgressIndicator!
    @IBOutlet weak var verifybutton: NSButton!
    @IBOutlet weak var changedbutton: NSButton!

    @IBOutlet weak var transferredNumber: NSTextField!
    @IBOutlet weak var transferredNumberSizebytes: NSTextField!
    @IBOutlet weak var newfiles: NSTextField!
    @IBOutlet weak var deletefiles: NSTextField!
    @IBOutlet weak var totalNumber: NSTextField!
    @IBOutlet weak var totalDirs: NSTextField!
    @IBOutlet weak var totalNumberSizebytes: NSTextField!
    @IBOutlet weak var localtotalNumber: NSTextField!
    @IBOutlet weak var localtotalDirs: NSTextField!
    @IBOutlet weak var localtotalNumberSizebytes: NSTextField!
    @IBOutlet weak var gotit: NSTextField!
    @IBOutlet weak var datelastbackup: NSTextField!
    @IBOutlet weak var dayslastbackup: NSTextField!
    @IBOutlet weak var rsynccommanddisplay: NSTextField!
    @IBOutlet weak var verifyradiobutton: NSButton!
    @IBOutlet weak var changedradiobutton: NSButton!

    @IBOutlet weak var localcatalog: NSTextField!
    @IBOutlet weak var remotecatalog: NSTextField!
    @IBOutlet weak var remoteserver: NSTextField!

    @IBAction func totinfo(_ sender: NSButton) {
        guard self.checkforrsync() == false else { return }
        globalMainQueue.async(execute: { () -> Void in
            self.presentAsSheet(self.viewControllerRemoteInfo!)
        })
    }

    @IBAction func quickbackup(_ sender: NSButton) {
        guard self.checkforrsync() == false else { return }
        self.openquickbackup()
    }

    @IBAction func automaticbackup(_ sender: NSButton) {
        self.presentAsSheet(self.viewControllerEstimating!)
    }

    // Selecting profiles
    @IBAction func profiles(_ sender: NSButton) {
        globalMainQueue.async(execute: { () -> Void in
            self.presentAsSheet(self.viewControllerProfile!)
        })
    }

    // Userconfiguration button
    @IBAction func userconfiguration(_ sender: NSButton) {
        globalMainQueue.async(execute: { () -> Void in
            self.presentAsSheet(self.viewControllerUserconfiguration!)
        })
    }

    @IBAction func verify(_ sender: NSButton) {
        guard self.index != nil else { return }
        self.rsynccommanddisplay.stringValue = Displayrsyncpath(index: self.index!, display: .verify).displayrsyncpath ?? ""
        self.verifyradiobutton.state = .on
        self.changedradiobutton.state = .off
        self.gotit.textColor = .white
        self.gotit.stringValue = "Verifying, please wait..."
        self.enabledisablebuttons(enable: false)
        self.working.startAnimation(nil)
        if let arguments = self.configurations?.arguments4verify(index: self.index!) {
            self.outputprocess = OutputProcess()
            self.outputprocess?.addlinefromoutput(str: "*** Verify ***")
            self.verifyandchanged(arguments: arguments)
        }
    }

    @IBAction func changed(_ sender: NSButton) {
        guard self.index != nil else { return }
        self.rsynccommanddisplay.stringValue = Displayrsyncpath(index: self.index!, display: .restore).displayrsyncpath ?? ""
        self.changedradiobutton.state = .on
        self.verifyradiobutton.state = .off
        self.gotit.textColor = .white
        self.gotit.stringValue = "Computing changed, please wait..."
        self.enabledisablebuttons(enable: false)
        self.working.startAnimation(nil)
        if let arguments = self.configurations?.arguments4restore(index: self.index!, argtype: .argdryRun) {
            self.outputprocess = OutputProcess()
            self.outputprocess?.addlinefromoutput(str: "*** Changed ***")
            self.verifyandchanged(arguments: arguments)
        }
    }

    private func verifyandchanged(arguments: [String]) {
        let verifytask = ProcessCmd(command: nil, arguments: arguments)
        verifytask.setupdateDelegate(object: self)
        verifytask.executeProcess(outputprocess: self.outputprocess)
        self.processRefererence = verifytask
    }

    @IBAction func info(_ sender: NSButton) {
        let resources = Resources()
        NSWorkspace.shared.open(URL(string: resources.getResource(resource: .verify))!)
    }

    @IBAction func displayrsynccommand(_ sender: NSButton) {
        guard self.index != nil else {
            self.rsynccommanddisplay.stringValue = ""
            return
        }
        if self.verifyradiobutton.state == .on {
            self.rsynccommanddisplay.stringValue = Displayrsyncpath(index: self.index!, display: .verify).displayrsyncpath ?? ""
        } else {
            self.rsynccommanddisplay.stringValue = Displayrsyncpath(index: self.index!, display: .restore).displayrsyncpath ?? ""
        }
    }

    // Abort button
    @IBAction func abort(_ sender: NSButton) {
        self.lastindex = self.index
        guard self.processRefererence != nil else { return }
        self.processRefererence!.abortProcess()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        ViewControllerReference.shared.setvcref(viewcontroller: .vcverify, nsviewcontroller: self)
        self.outputtable.delegate = self
        self.outputtable.dataSource = self
        self.working.usesThreadedAnimation = true
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        self.index = self.index()
        if let index = self.index {
            let config = self.configurations!.getConfigurations()[index]
            guard self.connected(config: config) == true else {
                self.gotit.stringValue = "Seems not to be connected..."
                return
            }
            guard index != self.lastindex ?? -1 else { return }
            guard self.estimatedindex ?? -1 != index else { return }
            self.resetinfo()
            self.setinfo()
            self.enabledisablebuttons(enable: false)
            self.estimatedindex = index
            self.gotit.stringValue = "Getting information, please wait ..."
            self.gotremoteinfo = false
            self.complete = false
            let datelastbackup = self.configurations?.getConfigurations()[index].dateRun ?? "none"
            let numberlastbackup = self.configurations?.getConfigurations()[index].dayssincelastbackup ?? "none"
            self.datelastbackup.stringValue = "Date last backup: " + datelastbackup
            self.dayslastbackup.stringValue = "Days since last backup: " + numberlastbackup
            self.estimateremoteinfo(index: index, local: true)
        } else {
            self.gotit.textColor = .red
            self.gotit.stringValue = "Please select a task in Execute ..."
            self.outputprocess = nil
            globalMainQueue.async(execute: { () -> Void in
                self.outputtable.reloadData()
            })
        }
    }

    override func viewDidDisappear() {
        super.viewDidDisappear()
        self.lastindex = self.index
    }

    private func enabledisablebuttons(enable: Bool) {
        self.verifybutton.isEnabled = enable
        self.changedbutton.isEnabled = enable
    }

    private func estimateremoteinfo(index: Int, local: Bool) {
        var arguments: [String]?
        self.working.startAnimation(nil)
        self.outputprocess = OutputProcess()
        if local {
            globalMainQueue.async(execute: { () -> Void in
                self.outputtable.reloadData()
            })
            arguments = self.configurations!.arguments4rsync(index: index, argtype: .argdryRunlocalcataloginfo)
        } else {
            arguments = self.configurations!.arguments4rsync(index: index, argtype: .argdryRun)
        }
        let verifytask = VerifyTask(arguments: arguments)
        verifytask.setdelegate(object: self)
        verifytask.executeProcess(outputprocess: self.outputprocess)
        self.processRefererence = verifytask
    }

    private func publishnumbers(outputprocess: OutputProcess?, local: Bool) {
        globalMainQueue.async(execute: { () -> Void in
            let infotask = RemoteinfonumbersOnetask(outputprocess: outputprocess)
            if local {
                self.localtotalNumber.stringValue = infotask.totalNumber!
                self.localtotalNumberSizebytes.stringValue = infotask.totalNumberSizebytes!
                self.localtotalDirs.stringValue = infotask.totalDirs!
            } else {
                self.transferredNumber.stringValue = infotask.transferredNumber!
                self.transferredNumberSizebytes.stringValue = infotask.transferredNumberSizebytes!
                self.totalNumber.stringValue = infotask.totalNumber!
                self.totalNumberSizebytes.stringValue = infotask.totalNumberSizebytes!
                self.totalDirs.stringValue = infotask.totalDirs!
                self.newfiles.stringValue = infotask.newfiles!
                self.deletefiles.stringValue = infotask.deletefiles!
                self.working.stopAnimation(nil)
                self.gotit.stringValue = ""
            }
        })
    }

    private func setinfo() {
        let hiddenID = self.configurations?.gethiddenID(index: self.index!) ?? 0
        guard hiddenID > -1 else { return }
        self.localcatalog.stringValue = self.configurations!.getResourceConfiguration(hiddenID, resource: .localCatalog)
        self.remoteserver.stringValue = self.configurations!.getResourceConfiguration(hiddenID, resource: .offsiteServer)
        self.remotecatalog.stringValue = self.configurations!.getResourceConfiguration(hiddenID, resource: .offsiteCatalog)
    }

    private func resetinfo() {
        self.localtotalNumber.stringValue = ""
        self.localtotalNumberSizebytes.stringValue = ""
        self.localtotalDirs.stringValue = ""
        self.transferredNumber.stringValue = ""
        self.transferredNumberSizebytes.stringValue = ""
        self.totalNumber.stringValue = ""
        self.totalNumberSizebytes.stringValue = ""
        self.totalDirs.stringValue = ""
        self.newfiles.stringValue = ""
        self.deletefiles.stringValue = ""
        self.datelastbackup.stringValue = "Date last backup:"
        self.dayslastbackup.stringValue = "Days since last backup:"
        self.rsynccommanddisplay.stringValue = ""
        self.verifyradiobutton.state = .off
        self.changedradiobutton.state = .off
        self.rsynccommanddisplay.stringValue = ""
        self.localcatalog.stringValue = ""
        self.remoteserver.stringValue = ""
        self.remotecatalog.stringValue = ""
    }
}

extension ViewControllerVerify: NSTableViewDataSource {
    func numberOfRows(in aTableView: NSTableView) -> Int {
        return self.outputprocess?.getOutput()?.count ?? 0
    }
}

extension ViewControllerVerify: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "outputID"), owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = self.outputprocess?.getOutput()?[row] ?? ""
            return cell
        } else {
            return nil
        }
    }
}

extension ViewControllerVerify: UpdateProgress {
    func processTermination() {
        if self.gotremoteinfo == false {
            if self.complete == false {
                self.publishnumbers(outputprocess: self.outputprocess, local: true)
            } else {
                self.gotremoteinfo = true
                self.publishnumbers(outputprocess: self.outputprocess, local: false)
                self.enabledisablebuttons(enable: true)
            }
            if let index = self.index {
                if self.complete == false {
                    self.complete = true
                    self.outputprocess = OutputProcess()
                    self.estimateremoteinfo(index: index, local: false)
                }
            }
            globalMainQueue.async(execute: { () -> Void in
                self.outputtable.reloadData()
            })
        } else {
            self.working.stopAnimation(nil)
            self.gotit.stringValue = "Completed ..."
            self.gotit.textColor = .green
            self.changedbutton.isEnabled = true
            self.verifybutton.isEnabled = true
        }
    }

    func fileHandler() {
        if self.gotremoteinfo == true {
            globalMainQueue.async(execute: { () -> Void in
                self.outputtable.reloadData()
            })
        }
    }
}

extension ViewControllerVerify: OpenQuickBackup {
    func openquickbackup() {
        globalMainQueue.async(execute: { () -> Void in
            self.presentAsSheet(self.viewControllerQuickBackup!)
        })
    }
}

extension ViewControllerVerify: DismissViewController {
    func dismiss_view(viewcontroller: NSViewController) {
        self.dismiss(viewcontroller)
    }
}
