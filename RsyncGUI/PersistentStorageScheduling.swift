//
//  PersistenStorescheduling.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 02/05/16.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//
//   Interface between Schedule in memory and
//   presistent store. Class is a interface
//   for Schedule.
//

import Files
import Foundation

class PersistentStorageScheduling: ReadWriteDictionary, SetSchedules {
    // Variable holds all schedule data from persisten storage
    var schedulesasdictionary: [NSDictionary]?

    // Saving Schedules from MEMORY to persistent store
    func savescheduleInMemoryToPersistentStore() {
        if let dicts: [NSDictionary] = ConvertSchedules().schedules {
            self.writeToStore(array: dicts)
        }
    }

    // Writing schedules to persistent store
    // Schedule is [NSDictionary]
    private func writeToStore(array: [NSDictionary]) {
        if self.writeNSDictionaryToPersistentStorage(array: array) {
            self.schedulesDelegate?.reloadschedulesobject()
        }
    }

    init(profile: String?) {
        super.init(whattoreadwrite: .schedule, profile: profile)
        if self.schedules == nil {
            self.schedulesasdictionary = self.readNSDictionaryFromPersistentStore()
        }
    }

    init(profile: String?, readonly: Bool) {
        super.init(whattoreadwrite: .schedule, profile: profile)
        if readonly == true {
            self.schedulesasdictionary = self.readNSDictionaryFromPersistentStore()
        }
    }
}
