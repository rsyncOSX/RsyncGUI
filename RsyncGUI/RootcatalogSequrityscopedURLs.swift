//
//  Sequrityscope.swift
//  RsyncGUI
//
//  Created by Thomas Evensen on 06/07/2019.
//  Copyright © 2019 Thomas Evensen. All rights reserved.
//
//  swiftlint:disable line_length

import Foundation

struct RootcatalogSequrityscopedURLs {

    var dictionary: NSMutableDictionary?

    init(suffix: String?) {
        let rootcatalog = Files(whatroot: .realRoot, configpath: ViewControllerReference.shared.configpath).realrootpath ?? ""
        let append = AppendSequrityscopedURLs(path: rootcatalog + (suffix ?? ""))
        self.dictionary = [
            "rootcatalog": append.urlpath!,
            "SecurityScoped": append.success
        ]
    }
}
