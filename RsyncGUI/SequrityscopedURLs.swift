//
//  Sequrityscope.swift
//  RsyncGUI
//
//  Created by Thomas Evensen on 06/07/2019.
//  Copyright © 2019 Thomas Evensen. All rights reserved.
//
//  swiftlint:disable line_length

import Foundation

class SequrityscopedURLs {

    var sequrityscopedURLs: [NSDictionary]?

    private func securityScopedURLrootcatalog() {
        let rootcatalog = Files(whatroot: .realRoot, configpath: ViewControllerReference.shared.configpath).realrootpath ?? ""
        let append = AppendSequrityscopedURLs(path: rootcatalog)
        let success = append.success
        // guard success else { return }
        let fileURLrootcatalog = append.urlpath
        let dict: NSMutableDictionary = [
            "localcatalog": fileURLrootcatalog!,
            "SecurityScoped": success
        ]
        self.sequrityscopedURLs!.append(dict)
    }

    private func securityScopedURLsshrootcatalog() {
        let rootcatalog = Files(whatroot: .realRoot, configpath: ViewControllerReference.shared.configpath).realrootpath ?? ""
        let sshrootcatalog = rootcatalog + "/.ssh"
        let append = AppendSequrityscopedURLs(path: sshrootcatalog)
        let success = append.success
        // guard success else { return }
        let fileURLsshrootcatalog = append.urlpath
        let dict: NSMutableDictionary = [
            "localcatalog": fileURLsshrootcatalog!,
            "SecurityScoped": success
        ]
        self.sequrityscopedURLs!.append(dict)
    }

    init() {
        self.sequrityscopedURLs = [NSDictionary]()
        self.securityScopedURLrootcatalog()
        self.securityScopedURLsshrootcatalog()
    }
}
