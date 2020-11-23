//
//  Created by Thomas Evensen on 08/02/16.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//
// swiftlint:disable cyclomatic_complexity function_body_length

import Foundation

struct Configuration {
    var hiddenID: Int
    var task: String
    var localCatalog: String
    var offsiteCatalog: String
    var offsiteUsername: String
    var parameter1: String
    var parameter2: String
    var parameter3: String
    var parameter4: String
    var parameter5: String
    var parameter6: String
    var offsiteServer: String
    var backupID: String
    var dateRun: String?
    // parameters choosed by user
    var parameter8: String?
    var parameter9: String?
    var parameter10: String?
    var parameter11: String?
    var parameter12: String?
    var parameter13: String?
    var parameter14: String?
    var rsyncdaemon: Int?
    var sshport: Int?
    var sshkeypathandidentityfile: String?
    var dayssincelastbackup: String?
    var markdays: Bool = false
    var profile: String?

    var lastruninseconds: Double? {
        if let date = self.dateRun {
            let dateformatter = Dateandtime().setDateformat()
            let lastbackup = dateformatter.date(from: date)
            let seconds: TimeInterval = lastbackup?.timeIntervalSinceNow ?? 0
            return seconds * (-1)
        } else {
            return nil
        }
    }

    init(dictionary: NSDictionary) {
        // Parameters 1 - 6 is mandatory, set by RsyncGUI.
        self.hiddenID = (dictionary.object(forKey: DictionaryStrings.hiddenID.rawValue) as? Int) ?? 0
        self.task = dictionary.object(forKey: DictionaryStrings.task.rawValue) as? String ?? ""
        self.localCatalog = dictionary.object(forKey: DictionaryStrings.localCatalog.rawValue) as? String ?? ""
        self.offsiteCatalog = dictionary.object(forKey: DictionaryStrings.offsiteCatalog.rawValue) as? String ?? ""
        self.offsiteUsername = dictionary.object(forKey: DictionaryStrings.offsiteUsername.rawValue) as? String ?? ""
        self.parameter1 = dictionary.object(forKey: DictionaryStrings.parameter1.rawValue) as? String ?? ""
        self.parameter2 = dictionary.object(forKey: DictionaryStrings.parameter2.rawValue) as? String ?? ""
        self.parameter3 = dictionary.object(forKey: DictionaryStrings.parameter3.rawValue) as? String ?? ""
        self.parameter4 = dictionary.object(forKey: DictionaryStrings.parameter4.rawValue) as? String ?? ""
        self.parameter5 = dictionary.object(forKey: DictionaryStrings.parameter5.rawValue) as? String ?? ""
        self.parameter6 = dictionary.object(forKey: DictionaryStrings.parameter6.rawValue) as? String ?? ""
        self.offsiteServer = dictionary.object(forKey: DictionaryStrings.offsiteServer.rawValue) as? String ?? ""
        self.backupID = dictionary.object(forKey: DictionaryStrings.backupID.rawValue) as? String ?? ""
        // Last run of task
        if let dateRun = dictionary.object(forKey: DictionaryStrings.dateRun.rawValue) {
            self.dateRun = dateRun as? String
            if let secondssince = self.lastruninseconds {
                self.dayssincelastbackup = String(format: "%.2f", secondssince / (60 * 60 * 24))
                if secondssince / (60 * 60 * 24) > ViewControllerReference.shared.marknumberofdayssince {
                    self.markdays = true
                }
            }
        }
        // Parameters 8 - 14 is user selected, as well as ssh port.
        if let parameter8 = dictionary.object(forKey: DictionaryStrings.parameter8.rawValue) {
            self.parameter8 = parameter8 as? String
        }
        if let parameter9 = dictionary.object(forKey: DictionaryStrings.parameter9.rawValue) {
            self.parameter9 = parameter9 as? String
        }
        if let parameter10 = dictionary.object(forKey: DictionaryStrings.parameter10.rawValue) {
            self.parameter10 = parameter10 as? String
        }
        if let parameter11 = dictionary.object(forKey: DictionaryStrings.parameter11.rawValue) {
            self.parameter11 = parameter11 as? String
        }
        if let parameter12 = dictionary.object(forKey: DictionaryStrings.parameter12.rawValue) {
            self.parameter12 = parameter12 as? String
        }
        if let parameter13 = dictionary.object(forKey: DictionaryStrings.parameter13.rawValue) {
            self.parameter13 = parameter13 as? String
        }
        if let parameter14 = dictionary.object(forKey: DictionaryStrings.parameter14.rawValue) {
            self.parameter14 = parameter14 as? String
        }
        if let rsyncdaemon = dictionary.object(forKey: DictionaryStrings.rsyncdaemon.rawValue) {
            self.rsyncdaemon = rsyncdaemon as? Int
        }
        if let sshport = dictionary.object(forKey: DictionaryStrings.sshport.rawValue) {
            self.sshport = sshport as? Int
        }
        if let sshidentityfile = dictionary.object(forKey: DictionaryStrings.sshkeypathandidentityfile.rawValue) {
            self.sshkeypathandidentityfile = sshidentityfile as? String
        }
    }

    init(dictionary: NSMutableDictionary) {
        self.hiddenID = dictionary.object(forKey: DictionaryStrings.hiddenID.rawValue) as? Int ?? 0
        self.task = dictionary.object(forKey: DictionaryStrings.task.rawValue) as? String ?? ""
        self.localCatalog = dictionary.object(forKey: DictionaryStrings.localCatalog.rawValue) as? String ?? ""
        self.offsiteCatalog = dictionary.object(forKey: DictionaryStrings.offsiteCatalog.rawValue) as? String ?? ""
        self.offsiteUsername = dictionary.object(forKey: DictionaryStrings.offsiteUsername.rawValue) as? String ?? ""
        self.parameter1 = dictionary.object(forKey: DictionaryStrings.parameter1.rawValue) as? String ?? ""
        self.parameter2 = dictionary.object(forKey: DictionaryStrings.parameter2.rawValue) as? String ?? ""
        self.parameter3 = dictionary.object(forKey: DictionaryStrings.parameter3.rawValue) as? String ?? ""
        self.parameter4 = dictionary.object(forKey: DictionaryStrings.parameter4.rawValue) as? String ?? ""
        self.parameter5 = dictionary.object(forKey: DictionaryStrings.parameter5.rawValue) as? String ?? ""
        self.parameter6 = dictionary.object(forKey: DictionaryStrings.parameter6.rawValue) as? String ?? ""
        self.offsiteServer = dictionary.object(forKey: DictionaryStrings.offsiteServer.rawValue) as? String ?? ""
        self.backupID = dictionary.object(forKey: DictionaryStrings.backupID.rawValue) as? String ?? ""
    }
}
