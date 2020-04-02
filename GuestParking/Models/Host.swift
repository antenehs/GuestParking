//
//  Host.swift
//  GuestParking
//
//  Created by Anteneh Sahledengel on 3/30/20.
//  Copyright © 2020 Anteneh Sahledengel. All rights reserved.
//

import Foundation

struct Host: Codable {
    var appartmentName: String? = "Amli"
    var appartmentID: String? = "11607"

    var parkingCode: String? = "LCRVP"
    var appartmentNumber: String? = "6234"
    var firstName: String? = "Someone"
    var lastName: String? = "Living"

    var fullName: String {
        return (firstName ?? "") + " " + (lastName ?? "")
    }
}

extension Host: PersistenceModel {

    static func allHosts() -> [Host] {
        return DiskPersistanceStore.shared.getAllObjectsOf(type: self)
    }

    func save() {
        DiskPersistanceStore.shared.save(object: self)
    }

    var primaryKey: String {
        return fullName
    }
}
