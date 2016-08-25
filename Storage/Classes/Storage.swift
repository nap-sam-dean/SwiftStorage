//
//  Encodable.swift
//  Pods
//
//  Created by Sam Dean on 7/8/16.
//
//

import Foundation


/**
 Base set of error cases thrown by Storage implementations
 */
public enum StorageError: ErrorType {
    case encodingFailed(value: Storable)
    case archiveFailed(encodedValue: AnyObject, path: String)
    case unarchiveFailed(path: String)
    case unexpectedType(expected: Any.Type, found: Any.Type)
    case decodingFailed(from: AnyObject, to: Any.Type)
}


/**
 Returned / consumed by the methods in the `Storable` protocol
 */
public typealias StoredResult = [String: NSCoding]


/**
 Implement this protocol on classes/structs you want to store.
 */
public protocol Storable {
    func storedResult() throws -> StoredResult
    
    init?(storedResult: StoredResult) throws
}


/**
 Implementations of this can store / retrieve stored objects/classes
 
 TODO: With swift 3 we can remove the [T] methods and just make arrays of Storable implement Storable
 */
public protocol Storage {
    associatedtype StorableType: Storable
    
    func store(value: StorableType, forKey key: String) throws
    
    func store(values: [StorableType], forKey key: String) throws
    
    func retrieve(forKey key: String) throws -> StorableType?
    
    func retrieve(forKey key: String) throws -> [StorableType]?
}


/**
 Beacuse Swift won't let protocols with associated types be parameters (they're not concrete types) we need to deal with this by using tpe erasure.
 
 http://krakendev.io/blog/generic-protocols-and-their-shortcomings
 
 Use this like
 
 ```
 let storage = AnyStorage(MyStorage<Brand>())
 ```
 
 You can now pass things like `AnyStorage<Brand>` around as a parameter - wheras you can't say `Storage<Brand>` or `Storage`
 */
public final class AnyStorage<StorableType: Storable>: Storage {
    
    private let _store: (value: StorableType, forKey: String) throws -> ()
    private let _storeA: (value: [StorableType], forKey: String) throws -> ()
    private let _retrieve: (forKey: String) throws -> StorableType?
    private let _retrieveA: (forKey: String) throws -> [StorableType]?
    
    required public init<U: Storage where StorableType == U.StorableType>(_ storage: U) {
        _store = storage.store
        _storeA = storage.store
        _retrieve = storage.retrieve
        _retrieveA = storage.retrieve
    }
    
    public func store(value: StorableType, forKey key: String) throws {
        try _store(value: value, forKey: key)
    }
    
    public func store(value: [StorableType], forKey key: String) throws {
        try _storeA(value: value, forKey: key)
    }
    
    public func retrieve(forKey key: String) throws -> StorableType? {
        return try _retrieve(forKey: key)
    }
    
    public func retrieve(forKey key: String) throws -> [StorableType]? {
        return try _retrieveA(forKey: key)
    }
}
