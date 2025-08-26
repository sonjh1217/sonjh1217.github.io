---
# the default layout is 'page'
icon: fas fa-info-circle
order: 4
---

I am an iOS engineer who started as a web developer. I like software, especially iOS applications, as it has fewer barriers for users, thus I can help numerous people from different backgrounds. I became a full-stack engineer at a Korean cosmetics startup and, as the team grew, I chose iOS engineering because of its intuitive UI, clear documentation, respect for user privacy, and accessibility. <br><br>
It has been 9 years since I started working as an iOS engineer. The driving force behind this journey was testing. After reading "Clean Code", I fell in love with TDD. However, because of UI constraints, I could write tests only on utility functions and the model layer. In iOS, especially at the time of MVC and UIKit, there were not many code aside from the UI. <br><br>
Through the ["Let's TDD"](https://www.youtube.com/watch?v=meTnd09Pf_M) course by Suyeol Jeon, I found the ways to write tests including UI code. With the strict implementation of TDD, I wrote tests for the model layer and also translated requirements into tests making them act as automated QA. Through tests, I was able to learn a lot and keep "clean code". As tests execute scenarios just as users do, I could learn details of UI layers and lifecycle of the app. Also because I controlled all conditions including network responses, view layers, and user defaults, I habituated dependency inversion. Running hundreds of tests synchronously revealed memory leaks and problems of accessing shared properties from different tests. <br><br>
With reactive programming and SwiftUI, it became harder and harder to test layers including UI code. It's the time to automate code writing if possible and free the part from test code. Also, I've witnessed ReactorKit makes zero breakages of requirements of tests as it compels good architecture. With these experiences, I've changed from a dogmatic TDD follower to a person who use TDD when it is valuable. Nowadays I only write tests on requirements, which involve the ViewModel layer of MVVM. Most tests are given URL response and states. When an action triggered, then the states need to be as supposed. <br><br>
I feel coding is like the art of making things agnostic of any unnecessary things. A module is like a village, and entities live following their responsibilities. By looking at entities, you should be able to grasp the village's activities. No single layer can be stupid. Each layer should be responsible for their duties. With tests, developers always confidently ensure that the service satisfies all requirements it has.<br><br>
Here, I write about things that I am curious about or need to remember. Thank you so much for visiting. 




