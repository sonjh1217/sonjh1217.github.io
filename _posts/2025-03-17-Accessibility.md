---
title:  "Accessibility"

categories:
  - SwiftUI
tags:
  - Accessibility
---

Source: [https://developer.apple.com/tutorials/app-dev-training/creating-the-edit-view](https://developer.apple.com/tutorials/app-dev-training/creating-the-edit-view)

## VoiceOver reads label text + accessibility trait

~~~
Button(action: {}) {
    Image(systemName: "forward.fill")
    }
    .accessibilityLabel("Next speaker")
~~~
{: .language-swift}

“Next speaker. Button.”

## Omit Spacer and combine components for VoiceOver

~~~
HStack {
    Label("Length", systemImage: "clock")
    Spacer()
    Text("\(scrum.lengthInMinutes) minutes")
}
.accessibilityElement(children: .combine)
~~~
{: .language-swift}

## Add text info for VoiceOver
~~~
Slider(value: $scrum.lengthInMinutesAsDouble, in: 5...30, step: 1) {
        Text("Length")
    }
~~~
{: .language-swift}
