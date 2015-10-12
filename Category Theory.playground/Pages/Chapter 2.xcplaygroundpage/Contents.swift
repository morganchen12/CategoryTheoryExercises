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

// Because we're mutating our struct to memoize things, we can't use lets.
// There's probably a better way to do this...
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

// No, it doesn't work. An RNG function with a single parameter cannot be referentially transparent
// unless that single arg is the function's seed. But if that's the case, the RNG is no longer random
// unless callers pass in different seeds each time, which is really painful for the caller.

// 3. Most RNGs can be initialized with a seed.  Implement a function that takes a seed, 
// calls the random number generator with that seed, and returns the result. Memoize that 
// function. Does it work?

// It works if we have the seed as an input as discussed above, but it's only useful if we return 
// the permuted seed alongside the randomly generated number.

// Here's a simple pseudo-RNG using the middle square method (which sucks, but is easy).
// In this method the random result is used as the next seed, which still isn't great for
// callers since they're now responsible for passing around the seed if they ever want to 
// get more than one random number.

extension Int {
    var square: Int { return self * self }
    
    var numberOfDigits: Int { return Int(ceil(log10(Double(self)))) }
    
    func power(exponent: Int) -> Int { return Int(pow(Double(self), Double(exponent))) }
    
    func middleDigits(digits: Int) -> Int? {
        guard digits <= self.numberOfDigits else { return nil }
        
        var result = self
        
        // trim off right end
        let rightDigits: Int = (self.numberOfDigits - digits) / 2
        result = result / 10.power(rightDigits)
        
        // trim off left end
        result = result % 10.power(digits)
        
        return result
    }
}

struct PRNG: GeneratorType {
    private var seed: Int
    
    init(seed: Int) {
        self.seed = seed
        while self.seed.numberOfDigits < 16 {
            self.seed *= 15485863 // prime numbers make everything better
        }
    }
    
    // This `next` function can be pretty easily rewritten to be stateless, which lets us
    // memoize.
    mutating func next() -> Int? {
        let result = seed.square.middleDigits(8)
        return result
    }
    
    static func next(seed: Int) -> Int {
        let result = seed.square.middleDigits(8)
        return result ?? 0 // I'm a horrible person
    }
}

var memoizedRandom = Memoize<Int, Int>(transform: PRNG.next)

var randoms: [Int] = []
var seed = 15485863
for var i = 0; i < 16; i++ {
    seed = memoizedRandom.invoke(seed)
    randoms.append(seed)
}

print(randoms)

// 4. Which of these C++ functions are pure? Only factorial.

// 5. Mappings from Bool to Bool
// Our knowledge of ADTs says that the type A -> B has |A| ^ |B| members where |A| is the number
// of members in A, |B| is the number of members in |B|, and ^ is power and not bitwise or. In this
// case we'll have four functions: Two returning true and false for every input, one reversing the 
// input, and the identity function.

let yes = { (_: Bool) in return true }
let no  = { (_: Bool) in return false }
let not = { (input: Bool) in return !input } // This is kind of cheating, since I used the not
                                             // operator to implement not.
let id  = { (input: Bool) in return input }

// There's probably a way to prove that these are all the possible mappings from Bool to Bool,
// but I don't know it yet.

// 6. Drawing? wat
