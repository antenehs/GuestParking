//
//  CodableExtensions.swift
//  GuestParking
//
//  Created by Anteneh Sahledengel on 3/30/20.
//  Copyright © 2020 Anteneh Sahledengel. All rights reserved.
//

import Foundation

extension Encodable {
    func toDictionary() -> [AnyHashable: Any]? {
        guard let data = try? JSONEncoder().encode(self),
            let dictionary = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [AnyHashable: Any] else {
                return nil
        }

        return dictionary
    }
}

extension Decodable {
    init?(dictionary: [AnyHashable: Any]) {
        guard let data = try? JSONSerialization.data(withJSONObject: dictionary, options: []),
            let decoded = try? JSONDecoder().decode(Self.self, from: data) else { return nil }

        self = decoded
    }
}
