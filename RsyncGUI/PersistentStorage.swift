//
//  PersistantStorage.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 20/11/2020.
//  Copyright © 2020 Thomas Evensen. All rights reserved.
//

import Foundation

final class PersistentStorage {
    var configPLIST: PersistentStorageConfiguration?
    var schedulePLIST: PersistentStorageScheduling?
    var whattoreadorwrite: WhatToReadWrite?

    func saveMemoryToPersistentStore() {
        switch self.whattoreadorwrite {
        case .configuration:
            self.configPLIST?.saveconfigInMemoryToPersistentStore()
        case .schedule:
            self.schedulePLIST?.savescheduleInMemoryToPersistentStore()
        default:
            return
        }
    }

    init(profile: String?, whattoreadorwrite: WhatToReadWrite, readonly: Bool) {
        self.whattoreadorwrite = whattoreadorwrite
        switch whattoreadorwrite {
        case .configuration:
            self.configPLIST = PersistentStorageConfiguration(profile: profile)
        case .schedule:
            self.schedulePLIST = PersistentStorageScheduling(profile: profile, readonly: readonly)
        default:
            return
        }
    }

    init(profile: String?, whattoreadorwrite: WhatToReadWrite) {
        self.whattoreadorwrite = whattoreadorwrite
        switch whattoreadorwrite {
        case .configuration:
            self.configPLIST = PersistentStorageConfiguration(profile: profile)
        case .schedule:
            self.schedulePLIST = PersistentStorageScheduling(profile: profile)
        default:
            return
        }
    }

    init() {}

    deinit {
        self.configPLIST = nil
        self.schedulePLIST = nil
    }
}
