//
//  UserManager.swift
//  GuestParking
//
//  Created by Anteneh Sahledengel on 8/24/19.
//  Copyright © 2019 Anteneh Sahledengel. All rights reserved.
//

import Foundation

class HostManager {

    static let shared = HostManager()

    private init() {}

    func latestHost() -> Host? {
        let firstHost = Host.allHosts().first

        #if DEBUG
        if firstHost == nil { return Host() }
        #endif

        return firstHost
    }
}
