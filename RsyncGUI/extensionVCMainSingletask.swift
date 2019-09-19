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
        globalMainQueue.async(execute: { () -> Void in
            self.presentAsSheet(self.viewControllerProgress!)
        })
    }

    func presentViewInformation(outputprocess: OutputProcess?) {
        self.outputprocess = outputprocess
        if self.dynamicappend {
            globalMainQueue.async(execute: { () -> Void in
                self.mainTableView.reloadData()
            })
        } else {
            globalMainQueue.async(execute: { () -> Void in
                self.presentAsSheet(self.viewControllerInformation!)
            })
        }
    }

    func terminateProgressProcess() {
        weak var localprocessupdateDelegate: UpdateProgress?
        localprocessupdateDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vcprogressview) as? ViewControllerProgressProcess
        localprocessupdateDelegate?.processTermination()
    }

    func seterrorinfo(info: String) {
        guard info.isEmpty == false else {
            self.dryRunOrRealRun.isHidden = true
            return
        }
        self.dryRunOrRealRun.textColor = .red
        self.dryRunOrRealRun.isHidden = false
        self.dryRunOrRealRun.stringValue = info
    }

    // Function for getting numbers out of output object updated when
    // Process object executes the job.
    func setNumbers(outputprocess: OutputProcess?) {
        globalMainQueue.async(execute: { () -> Void in
            guard outputprocess != nil else {
                self.transferredNumber.stringValue = ""
                self.transferredNumberSizebytes.stringValue = ""
                self.totalNumber.stringValue = ""
                self.totalNumberSizebytes.stringValue = ""
                self.totalDirs.stringValue = ""
                self.newfiles.stringValue = ""
                self.deletefiles.stringValue = ""
                return
            }
            let remoteinfotask = RemoteinfonumbersOnetask(outputprocess: outputprocess)
            self.transferredNumber.stringValue = remoteinfotask.transferredNumber!
            self.transferredNumberSizebytes.stringValue = remoteinfotask.transferredNumberSizebytes!
            self.totalNumber.stringValue = remoteinfotask.totalNumber!
            self.totalNumberSizebytes.stringValue = remoteinfotask.totalNumberSizebytes!
            self.totalDirs.stringValue = remoteinfotask.totalDirs!
            self.newfiles.stringValue = remoteinfotask.newfiles!
            self.deletefiles.stringValue = remoteinfotask.deletefiles!
        })
    }

    // Returns number set from dryrun to use in logging run
    // after a real run. Logging is in newSingleTask object.
    func gettransferredNumber() -> String {
        return self.transferredNumber.stringValue
    }

    func gettransferredNumberSizebytes() -> String {
        return self.transferredNumberSizebytes.stringValue
    }
}
