---
title:  "How iOS Apps Are Built: From Source Code to Libraries"

categories:
  - iOS
  - Basic Concept
tags:
  - Library
  - Build
---

![image](./assets/img/post/build.png)

## Static Library vs. Dynamic Library
1. How to include in an app
    1. Static libraries: You only need to **Link**.
    1. Dynamic libraries: You need to **Link + Embed**.
        1. Link writes Dynamic Library References (LC_LOAD_DYLIB) into the executable.
        1. Embed places the linked library binary (the .dylib inside the .framework) into the app bundle (usually at .app/Frameworks) and signs it.
    1. The settings for linking and embedding (e.g., Link Binary With Libraries) are often managed automatically by dependency managers such as SPM, CocoaPods, or Carthage.
1. Advantages
    1. Static libraries
        1. Faster launch time; no need to load dylibs at runtime
        1. Dead-code strip
    1. Dynamic libraries
        1. Shared across targets or modules
        1. Faster linking; all `.o` files do not need to be merged into the executable
        1. With *ABI* stability (*Library Evolution* enabled), incremental rebuilds can often be avoided when the library changes
        
- *ABI(Application Binary Interface)* is defines the binary-level contract between compiled pieces of code
    - How function calls are made (calling conventions, how parameters are passed — registers vs. stack).
    - How return values are given back.
    - Memory layout of data types, structs, and classes.
    - Alignment, padding, and size rules.
    - Exception handling and system call conventions.
- *Library evolution* is the ability of a library to evolve (add features, change internal implementations) without breaking existing client code that already depend on it. It's introduced in Swift 5.
        
## System Framework (ex. UIKit, Foundation)
They are provided as dynamic libraries, but they are **embedded in the OS**. Therefore, you only need to link. Basic frameworks such as UIKit and Foundation are linked when you make an app template. But for additional frameworks such as ARKit, you need to link.        

    
