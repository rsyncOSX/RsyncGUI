//
//  Norsync.swift
//  RsyncGUI
//
//  Created by Thomas Evensen on 24/06/2019.
//  Copyright © 2019 Thomas Evensen. All rights reserved.
//

import Foundation

struct Norsync {
    init() {
        if let rsync = ViewControllerReference.shared.rsyncPath {
            Alerts.showInfo(info: "ERROR: no rsync in " + rsync)
        } else {
            Alerts.showInfo(info: "ERROR: no rsync in /usr/local/bin")
        }
    }
}
