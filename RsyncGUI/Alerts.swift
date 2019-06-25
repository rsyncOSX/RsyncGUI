//
//  alerts.swift
//  Rsync
//
//  Created by Thomas Evensen on 01/02/16.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//

import Cocoa

public struct Alerts {

    public static func showInfo(info: String) {
        let alert = NSAlert()
        alert.messageText = info
        alert.alertStyle = NSAlert.Style.warning
        alert.addButton(withTitle: "Close")
        alert.runModal()
    }

    public static func dialogOrCancel(question: String, text: String, dialog: String) -> Bool {
        let myPopup: NSAlert = NSAlert()
        myPopup.messageText = question
        myPopup.informativeText = text
        myPopup.alertStyle = NSAlert.Style.warning
        myPopup.addButton(withTitle: dialog)
        myPopup.addButton(withTitle: "Cancel")
        let res = myPopup.runModal()
        if res == NSApplication.ModalResponse.alertFirstButtonReturn {
            return true
        }
        return false
    }
}
