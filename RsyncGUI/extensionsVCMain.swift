//
//  extensionsViewControllertabMain.swift
//  RsyncGUI
//
//  Created by Thomas Evensen on 31.05.2018.
//  Copyright © 2018 Thomas Evensen. All rights reserved.
//
//  swiftlint:disable file_length line_length

import Cocoa
import Foundation

// Get output from rsync command
extension ViewControllerMain: GetOutput {
    // Get information from rsync output.
    func getoutput() -> [String] {
        return (self.outputprocess?.trimoutput(trim: .two)) ?? []
    }
}

// Scheduled task are changed, read schedule again og redraw table
extension ViewControllerMain: Reloadandrefresh {
    // Refresh tableView in main
    func reloadtabledata() {
        globalMainQueue.async { () -> Void in
            self.mainTableView.reloadData()
        }
    }
}

// Parameters to rsync is changed
extension ViewControllerMain: RsyncUserParams {
    // Do a reread of all Configurations
    func rsyncuserparamsupdated() {}
}

// Get index of selected row
extension ViewControllerMain: GetSelecetedIndex {
    func getindex() -> Int? {
        return self.index
    }
}

// New profile is loaded.
extension ViewControllerMain: NewProfile {
    // Function is called from profiles when new or default profiles is seleceted
    func newprofile(profile: String?, selectedindex: Int?) {
        if let index = selectedindex {
            self.profilepopupbutton.selectItem(at: index)
        } else {
            self.initpopupbutton()
        }
        self.reset()
        self.singletask = nil
        self.deselect()
        // Read configurations and Scheduledata
        self.configurations = self.createconfigurationsobject(profile: profile)
        self.schedules = self.createschedulesobject(profile: profile)
        // Make sure loading profile
        self.displayProfile()
        self.reloadtabledata()
        self.deselectrowtable()
    }

    func reloadprofilepopupbutton() {
        globalMainQueue.async { () -> Void in
            self.displayProfile()
        }
    }
}

// Rsync path is changed, update displayed rsync command
extension ViewControllerMain: RsyncIsChanged {
    // If row is selected an update rsync command in view
    func rsyncischanged() {
        // Update rsync command in display
        self.setinfoaboutrsync()
        // Setting shortstring
        self.rsyncversionshort.stringValue = ViewControllerReference.shared.rsyncversionshort ?? ""
    }
}

// Check for remote connections, reload table when completed.
extension ViewControllerMain: Connections {
    // Remote servers offline are marked with red line in mainTableView
    func displayConnections() {
        globalMainQueue.async { () -> Void in
            self.mainTableView.reloadData()
        }
    }
}

// Dismisser for sheets
extension ViewControllerMain: DismissViewController {
    // Function for dismissing a presented view
    func dismiss_view(viewcontroller: NSViewController) {
        self.dismiss(viewcontroller)
        // Reset radiobuttons
        globalMainQueue.async { () -> Void in
            self.mainTableView.reloadData()
            self.displayProfile()
        }
        self.setinfoaboutrsync()
    }
}

// Deselect a row
extension ViewControllerMain: DeselectRowTable {
    // deselect a row after row is deleted
    func deselect() {
        if let index = self.index {
            ViewControllerReference.shared.process = nil
            self.index = nil
            self.mainTableView.deselectRow(index)
        }
    }
}

// If rsync throws any error
extension ViewControllerMain: RsyncError {
    func rsyncerror() {
        // Set on or off in user configuration
        globalMainQueue.async { () -> Void in
            self.info.stringValue = "See https://rsyncosx.netlify.app/post/rsyncguiintro/"
            guard ViewControllerReference.shared.haltonerror == true else { return }
            self.deselect()
            // Abort any operations
            _ = InterruptProcess()
            // Either error in single task
            self.singletask?.error()
        }
    }
}

