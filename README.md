# Receiver

<a href="https://github.com/Carthage/Carthage"><img src="https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat"></a>
<a href="https://github.com/RuiAAPeres/Receiver#cocoapods"><img src="https://img.shields.io/cocoapods/v/Receiver.svg?style=flat"></a>
[![codecov](https://codecov.io/gh/RuiAAPEres/Receiver/branch/master/graph/badge.svg)](https://codecov.io/gh/RuiAAPeres/Receiver)
[![Build Status](https://travis-ci.org/RuiAAPeres/Receiver.svg?branch=master)](https://travis-ci.org/RuiAAPeres/Receiver)
[![Swift 4.1](https://img.shields.io/badge/Swift-4.1-orange.svg?style=flat)](https://developer.apple.com/swift/)
[![License MIT](https://img.shields.io/badge/License-MIT-lightgrey.svg?style=flat)](https://opensource.org/licenses/MIT)


1. [Intro](https://github.com/RuiAAPeres/Receiver#intro)
2. [🌈 Enter `Receiver`! 🌈](https://github.com/RuiAAPeres/Receiver#-enter-receiver-)
3. [Adding as a Dependency 🚀](https://github.com/RuiAAPeres/Receiver#adding-as-a-dependency-)
4. [Basic usage 😎](https://github.com/RuiAAPeres/Receiver#basic-usage-)
5. [Operators 🤖](https://github.com/RuiAAPeres/Receiver#operators-)
6. [Strategies](https://github.com/RuiAAPeres/Receiver#strategies)
7. [Opinionated, in what way? 🤓](https://github.com/RuiAAPeres/Receiver#opinionated-in-what-way-)
8. [Ok, so why would I use this? 🤷‍♀️](https://github.com/RuiAAPeres/Receiver#ok-so-why-would-i-use-this-️)


## Intro

As a [ReactiveSwift](https://github.com/ReactiveCocoa/ReactiveSwift) user myself, most of time, it's difficult to convince someone to just simply start using it. The reality, for better or worse, is that most projects/teams are not ready to adopt it:

1. The intrinsic problems of adding a big dependency.
2. The learning curve.
3. Adapting the current codebase to a FRP mindset/approach.

Nevertheless, a precious pattern can still be used, even without such an awesome lib like [ReactiveSwift](https://github.com/ReactiveCocoa/ReactiveSwift). 😖

## 🌈 Enter `Receiver`! 🌈

![](https://viralviralvideos.com/wp-content/uploads/GIF/2015/06/OMG-this-is-so-awesome-GIF.gif)

`Receiver` is nothing more than an opinionated micro framework implementation of the [Observer pattern](https://en.wikipedia.org/wiki/Observer_pattern) (**~120 LOC**). Or, if you prefer, [`FRP`](https://en.wikipedia.org/wiki/Functional_reactive_programming) without the `F` and a really small `R` ([rP](https://en.wikipedia.org/wiki/Reactive_programming) 🤔).

## Adding as a Dependency 🚀

#### Carthage

If you use Carthage to manage your dependencies, simply add Receiver to your Cartfile:

```
github "RuiAAPeres/Receiver" ~> 0.0.1
```

If you use Carthage to build your dependencies, make sure you have added `Receiver.framework` to the "Linked Frameworks and Libraries" section of your target, and have included them in your Carthage framework copying build phase.

#### CocoaPods

If you use CocoaPods to manage your dependencies, simply add `Receiver` to your Podfile:

```
pod 'Receiver', '~> 0.0.1'
```

## Basic usage 😎

Let's begin with the basics. **There are three methods in total**. Yup, that's right.

#### 1. Creating the Receiver

```swift
let (transmitter, receiver) = Receiver<Int>.make()
```

A `receiver` can never be created without an associated `transmitter` (what good would that be?)

#### 2. Listening to an event 📡

This is how you observe events:

```swift
receiver.listen { cheezburgers in print("Can I haz \(cheezburgers) cheezburger. 🐈") }
```

As expected, you can do so as many times as you want:

```swift
receiver.listen { cheezburgers in print("Can I haz \(cheezburgers) cheezburger. 🐈") }


receiver.listen { cheezburgers in print("I have \(cheezburgers) cheezburgers and you have none!")}
```

And both handlers will be called, when an event is broadcasted. ⚡️

#### 3. Broadcasting an event 📻

This is how you send events:

```swift
transmitter.broadcast(1)
```

## Operators 🤖

Receiver provides a set of operators akin to ReactiveSwift:

* [`map`](https://github.com/RuiAAPeres/Receiver/blob/master/Receiver/Sources/Receiver%2BOperators.swift#L2#L26)
* [`filter`](https://github.com/RuiAAPeres/Receiver/blob/master/Receiver/Sources/Receiver%2BOperators.swift#L28#L56)
* [`withPrevious`](https://github.com/RuiAAPeres/Receiver/blob/master/Receiver/Sources/Receiver%2BOperators.swift#L58#L88)
* [`take`](https://github.com/RuiAAPeres/Receiver/blob/master/Receiver/Sources/Receiver%2BOperators.swift#L129#L164)
* [`skip`](https://github.com/RuiAAPeres/Receiver/blob/master/Receiver/Sources/Receiver%2BOperators.swift#L90#L127)
* [`skipRepeats`](https://github.com/RuiAAPeres/Receiver/blob/master/Receiver/Sources/Receiver%2BOperators.swift#L167#L214)
* [`skipNil`](https://github.com/RuiAAPeres/Receiver/blob/master/Receiver/Sources/Receiver%2BOperators.swift#L257#L290)
* [`uniqueValues`](https://github.com/RuiAAPeres/Receiver/blob/master/Receiver/Sources/Receiver%2BOperators.swift#L217#L254)

## Strategies

If you are familiar with FRP, you must have heard about [cold and hot semantics](http://codeplease.io/2017/10/15/ras-s1e3-3/) (if not don't worry! ☺️). `Receiver` provides all three flavours explicitly, when you initialize it, via `make(strategy:)`. By default, the `Receiver` is `.hot`.

### `.cold` ❄️:

```swift
let (transmitter, receiver) = Receiver<Int>.make(with: .cold)
transmitter.broadcast(1)
transmitter.broadcast(2)
transmitter.broadcast(3)

receiver.listen { wave in
    // This will be called with `wave == 1`
    // This will be called with `wave == 2`
    // This will be called with `wave == 3`
    // This will be called with `wave == 4`
}

transmitter.broadcast(4)
```

Internally, the `Receiver` will keep a buffer of the previous sent values. Once there is a new listener, all the previous values are sent. When the `4` is sent, it will be "listened to" as expected.

### `.warm(upTo: Int)` 🌈:

This strategy allows you to specify how big the buffer should be:

```swift
let (transmitter, receiver) = Receiver<Int>.make(with: .warm(upTo: 1))
transmitter.broadcast(1)
transmitter.broadcast(2)

receiver.listen { wave in
    // This will be called with `wave == 2`
    // This will be called with `wave == 3`
}

transmitter.broadcast(3)
```

In this case `1` will never be called, because the limit specified (`upTo: 1`) is too low, so only `2` is kept in the buffer.

### `.hot` 🔥:

```swift
let (transmitter, receiver) = Receiver<Int>.make(with: .hot) // this is the default strategy
transmitter.broadcast(1)
transmitter.broadcast(2)

receiver.listen { wave in
    // This will be called with `wave == 3`
}

transmitter.broadcast(3)
```

Anything broadcasted before listening is discarded.

## Opinionated, in what way? 🤓

#### Initializer. 🌳

The `make` method, follows the same approach used in ReactiveSwift, with `pipe`. Since a `receiver` only makes sense with a `transmitter`, it's only logical for them to be created together.

#### Separation between the reader and the writer. ⬆️ ⬇️

A lot of libs have the reader and the writer bundled within the same entity. For the purposes and use cases of this lib, it makes sense to have these concerns separated. It's a bit like a `UITableView` and a `UITableViewDataSource`: one fuels the other, so it might be better for them to be split into two different entities.

## Ok, so why would I use this? 🤷‍♀️

~Well, to make your codebase awesome of course.~ There are a lot of places where the observer pattern can be useful. In the most simplistic scenario, when delegation is not good enough and you have an `1-to-N` relationship.

A good use case for this would in tracking an `UIApplication`'s lifecycle:

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
        // Pass down the `receiver` to where it's needed (e.g. ViewModel, Controllers)

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

Similar to the `ApplicationLifecycle`, the same approach could be used for MVVM:


```swift
class MyViewController: UIViewController {
    private let viewModel: MyViewModel
    private let transmitter: Receiver<UIViewControllerLifecycle>.Transmitter

    init(viewModel: MyViewModel, transmitter: Receiver<UIViewControllerLifecycle>.Transmitter) {
        self.viewModel = viewModel
        self.transmitter = transmitter
        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        super.viewdDidLoad()
        transmitter.broadcast(.viewDidLoad)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        transmitter.broadcast(.viewDidAppear)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        transmitter.broadcast(.viewDidDisappear)
    }
}
```

The nice part is that the `UIViewController` is never aware of the `receiver`, as it should be. ✨

At initialization time:

```swift
let (transmitter, receiver) = Receiver<UIViewControllerLifecycle>.make()
let viewModel = MyViewModel(with: receiver)
let viewController = MyViewController(viewModel: viewModel, transmitter: transmitter)
```
