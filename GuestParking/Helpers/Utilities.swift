//
//  Utilities.swift
//  GuestParking
//
//  Created by Anteneh Sahledengel on 3/31/20.
//  Copyright © 2020 Anteneh Sahledengel. All rights reserved.
//

import Foundation

protocol MirrorableEnum {}
extension MirrorableEnum {
    var mirror: (label: String, params: [String: Any]) {
        get {
            let reflection = Mirror(reflecting: self)
            guard reflection.displayStyle == .enum,
                let associated = reflection.children.first else {
                    return ("\(self)", [:])
            }
            let values = Mirror(reflecting: associated.value).children
            var valuesArray = [String: Any]()
            for case let item in values where item.label != nil {
                valuesArray[item.label!] = item.value
            }
            return (associated.label!, valuesArray)
        }
    }

    var caseName: String { return mirror.label }
}
