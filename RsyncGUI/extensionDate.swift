//
//  extension Date
//  RsyncGUI
//
//  Created by Thomas Evensen on 08/12/2018.
//  Copyright © 2018 Thomas Evensen. All rights reserved.
//

import Foundation

extension Date {
    init(year: Int, month: Int, day: Int) {
        let calendar = Calendar.current
        var dateComponent = DateComponents()
        dateComponent.year = year
        dateComponent.month = month
        dateComponent.day = day
        self = calendar.date(from: dateComponent)!
    }
}

extension String {
    var setdatesuffixbackupstring: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "-yyyy-MM-dd"
        return self + formatter.string(from: Date())
    }
}
