//
//  Selectprofile.swift
//  RsyncGUI
//
//  Created by Thomas Evensen on 25/06/2019.
//  Copyright © 2019 Thomas Evensen. All rights reserved.
//
// swiftlint:disable line_length

import Foundation

final class Selectprofile {
    var profile: String?
    weak var newprofileDelegate: NewProfile?
    weak var restoreprofileDelegate: NewProfile?
    weak var loggdataprofileDelegate: NewProfile?

    init(profile: String?) {
        weak var getprocess: GetProcessreference?
        getprocess = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllerMain
        guard getprocess?.getprocessreference() == nil else { return }
        self.profile = profile
        self.newprofileDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllerMain
        self.loggdataprofileDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vcloggdata) as? ViewControllerLoggData
        self.restoreprofileDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vcrestore) as? ViewControllerRestore
        if self.profile == "Default profile" {
            newprofileDelegate?.newProfile(profile: nil)
        } else {
            newprofileDelegate?.newProfile(profile: self.profile)
        }
        self.restoreprofileDelegate?.newProfile(profile: nil)
        self.loggdataprofileDelegate?.newProfile(profile: nil)
    }
}
