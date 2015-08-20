# Apodidae #
### Swift Dependency Injection Framework ###
With Swift 2.0 and this talk from Apple, protocol oriented programming has now arrived on the Cocoa scene. Although protocols allow for elegant decoupling of interface from implementation, a little extra glue (in the form of Dependecy Injection) cements the ideal of never having to know if your duck is actually a duck

### Name ###
Apodidae is the taxonomic family of birds known as swifts in english. Is your swift a sooty swift or a lesser swallow tail swift? You don't care! that's why you're using dependency injection, obviously...

### Usage ###
Have a protocol that needs filling? add Injectable to your implementation:
```swift
protocol Swift {
  func airspeedVelocity() -> Int
}

struct WhiteThroatedNeedleTail: Swift, Injectable {
  static func dependencies -> [Any] {
    return []
  }

  init(dependencies: [Injectable]) {}

  func airspeedVelocity() -> Int {
    return 169
  }
}
```
and register with the registrar:
```swift
import Apodidae

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {

  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    // init application
    ...
    registerDependencies()
  }

  func registerDependencies() -> Void {
    let registrar = Registrar.instance
    // NOTE: Implementation MUST implement the Injectable protocol
    // NOTE: Currently registration is not type safe - you could register a nonconforming class
    registrar.register(Swift.self, WhiteThroatedNeedleTail.self)
  }
}
```
Instances of your protocol can then be grabbed from the registrar:
```swift
struct Thingy {
  let swift = Registrar.instance.obtain(Swift.self) as! Swift

  func howFastAreMyBirds() -> Int {
    return self.swift.airspeedVelocity()
  }
}
```
But what if my dependencies have dependencies?? Apodidae will resolve the chained dependencies before providing you the implementation:
```swift
protocol BirdCage: Injectable {
  func howFastAreMyBirds() -> Int
}

struct Thingy: BirdCage {
  let swift: Swift

  static func dependencies -> [Any] {
    return [
      Swift.self // defines the type dependency on a swift
    ]
  }

  init(dependencies: [Injectable]) {
    // Dependencies are returned in the same order you specified
    self.swift = dependencies[0] as! Swift
  }

  func howFastAreMyBirds() -> Int {
    return self.swift.airspeedVelocity()
  }
}
```
