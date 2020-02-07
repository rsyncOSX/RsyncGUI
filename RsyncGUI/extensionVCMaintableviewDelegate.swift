//
//  extensionVCMaintableviewDelegate.swift
//  RsyncGUI
//
//  Created by Thomas Evensen on 26/08/2019.
//  Copyright © 2019 Thomas Evensen. All rights reserved.
//
// swiftlint:disable cyclomatic_complexity

import Cocoa
import Foundation

extension ViewControllerMain: NSTableViewDataSource {
    // Delegate for size of table
    func numberOfRows(in _: NSTableView) -> Int {
        return self.configurations?.configurationsDataSourcecount() ?? 0
    }
}

extension ViewControllerMain: NSTableViewDelegate, Attributedestring {
    // TableView delegates
    func tableView(_: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        guard self.configurations != nil else { return nil }
        if row > (self.configurations?.configurationsDataSourcecount() ?? 0) - 1 { return nil }
        let object: NSDictionary = self.configurations!.getConfigurationsDataSource()![row]
        let markdays: Bool = self.configurations!.getConfigurations()[row].markdays
        let celltext = object[tableColumn!.identifier] as? String
        if tableColumn!.identifier.rawValue == "daysID" {
            if markdays {
                return self.attributedstring(str: celltext!, color: NSColor.red, align: .right)
            } else {
                return object[tableColumn!.identifier] as? String
            }
        } else if tableColumn!.identifier.rawValue == "offsiteServerCellID",
            ((object[tableColumn!.identifier] as? String)?.isEmpty) == true {
            return "localhost"
        } else if tableColumn!.identifier.rawValue == "statCellID" {
            if row == self.index {
                if self.singletask == nil {
                    return #imageLiteral(resourceName: "yellow")
                } else {
                    return #imageLiteral(resourceName: "green")
                }
            }
        } else {
            if tableColumn!.identifier.rawValue == "batchCellID" {
                return object[tableColumn!.identifier] as? Int
            } // Check if test for connections is selected
            if self.configurations?.tcpconnections?.connectionscheckcompleted ?? false == true {
                if (self.configurations?.tcpconnections?.gettestAllremoteserverConnections()?[row]) ?? false,
                    tableColumn!.identifier.rawValue == "offsiteServerCellID" {
                    return self.attributedstring(str: celltext ?? "", color: NSColor.red, align: .left)
                } else {
                    return object[tableColumn!.identifier] as? String
                }
            } else {
                return object[tableColumn!.identifier] as? String
            }
        }
        return nil
    }

    // Toggling batch
    func tableView(_: NSTableView, setObjectValue _: Any?, for _: NSTableColumn?, row: Int) {
        if self.process != nil {
            self.abortOperations()
        }
        let task = self.configurations!.getConfigurations()[row].task
        if ViewControllerReference.shared.synctasks.contains(task) {
            self.configurations!.togglebatch(row)
        }
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
        } else {
            self.index = nil
        }
        self.reset()
        self.showrsynccommandmainview()
        self.reloadtabledata()
    }
}
