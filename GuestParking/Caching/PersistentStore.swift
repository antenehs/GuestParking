//
//  PersistenceStoreType.swift
//  FitbitSync
//
//  Created by Anteneh Sahledengel on 8/4/18.
//  Copyright © 2018 Anteneh Sahledengel. All rights reserved.
//

protocol PersistenceModel {
    
    var primaryKey: String { get }

    static var savingFolderPath: String { get }
    static func savingPath(forPrimaryKey primaryKey: String) -> String
}

extension PersistenceModel {
    static var savingFolderPath: String {
        return "\(self)"
    }

    static func savingPath(forPrimaryKey primaryKey: String) -> String {
        return "\(self)/\(primaryKey)"
    }
}

protocol PersistentStore {
    
    static var instance: Self { get }
    
    func getObjectOf<T>(type: T.Type, primaryKey: String) -> T? where T: Codable & PersistenceModel
    func getAllObjectsOf<T>(type: T.Type) -> [T] where T: Codable & PersistenceModel
    func getAllObjectsOf<T>(type: T.Type, matching: (_ element: T) -> Bool) -> [T] where T: Codable & PersistenceModel
    
    func save<T>(object: T) where T: Codable & PersistenceModel
    func save<T>(objects: [T]) where T: Codable & PersistenceModel
    
    func deleteObjectOf<T>(type: T.Type, primaryKey: String) where T: Codable & PersistenceModel
    func deleteObjectsOf<T>(type: T.Type, primaryKeys: [String]) where T: Codable & PersistenceModel
    
    func deleteAllOf<T>(type: T.Type) where T: Codable & PersistenceModel
    func deleteAll()
}
