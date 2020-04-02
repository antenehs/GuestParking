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
        let latestHost = DiskPersistanceStore.shared.getAllObjectsOf(type: LatestHost.self).first

        #if DEBUG
        if latestHost == nil { return Host() }
        #endif

        return latestHost?.host
    }

    func saveHost(_ host: Host) {
        host.save()

        DiskPersistanceStore.shared.save(object: LatestHost(host: host))
    }
}

struct LatestHost: Codable, PersistenceModel {
    var host: Host

    var primaryKey: String {
        return "LatestHost"
    }
}
