//  Created by Thomas Evensen on 19/08/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//
//  swiftlint:disable type_body_length line_length

import Cocoa
import Foundation

class ViewControllerMain: NSViewController, ReloadTable, Deselect, VcMain, Delay, Fileerrormessage, Setcolor, Checkforrsync {
    // Main tableview
    @IBOutlet var mainTableView: NSTableView!
    // Progressbar indicating work
    @IBOutlet var working: NSProgressIndicator!
    @IBOutlet var workinglabel: NSTextField!
    // Displays the rsyncCommand
    @IBOutlet var rsyncCommand: NSTextField!
    // If On result of Dryrun is presented before
    // executing the real run
    @IBOutlet var dryRunOrRealRun: NSTextField!
    // number of files to be transferred
    @IBOutlet var transferredNumber: NSTextField!
    // size of files to be transferred
    @IBOutlet var transferredNumberSizebytes: NSTextField!
    // total number of files in remote volume
    @IBOutlet var totalNumber: NSTextField!
    // total size of files in remote volume
    @IBOutlet var totalNumberSizebytes: NSTextField!
    // Showing info about profile
    @IBOutlet var profilInfo: NSTextField!
    @IBOutlet var rsyncversionshort: NSTextField!
    @IBOutlet var backupdryrun: NSButton!
    @IBOutlet var restoredryrun: NSButton!
    @IBOutlet var verifydryrun: NSButton!
    @IBOutlet var profilepopupbutton: NSPopUpButton!

    // Configurations object
    var configurations: Configurations?
    var schedules: Schedules?
    // Reference to the taskobjects
    var singletask: SingleTask?
    var executetasknow: ExecuteTaskNow?
    // Reference to Process task
    var process: Process?
    // Index to selected row, index is set when row is selected
    var index: Int?
    // Getting output from rsync
    var outputprocess: OutputProcess?
    // Keep track of all errors
    var outputerrors: OutputErrors?

    @IBOutlet var info: NSTextField!

    func info(num: Int) {
        switch num {
        case 1:
            self.info.stringValue = "Select a task...."
        case 2:
            self.info.stringValue = "Possible error logging..."
        case 3:
            self.info.stringValue = "No rsync in path..."
        case 4:
            self.info.stringValue = "⌘A to abort or wait..."
        case 5:
            self.info.stringValue = "Menu app is running..."
        case 6:
            self.info.stringValue = "This is a combined task, execute by ⌘R..."
        case 7:
            self.info.stringValue = "Only valid for backup, snapshot and combined tasks..."
        case 8:
            self.info.stringValue = "No rclone config found..."
        default:
            self.info.stringValue = ""
        }
    }

