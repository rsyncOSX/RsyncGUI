//
//  ViewControllerSsh.swift
//  RsyncGUI
//
//  Created by Thomas Evensen on 23.04.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//
//  swiftlint:disable  line_length

import Cocoa
import Foundation

protocol ResetSequrityScopedURL: AnyObject {
    func resetsequrityscopedurl()
}

protocol SaveSequrityScopedURL: AnyObject {
    func savesequrityscopedurl(urlpath: URL)
}

class ViewControllerSsh: NSViewController, SetConfigurations, VcMain, Checkforrsync, Help {
    var sshcmd: Ssh?
    var hiddenID: Int?
    var data: [String]?
    var outputprocess: OutputProcess?
    var execute: Bool = false

    @IBOutlet var rsaCheck: NSButton!
    @IBOutlet var detailsTable: NSTableView!
    @IBOutlet var copykeycommand: NSTextField!
    @IBOutlet var sshport: NSTextField!
    @IBOutlet var sshkeypathandidentityfile: NSTextField!
    @IBOutlet var verifykeycommand: NSTextField!
    @IBOutlet var SequrityScopedTable: NSTableView!

    var viewControllerSource: NSViewController? {
        return (self.storyboard?.instantiateController(withIdentifier: "CopyFilesID")
            as? NSViewController)
    }

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
        globalMainQueue.async { () -> Void in
            self.presentAsSheet(self.viewControllerProfile!)
        }
    }

    // Userconfiguration button
    @IBAction func userconfiguration(_: NSButton) {
        globalMainQueue.async { () -> Void in
            self.presentAsSheet(self.viewControllerUserconfiguration!)
        }
    }

    @IBAction func resetsequrityscoped(_: NSButton) {
        let answer = Alerts.dialogOrCancel(question: "You are about to reset RsynGUI access to your files", text: "Please close and start RsyncGUI again", dialog: "Reset")
        if answer {
            weak var resetsequrityscopedDelegate: ResetSequrityScopedURL?
            resetsequrityscopedDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllerMain
            resetsequrityscopedDelegate?.resetsequrityscopedurl()
        }
    }

    @IBAction func showHelp(_: AnyObject?) {
        self.help()
    }

    @IBAction func createPublicPrivateRSAKeyPair(_: NSButton) {
        self.outputprocess = OutputProcess()
        self.sshcmd = Ssh(outputprocess: self.outputprocess)
        guard self.sshcmd?.islocalpublicrsakeypresent() ?? true == false else { return }
        self.sshcmd?.creatersakeypair()
    }

    @IBAction func source(_: NSButton) {
        guard self.sshcmd != nil else {
            self.data = ["Press the \"Check\" button before this action..."]
            globalMainQueue.async { () -> Void in
                self.detailsTable.reloadData()
            }
            return
        }
        self.presentAsSheet(self.viewControllerSource!)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        ViewControllerReference.shared.setvcref(viewcontroller: .vcssh, nsviewcontroller: self)
        self.detailsTable.delegate = self
        self.detailsTable.dataSource = self
        self.SequrityScopedTable.delegate = self
        self.SequrityScopedTable.dataSource = self
        self.outputprocess = nil
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        self.changesshparameters()
        globalMainQueue.async { () -> Void in
            self.SequrityScopedTable.reloadData()
        }
    }

    override func viewDidDisappear() {
        super.viewDidDisappear()
        self.copykeycommand.stringValue = ""
        self.verifykeycommand.stringValue = ""
    }

    private func checkforPrivateandPublicRSAKeypair() {
        self.sshcmd = Ssh(outputprocess: nil)
        if self.sshcmd?.islocalpublicrsakeypresent() ?? false {
            self.rsaCheck.state = .on
        } else {
            self.rsaCheck.state = .off
        }
    }

    private func changesshparameters() {
        self.sshkeypathandidentityfile.stringValue = ViewControllerReference.shared.sshkeypathandidentityfile ?? ""
        if let sshport = ViewControllerReference.shared.sshport {
            self.sshport.stringValue = String(sshport)
        } else {
            self.sshport.stringValue = ""
        }
        self.checkforPrivateandPublicRSAKeypair()
    }

    func copylocalpubrsakeyfile() {
        guard self.sshcmd?.islocalpublicrsakeypresent() ?? false == true else { return }
        self.outputprocess = OutputProcess()
        self.sshcmd = Ssh(outputprocess: self.outputprocess)
        if let hiddenID = self.hiddenID {
            self.sshcmd?.copykeyfile(hiddenID: hiddenID)
            self.copykeycommand.stringValue = sshcmd?.commandCopyPasteTerminal ?? ""
            self.sshcmd?.verifyremotekey(hiddenID: hiddenID)
            self.verifykeycommand.stringValue = sshcmd?.commandCopyPasteTerminal ?? ""
        }
    }
}

extension ViewControllerSsh: DismissViewController {
    func dismiss_view(viewcontroller: NSViewController) {
        self.dismiss(viewcontroller)
        self.copylocalpubrsakeyfile()
        self.changesshparameters()
    }
}

extension ViewControllerSsh: GetSource {
    func getSourceindex(index: Int) {
        self.hiddenID = index
        let config = self.configurations!.getConfigurations()[self.configurations!.getIndex(hiddenID!)]
        if config.offsiteServer.isEmpty == true {
            self.execute = false
        } else {
            self.execute = true
        }
    }
}

extension ViewControllerSsh: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        if tableView == self.detailsTable {
            return self.data?.count ?? 0
        } else {
            return self.configurations?.SequrityScopedURLs?.unique().count ?? 0
        }
    }
}

extension ViewControllerSsh: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        if tableView == self.detailsTable {
            if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "output"), owner: nil) as? NSTableCellView {
                cell.textField?.stringValue = self.data?[row] ?? ""
                return cell
            } else {
                return nil
            }
        } else {
            guard self.configurations?.SequrityScopedURLs?.unique() != nil else { return nil }
            guard row < (self.configurations?.SequrityScopedURLs?.unique().count ?? -1) else { return nil }
            let object: NSDictionary = self.configurations!.SequrityScopedURLs!.unique()[row]
            switch tableColumn!.identifier.rawValue {
            case "SecurityScoped":
                if (object.value(forKey: "SecurityScoped") as? Bool) == true {
                    return #imageLiteral(resourceName: "green")
                } else {
                    return #imageLiteral(resourceName: "red")
                }
            case "rootcatalog":
                return (object.value(forKey: "rootcatalog") as? NSURL)?.absoluteString ?? ""
            case "localcatalog":
                return (object.value(forKey: "localcatalog") as? NSURL)?.absoluteString ?? ""
            default:
                return nil
            }
        }
    }
}

extension ViewControllerSsh: UpdateProgress {
    func processTermination() {
        globalMainQueue.async { () -> Void in
            self.checkforPrivateandPublicRSAKeypair()
        }
    }

    func fileHandler() {
        self.data = self.outputprocess?.getOutput()
        globalMainQueue.async { () -> Void in
            self.detailsTable.reloadData()
        }
    }
}

extension ViewControllerSsh: OpenQuickBackup {
    func openquickbackup() {
        globalMainQueue.async { () -> Void in
            self.presentAsSheet(self.viewControllerQuickBackup!)
        }
    }
}
