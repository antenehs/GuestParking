//
//  DiskPersistenceStore.swift
//  FitbitSync
//
//  Created by Anteneh Sahledengel on 8/4/18.
//  Copyright © 2018 Anteneh Sahledengel. All rights reserved.
//

import Disk

final class DiskPersistanceStore: PersistentStore {
    
    static let shared = DiskPersistanceStore()
    
    static var instance: DiskPersistanceStore {
        return DiskPersistanceStore.shared
    }
    
    func getObjectOf<T>(type: T.Type, primaryKey: String) -> T? where T: Codable & PersistenceModel {
        
        let key = T.savingPath(forPrimaryKey: primaryKey)
        
        do {
            let object = try Disk.retrieve(key, as: type)
            return object
        } catch  {
            print("Failed to retrieve object:\(error.localizedDescription)")
            return nil
        }
    }
    
    func getAllObjectsOf<T>(type: T.Type) -> [T] where T: Codable & PersistenceModel {
        
        let key = T.savingFolderPath
        
        do {
            let objects = try Disk.retrieveAll(key, as: [T].self)
            return objects
        } catch {
            print("Failed to retrieve object:\(error.localizedDescription)")
        }
        
        return []
    }
    
    func getAllObjectsOf<T>(type: T.Type, matching: (_ element: T) -> Bool) -> [T] where T: Codable & PersistenceModel {
        
        return getAllObjectsOf(type: type).filter(matching)
    }
    
    func save<T>(object: T) where T: Codable & PersistenceModel {
        let key = T.savingPath(forPrimaryKey: object.primaryKey)
        
        do {
            try Disk.save(object, as: key)
        } catch {
            print("Failed to save object:\(error.localizedDescription)")
        }
    }
    
    func save<T>(objects: [T]) where T: Codable & PersistenceModel {
        for object in objects {
            save(object: object)
        }
    }
    
    func deleteObjectOf<T>(type: T.Type, primaryKey: String) where T: Codable & PersistenceModel {
        let key = T.savingPath(forPrimaryKey: primaryKey)
        
        do {
            try Disk.remove(key)
        } catch {
            print("Failed to delete object:\(error.localizedDescription)")
        }
        
    }
    
    func deleteObjectsOf<T>(type: T.Type, primaryKeys: [String]) where T: Codable & PersistenceModel {
        for key in primaryKeys {
            deleteObjectOf(type: type, primaryKey: key)
        }
    }
    
    func deleteAllOf<T>(type: T.Type) where T: Codable & PersistenceModel {
        let key = T.savingFolderPath
        
        do {
            try Disk.remove(key)
        } catch {
            print("Failed to delete objects:\(error.localizedDescription)")
        }
    }
    
    func deleteAll() {
        do {
            try Disk.clear()
        } catch {
            print("Failed to delete objects:\(error.localizedDescription)")
        }
    }
}

fileprivate extension Disk {
    
    /// Retrieve and decode a struct from a file on disk. This will also get all the codables in a folder.
    ///
    /// - Parameters:
    ///   - path: path of the file/folder holding desired data
    ///   - directory: user directory to retrieve the file from
    ///   - type: struct type (i.e. Message.self or [Message].self)
    /// - Returns: decoded structs of data
    /// - Throws: Error if there were any issues retrieving the data or decoding it to the specified type
    static func retrieveAll<T: Decodable>(_ path: String, from directory: Directory, as type: [T].Type) throws -> [T] {
        do {
            guard let url = FileUtils.getExistingFileURLInDocumentsDirectory(for: path) else {
                print("Invalid file path - \(path)")
                return []
            }
            
            let fileUrls = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: [])

            var objects = [T]()
            for i in 0..<fileUrls.count {
                let fileUrl = fileUrls[i]
                let data = try Data(contentsOf: fileUrl)
                if let object = try? JSONDecoder().decode(T.self, from: data) {
                    objects.append(object)
                }
            }
            return objects
        } catch {
            throw error
        }
    }
    
    // MARK: Helpers
    
    static func save<T: Encodable>(_ value: T, as path: String) throws {
        try save(value, to: .documents, as: path)
    }
    
    static func retrieve<T: Decodable>(_ path: String, as type: T.Type) throws -> T {
        return try retrieve(path, from: .documents, as: type)
    }
    
    static func retrieveAll<T: Decodable>(_ path: String, as type: [T].Type) throws -> [T] {
        return try retrieveAll(path, from: .documents, as: type)
    }
    
    static func remove(_ path: String) throws {
        try remove(path, from: .documents)
    }
    
    static func clear() throws {
        try clear(.documents)
    }
}