    @IBAction func infoonetask(_: NSButton) {
        guard self.index != nil else {
            self.info(num: 1)
            return
        }
        guard self.checkforrsync() == false else { return }
        let task = self.configurations!.getConfigurations()[self.index!].task
        guard ViewControllerReference.shared.synctasks.contains(task) else {
            self.info(num: 7)
            return
        }
        self.presentAsSheet(self.viewControllerInformationLocalRemote!)
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

    @IBAction func edit(_: NSButton) {
        self.reset()
        guard self.index != nil else {
            self.info(num: 1)
            return
        }
        globalMainQueue.async { () -> Void in
            self.presentAsSheet(self.editViewController!)
        }
    }

    @IBAction func rsyncparams(_: NSButton) {
        self.reset()
        guard self.index != nil else {
            self.info(num: 1)
            return
        }
        globalMainQueue.async { () -> Void in
            self.presentAsSheet(self.viewControllerRsyncParams!)
        }
    }

    @IBAction func delete(_: NSButton) {
        guard self.index != nil else {
            self.info(num: 1)
            return
        }
        if let hiddenID = self.configurations?.gethiddenID(index: self.index!) {
            let answer = Alerts.dialogOrCancel(question: "Delete selected task?", text: "Cancel or Delete", dialog: "Delete")
            if answer {
                // Delete Configurations and Schedules by hiddenID
                self.configurations!.deleteConfigurationsByhiddenID(hiddenID: hiddenID)
                self.schedules!.deletescheduleonetask(hiddenID: hiddenID)
                self.deselect()
                self.index = nil
                self.reloadtabledata()
            }
        }
        self.reset()
    }

    func reset() {
        self.setNumbers(outputprocess: nil)
        self.process = nil
        self.singletask = nil
    }

    @IBAction func TCP(_: NSButton) {
        self.configurations?.tcpconnections = TCPconnections()
        self.configurations?.tcpconnections?.testAllremoteserverConnections()
        self.displayProfile()
    }

    // Presenting Information from Rsync
    @IBAction func information(_: NSButton) {
        globalMainQueue.async { () -> Void in
            self.presentAsSheet(self.viewControllerInformation!)
        }
    }

    // Abort button
    @IBAction func abort(_: NSButton) {
        globalMainQueue.async { () -> Void in
            self.abortOperations()
            self.process = nil
        }
    }

    // Userconfiguration button
    @IBAction func userconfiguration(_: NSButton) {
        globalMainQueue.async { () -> Void in
            self.presentAsSheet(self.viewControllerUserconfiguration!)
        }
    }

    // Selecting profiles
    @IBAction func profiles(_: NSButton) {
        if self.configurations?.tcpconnections?.connectionscheckcompleted ?? true {
            globalMainQueue.async { () -> Void in
                self.presentAsSheet(self.viewControllerProfile!)
            }
        } else {
            self.displayProfile()
        }
    }

    // Selecting About
    @IBAction func about(_: NSButton) {
        self.presentAsModalWindow(self.viewControllerAbout!)
    }

    // Selecting automatic backup
    @IBAction func automaticbackup(_: NSButton) {
        self.automaticbackup()
    }

    @IBAction func executetasknow(_: NSButton) {
        guard self.checkforrsync() == false else { return }
        guard self.index != nil else {
            self.info(num: 1)
            return
        }
        let task = self.configurations!.getConfigurations()[self.index!].task
        guard ViewControllerReference.shared.synctasks.contains(task) else {
            return
        }
        self.executetasknow = ExecuteTaskNow(index: self.index!)
    }

    func automaticbackup() {
        self.presentAsSheet(self.viewControllerEstimating!)
    }

    // Function for display rsync command
    @IBAction func showrsynccommand(_: NSButton) {
        self.showrsynccommandmainview()
    }

    // Display correct rsync command in view
    func showrsynccommandmainview() {
        if let index = self.index {
            guard index <= self.configurations!.getConfigurations().count else { return }
            if self.backupdryrun.state == .on {
                self.rsyncCommand.stringValue = Displayrsyncpath(index: index, display: .synchronize).displayrsyncpath ?? ""
            } else if self.restoredryrun.state == .on {
                self.rsyncCommand.stringValue = Displayrsyncpath(index: index, display: .restore).displayrsyncpath ?? ""
            } else {
                self.rsyncCommand.stringValue = Displayrsyncpath(index: index, display: .verify).displayrsyncpath ?? ""
            }
        } else {
            self.rsyncCommand.stringValue = ""
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.mainTableView.delegate = self
        self.mainTableView.dataSource = self
        self.working.usesThreadedAnimation = true
        ViewControllerReference.shared.setvcref(viewcontroller: .vctabmain, nsviewcontroller: self)
        _ = RsyncVersionString()
        self.mainTableView.target = self
        self.mainTableView.doubleAction = #selector(ViewControllerMain.tableViewDoubleClick(sender:))
        self.backupdryrun.state = .on
        // configurations and schedules
        self.createandreloadconfigurations()
        self.createandreloadschedules()
        //
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        if ViewControllerReference.shared.initialstart == 0 {
            self.view.window?.center()
            ViewControllerReference.shared.initialstart = 1
        }
        if self.configurations!.configurationsDataSourcecount() > 0 {
            globalMainQueue.async { () -> Void in
                self.mainTableView.reloadData()
            }
        }
        self.rsyncischanged()
        self.displayProfile()
        self.initpopupbutton(button: self.profilepopupbutton)
        self.info(num: 0)
    }

    override func viewDidDisappear() {
        super.viewDidDisappear()
    }

    // Execute tasks by double click in table
    @objc(tableViewDoubleClick:) func tableViewDoubleClick(sender _: AnyObject) {
        self.executeSingleTask()
    }

    // Single task can be activated by double click from table
    func executeSingleTask() {
        guard self.checkforrsync() == false else { return }
        guard self.index != nil else { return }
        let task = self.configurations!.getConfigurations()[self.index!].task
        guard ViewControllerReference.shared.synctasks.contains(task) else {
            self.info(num: 6)
            return
        }
        guard self.singletask != nil else {
            // Dry run
            self.singletask = SingleTask(index: self.index!)
            self.singletask?.executeSingleTask()
            return
        }
        // Real run
        self.singletask?.executeSingleTask()
    }

    // Execute BATCH TASKS only
    @IBAction func executeBatch(_: NSButton) {
        guard self.checkforrsync() == false else { return }
        self.setNumbers(outputprocess: nil)
        self.deselect()
        globalMainQueue.async { () -> Void in
            self.presentAsSheet(self.viewControllerBatch!)
        }
    }

    // Function for setting profile
    func displayProfile() {
        weak var localprofileinfomain: SetProfileinfo?
        weak var localprofileinfoadd: SetProfileinfo?
        guard self.configurations?.tcpconnections?.connectionscheckcompleted ?? true else {
            self.profilInfo.stringValue = "Profile: please wait..."
            self.profilInfo.textColor = .white
            return
        }
        if let profile = self.configurations!.getProfile() {
            self.profilInfo.stringValue = "Profile: " + profile
            self.profilInfo.textColor = setcolor(nsviewcontroller: self, color: .white)
        } else {
            self.profilInfo.stringValue = "Profile: default"
            self.profilInfo.textColor = setcolor(nsviewcontroller: self, color: .green)
        }
        localprofileinfoadd = ViewControllerReference.shared.getvcref(viewcontroller: .vcnewconfigurations) as? ViewControllerNewConfigurations
        localprofileinfomain?.setprofile(profile: self.profilInfo.stringValue, color: self.profilInfo.textColor!)
        localprofileinfoadd?.setprofile(profile: self.profilInfo.stringValue, color: self.profilInfo.textColor!)
        self.showrsynccommandmainview()
    }

    func createandreloadschedules() {
        self.process = nil
        guard self.configurations != nil else {
            self.schedules = Schedules(profile: nil)
            return
        }
        if let profile = self.configurations!.getProfile() {
            self.schedules = nil
            self.schedules = Schedules(profile: profile)
        } else {
            self.schedules = nil
            self.schedules = Schedules(profile: nil)
        }
    }

    func createandreloadconfigurations() {
        guard self.configurations != nil else {
            self.configurations = Configurations(profile: nil)
            return
        }
        if let profile = self.configurations!.getProfile() {
            self.configurations = nil
            self.configurations = Configurations(profile: profile)
        } else {
            self.configurations = nil
            self.configurations = Configurations(profile: nil)
        }
        globalMainQueue.async { () -> Void in
            self.mainTableView.reloadData()
        }
        if let reloadDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vcallprofiles) as? ViewControllerAllProfiles {
            reloadDelegate.reloadtable()
        }
    }

    private func initpopupbutton(button: NSPopUpButton) {
        var profilestrings: [String]?
        profilestrings = CatalogProfile().getDirectorysStrings()
        profilestrings?.insert("Default profile", at: 0)
        button.removeAllItems()
        button.addItems(withTitles: profilestrings ?? [])
        button.selectItem(at: 0)
    }

    @IBAction func selectprofile(_: NSButton) {
        var profile = self.profilepopupbutton.titleOfSelectedItem
        if profile == "Default profile" {
            profile = nil
        }
        _ = Selectprofile(profile: profile)
    }
}
