// Category: The Essence of Composition
import Foundation

// 1. Implement the identity function.

func id<T>(input: T) -> T { return input }

// 2. Implement the composition function.

infix operator ∘ { associativity left precedence 130 }
func ∘<A, B, C>(f: A -> B, g: B -> C) -> A -> C {
    return { f(g($0)) }
}

// 3. Write a program that tries to test that your composition function respects identity.

struct IntegerGenerator: GeneratorType {
    var nextValue: Int
    
    init(initialValue: Int) {
        nextValue = initialValue
    }
    
    mutating func next() -> Int? {
        let result = nextValue
        nextValue++
        return result
    }
}

struct NonNegativeIntegers: SequenceType {
    func generate() -> IntegerGenerator {
        return IntegerGenerator(initialValue: 0)
    }
}

let integers = NonNegativeIntegers()
let addFive: Int -> Int = { $0 + 5 }

for integer in integers {
    print(addFive(integer) == (id ∘ addFive)(integer))
    if integer > 250 { break }
}

// 4. Is the world wide web a category in any sense? Are links morphisms? 

// I guess so? If webpage A links to webpage B and webpage B links to webpage C, then it's possible to
// travel from A to C.

// 5. Is Facebook a category, with people as objects and friends as morphisms? 

// I don't think friendships on Facebook can be composed in the same way we've composed functions above,
// so I guess not.

// 6. When is a directed graph a category?

// The morphisms have to be composable, right? So for every node connected indirectly to another 
// node through a set of edges there must be another edge that connects both nodes directly that
// is the composition of those edges as morphisms. In code we're used to representing nodes as
// some instances of a type and edges as functions, and since functions are composable, that means
// most of the graphs we're used to dealing with must also be categories as well.
