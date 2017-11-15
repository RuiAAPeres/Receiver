# Receiver

<a href="https://github.com/Carthage/Carthage"><img src="https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat"></a>
[![Swift 3.0](https://img.shields.io/badge/Swift-4.0-orange.svg?style=flat)](https://developer.apple.com/swift/)
[![License MIT](https://img.shields.io/badge/License-MIT-lightgrey.svg?style=flat)](https://opensource.org/licenses/MIT)


---

As a [ReactiveSwift](https://github.com/ReactiveCocoa/ReactiveSwift) user myself, most of time, it's difficult to convince someone to just simply start using it. The reality, for better or worse, is that most projects/teams are not ready to adopt it:

1. Fear of adding a big dependency.
2. The learning curve.
3. Adapting the current codebase to a FRP mindset/approach.

Nevertheless, a precious pattern can still be used, even without such an awesome lib like [ReactiveSwift](https://github.com/ReactiveCocoa/ReactiveSwift). 😖

### 🌈 Enter `Receiver`! 🌈

![](https://viralviralvideos.com/wp-content/uploads/GIF/2015/06/OMG-this-is-so-awesome-GIF.gif)

`Receiver` is nothing more than an opinionated implementation of the [Observer pattern](https://en.wikipedia.org/wiki/Observer_pattern). Or, if you prefer, [`FRP`](https://en.wikipedia.org/wiki/Functional_reactive_programming) without the `F` and a really small `R` ([rP](https://en.wikipedia.org/wiki/Reactive_programming) 🤔). 

### Show me the codez! 😸

Let's begin with the basics. **There are three methods in total**. Yup, that's right. 

#### 1. Creating the Receiver

```swift
let (transmitter, receiver) = Receiver<Int>.make()
```

A `receiver` can never be created without an associated `transmitter` (what good would that be?)

#### 2. Listening to an event 📡

This is how you observe events:

```swift
receiver.listen { wave in print("Can I haz \(wave) cheezburger. 🐈") }
```

#### 3. Broadcasting an event 📻

This is how you send events:

```swift
transmitter.broadcast(1)
```

### Opinionated, in what way? 🤓

#### Initializer. 🌳

The `make` method, follows the same approach used in ReactiveSwift, with `pipe`. Since one only makes senses with the other, it's logical for them to be created together within the same API. 

#### Separation between the reader and the writer. ⬆️ ⬇️

A lot of libs have the reader and the writer bundled within the same entity. For the purposes and use cases of this lib, it makes sense to have these concerns separated. It's a bit like a `UITableView` and a `UITableViewDataSource`: one fuels the other, so it might be better for them to split into two different entities. 

#### `sendLastValue` and `onlyNewValues` 🔥 ❄️

If you are familiar with FRP, you must have heard about [cold and hot semantics](http://codeplease.io/2017/10/15/ras-s1e3-3/). `Receiver` can't really provide cold semantics, but it can provide something a bit more unusual called "warm" semantics. A "warm" `Receiver`, is a hot one, but provides the last value sent.


### Ok, so why would I use this? 🤷‍♀️

~Well, to make your codebase awesome of course.~ There are a lot of places where the observer pattern can be useful. In the most simplistic scenario, when delegation is not good enough and you have an `1-to-N` relationship.

A good use case for this would in tracking an UIApplication lifecycle:

```swift
enum ApplicationLifecycle {
    case didFinishLaunching
    case didBecomeActive
    case didEnterBackground
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    private var transmitter: Receiver<ApplicationLifecycle>.Transmitter!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        let (transmitter, receiver) = Receiver<ApplicationLifecycle>.make()
        self.transmitter = transmitter
        // Pass down the `receiver` to where it's needed (ViewModels, for example)

        transmitter.broadcast(.didFinishLaunching)
        return true
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        transmitter.broadcast(.didEnterBackground)
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        transmitter.broadcast(.didBecomeActive)
    }
}


```
