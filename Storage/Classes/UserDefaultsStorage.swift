//
//  UserDefaultsStorage.swift
//  Pods
//
//  Created by Sam Dean on 8/23/16.
//
//

import Foundation


public final class UserDefaultsStorage<StorableType: Storable>: Storage {
    
    let defaults: NSUserDefaults
    
    public init(defaults: NSUserDefaults) {
        self.defaults = defaults
    }
    
    public func store(value: StorableType, forKey key: String) throws {
        let encoded = try value.storedResult()
    
        let data = NSKeyedArchiver.archivedDataWithRootObject(encoded)
        
        self.defaults.setObject(data, forKey: key)
    }
    
    public func store(values: [StorableType], forKey key: String) throws {
        let encoded = try values.map { try $0.storedResult() }
        
        let data = NSKeyedArchiver.archivedDataWithRootObject(encoded)
        
        self.defaults.setObject(data, forKey: key)
    }
    
    public func retrieve(forKey key: String) throws -> StorableType? {
        guard let object = self.defaults.objectForKey(key) else {
            return nil
        }
        
        guard let data = object as? NSData else {
            throw StorageError.unexpectedType(expected: NSData.self, found: object.dynamicType)
        }
        
        guard let encoded = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? StoredResult else {
            throw StorageError.unexpectedType(expected: StoredResult.self, found: data.dynamicType)
        }
        
        guard let value = try StorableType.init(storedResult: encoded) else {
            throw StorageError.decodingFailed(from: encoded, to: StorableType.self)
        }
        
        return value
    }
    
    public func retrieve(forKey key: String) throws -> [StorableType]? {
        guard let object = self.defaults.objectForKey(key) else {
            return nil
        }
        
        guard let data = object as? NSData else {
            throw StorageError.unexpectedType(expected: NSData.self, found: object.dynamicType)
        }
        
        guard let encoded = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? [StoredResult] else {
            throw StorageError.unexpectedType(expected: [StoredResult].self, found: data.dynamicType)
        }
        
        return try encoded.map {
            guard let value = try StorableType.init(storedResult: $0) else {
                throw StorageError.decodingFailed(from: $0, to: StorableType.self)
            }
            
            return value
        }
    }
}
