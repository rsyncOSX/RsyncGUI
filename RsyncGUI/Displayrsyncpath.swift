//
//  Displayrsyncpath.swift
//  RsyncGUI
//
//  Created by Thomas Evensen on 24/06/2019.
//  Copyright © 2019 Thomas Evensen. All rights reserved.
//

import Foundation

protocol Setinfoaboutrsync: AnyObject {
    func setinfoaboutrsync()
}

enum RsynccommandDisplay {
    case synchronize
    case restore
    case verify
}

struct Displayrsyncpath: SetConfigurations {
    var displayrsyncpath: String?

    init(index: Int, display: RsynccommandDisplay) {
        var str: String?
        let config = self.configurations!.getargumentAllConfigurations()[index]
        str = Getrsyncpath().rsyncpath ?? ""
        str = str! + " "
        switch display {
        case .synchronize:
            if let count = config.argdryRunDisplay?.count {
                for i in 0 ..< count {
                    str = str! + config.argdryRunDisplay![i]
                }
            }
        case .restore:
            if let count = config.restoredryRunDisplay?.count {
                for i in 0 ..< count {
                    str = str! + config.restoredryRunDisplay![i]
                }
            }
        case .verify:
            if let count = config.verifyDisplay?.count {
                for i in 0 ..< count {
                    str = str! + config.verifyDisplay![i]
                }
            }
        }
        self.displayrsyncpath = str
    }
}
