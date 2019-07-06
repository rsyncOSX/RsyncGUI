//
//  Sequrityscope.swift
//  RsyncGUI
//
//  Created by Thomas Evensen on 06/07/2019.
//  Copyright © 2019 Thomas Evensen. All rights reserved.
//
//  swiftlint:disable line_length

import Foundation

struct SequrityscopedURLs {

    var dictionary: NSMutableDictionary?

    init(prefix: String?) {
        var rootcatalog = Files(whatroot: .realRoot, configpath: ViewControllerReference.shared.configpath).realrootpath ?? ""
        if prefix != nil {
            rootcatalog = rootcatalog + prefix!
        }
        let append = AppendSequrityscopedURLs(path: rootcatalog)
        self.dictionary = [
            "localcatalog": append.urlpath!,
            "SecurityScoped": append.success
        ]
    }
}
