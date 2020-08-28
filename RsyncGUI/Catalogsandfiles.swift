//
//  files.swift
//  RsyncGUI
//
//  Created by Thomas Evensen on 26.04.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//

import Files
import Foundation

enum WhichRoot {
    case profileRoot
    case sshRoot
    case sandboxedRoot
}

enum Fileerrortype {
    case writelogfile
    case profilecreatedirectory
    case profiledeletedirectory
    case filesize
    case sequrityscoped
    case homerootcatalog
}

// Protocol for reporting file errors
protocol Fileerror: AnyObject {
    func errormessage(errorstr: String, errortype: Fileerrortype)
}

protocol Fileerrors {
    var errorDelegate: Fileerror? { get }
}

extension Fileerrors {
    var errorDelegate: Fileerror? {
        return ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllerMain
    }

    func error(error: String, errortype: Fileerrortype) {
        self.errorDelegate?.errormessage(errorstr: error, errortype: errortype)
    }
}

protocol Errormessage {
    func errordescription(errortype: Fileerrortype) -> String
}

extension Errormessage {
    func errordescription(errortype: Fileerrortype) -> String {
        switch errortype {
        case .writelogfile:
            return "Could not write to logfile"
        case .profilecreatedirectory:
            return "Could not create profile directory"
        case .profiledeletedirectory:
            return "Could not delete profile directory"
        case .filesize:
            return "Filesize of logfile is getting bigger"
        case .sequrityscoped:
            return "Could not save SequrityScoped URL"
        case .homerootcatalog:
            return "Could not get root of homecatalog"
        }
    }
}

class Catalogsandfiles: NamesandPaths, Fileerrors {
    // Function for returning files in path as array of URLs
    func getcatalogsasURLnames() -> [URL]? {
        if let atpath = self.rootpath {
            do {
                var array = [URL]()
                for file in try Folder(path: atpath).files {
                    array.append(file.url)
                }
                return array
            } catch {
                return nil
            }
        }
        return nil
    }

    // Function for returning files in path as array of Strings
    func getfilesasstringnames() -> [String]? {
        if let atpath = self.rootpath {
            do {
                var array = [String]()
                for file in try Folder(path: atpath).files {
                    array.append(file.name)
                }
                return array
            } catch {
                return nil
            }
        }
        return nil
    }

    // Function for returning profiles as array of Strings
    func getcatalogsasstringnames() -> [String]? {
        if let atpath = self.rootpath {
            var array = [String]()
            do {
                for folders in try Folder(path: atpath).subfolders {
                    array.append(folders.name)
                }
                return array
            } catch {
                return nil
            }
        }
        return nil
    }

    // Func that creates directory if not created
    func createprofilecatalog() {
        let fileManager = FileManager.default
        if let path = self.rootpath {
            // Profile root
            if fileManager.fileExists(atPath: path) == false {
                do {
                    try fileManager.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
                } catch let e {
                    let error = e as NSError
                    self.error(error: error.description, errortype: .profilecreatedirectory)
                }
            }
        }
    }

    override init(whichroot: WhichRoot, configpath: String?) {
        super.init(whichroot: whichroot, configpath: configpath)
    }
}
