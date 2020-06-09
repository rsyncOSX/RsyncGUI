//
//  Sequrityscope.swift
//  RsyncGUI
//
//  Created by Thomas Evensen on 06/07/2019.
//  Copyright © 2019 Thomas Evensen. All rights reserved.
//
//  swiftlint:disable line_length trailing_comma

import Foundation

struct RootcatalogSequrityscopedURLs {
    var dictionary: NSMutableDictionary?

    init(suffix: String?) {
        let rootcatalog = Files(whichroot: .sandboxedRoot, configpath: ViewControllerReference.shared.configpath).rootpath ?? ""
        let append = AppendSequrityscopedURLs(path: rootcatalog + (suffix ?? ""))
        self.dictionary = [
            "rootcatalog": append.urlpath!,
            "SecurityScoped": append.success,
        ]
    }
}
