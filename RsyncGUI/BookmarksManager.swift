//
//  BookmarksManager.swift
//  Sandbox
//
//  Created by Vincent Esche on 3/10/15.
//  Copyright (c) 2015 Vincent Esche. All rights reserved.
//
// swiftlint:disable line_length

import Foundation

public class BookmarksManager: FileErrors {
    public let userDefaults: UserDefaults
    public static let defaultManager: BookmarksManager = BookmarksManager()
    private static let userDefaultsBookmarksKey = "no.blogspot.rsyncgui"

    private var securityScopedBookmarksByFilePath: [String: NSData] {
        get {
            let bookmarksByFilePath = self.userDefaults.dictionary(forKey: BookmarksManager.userDefaultsBookmarksKey) as? [String: NSData]
            return bookmarksByFilePath ?? [:]
        }
        set {
            self.userDefaults.set(newValue, forKey: BookmarksManager.userDefaultsBookmarksKey)
        }
    }

    public func clearSecurityScopedBookmarks() {
        self.securityScopedBookmarksByFilePath = [:]
    }

    public func fileURLFromSecurityScopedBookmark(bookmark: NSData) -> URL? {
        let options: NSURL.BookmarkResolutionOptions = [.withSecurityScope, .withoutUI]
        var stale: ObjCBool = false
        if let fileURL = try? NSURL(resolvingBookmarkData: bookmark as Data, options: options, relativeTo: nil, bookmarkDataIsStale: &stale) {
            return fileURL as URL
        } else {
            return nil
        }
    }

    public func loadSecurityScopedURLForFileAtURL(fileURL: URL) -> URL? {
        if let bookmark = self.loadSecurityScopedBookmarkForFileAtURL(fileURL: fileURL) {
            return self.fileURLFromSecurityScopedBookmark(bookmark: bookmark)
        }
        return nil
    }

    public func loadSecurityScopedBookmarkForFileAtURL(fileURL: URL) -> NSData? {
        var resolvedFileURL: URL?
        resolvedFileURL = fileURL.standardizedFileURL.resolvingSymlinksInPath()
        let bookmarksByFilePath = self.securityScopedBookmarksByFilePath
        var securityScopedBookmark = bookmarksByFilePath[resolvedFileURL!.path]
        while securityScopedBookmark == nil, resolvedFileURL!.pathComponents.count > 1 {
            resolvedFileURL = resolvedFileURL?.deletingLastPathComponent()
            securityScopedBookmark = bookmarksByFilePath[resolvedFileURL!.path]
        }
        return securityScopedBookmark
    }

    public func securityScopedBookmarkForFileAtURL(fileURL: URL) -> NSData? {
        do {
            let bookmark = try fileURL.bookmarkData(options: NSURL.BookmarkCreationOptions.withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil)
            return bookmark as NSData?
        } catch let e {
            let error = e as NSError
            self.error(error: error.description, errortype: .sequrityscoped)
            return nil
        }
    }

    public func saveSecurityScopedBookmarkForFileAtURL(securityScopedFileURL: URL) {
        if let bookmark = self.securityScopedBookmarkForFileAtURL(fileURL: securityScopedFileURL) {
            self.saveSecurityScopedBookmark(securityScopedBookmark: bookmark)
        }
    }

    public func saveSecurityScopedBookmark(securityScopedBookmark: NSData) {
        if let fileURL = self.fileURLFromSecurityScopedBookmark(bookmark: securityScopedBookmark) {
            var savesecurityScopedBookmarks = self.securityScopedBookmarksByFilePath
            savesecurityScopedBookmarks[fileURL.path] = securityScopedBookmark
            self.securityScopedBookmarksByFilePath = savesecurityScopedBookmarks
        }
    }

    public init() {
        self.userDefaults = UserDefaults.standard
    }
}
