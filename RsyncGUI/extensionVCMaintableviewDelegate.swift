//
//  extensionVCMaintableviewDelegate.swift
//  RsyncGUI
//
//  Created by Thomas Evensen on 26/08/2019.
//  Copyright © 2019 Thomas Evensen. All rights reserved.
//
//  swiftlint:disable cyclomatic_complexity

import Cocoa
import Foundation

// Dismiss view when rsync error
protocol ReportonandhaltonError: AnyObject {
    func reportandhaltonerror()
}

protocol Attributedestring: AnyObject {
    func attributedstring(str: String, color: NSColor, align: NSTextAlignment) -> NSMutableAttributedString
}

extension Attributedestring {
    func attributedstring(str: String, color: NSColor, align: NSTextAlignment) -> NSMutableAttributedString {
        let attributedString = NSMutableAttributedString(string: str)
        let range = (str as NSString).range(of: str)
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: range)
        attributedString.setAlignment(align, range: range)
        return attributedString
    }
}

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
        if let object: NSDictionary = self.configurations?.getConfigurationsDataSource()?[row],
           let markdays: Bool = self.configurations?.getConfigurations()?[row].markdays,
           let tableColumn = tableColumn
        {
            let celltext = object[tableColumn.identifier] as? String
            if tableColumn.identifier.rawValue == DictionaryStrings.daysID.rawValue {
                if markdays {
                    return self.attributedstring(str: celltext!, color: NSColor.red, align: .right)
                } else {
                    return object[tableColumn.identifier] as? String
                }
            } else if tableColumn.identifier.rawValue == DictionaryStrings.offsiteServerCellID.rawValue,
                      ((object[tableColumn.identifier] as? String)?.isEmpty) == true
            {
                return "localhost"
            } else if tableColumn.identifier.rawValue == "statCellID" {
                if row == self.index {
                    if self.singletask == nil {
                        return #imageLiteral(resourceName: "yellow")
                    } else {
                        return #imageLiteral(resourceName: "green")
                    }
                }
            } else {
                // Check if test for connections is selected
                if self.configurations?.tcpconnections?.connectionscheckcompleted ?? false == true {
                    if (self.configurations?.tcpconnections?.gettestAllremoteserverConnections()?[row]) ?? false,
                       tableColumn.identifier.rawValue == DictionaryStrings.offsiteServerCellID.rawValue
                    {
                        return self.attributedstring(str: celltext ?? "", color: NSColor.red, align: .left)
                    } else {
                        return object[tableColumn.identifier] as? String
                    }
                } else {
                    return object[tableColumn.identifier] as? String
                }
            }
            return nil
        }
        return nil
    }

    // when row is selected
    // setting which table row is selected, force new estimation
    func tableViewSelectionDidChange(_ notification: Notification) {
        self.seterrorinfo(info: "")
        // If change row during estimation
        if ViewControllerReference.shared.process != nil, self.index != nil { self.abortOperations() }
        self.backupdryrun.state = .on
        self.info.stringValue = Infoexecute().info(num: 0)
        let myTableViewFromNotification = (notification.object as? NSTableView)!
        let indexes = myTableViewFromNotification.selectedRowIndexes
        if let index = indexes.first {
            self.index = index
            self.indexes = self.mainTableView.selectedRowIndexes
        } else {
            self.index = nil
            self.indexes = nil
        }
        self.reset()
        self.showrsynccommandmainview()
        self.reloadtabledata()
    }

    func tableView(_: NSTableView, rowActionsForRow _: Int, edge: NSTableView.RowActionEdge) -> [NSTableViewRowAction] {
        if edge == .leading {
            let printAction = NSTableViewRowAction(style: .regular, title: "Print") { _, _ in
                print("Now printing...")
            }
            printAction.backgroundColor = NSColor.gray
            return [printAction]

        } else {
            let deleteAction = NSTableViewRowAction(style: .destructive, title: "Delete") { _, _ in
                // self.viewModel.removePurchase(atIndex: row)
                // self.tableView.reloadData()
            }

            return [deleteAction]
        }
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard self.configurations != nil else { return nil }
        if row > (self.configurations?.configurationsDataSourcecount() ?? 0) - 1 { return nil }
        if let object: NSDictionary = self.configurations?.getConfigurationsDataSource()?[row],
           let markdays: Bool = self.configurations?.getConfigurations()?[row].markdays,
           let tableColumn = tableColumn
        {
            let cellIdentifier: String = tableColumn.identifier.rawValue
            switch cellIdentifier {
            case "taskCellID":
                if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: self) as? NSTableCellView {
                    cell.textField?.stringValue = object.value(forKey: cellIdentifier) as? String ?? ""
                    if row == self.index {
                        if self.singletask == nil {
                            cell.imageView?.image = NSImage(#imageLiteral(resourceName: "yellow"))
                        } else {
                            cell.imageView?.image = NSImage(#imageLiteral(resourceName: "green"))
                        }
                    }
                    return cell
                }
            case "offsiteServerCellID":
                if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: self) as? NSTableCellView {
                    cell.textField?.stringValue = object.value(forKey: cellIdentifier) as? String ?? ""
                    if cell.textField?.stringValue.isEmpty ?? true {
                        cell.textField?.stringValue = "localhost"
                    }
                    return cell
                }
            default:
                if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: self) as? NSTableCellView {
                    cell.textField?.stringValue = object.value(forKey: cellIdentifier) as? String ?? ""
                    return cell
                }
            }
        }
        return nil
    }
}
