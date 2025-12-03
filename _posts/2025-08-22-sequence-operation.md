---
title:  "Should I Change All For Loops to Higher-Order Functions?"

categories:
  - Functional Programming
tags:
  - Higher-Order Operation
---

## Nope
If intent is a **pure transformation**, higher-order operations is a better option than for loops. Because they are predefined method, they are concise and easy to read. <br>
Additionally as closures are intended not to have side effects to other variables, but to have only the input and output, they are generally safer . (Of course, it’s still possible to modify captured variables inside a closure.)
~~~
var hello = ""
let evenNumbers = numbers
                    .filter {
                        hello = "hello"
                        return $0 % 2 == 0
                    }
                    .map { $0 * 2 }

print(hello) //hello
~~~
{: .language-swift}


In closure of the methods, you cannot use `break` or `continue`. Also, you cannot `return` value of outer function. The scope is limited to the closure. If you do not want to apply to closure to all elements and just want to do some action in iteration, for loops can be a better option. See [forEach](https://developer.apple.com/documentation/swift/sequence/foreach(_:)) for details. If you want to use `continue` in the closure, you can use `filter` + `map` or `return nil`+`compactMap` instead.
~~~
func isAnagram(with string: String) -> Bool {
    guard string.count == self.count else {
        return false
    }
    
    var dict = self.reduce(into: [Character: Int]()) { dict, char in
        dict[char, default: 0] += 1
    }
    
    for char in string {
        if dict.keys.contains(char) {
            dict[char, default: 0] -= 1
        } else {
            return false
        }
    }
    
    return dict.values.allSatisfy { $0 == 0 }
}
~~~
{: .language-swift}

Remember useful [sequence functions](https://developer.apple.com/documentation/swift/sequence), and use them when they fit your intention — instead of stretching a `for` loop unnecessarily:

1. `map`, `flatMap`, `compactMap`(removes nil)
2. `filter`
3. `reduce`
4. `allSatisfy`
5. `contains`

## When Did Higher-Order Functions Become Popular in Swift?

`map` method is from Swift 1.0, 2014. But Objective-C was popular, and **imperative** `for` loop styles were used.<br>
During 2016-2018, RxSwift/ReactiveCocoa popularize operator chains (`map`, `filter`, `flatMap`, `scan`…), normalizing **declarative**, side-effect-light code.<br>
In 2018, Swift 4.1 introduced `compactMap`. <br>
In 2019, SwiftUI and Combine push a **declarative** mindset; chains of transforms become mainstream even in non-reactive code.<br>
Higher-order functions are now common for “transform/filter/query” over collections.<br>
Lint rules and code reviews in many teams encourage `map`/`filter` when intent is a pure transformation.

## What Does 'Higher-Order' Means?

Order means **level**<br>
0th-order: value
~~~
let n: Int = 42
~~~
{: .language-swift}
1st-order function: parameter and return values are values
~~~
func square(_ x: Int) -> Int { x * x }
~~~
{: .language-swift}

Higher-order function: parameter or return values are function.
~~~
func applyTwice(_ f: (Int) -> Int, to x: Int) -> Int {
    f(f(x))
}
let doubled = applyTwice({ $0 * 2 }, to: 3)   // 12

func makeAdder(_ n: Int) -> (Int) -> Int {
    return { x in x + n }
}
let add5 = makeAdder(5)
add5(10) // 15

let numbers = [1, 2, 3, 4, 5]
let doubledEvens = numbers
    .filter { $0 % 2 == 0 }   
    .map { $0 * 2 }          
// [4, 8]
~~~
{: .language-swift}

