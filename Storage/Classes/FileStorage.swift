//
//  Storage.swift
//  Pods
//
//  Created by Sam Dean on 7/8/16.
//
//

import Foundation


public final class FileStorage<StorableType: Storable>: Storage {
    
    let path: String
    
    public init(path: String) {
        self.path = path
    }
    
    public func store(value: StorableType) throws {
        let dictionary = try value.storedResult()
        
        guard NSKeyedArchiver.archiveRootObject(dictionary, toFile: self.path) else {
            throw StorageError.archiveFailed(encodedValue: dictionary, path: path)
        }
    }
    
    public func store(values: [StorableType]) throws {
        let dictionaries: [StoredResult] = try values.map { return try $0.storedResult() }
        
        guard NSKeyedArchiver.archiveRootObject(dictionaries, toFile: self.path) else {
            throw StorageError.archiveFailed(encodedValue: dictionaries, path: path)
        }
    }
    
    public func retrieve() throws -> StorableType? {
        guard let unarchived = NSKeyedUnarchiver.unarchiveObjectWithFile(self.path) else {
            return nil
        }
        
        guard let dictionary = unarchived as? StoredResult else {
            throw StorageError.unexpectedType(expected: StoredResult.self, found: unarchived.dynamicType)
        }
        
        guard let value = try StorableType.init(storedResult: dictionary) else {
            throw StorageError.decodingFailed(from: dictionary, to: StorableType.self)
        }
        
        return value
    }
    
    public func retrieve() throws -> [StorableType]? {
        guard let unarchived = NSKeyedUnarchiver.unarchiveObjectWithFile(self.path) else {
            return nil
        }

        guard let array = unarchived as? [StoredResult] else {
            throw StorageError.unexpectedType(expected: StoredResult.self, found: unarchived.dynamicType)
        }
        
        let values: [StorableType] = try array.map { encoded in
            guard let value = try StorableType.init(storedResult: encoded) else {
                throw StorageError.decodingFailed(from: encoded, to: StorableType.self)
            }
            return value
        }
        
        return values
    }
}
