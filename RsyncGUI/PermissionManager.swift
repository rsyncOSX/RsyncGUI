//
//  PermissionManager.swift
//  Sandbox
//
//  Created by Vincent Esche on 3/10/15.
//  Copyright (c) 2015 Vincent Esche. All rights reserved.
//
// swiftlint: disable line_length

import Cocoa

public protocol OpenPanelDelegateType: AnyObject, NSOpenSavePanelDelegate {
    var fileURL: NSURL! { get set }
}

public class PermissionManager {
    public let bookmarksManager: BookmarksManager
    public lazy var openPanelDelegate: OpenPanelDelegateType = OpenPanelDelegate()
    public lazy var openPanel: NSOpenPanel = OpenPanelBuilder().openPanel()
    public static let defaultManager = PermissionManager()

    public func needsPermissionForFileAtURL(fileURL: URL) -> Bool {
        let reachable = try? fileURL.checkResourceIsReachable()
        let readable = FileManager.default.isReadableFile(atPath: fileURL.absoluteString)
        return reachable ?? false && !readable
    }

    public func askUserForSecurityScopeForFileAtURL(fileURL: URL) -> URL? {
        if !self.needsPermissionForFileAtURL(fileURL: fileURL) { return fileURL }
        let openPanel = self.openPanel
        if openPanel.directoryURL == nil {
            openPanel.directoryURL = fileURL.deletingLastPathComponent()
        }
        let openPanelDelegate = self.openPanelDelegate
        openPanelDelegate.fileURL = fileURL as NSURL
        openPanel.delegate = openPanelDelegate
        var securityScopedURL: URL?
        let closure: () -> Void = {
            NSApplication.shared.activate(ignoringOtherApps: true)
            if openPanel.runModal().rawValue == NSApplication.ModalResponse.OK.rawValue {
                securityScopedURL = openPanel.url as URL?
            }
            openPanel.delegate = nil
        }
        if Thread.isMainThread {
            closure()
        } else {
            DispatchQueue.main.sync(execute: closure)
        }
        if let pathforcatalog = securityScopedURL {
            self.bookmarksManager.saveSecurityScopedBookmarkForFileAtURL(securityScopedFileURL: pathforcatalog)
        }
        return securityScopedURL
    }

    public func accessSecurityScopedFileAtURL(fileURL: URL) -> Bool {
        let accessible = fileURL.startAccessingSecurityScopedResource()
        if accessible {
            return true
        } else {
            return false
        }
    }

    public func accessAndIfNeededAskUserForSecurityScopeForFileAtURL(fileURL: URL) -> Bool {
        if self.needsPermissionForFileAtURL(fileURL: fileURL) == false { return true }
        let bookmarkedURL = self.bookmarksManager.loadSecurityScopedURLForFileAtURL(fileURL: fileURL)
        let securityScopedURL = bookmarkedURL ?? self.askUserForSecurityScopeForFileAtURL(fileURL: fileURL)
        if securityScopedURL != nil {
            return self.accessSecurityScopedFileAtURL(fileURL: securityScopedURL!)
        }
        return false
    }

    public init(bookmarksManager: BookmarksManager = BookmarksManager()) {
        self.bookmarksManager = bookmarksManager
    }
}
