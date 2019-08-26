//
//  ViewControllertabMain.swift
//  RsyncGUIver30
//  The Main ViewController.
//
//  Created by Thomas Evensen on 19/08/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//
//  swiftlint:disable file_length type_body_length line_length

import Foundation
import Cocoa

class ViewControllerMain: NSViewController, ReloadTable, Deselect, VcMain, Delay, Fileerrormessage, Setcolor {

    // Main tableview
    @IBOutlet weak var mainTableView: NSTableView!
    // Progressbar indicating work
    @IBOutlet weak var working: NSProgressIndicator!
    @IBOutlet weak var workinglabel: NSTextField!
    // Displays the rsyncCommand
    @IBOutlet weak var rsyncCommand: NSTextField!
    // If On result of Dryrun is presented before
    // executing the real run
    @IBOutlet weak var dryRunOrRealRun: NSTextField!
    // number of files to be transferred
    @IBOutlet weak var transferredNumber: NSTextField!
    // size of files to be transferred
    @IBOutlet weak var transferredNumberSizebytes: NSTextField!
    // total number of files in remote volume
    @IBOutlet weak var totalNumber: NSTextField!
    // total size of files in remote volume
    @IBOutlet weak var totalNumberSizebytes: NSTextField!
    // total number of directories remote volume
    @IBOutlet weak var totalDirs: NSTextField!
    // Showing info about profile
    @IBOutlet weak var profilInfo: NSTextField!
    // New files
    @IBOutlet weak var newfiles: NSTextField!
    // Delete files
    @IBOutlet weak var deletefiles: NSTextField!
    @IBOutlet weak var rsyncversionshort: NSTextField!
    @IBOutlet weak var backupdryrun: NSButton!
    @IBOutlet weak var restoredryrun: NSButton!
    @IBOutlet weak var verifydryrun: NSButton!
    // Delegate for refresh allprofiles if changes in profiles
    weak var allprofiledetailsDelegate: ReloadTableAllProfiles?

    // Configurations object
    var configurations: Configurations?
    var schedules: Schedules?
    // Reference to the taskobjects
    var singletask: SingleTask?
    var batchtasks: ExecuteBatch?
    var executetasknow: ExecuteTaskNow?
    var tcpconnections: TCPconnections?
    // Reference to Process task
    var process: Process?
    // Index to selected row, index is set when row is selected
    var index: Int?
    // Getting output from rsync
    var outputprocess: OutputProcess?
    // Dynamic view of output
    var dynamicappend: Bool = false
    // HiddenID task, set when row is selected
    var hiddenID: Int?
    // Can load profiles
    // Load profiles only when testing for connections are done.
    // Application crash if not
    var loadProfileMenu: Bool = false
    // Keep track of all errors
    var outputerrors: OutputErrors?
    // Allprofiles view presented
    var allprofilesview: Bool = false

    @IBOutlet weak var info: NSTextField!

    @IBAction func restore(_ sender: NSButton) {
        guard self.index != nil else {
            self.info(num: 1)
            return
        }
        guard ViewControllerReference.shared.norsync == false else {
            _ = Norsync()
            return
        }
        guard self.configurations!.getConfigurations()[self.index!].task == ViewControllerReference.shared.synchronize else {
            self.info(num: 7)
            return
        }
        self.presentAsSheet(self.restoreViewController!)
    }

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

    @IBAction func infoonetask(_ sender: NSButton) {
        guard self.index != nil else {
            self.info(num: 1)
            return
        }
        guard ViewControllerReference.shared.norsync == false else {
            _ = Norsync()
            return
        }
        guard self.configurations!.getConfigurations()[self.index!].task == ViewControllerReference.shared.synchronize else {
            self.info(num: 7)
            return
        }
        self.presentAsSheet(self.viewControllerInformationLocalRemote!)
    }

    @IBAction func totinfo(_ sender: NSButton) {
        guard ViewControllerReference.shared.norsync == false else {
            _ = Norsync()
            return
        }
        globalMainQueue.async(execute: { () -> Void in
            self.presentAsSheet(self.viewControllerRemoteInfo!)
        })
    }

    @IBAction func quickbackup(_ sender: NSButton) {
        guard ViewControllerReference.shared.norsync == false else {
            _ = Norsync()
            return
        }
        self.openquickbackup()
    }

    @IBAction func edit(_ sender: NSButton) {
        self.reset()
        guard self.index != nil else {
            self.info(num: 1)
            return
        }
        globalMainQueue.async(execute: { () -> Void in
            self.presentAsSheet(self.editViewController!)
        })
    }

    @IBAction func rsyncparams(_ sender: NSButton) {
        self.reset()
        guard self.index != nil else {
            self.info(num: 1)
            return
        }
        globalMainQueue.async(execute: { () -> Void in
            self.presentAsSheet(self.viewControllerRsyncParams!)
        })
    }

    @IBAction func delete(_ sender: NSButton) {
        self.reset()
        guard self.hiddenID != nil else {
            self.info(num: 1)
            return
        }
        let answer = Alerts.dialogOrCancel(question: "Delete selected task?", text: "Cancel or Delete", dialog: "Delete")
        if answer {
            if self.hiddenID != nil {
                // Delete Configurations and Schedules by hiddenID
                self.configurations!.deleteConfigurationsByhiddenID(hiddenID: self.hiddenID!)
                self.schedules!.deletescheduleonetask(hiddenID: self.hiddenID!)
                self.deselect()
                self.hiddenID = nil
                self.index = nil
                self.reloadtabledata()
            }
        }
    }

