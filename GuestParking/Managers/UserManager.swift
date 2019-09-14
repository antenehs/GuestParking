//
//  UserManager.swift
//  GuestParking
//
//  Created by Anteneh Sahledengel on 8/24/19.
//  Copyright © 2019 Anteneh Sahledengel. All rights reserved.
//

import Foundation

class UserManager {

    static let shared = UserManager()

    private init() {}

    var parkingCode = "LCRVP"
    var fullName = "Anteneh Sahledengel"
    var aptNumber = "3115"
}

