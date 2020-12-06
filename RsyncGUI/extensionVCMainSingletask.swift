//
//  extensionVCMainSingletask.swift
//  RsyncGUI
//
//  Created by Thomas Evensen on 26/08/2019.
//  Copyright © 2019 Thomas Evensen. All rights reserved.
//
//  swiftlint:disable line_length

import Foundation

extension ViewControllerMain: SingleTaskProcess {
    func presentViewProgress() {
        globalMainQueue.async { () -> Void in
            self.presentAsSheet(self.viewControllerProgress!)
        }
    }

    func presentViewInformation(outputprocess: OutputProcess?) {
        self.outputprocess = outputprocess
        if self.appendnow() {
            globalMainQueue.async { () -> Void in
                self.mainTableView.reloadData()
            }
        } else {
            globalMainQueue.async { () -> Void in
                self.presentAsSheet(self.viewControllerInformation!)
            }
        }
    }

    func terminateProgressProcess() {
        weak var localprocessupdateDelegate: UpdateProgress?
        localprocessupdateDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vcprogressview) as? ViewControllerProgressProcess
        localprocessupdateDelegate?.processTermination()
    }
}