    func reset() {
        self.outputprocess = nil
        self.setNumbers(outputprocess: nil)
        self.process = nil
        self.singletask = nil
    }

    @IBOutlet weak var TCPButton: NSButton!
    @IBAction func TCP(_ sender: NSButton) {
        self.TCPButton.isEnabled = false
        self.loadProfileMenu = false
        self.displayProfile()
        self.tcpconnections = TCPconnections()
        self.tcpconnections?.testAllremoteserverConnections()
    }

    // Presenting Information from Rsync
    @IBAction func information(_ sender: NSButton) {
        globalMainQueue.async(execute: { () -> Void in
            self.presentAsSheet(self.viewControllerInformation!)
        })
    }

    // Abort button
    @IBAction func abort(_ sender: NSButton) {
        globalMainQueue.async(execute: { () -> Void in
            self.abortOperations()
            self.process = nil
        })
    }

    // Userconfiguration button
    @IBAction func userconfiguration(_ sender: NSButton) {
        globalMainQueue.async(execute: { () -> Void in
            self.presentAsSheet(self.viewControllerUserconfiguration!)
        })
    }

    // Selecting profiles
    @IBAction func profiles(_ sender: NSButton) {
        if self.loadProfileMenu == true {
            globalMainQueue.async(execute: { () -> Void in
                self.presentAsSheet(self.viewControllerProfile!)
            })
        } else {
            self.displayProfile()
        }
    }

    // Logg records
    @IBAction func loggrecords(_ sender: NSButton) {
        globalMainQueue.async(execute: { () -> Void in
            self.presentAsSheet(self.viewControllerScheduleDetails!)
        })
    }

    // Selecting About
    @IBAction func about (_ sender: NSButton) {
        self.presentAsModalWindow(self.viewControllerAbout!)
    }

    // Selecting automatic backup
    @IBAction func automaticbackup (_ sender: NSButton) {
        self.automaticbackup()
    }

    @IBAction func executetasknow(_ sender: NSButton) {
        guard ViewControllerReference.shared.norsync == false else {
            _ = Norsync()
            return
        }
        guard self.hiddenID != nil else {
            self.info(num: 1)
            return
        }
        guard self.index != nil else {
            self.info(num: 1)
            return
        }
        guard self.configurations!.getConfigurations()[self.index!].task == ViewControllerReference.shared.synchronize
            else { return }
        self.executetasknow = ExecuteTaskNow(index: self.index!)
    }

    func automaticbackup() {
        self.presentAsSheet(self.viewControllerEstimating!)
    }

    // Function for display rsync command
    @IBAction func showrsynccommand(_ sender: NSButton) {
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
        self.loadProfileMenu = true
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
            globalMainQueue.async(execute: { () -> Void in
                self.mainTableView.reloadData()
            })
        }
        self.rsyncischanged()
        self.displayProfile()
        self.info(num: 0)
    }

    override func viewDidDisappear() {
        super.viewDidDisappear()
        // Do not allow notify in Main
        self.dynamicappend = false
    }

    // Execute tasks by double click in table
    @objc(tableViewDoubleClick:) func tableViewDoubleClick(sender: AnyObject) {
        self.executeSingleTask()
    }

    // Single task can be activated by double click from table
    func executeSingleTask() {
        guard ViewControllerReference.shared.norsync == false else {
            _ = Norsync()
            return
        }
        guard self.index != nil else { return }
        guard self.configurations!.getConfigurations()[self.index!].task == ViewControllerReference.shared.synchronize
            else {
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
    @IBAction func executeBatch(_ sender: NSButton) {
        guard ViewControllerReference.shared.norsync == false else {
            _ = Norsync()
            return
        }
        self.singletask = nil
        self.setNumbers(outputprocess: nil)
        self.deselect()
        globalMainQueue.async(execute: { () -> Void in
            self.presentAsSheet(self.viewControllerBatch!)
        })
    }

    // Function for setting profile
    func displayProfile() {
        weak var localprofileinfomain: SetProfileinfo?
        weak var localprofileinfoadd: SetProfileinfo?
        guard self.loadProfileMenu == true else {
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
        localprofileinfoadd = ViewControllerReference.shared.getvcref(viewcontroller: .vcnewconfigurations ) as? ViewControllerNewConfigurations
        localprofileinfomain?.setprofile(profile: self.profilInfo.stringValue, color: self.profilInfo.textColor!)
        localprofileinfoadd?.setprofile(profile: self.profilInfo.stringValue, color: self.profilInfo.textColor!)
        self.TCPButton.isEnabled = true
        self.showrsynccommandmainview()
    }

    // when row is selected
    // setting which table row is selected, force new estimation
    func tableViewSelectionDidChange(_ notification: Notification) {
        self.seterrorinfo(info: "")
        // If change row during estimation
        if self.process != nil { self.abortOperations() }
        self.backupdryrun.state = .on
        self.info(num: 0)
        let myTableViewFromNotification = (notification.object as? NSTableView)!
        let indexes = myTableViewFromNotification.selectedRowIndexes
        if let index = indexes.first {
            self.index = index
            self.hiddenID = self.configurations!.gethiddenID(index: index)
            self.outputprocess = nil
            self.setNumbers(outputprocess: nil)
        } else {
            self.index = nil
        }
        self.process = nil
        self.singletask = nil
        self.showrsynccommandmainview()
        self.reloadtabledata()
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
        globalMainQueue.async(execute: { () -> Void in
            self.mainTableView.reloadData()
        })
        if self.allprofilesview {
            self.allprofiledetailsDelegate?.reloadtable()
        }
    }
}
