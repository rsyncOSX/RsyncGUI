//
//  ConvertUserconfiguration.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 26/04/2019.
//  Copyright © 2019 Thomas Evensen. All rights reserved.
//
// swiftlint:disable function_body_length trailing_comma cyclomatic_complexity

import Foundation

struct ConvertUserconfiguration {
    var userconfiguration: [NSMutableDictionary]?

    init() {
        var version3Rsync: Int?
        var detailedlogging: Int?
        var minimumlogging: Int?
        var fulllogging: Int?
        var rsyncPath: String?
        var restorePath: String?
        var marknumberofdayssince: String?
        var haltonerror: Int?
        var monitornetworkconnection: Int?
        var array = [NSMutableDictionary]()
        if ViewControllerReference.shared.rsyncversion3 {
            version3Rsync = 1
        } else {
            version3Rsync = 0
        }
        if ViewControllerReference.shared.detailedlogging {
            detailedlogging = 1
        } else {
            detailedlogging = 0
        }
        if ViewControllerReference.shared.minimumlogging {
            minimumlogging = 1
        } else {
            minimumlogging = 0
        }
        if ViewControllerReference.shared.fulllogging {
            fulllogging = 1
        } else {
            fulllogging = 0
        }
        if ViewControllerReference.shared.rsyncPath != nil {
            rsyncPath = ViewControllerReference.shared.rsyncPath!
        }
        if ViewControllerReference.shared.temporarypathforrestore != nil {
            restorePath = ViewControllerReference.shared.temporarypathforrestore!
        }
        if ViewControllerReference.shared.haltonerror == true {
            haltonerror = 1
        } else {
            haltonerror = 0
        }
        if ViewControllerReference.shared.monitornetworkconnection {
                   monitornetworkconnection = 1
               } else {
                   monitornetworkconnection = 0
               }
        marknumberofdayssince = String(ViewControllerReference.shared.marknumberofdayssince)
        let dict: NSMutableDictionary = [
            "version3Rsync": version3Rsync ?? 0 as Int,
            "detailedlogging": detailedlogging ?? 0 as Int,
            "minimumlogging": minimumlogging ?? 0 as Int,
            "fulllogging": fulllogging ?? 0 as Int,
            "marknumberofdayssince": marknumberofdayssince ?? "5.0",
            "haltonerror": haltonerror ?? 0 as Int,
            "monitornetworkconnection": monitornetworkconnection ?? 0 as Int,
        ]
        if rsyncPath != nil {
            dict.setObject(rsyncPath!, forKey: "rsyncPath" as NSCopying)
        }
        if restorePath != nil {
            dict.setObject(restorePath!, forKey: "restorePath" as NSCopying)
        } else {
            dict.setObject("", forKey: "restorePath" as NSCopying)
        }
        if let sshkeypathandidentityfile = ViewControllerReference.shared.sshkeypathandidentityfile {
            dict.setObject(sshkeypathandidentityfile, forKey: "sshkeypathandidentityfile" as NSCopying)
        }
        if let sshport = ViewControllerReference.shared.sshport {
            dict.setObject(sshport, forKey: "sshport" as NSCopying)
        }
        array.append(dict)
        self.userconfiguration = array
    }
}
