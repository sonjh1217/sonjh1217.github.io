---
title:  "Whether to add .0 on CGFloat parameter"

categories:
  - Swift
tags:
  - Coding-Convention
---

Years ago, Apple tutorial included .0 when initializing CGFloat.
However, this pattern has since been removed.

~~~
CardView(scrum: scrum)
            .background(scrum.theme.mainColor)
            .previewLayout(.fixed(width: 400, height: 60))
~~~
{: .language-swift}


So, I tested the performance difference between the two cases.

~~~
import CoreGraphics

let start = CFAbsoluteTimeGetCurrent()
for _ in 0..<1_000_000 {
    let _ = CGFloat(10) * 2.5
}
let end = CFAbsoluteTimeGetCurrent()
print("Without .0: \(end - start)")

let start2 = CFAbsoluteTimeGetCurrent()
for _ in 0..<1_000_000 {
    let _ = CGFloat(10.0) * 2.5
}
let end2 = CFAbsoluteTimeGetCurrent()
print("With .0: \(end2 - start2)")
~~~
{: .language-swift}

## Result

~~~
Without .0: 0.1854790449142456
With .0: 0.1740100383758545
~~~
{: .language-swift}

The difference was 0.01 seconds over one million times iterations.

For reference,

10 -> the value is converted from Int to CGFloat<br>
10.0 -> from Double to CGFloat

## Conclusion
I decided to follow Apple’s updated tutorial style and omit .0 because the performance difference is negligible.

