# Storage

[![CI Status](https://img.shields.io/travis/nap-sam-dean/Storage.svg?style=flat)](https://travis-ci.org/nap-sam-dean/Storage)
[![Version](https://img.shields.io/cocoapods/v/Storage.svg?style=flat)](http://cocoapods.org/pods/Storage)
[![License](https://img.shields.io/cocoapods/l/Storage.svg?style=flat)](http://cocoapods.org/pods/Storage)
[![Platform](https://img.shields.io/cocoapods/p/Storage.svg?style=flat)](http://cocoapods.org/pods/Storage)

## Usage

Let's say you have a Swift struct (which you should have, or you're doing it wrong).

```swift
struct ExampleStruct {
    let name: String
    let age: Int
}
```

and you want to store it. You can't `NSCoding` it because Swift, so here's an alternative.

If you make `ExampleStruct` implement `Storable` like this

```swift
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
```

then you can store it into (and retrieve it from) a `Storage` instance.

```swift
let object = ExampleStruct(name: "Bob", age: 99)

let storage = AnyStorage(UserDefaultsStorage<ExampleStruct>(defaults: NSUserDefaults.standardUserDefaults()))

try! storage.store(object, forKey: "some_key")
```

Assuming you want to get to it later, 

```swift
let o2: ExampleStruct = try! storage.retrieve("some_key")!

print(o2)
```

### Places to store things

There are three places you can store things: 

  - User defaults (`UserDefaultsStorage`)
  - File system (`FileStorage`)
  - Keychain (`KeychainStorage`)

or, if you want, just implement the `Storage` protocol yourself :)


## Unusage

This is for places where you might have previously used `NSCoding`. If you're thinking of using this to replace Core Data / MySQL etc YMMV.


## Installation

Storage is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'Storage'
```

## Author

Sam Dean, sam.dean@net-a-porter.com

## License

Storage is available under the MIT license. See the LICENSE file for more info.
