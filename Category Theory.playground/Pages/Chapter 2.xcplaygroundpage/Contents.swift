// Types and Functions

// 1. Define memoize

import Foundation

struct Memoize<A: Hashable, B: Hashable> {
    private var transformations: [A: B]
    private let transform: A -> B
    
    init(transformations: [A: B], transform: A -> B) {
        self.transformations = transformations
        self.transform = transform
    }
    
    init(transform: A -> B) {
        self.transformations = [:]
        self.transform = transform
    }
    
    mutating func invoke(param: A) -> B {
        if let memoized = self.transformations[param] {
            return memoized
        }
        
        let result = transform(param)
        transformations[param] = result
        return result
    }
}

var slowAddFive = Memoize<Int, Int> { (x: Int) in
    sleep(1)
    return x + 5
}

func measureBlock(block: () -> ()) -> CFTimeInterval {
    let startTime = CFAbsoluteTimeGetCurrent()
    block()
    let endTime = CFAbsoluteTimeGetCurrent()
    return endTime - startTime
}

measureBlock {
    slowAddFive.invoke(5)
}

measureBlock {
    slowAddFive.invoke(5)
}

// 2. Try memoizing an RNG function. Does it work?

var fairDiceRoll = Memoize<Int, Int> { (x: Int) in
    return Int(arc4random_uniform(UInt32(x)))
}

let random1 = fairDiceRoll.invoke(6)
let random2 = fairDiceRoll.invoke(6)

// No, it doesn't work. An RNG function with a single parameter cannot be referentially transparent.

// 3. Most RNGs can be initialized with a seed.  Implement a function that takes a seed, 
// calls the random number generator with that seed, and returns the result. Memoize that 
// function. Does it work?


