//
//  Host.swift
//  GuestParking
//
//  Created by Anteneh Sahledengel on 3/30/20.
//  Copyright © 2020 Anteneh Sahledengel. All rights reserved.
//

import Foundation

struct Host: Codable {
    var appartmentName: String? = "801 Las Co Apartments - 801 Lake Carolyn Parkway"
    var appartmentID: String? = "95"

    var parkingCode: String? = "LCRVP"
    var appartmentNumber: String? = "3115"
    var firstName: String? = "Anteneh"
    var lastName: String? = "Sahledengel"

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
