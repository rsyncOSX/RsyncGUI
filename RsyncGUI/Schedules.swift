//
//  This object stays in memory runtime and holds key data and operations on Schedules.
//  The obect is the model for the Schedules but also acts as Controller when
//  the ViewControllers reads or updates data.
//
//  Created by Thomas Evensen on 09/05/16.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//

import Cocoa
import Foundation

class Schedules: ScheduleWriteLoggData {
    // Return reference to Schedule data
    // self.Schedule is privat data
    func getSchedule() -> [ConfigurationSchedule]? {
        return self.schedules
    }

    // Function deletes all Schedules by hiddenID. Invoked when Configurations are
    // deleted. When a Configuration are deleted all tasks connected to
    // Configuration has to  be deleted.
    // - parameter hiddenID : hiddenID for task
    func deletescheduleonetask(hiddenID: Int) {
        var delete: Bool = false
        for i in 0 ..< (self.schedules?.count ?? 0) where self.schedules?[i].hiddenID == hiddenID {
            // Mark Schedules for delete
            // Cannot delete in memory, index out of bound is result
            self.schedules?[i].delete = true
            delete = true
        }
        if delete {
            PersistentStorageScheduling(profile: self.profile).savescheduleInMemoryToPersistentStore()
            // Send message about refresh tableView
            self.reloadtable(vcontroller: .vctabmain)
        }
    }

    // Test if Schedule record in memory is set to delete or not
    func delete(dict: NSDictionary) {
        if let hiddenID = dict.value(forKey: DictionaryStrings.hiddenID.rawValue) as? Int {
            if let schedule = dict.value(forKey: DictionaryStrings.schedule.rawValue) as? String {
                if let datestart = dict.value(forKey: DictionaryStrings.dateStart.rawValue) as? String {
                    if let i = self.schedules?.firstIndex(where: { $0.hiddenID == hiddenID
                            && $0.schedule == schedule
                            && $0.dateStart == datestart
                    }) {
                        self.schedules?[i].delete = true
                    }
                }
            }
        }
    }

    // Function for reading all jobs for schedule and all history of past executions.
    // Schedules are stored in self.schedules. Schedules are sorted after hiddenID.
    private func readschedules() {
        var store = PersistentStorageScheduling(profile: self.profile).getScheduleandhistory(includelog: true)
        guard store != nil else { return }
        var data = [ConfigurationSchedule]()
        for i in 0 ..< (store?.count ?? 0) where store?[i].logrecords?.isEmpty == false || store?[i].dateStop != nil {
            store?[i].profilename = self.profile
            if let store = store?[i] {
                data.append(store)
            }
        }
        // Sorting schedule after hiddenID
        data.sort { (schedule1, schedule2) -> Bool in
            if schedule1.hiddenID > schedule2.hiddenID {
                return false
            } else {
                return true
            }
        }
        // Setting self.Schedule as data
        self.schedules = data
    }

    override init(profile: String?) {
        super.init(profile: profile)
        self.profile = profile
        let schedulesdata = SchedulesData(profile: profile,
                                          validhiddenID: self.configurations?.validhiddenID)
        self.schedules = schedulesdata.schedules
    }
}
