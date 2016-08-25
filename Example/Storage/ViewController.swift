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
        
        let storage = AnyStorage(UserDefaultsStorage<ExampleStruct>(defaults: NSUserDefaults.standardUserDefaults(), key: "example"))
        
        try! storage.store(object)
        
        // Prove that the user defaults has that key set
        print(NSUserDefaults.standardUserDefaults().objectForKey("example")!)
        
        // Extract and print the object again
        let o2: ExampleStruct = try! storage.retrieve()!
        print(o2)
        
        doSomething(storage)
    }
    
    // Show how to use AnyStorage to pass around Storage<> instances
    func doSomething(storage: AnyStorage<ExampleStruct>) {
        let object: ExampleStruct = try! storage.retrieve()!
        print(object)
    }
}
