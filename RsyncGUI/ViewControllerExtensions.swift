//
//  ViewControllerExtensions.swift
//  RsyncGUI
//
//  Created by Thomas Evensen on 28.10.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//
// swiftlint:disable line_length

import Cocoa
import Foundation

protocol VcMain {
    var storyboard: NSStoryboard? { get }
}

extension VcMain {
    var storyboard: NSStoryboard? {
        return NSStoryboard(name: "Main", bundle: nil)
    }

    // SheetViews
    var sheetviewsstoryboard: NSStoryboard? {
        return NSStoryboard(name: "SheetViews", bundle: nil)
    }

    // StoryboardOutputID
    var viewControllerAllOutput: NSViewController? {
        return (self.storyboard?.instantiateController(withIdentifier: "StoryboardOutputID")
            as? NSViewController)
    }

    // Rsync userparams
    var viewControllerRsyncParams: NSViewController? {
        return (self.storyboard?.instantiateController(withIdentifier: "StoryboardRsyncParamsID")
            as? NSViewController)!
    }

    // Edit
    var editViewController: NSViewController? {
        return (self.storyboard?.instantiateController(withIdentifier: "StoryboardEditID")
            as? NSViewController)
    }

    // Information about rsync output
    var viewControllerInformation: NSViewController? {
        return (self.sheetviewsstoryboard?.instantiateController(withIdentifier: "StoryboardInformationID")
            as? NSViewController)
    }

    // Progressbar process
    var viewControllerProgress: NSViewController? {
        return (self.sheetviewsstoryboard?.instantiateController(withIdentifier: "StoryboardProgressID")
            as? NSViewController)
    }

    // Userconfiguration
    var viewControllerUserconfiguration: NSViewController? {
        return (self.sheetviewsstoryboard?.instantiateController(withIdentifier: "StoryboardUserconfigID")
            as? NSViewController)
    }

    // Profile
    var viewControllerProfile: NSViewController? {
        return (self.sheetviewsstoryboard?.instantiateController(withIdentifier: "ProfileID")
            as? NSViewController)
    }

    // About
    var viewControllerAbout: NSViewController? {
        return (self.sheetviewsstoryboard?.instantiateController(withIdentifier: "AboutID")
            as? NSViewController)
    }

    // Quick backup process
    var viewControllerQuickBackup: NSViewController? {
        return (self.sheetviewsstoryboard?.instantiateController(withIdentifier: "StoryboardQuickBackupID")
            as? NSViewController)
    }

    // Remote Info
    var viewControllerRemoteInfo: NSViewController? {
        return (self.sheetviewsstoryboard?.instantiateController(withIdentifier: "StoryboardRemoteInfoID")
            as? NSViewController)
    }

    // Estimating
    var viewControllerEstimating: NSViewController? {
        return (self.sheetviewsstoryboard?.instantiateController(withIdentifier: "StoryboardEstimatingID")
            as? NSViewController)
    }

    // local and remote info
    var viewControllerInformationLocalRemote: NSViewController? {
        return (self.sheetviewsstoryboard?.instantiateController(withIdentifier: "StoryboardLocalRemoteID")
            as? NSViewController)
    }

    // AssistID
    var viewControllerAssist: NSViewController? {
        return (self.sheetviewsstoryboard?.instantiateController(withIdentifier: "AssistID")
            as? NSViewController)
    }

    // All profiles
    var allprofiles: NSViewController? {
        return (self.sheetviewsstoryboard?.instantiateController(withIdentifier: "ViewControllerAllProfilesID")
            as? NSViewController)
    }

    // CopyFilesID
}

// Protocol for dismissing a viewcontroller
protocol DismissViewController: AnyObject {
    func dismiss_view(viewcontroller: NSViewController)
}

protocol SetDismisser {
    func dismissview(viewcontroller: NSViewController, vcontroller: ViewController)
}

extension SetDismisser {
    var dismissDelegateMain: DismissViewController? {
        return ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllerMain
    }

    var dismissDelegateNewConfigurations: DismissViewController? {
        return ViewControllerReference.shared.getvcref(viewcontroller: .vcnewconfigurations) as? ViewControllerNewConfigurations
    }

    var dismissDelegateSsh: DismissViewController? {
        return ViewControllerReference.shared.getvcref(viewcontroller: .vcssh) as? ViewControllerSsh
    }

    var dismissDelegateLoggData: DismissViewController? {
        return ViewControllerReference.shared.getvcref(viewcontroller: .vcloggdata) as? ViewControllerLoggData
    }

    var dismissDelegateRestore: DismissViewController? {
        return ViewControllerReference.shared.getvcref(viewcontroller: .vcrestore) as? ViewControllerRestore
    }

    func dismissview(viewcontroller _: NSViewController, vcontroller: ViewController) {
        if vcontroller == .vctabmain {
            self.dismissDelegateMain?.dismiss_view(viewcontroller: (self as? NSViewController)!)
        } else if vcontroller == .vcnewconfigurations {
            self.dismissDelegateNewConfigurations?.dismiss_view(viewcontroller: (self as? NSViewController)!)
        } else if vcontroller == .vcssh {
            self.dismissDelegateSsh?.dismiss_view(viewcontroller: (self as? NSViewController)!)
        } else if vcontroller == .vcloggdata {
            self.dismissDelegateLoggData?.dismiss_view(viewcontroller: (self as? NSViewController)!)
        } else if vcontroller == .vcrestore {
            self.dismissDelegateRestore?.dismiss_view(viewcontroller: (self as? NSViewController)!)
        }
    }
}

