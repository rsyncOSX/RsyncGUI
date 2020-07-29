//
//  Readwritefiles.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 25/10/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//
//  let str = "/Rsync/" + serialNumber + profile? + "/scheduleRsync.plist"
//  let str = "/Rsync/" + serialNumber + profile? + "/configRsync.plist"
//  let str = "/Rsync/" + serialNumber + "/config.plist"
//

import Cocoa
import Foundation

enum WhatToReadWrite {
    case schedule
    case configuration
    case userconfig
    case none
}

class ReadWriteDictionary: NamesandPaths {
    /*
     private func setnameandpath() {
         let docupath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as NSArray
         let docuDir = docupath.firstObject as? String ?? ""
         if ViewControllerReference.shared.macserialnumber == nil {
             ViewControllerReference.shared.macserialnumber = Macserialnumber().getMacSerialNumber() ?? ""
         }
         let macserialnumber = ViewControllerReference.shared.macserialnumber
         // Use profile
         if let profile = self.profile {
             guard profile.isEmpty == false else { return }
             let profilePath = CatalogProfile()
             profilePath.createDirectory()
             self.filepath = self.configpath! + macserialnumber! + "/" + profile + "/"
             self.filename = docuDir + self.configpath! + macserialnumber! + "/" + profile + self.plistname!
         } else {
             // no profile
             let profilePath = CatalogProfile()
             profilePath.createDirectory()
             self.filename = docuDir + self.configpath! + macserialnumber! + self.plistname!
             self.filepath = self.configpath! + macserialnumber! + "/"
         }
     }
     */
    // Function for reading data from persistent store
    func readNSDictionaryFromPersistentStore() -> [NSDictionary]? {
        var data = [NSDictionary]()
        guard self.filename != nil, self.key != nil else { return nil }
        let dictionary = NSDictionary(contentsOfFile: self.filename!)
        let items: Any? = dictionary?.object(forKey: self.key!)
        guard items != nil else { return nil }
        if let arrayofitems = items as? NSArray {
            for i in 0 ..< arrayofitems.count {
                if let item = arrayofitems[i] as? NSDictionary {
                    data.append(item)
                }
            }
        }
        return data
    }

    // Function for write data to persistent store
    func writeNSDictionaryToPersistentStorage(array: [NSDictionary]) -> Bool {
        let dictionary = NSDictionary(object: array, forKey: self.key! as NSCopying)
        guard self.filename != nil else { return false }
        let write = dictionary.write(toFile: self.filename!, atomically: true)
        return write
    }

    init(whattoreadwrite: WhatToReadWrite, profile: String?, configpath: String) {
        super.init(whattoreadwrite: whattoreadwrite, profile: profile, configpath: configpath)
    }
}
