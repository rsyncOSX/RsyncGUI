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
    weak var newProfileDelegate: NewProfile?
    weak var copyfilesnewProfileDelegate: NewProfile?
    weak var loggdataProfileDelegate: NewProfile?

    init(profile: String?) {
        weak var getprocess: GetProcessreference?
        getprocess = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllerMain
        guard getprocess?.getprocessreference() == nil else { return }
        self.profile = profile
        self.newProfileDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllerMain
        self.copyfilesnewProfileDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vccopyfiles) as? ViewControllerCopyFiles
        self.loggdataProfileDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vcloggdata) as? ViewControllerLoggData
        if self.profile == "Default profile" {
            newProfileDelegate?.newProfile(profile: nil)
        } else {
            newProfileDelegate?.newProfile(profile: self.profile)
        }
        self.copyfilesnewProfileDelegate?.newProfile(profile: nil)
        self.loggdataProfileDelegate?.newProfile(profile: nil)
    }
}