// Protocol for deselecting rowtable
protocol DeselectRowTable: AnyObject {
    func deselect()
}

protocol Deselect {
    var deselectDelegateMain: DeselectRowTable? { get }
}

extension Deselect {
    var deselectDelegateMain: DeselectRowTable? {
        return ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllerMain
    }

    func deselectrowtable() {
        self.deselectDelegateMain?.deselect()
    }
}

protocol Index {
    func index() -> Int?
}

extension Index {
    func index() -> Int? {
        let view = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllerMain
        return view?.getindex()
    }
}

protocol Delay {
    func delayWithSeconds(_ seconds: Double, completion: @escaping () -> Void)
}

extension Delay {
    func delayWithSeconds(_ seconds: Double, completion: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            completion()
        }
    }
}

protocol Connected {
    func connected(config: Configuration?) -> Bool
}

extension Connected {
    func connected(config: Configuration?) -> Bool {
        var port: Int = 22
        if let config = config {
            if config.offsiteServer.isEmpty == false {
                if let sshport: Int = config.sshport { port = sshport }
                let success = TCPconnections().testTCPconnection(config.offsiteServer, port: port, timeout: 1)
                return success
            } else {
                return true
            }
        }
        return false
    }
}

protocol Abort: AnyObject {
    func abort()
}

extension Abort {
    func abort() {
        let view = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllerMain
        view?.abortOperations()
    }
}

protocol Help: AnyObject {
    func help()
}

extension Help {
    func help() {
        NSWorkspace.shared.open(URL(string: "https://rsyncosx.netlify.app/post/rsyncguiintro/")!)
    }
}

protocol GetOutput: AnyObject {
    func getoutput() -> [String]
}

protocol OutPut {
    var informationDelegateMain: GetOutput? { get }
}

extension OutPut {
    var informationDelegateMain: GetOutput? {
        return ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllerMain
    }

    func getinfo() -> [String] {
        return (self.informationDelegateMain?.getoutput()) ?? [""]
    }
}

protocol RsyncIsChanged: AnyObject {
    func rsyncischanged()
}

protocol NewRsync {
    func newrsync()
}

extension NewRsync {
    func newrsync() {
        let view = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllerMain
        view?.rsyncischanged()
    }
}

protocol TemporaryRestorePath {
    func temporaryrestorepath()
}

protocol ChangeTemporaryRestorePath {
    func changetemporaryrestorepath()
}

extension ChangeTemporaryRestorePath {
    func changetemporaryrestorepath() {
        let view = ViewControllerReference.shared.getvcref(viewcontroller: .vcrestore) as? ViewControllerRestore
        view?.temporaryrestorepath()
    }
}

protocol Createandreloadconfigurations: AnyObject {
    func createandreloadconfigurations()
}

// Protocol for doing a refresh of tabledata
protocol Reloadsortedandrefresh {
    func reloadsortedandrefreshtabledata()
}

// Protocol for sorting
protocol Sorting {
    func sortbydate(notsortedlist: [NSMutableDictionary]?, sortdirection: Bool) -> [NSMutableDictionary]?
    func sortbystring(notsortedlist: [NSMutableDictionary]?, sortby: Sortandfilter?, sortdirection: Bool) -> [NSMutableDictionary]?
}

extension Sorting {
    func sortbydate(notsortedlist: [NSMutableDictionary]?, sortdirection: Bool) -> [NSMutableDictionary]? {
        let dateformatter = Dateandtime().setDateformat()
        let sorted = notsortedlist?.sorted { (dict1, dict2) -> Bool in
            if let date1localized = dateformatter.date(from: (dict1.value(forKey: DictionaryStrings.dateExecuted.rawValue) as? String) ?? "") {
                if let date2localized = dateformatter.date(from: (dict2.value(forKey: DictionaryStrings.dateExecuted.rawValue) as? String) ?? "") {
                    if date1localized.timeIntervalSince(date2localized) > 0 {
                        return sortdirection
                    } else {
                        return !sortdirection
                    }
                } else {
                    return !sortdirection
                }
            }
            return false
        }
        return sorted
    }

    func sortbystring(notsortedlist: [NSMutableDictionary]?, sortby: Sortandfilter?, sortdirection: Bool) -> [NSMutableDictionary]? {
        let sortstring = self.filterbystring(filterby: sortby)
        let sorted = notsortedlist?.sorted { (dict1, dict2) -> Bool in
            if let dict1 = dict1.value(forKey: sortstring) as? String,
               let dict2 = dict2.value(forKey: sortstring) as? String
            {
                if dict1 > dict2 { return sortdirection } else { return !sortdirection }
            }
            return false
        }
        return sorted
    }

    func filterbystring(filterby: Sortandfilter?) -> String {
        switch filterby ?? .none {
        case .localcatalog:
            return DictionaryStrings.localCatalog.rawValue
        case .profile:
            return DictionaryStrings.profile.rawValue
        case .offsitecatalog:
            return DictionaryStrings.remoteCatalog.rawValue
        case .offsiteserver:
            return DictionaryStrings.offsiteServer.rawValue
        case .task:
            return DictionaryStrings.task.rawValue
        case .backupid:
            return DictionaryStrings.backupID.rawValue
        case .numberofdays:
            return DictionaryStrings.daysID.rawValue
        case .executedate:
            return DictionaryStrings.dateExecuted.rawValue
        default:
            return ""
        }
    }
}
