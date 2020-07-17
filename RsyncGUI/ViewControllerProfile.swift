//
//  ViewControllerProfile.swift
//  RsyncGUI
//
//  Created by Thomas Evensen on 17/10/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//

import Cocoa
import Foundation

// Protocol for adding new profiles
protocol NewProfile: AnyObject {
    func newprofile(profile: String?, selectedindex: Int?)
    func reloadprofilepopupbutton()
}

class ViewControllerProfile: NSViewController, SetConfigurations, SetDismisser, Delay {
    private var profilesArray: [String]?
    private var profile: CatalogProfile?
    private var useprofile: String?

    @IBOutlet var loadbutton: NSButton!
    @IBOutlet var newprofile: NSTextField!
    @IBOutlet var profilesTable: NSTableView!

    @IBAction func defaultProfile(_: NSButton) {
        _ = Selectprofile(profile: nil, selectedindex: nil)
        self.dismissView()
    }

    @IBAction func deleteProfile(_: NSButton) {
        if let useprofile = self.useprofile {
            self.profile?.deleteProfileDirectory(profileName: useprofile)
            _ = Selectprofile(profile: nil, selectedindex: nil)
        }
        self.dismissView()
    }

    // Use profile or close
    @IBAction func close(_: NSButton) {
        let newprofile = self.newprofile.stringValue
        guard newprofile.isEmpty == false else {
            if self.useprofile != nil {
                _ = Selectprofile(profile: self.useprofile, selectedindex: nil)
            }
            self.dismissView()
            return
        }
        let success = self.profile?.createProfileDirectory(profileName: newprofile)
        guard success == true else {
            self.dismissView()
            return
        }
        _ = Selectprofile(profile: newprofile, selectedindex: nil)
        self.dismissView()
    }

    private func dismissView() {
        if (self.presentingViewController as? ViewControllerMain) != nil {
            self.dismissview(viewcontroller: self, vcontroller: .vctabmain)
        } else if (self.presentingViewController as? ViewControllerNewConfigurations) != nil {
            self.dismissview(viewcontroller: self, vcontroller: .vcnewconfigurations)
        } else if (self.presentingViewController as? ViewControllerSsh) != nil {
            self.dismissview(viewcontroller: self, vcontroller: .vcssh)
        } else if (self.presentingViewController as? ViewControllerVerify) != nil {
            self.dismissview(viewcontroller: self, vcontroller: .vcverify)
        } else if (self.presentingViewController as? ViewControllerLoggData) != nil {
            self.dismissview(viewcontroller: self, vcontroller: .vcloggdata)
        } else if (self.presentingViewController as? ViewControllerRestore) != nil {
            self.dismissview(viewcontroller: self, vcontroller: .vcrestore)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.profilesTable.delegate = self
        self.profilesTable.dataSource = self
        self.profilesTable.target = self
        self.newprofile.delegate = self
        self.profilesTable.doubleAction = #selector(ViewControllerProfile.tableViewDoubleClick(sender:))
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        self.profile = CatalogProfile()
        self.profilesArray = self.profile!.getDirectorysStrings()
        globalMainQueue.async { () -> Void in
            self.profilesTable.reloadData()
        }
        self.newprofile.stringValue = ""
    }

    @objc(tableViewDoubleClick:) func tableViewDoubleClick(sender _: AnyObject) {
        _ = Selectprofile(profile: self.useprofile, selectedindex: nil)
        self.dismissView()
    }
}

extension ViewControllerProfile: NSTableViewDataSource {
    func numberOfRows(in _: NSTableView) -> Int {
        return self.profilesArray?.count ?? 0
    }
}

extension ViewControllerProfile: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, viewFor _: NSTableColumn?, row: Int) -> NSView? {
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "profilesID"),
                                         owner: self) as? NSTableCellView {
            cell.textField?.stringValue = self.profilesArray?[row] ?? ""
            return cell
        } else {
            return nil
        }
    }

    func tableViewSelectionDidChange(_ notification: Notification) {
        let myTableViewFromNotification = (notification.object as? NSTableView)!
        let indexes = myTableViewFromNotification.selectedRowIndexes
        if let index = indexes.first {
            self.useprofile = self.profilesArray![index]
        }
    }
}

extension ViewControllerProfile: NSTextFieldDelegate {
    func controlTextDidBeginEditing(_: Notification) {
        self.delayWithSeconds(0.5) {
            if self.newprofile.stringValue.count > 0 {
                self.loadbutton.title = "Save"
            } else {
                self.loadbutton.title = "Load"
            }
        }
    }
}
