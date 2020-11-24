//
//  Allschedules.swift
//  RsyncOSXsched
//
//  Created by Thomas Evensen on 06.05.2018.
//  Copyright © 2018 Maxim. All rights reserved.
//
// swiftlint:disable line_length

import Cocoa
import Foundation

class Allschedules {
    private var allschedules: [ConfigurationSchedule]?
    private var allprofiles: [String]?

    private func readallschedules(includelog: Bool) {
        var configurationschedule: [ConfigurationSchedule]?
        for i in 0 ..< (self.allprofiles?.count ?? 0) {
            let profilename = self.allprofiles?[i]
            if self.allschedules == nil {
                self.allschedules = []
            }
            if profilename == "Default profile" {
                configurationschedule = PersistentStorageAllprofilesAPI(profile: nil).getScheduleandhistory(includelog: includelog)
            } else {
                configurationschedule = PersistentStorageAllprofilesAPI(profile: profilename).getScheduleandhistory(includelog: includelog)
            }
            for j in 0 ..< (configurationschedule?.count ?? 0) {
                configurationschedule?[j].profilename = profilename
                if let configurationschedule = configurationschedule?[j] {
                    self.allschedules?.append(configurationschedule)
                }
            }
        }
    }

    init(includelog: Bool) {
        self.allprofiles = AllProfilenames().allprofiles
        self.readallschedules(includelog: includelog)
    }
}
