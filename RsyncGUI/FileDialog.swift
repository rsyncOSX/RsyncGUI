//
//  FileDialog.swift
//  RsyncGUI
//
//  Created by Thomas Evensen on 21/09/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//
// swiftlint:disable line_length

import Foundation
import Cocoa

final class FileDialog {

    var urlpath: URL?
    var modal: Bool = true

    private func saveSequrityScopedURL() {
        weak var sequrityscopedsavepathDelegate: SaveSequrityScopedURL?
        sequrityscopedsavepathDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllertabMain
        sequrityscopedsavepathDelegate?.savesequrityscopedurl(urlpath: self.urlpath!)
    }

    private func openfiledlg (title: String, message: String) {
        let openPanel = NSOpenPanel()
        openPanel.prompt = "Select"
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = true
        openPanel.canCreateDirectories = true
        openPanel.canChooseFiles = false
        openPanel.resolvesAliases = true
        openPanel.isReleasedWhenClosed = true
        openPanel.title = title
        openPanel.message = message
        if self.modal {
            let OK = openPanel.runModal()
            if OK.rawValue == NSApplication.ModalResponse.OK.rawValue {
                self.urlpath = openPanel.url
                self.saveSequrityScopedURL()
            }
        } else {
            openPanel.begin(completionHandler: { response in
                if response.rawValue == NSFileHandlingPanelOKButton {
                    self.urlpath = openPanel.url
                    self.saveSequrityScopedURL()
                }
            })
        }
    }

    init() {
        self.openfiledlg(title: "Catalogs", message: "Select catalog")
    }
}
