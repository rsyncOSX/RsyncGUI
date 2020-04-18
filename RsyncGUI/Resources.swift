//
//  Resources.swift
//  RsyncGUI
//
//  Created by Thomas Evensen on 20/12/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//

import Foundation

// Enumtype type of resource
enum ResourceType {
    case changelog
    case documents
    case introduction
    case verify
}

struct Resources {
    // Resource strings
    private var changelog: String = "https://rsyncosx.netlify.app/post/rclonechangelog/"
    private var documents: String = "https://rsyncosx.netlify.app/post/rsyncguifirststart/"
    private var introduction: String = "https://rsyncosx.netlify.app/post/rsyncguiintro/"
    private var verify: String = "https://rsyncosx.netlify.app/post/verify/"
    // Get the resource.
    func getResource(resource: ResourceType) -> String {
        switch resource {
        case .changelog:
            return self.changelog
        case .documents:
            return self.documents
        case .introduction:
            return self.introduction
        case .verify:
            return self.verify
        }
    }
}