// If, for any reason, handling files or directory throws an error
extension ViewControllerMain: Fileerror {
    func errormessage(errorstr: String, errortype: Fileerrortype) {
        globalMainQueue.async { () -> Void in
            if self.outputprocess == nil {
                self.outputprocess = OutputProcess()
            }
            if errortype == .filesize {
                self.info.stringValue = "Size logfile: " + errorstr
            } else {
                self.outputprocess?.addlinefromoutput(str: self.errordescription(errortype: errortype) + "\n" + errorstr)
                self.info.stringValue = "Error: see https://rsyncosx.netlify.app/post/rsyncguiintro/"
            }
            guard errortype != .filesize else { return }
            _ = Logging(self.outputprocess, true)
        }
    }
}

// Abort task from progressview
extension ViewControllerMain: Abort {
    // Abort any task
    func abortOperations() {
        // Terminates the running process
        _ = InterruptProcess()
        if self.configurations?.remoteinfoestimation != nil, self.configurations?.estimatedlist != nil {
            self.configurations?.remoteinfoestimation = nil
        }
        self.working.stopAnimation(nil)
        self.index = nil
    }
}

// Extensions from here are used in newSingleTask
extension ViewControllerMain: StartStopProgressIndicatorSingleTask {
    func startIndicatorExecuteTaskNow() {
        self.working.startAnimation(nil)
    }

    func startIndicator() {
        self.working.startAnimation(nil)
    }

    func stopIndicator() {
        self.working.stopAnimation(nil)
    }
}

extension ViewControllerMain: GetConfigurationsObject {
    func getconfigurationsobject() -> Configurations? {
        guard self.configurations != nil else { return nil }
        return self.configurations
    }

    func createconfigurationsobject(profile: String?) -> Configurations? {
        self.configurations = nil
        self.configurations = Configurations(profile: profile)
        return self.configurations
    }

    // After a write, a reload is forced.
    // After a write, a reload is forced.
    func reloadconfigurationsobject() {
        self.createandreloadconfigurations()
    }
}

extension ViewControllerMain: GetSchedulesObject {
    func reloadschedulesobject() {
        self.createandreloadschedules()
    }

    func getschedulesobject() -> Schedules? {
        return self.schedules
    }

    func createschedulesobject(profile: String?) -> Schedules? {
        self.schedules = nil
        self.schedules = Schedules(profile: profile)
        return self.schedules
    }
}

extension ViewControllerMain: GetHiddenID {
    func gethiddenID() -> Int? {
        guard self.index != nil else { return -1 }
        if let hiddenID = self.configurations?.gethiddenID(index: self.index!) {
            return hiddenID
        } else {
            return -1
        }
    }
}

extension ViewControllerMain: Setinfoaboutrsync {
    internal func setinfoaboutrsync() {
        if ViewControllerReference.shared.norsync == true {
            self.info.stringValue = Infoexecute().info(num: 3)
        } else {
            self.info.stringValue = Infoexecute().info(num: 0)
        }
    }
}

extension ViewControllerMain: ErrorOutput {
    func erroroutput() {
        self.info.stringValue = Infoexecute().info(num: 2)
    }
}

extension ViewControllerMain: Createandreloadconfigurations {
    // func reateandreloadconfigurations()
}

extension ViewControllerMain: SendOutputProcessreference {
    func sendoutputprocessreference(outputprocess: OutputProcess?) {
        self.outputprocess = outputprocess
    }
}

extension ViewControllerMain: SetRemoteInfo {
    func getremoteinfo() -> RemoteinfoEstimation? {
        return self.configurations!.remoteinfoestimation
    }

    func setremoteinfo(remoteinfotask: RemoteinfoEstimation?) {
        self.configurations!.remoteinfoestimation = remoteinfotask
    }
}

extension ViewControllerMain: OpenQuickBackup {
    func openquickbackup() {
        globalMainQueue.async { () -> Void in
            self.presentAsSheet(self.viewControllerQuickBackup!)
        }
    }
}

extension ViewControllerMain: Count {
    func maxCount() -> Int {
        return (self.outputprocess?.getMaxcount() ?? 0)
    }

    func inprogressCount() -> Int {
        return (self.outputprocess?.count() ?? 0)
    }
}

extension ViewControllerMain: Reloadsortedandrefresh {
    func reloadsortedandrefreshtabledata() {
        globalMainQueue.async { () -> Void in
            self.mainTableView.reloadData()
        }
    }
}

