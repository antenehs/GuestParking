//
//  ParkingSiteManager.swift
//  GuestParking
//
//  Created by Anteneh Sahledengel on 4/2/20.
//  Copyright © 2020 Anteneh Sahledengel. All rights reserved.
//

import Foundation

enum ParkingSite: String, CaseIterable {
    case parkingBadge = "ParkingBadge"
    case register2Park = "Register2Park"

    func pageManager() -> PageManager {
        switch self {
        case .parkingBadge:
            return ParkingBadgePageManager()
        case .register2Park:
            return Register2ParkPageManager()
        }
    }
}
