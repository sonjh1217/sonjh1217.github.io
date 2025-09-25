---
title:  "iOS Memory"

categories:
  - iOS
  - Memory
tags:
  - Memory
---

## App Memory's Four Segments

![image](./assets/img/post/memory.png)

1. **Code**: Machine code compiled from source code
1. **Data**: Global variables, static variables, static literals
1. **Heap**: Dynamically allocated data (size and lifetime determined at runtime)
    1. Reference types
        1. Class objects
    1. Internal buffers of arrays, strings, and dictionaries 
        1. But they behave like value types via copy-on-write
    1. Escaping closures' captured contexts & mutable capture boxes
        1. May include value types when needed
        1. Because the closure must be able to access them later when it executes
    1. Lifetime Managed by ARC
1. **Stack segment**: Function call frames
    1. Return addresses, saved registers, storage slots for parameters and local variables, temporaries
    1. Lifetime managed automatically in LIFO order when the scope ends
    1. One per thread
    1. Limited capacity, so deep recursion can cause a stack overflow

## Closure's captured contexts & mutable capture boxes
1. A closure’s code resides in the code (text) segment.<br> A closure value consists of a code pointer and a context pointer.<br> That value is stored wherever the variable or property that holds the closure is stored.
1. Escaping Closure: the closure can be stored and executed later
1. Captured Contexts & mutable capture boxes

![image](./assets/img/post/closureCapture.drawio-2.png)

~~~
let f = { print("hi") } // no capture -> no context

let x = 10
let g = { print(x) } // context: [x=10], no boxes 

var n = 0
let c2 = { print(n) } // context: [&box], box(n)

var n = 0
let c3 = { n += 1 } // context: [&box], box(n)
~~~
{: .language-swift}

## Reference Types & Value Types

1. Reference Types
    1. `Class`
    1. `Actor`
    1. Closure
    1. `NSObject`
    1. UIKit/AppKit types (e.g., `UIView`, `UIColor`)
1. Value Types
    1. Primitive types: `Int`, `Float`, `Double`, `Bool`, `Character`
    1. `String`
    1. Collection types: `Array`, `Set`, `Dictionary`
    1. `Tuple`
    1. `Struct`
    1. `Enum`
        1. `Optional`

