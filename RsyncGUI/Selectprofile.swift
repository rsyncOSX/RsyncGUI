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

    init(profile: String?, selectedindex: Int?) {
        self.profile = profile
        self.newprofileDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllerMain
        self.loggdataprofileDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vcloggdata) as? ViewControllerLoggData
        self.restoreprofileDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vcrestore) as? ViewControllerRestore
        if self.profile == "Default profile" {
            newprofileDelegate?.newprofile(profile: nil, selectedindex: selectedindex)
        } else {
            newprofileDelegate?.newprofile(profile: self.profile, selectedindex: selectedindex)
        }
        self.restoreprofileDelegate?.newprofile(profile: nil, selectedindex: selectedindex)
        self.loggdataprofileDelegate?.newprofile(profile: nil, selectedindex: selectedindex)
        // Close edit and parameters view if open
        if let view = ViewControllerReference.shared.getvcref(viewcontroller: .vcrsyncparameters) as? ViewControllerRsyncParameters {
            weak var closeview: ViewControllerRsyncParameters?
            closeview = view
            closeview?.closeview()
        }
        if let view = ViewControllerReference.shared.getvcref(viewcontroller: .vcedit) as? ViewControllerEdit {
            weak var closeview: ViewControllerEdit?
            closeview = view
            closeview?.closeview()
        }
    }
}