extension ViewControllerMain: ViewOutputDetails {
    func getalloutput() -> [String] {
        return self.outputprocess?.getrawOutput() ?? []
    }

    func reloadtable() {
        weak var localreloadDelegate: Reloadandrefresh?
        localreloadDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vcalloutput) as? ViewControllerAllOutput
        localreloadDelegate?.reloadtabledata()
    }

    func appendnow() -> Bool {
        if ViewControllerReference.shared.getvcref(viewcontroller: .vcalloutput) != nil {
            return true
        } else {
            return false
        }
    }
}

extension ViewControllerMain: ResetSequrityScopedURL {
    func resetsequrityscopedurl() {
        let permissionManager = PermissionManager(bookmarksManager: BookmarksManager.defaultManager)
        permissionManager.bookmarksManager.clearSecurityScopedBookmarks()
    }
}

extension ViewControllerMain: SaveSequrityScopedURL {
    func savesequrityscopedurl(urlpath: URL) {
        let permissionManager = PermissionManager(bookmarksManager: BookmarksManager.defaultManager)
        permissionManager.bookmarksManager.saveSecurityScopedBookmarkForFileAtURL(securityScopedFileURL: urlpath)
    }
}

// Protocol for start,stop, complete progressviewindicator
protocol StartStopProgressIndicator: AnyObject {
    func start()
    func stop()
}

// Protocol for either completion of work or update progress when Process discovers a
// process termination and when filehandler discover data
protocol UpdateProgress: AnyObject {
    func processTermination()
    func fileHandler()
}

protocol ViewOutputDetails: AnyObject {
    func reloadtable()
    func appendnow() -> Bool
    func getalloutput() -> [String]
}

protocol SetProfileinfo: AnyObject {
    func setprofile(profile: String, color: NSColor)
}

// Protocol for getting the hiddenID for a configuration
protocol GetHiddenID: AnyObject {
    func gethiddenID() -> Int?
}

enum Color {
    case red
    case white
    case green
    case black
}

protocol Setcolor: AnyObject {
    func setcolor(nsviewcontroller: NSViewController, color: Color) -> NSColor
}

protocol Checkforrsync: AnyObject {
    func checkforrsync() -> Bool
}

extension Checkforrsync {
    func checkforrsync() -> Bool {
        if ViewControllerReference.shared.norsync == true {
            _ = Norsync()
            return true
        } else {
            return false
        }
    }
}

extension Setcolor {
    private func isDarkMode(view: NSView) -> Bool {
        return view.effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
    }

    func setcolor(nsviewcontroller: NSViewController, color: Color) -> NSColor {
        let darkmode = isDarkMode(view: nsviewcontroller.view)
        switch color {
        case .red:
            return .red
        case .white:
            if darkmode {
                return .white
            } else {
                return .black
            }
        case .green:
            if darkmode {
                return .green
            } else {
                return .blue
            }
        case .black:
            if darkmode {
                return .white
            } else {
                return .black
            }
        }
    }
}

// Get multiple selected indexes
protocol GetMultipleSelectedIndexes: AnyObject {
    func getindexes() -> [Int]
    func multipleselection() -> Bool
}

extension ViewControllerMain: GetMultipleSelectedIndexes {
    func multipleselection() -> Bool {
        return self.multipeselection
    }

    func getindexes() -> [Int] {
        if let indexes = self.indexes {
            return indexes.map { $0 }
        } else {
            return []
        }
    }
}

extension ViewControllerMain: DeinitExecuteTaskNow {
    func deinitexecutetasknow() {
        self.executetasknow = nil
    }
}

extension ViewControllerMain: DisableEnablePopupSelectProfile {
    func enableselectpopupprofile() {
        self.profilepopupbutton.isEnabled = true
    }

    func disableselectpopupprofile() {
        self.profilepopupbutton.isEnabled = false
    }
}

extension ViewControllerMain: Sidebarbuttonactions {
    func sidebarbuttonactions(action: Sidebaractionsmessages) {
        switch action {
        case .Delete:
            self.delete()
        default:
            return
        }
    }
}
