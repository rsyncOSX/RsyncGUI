//
//  ConvertOneConfig.swift
//  RsyncGUI
//
//  Created by Thomas Evensen on 30/05/2019.
//  Copyright © 2019 Thomas Evensen. All rights reserved.
//
// swiftlint:disable trailing_comma

import Foundation

struct ConvertOneConfig {
    var config: Configuration?

    var dict: NSMutableDictionary {
        let row: NSMutableDictionary = [
            DictionaryStrings.taskCellID.rawValue: self.config?.task ?? "",
            DictionaryStrings.hiddenID.rawValue: self.config?.hiddenID ?? "",
            DictionaryStrings.localCatalogCellID.rawValue: self.config?.localCatalog ?? "",
            DictionaryStrings.offsiteCatalogCellID.rawValue: self.config?.offsiteCatalog ?? "",
            DictionaryStrings.offsiteUsernameID.rawValue: self.config?.offsiteUsername ?? "",
            DictionaryStrings.offsiteServerCellID.rawValue: self.config?.offsiteServer ?? "",
            "backupIDCellID": self.config?.backupID ?? "",
            "runDateCellID": self.config?.dateRun ?? "",
            DictionaryStrings.daysID.rawValue: self.config?.dayssincelastbackup ?? "",
            DictionaryStrings.markdays.rawValue: self.config?.markdays ?? "",
            DictionaryStrings.selectCellID.rawValue: 0,
        ]
        return row
    }

    init(config: Configuration) {
        self.config = config
    }
}
