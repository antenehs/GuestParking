//
//  Host.swift
//  GuestParking
//
//  Created by Anteneh Sahledengel on 3/30/20.
//  Copyright © 2020 Anteneh Sahledengel. All rights reserved.
//

import Foundation

struct Host: Codable {
    var appartmentName: String? = ""
    var appartmentID: String? = ""

    var parkingCode: String? = ""
    var appartmentNumber: String? = ""
    var firstName: String? = ""
    var lastName: String? = ""

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
