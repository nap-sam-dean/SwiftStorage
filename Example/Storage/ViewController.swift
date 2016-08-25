//
//  ViewController.swift
//  Storage
//
//  Created by Sam Dean on 08/24/2016.
//  Copyright (c) 2016 Sam Dean. All rights reserved.
//

import UIKit

import Storage


struct ExampleStruct {
    let name: String
    let age: Int
}


extension ExampleStruct: Storable {
    
    func storedResult() throws -> StoredResult {
        return [ "name": self.name, "age": self.age ]
    }
    
    init?(storedResult: StoredResult) throws {
        guard let name = storedResult["name"] as? String,
            let age = storedResult["age"] as? Int else {
                return nil
        }
        
        self.init(name: name, age: age)
    }
}


class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let object = ExampleStruct(name: "Bob", age: 99)
        
        
        // Example of user defaults
        let userDefaultStorage = AnyStorage(UserDefaultsStorage<ExampleStruct>(defaults: NSUserDefaults.standardUserDefaults()))
        try! userDefaultStorage.store(object, forKey: "example")
        
        // Prove that the user defaults has that key set
        print(NSUserDefaults.standardUserDefaults().objectForKey("example")!)
        
        // Extract and print the object again
        let o2: ExampleStruct = try! userDefaultStorage.retrieve(forKey: "example")!
        print(o2)
        
        
        // Example of file storage
        let path = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true).first! + "/storage"
        //print("Storing at path \(path)")
        let fileStorage = AnyStorage(FileStorage<ExampleStruct>(path: path))
        try! fileStorage.store(object, forKey: "example")
        
        // Extract and print the object again
        let o3: ExampleStruct = try! userDefaultStorage.retrieve(forKey: "example")!
        print(o3)
        
        
        
        
        // Show passing AnyStorage around works
        doSomething(userDefaultStorage)
    }
    
    // Show how to use AnyStorage to pass around Storage<> instances
    func doSomething(storage: AnyStorage<ExampleStruct>) {
        let object: ExampleStruct = try! storage.retrieve(forKey: "example")!
        print(object)
    }
}
