---
title:  "Testing DispatchQueue-Based Code Without Waiting"

categories:
  - Test
tags:
  - TDD
  - DispatchQueue
---

## A Pragmatic, TDD-First Approach

I used to write async tests using `XCTestExpectation` and `wait(for:timeout:)`.
That approach works, and I’ve shipped production code with it.

But once you adopt **TDD seriously** and start adding **a large number of tests**, even very small waits become a real cost.

A 0.1-second wait looks harmless in isolation, but in practice it multiplies:

- hundreds or thousands of tests
- frequent local test runs during development
- CI runs on every pull request
- multiple developers triggering CI repeatedly

This effect becomes especially pronounced in **larger teams or fast-moving codebases**.
When changes land frequently and CI runs are constant, even small per-test delays turn into
noticeable friction: slower feedback loops, longer CI queues, and more time spent waiting
instead of iterating.

At that point, `wait` stops being a simple testing tool and starts becoming
a **tax on development velocity**.

This post explains a pragmatic approach I use to test code that relies on `DispatchQueue`,
while keeping tests fast, safe to run in parallel, and suitable for TDD-heavy workflows.

---

## The Goal

This approach is **not** about proving that Grand Central Dispatch works correctly.

The goal is much simpler:

- Given my actual implementation
- When certain methods are called
- Then the observable behavior matches what I designed

If a change breaks the intended behavior, the test should fail.
That’s it.

---

## How I Structure Tests

I try to express a test scenario as a **minimal set of unit tests** that compose together:

- each test verifies a single, observable requirement  
- dependencies are injected via initializers  
- the combination covers the scenario, and any broken piece fails fast  
- failures are local and explainable, so debugging stays cheap  

Focusing on a minimal set also helps avoid tests that merely validate implementation details.
If a test exists only because of how the code is structured internally,
it is usually a sign that the test is checking the wrong thing.

---

## Why Dependencies Are Injected via Initializers

Dependencies are injected via initializers, not to make tests more clever,
but to keep the production API clean.

I explicitly avoid the following alternatives:

- **Making properties mutable or `internal` just for tests**  
  Dependencies that are not meant to change in production should not become mutable
  simply to accommodate tests. Allowing tests to mutate them would also allow
  production code to do the same, weakening the guarantees the type is supposed to provide.

- **Adding helper methods**  
  APIs added solely to support testing usually have to live in production code,
  often by exposing or mutating otherwise private dependencies.
  This introduces additional decision points for developers and increases
  cognitive overhead around configuration.

- **Mutating global or shared state**  
  Touching globals or singletons makes tests interfere with each other,
  breaks isolation, and often prevents safe parallel execution.
  Tests should not depend on or modify state that other tests can observe.

Initializer-based dependency injection avoids all of these.
It keeps changes and additional surface area minimal,
and makes external dependencies explicit at construction time.

---

## The Core Idea: Inject the Queue

Instead of hard-coding `DispatchQueue`, I inject it through a small protocol.

~~~swift
protocol DispatchQueueType {
    func async(
        flags: DispatchWorkItemFlags,
        execute work: @escaping @Sendable () -> Void
    )

    func async(
        group: DispatchGroup?,
        qos: DispatchQoS,
        flags: DispatchWorkItemFlags,
        execute work: @escaping @Sendable () -> Void
    )

    func sync<T>(execute work: () throws -> T) rethrows -> T
}

extension DispatchQueueType {
    func async(
        flags: DispatchWorkItemFlags,
        execute work: @escaping @Sendable () -> Void
    ) {
        async(group: nil, qos: .unspecified, flags: flags, execute: work)
    }
}
~~~

This keeps the production API clean and avoids any test-only surface.

---

## Production Code: Real Concurrent Queue

The production implementation still uses a real concurrent queue.

~~~swift
final class FeatureFlagManager {
    static let shared = FeatureFlagManager()

    private let dataSource: FeatureFlagDataSource
    private let queue: DispatchQueueType

    private var flags: [FeatureFlagKey: Bool]
    private var didFinishLaunch = false

    var refreshProvider: (@Sendable () async throws -> [FeatureFlagKey: Bool])?

    init(
        dataSource: FeatureFlagDataSource = UserDefaultsFlagDataSource(),
        queue: DispatchQueueType = DispatchQueue(
            label: "feature.flags.queue",
            attributes: .concurrent
        )
    ) {
        self.dataSource = dataSource
        self.flags = dataSource.initialFlags()
        self.queue = queue
    }

    // Feature flag logic…
}
~~~

There is no conditional compilation, no “test mode”, and no fake code paths.
This is normal production code with dependency injection.

---

## The Test Queue: Inline and Deterministic

For tests, I provide a queue that executes work immediately.

~~~swift
final class MockDispatchQueue: DispatchQueueType {
    func async(
        group: DispatchGroup?,
        qos: DispatchQoS,
        flags: DispatchWorkItemFlags,
        execute work: @escaping @Sendable () -> Void
    ) {
        work()
    }

    func sync<T>(execute work: () throws -> T) rethrows -> T {
        try work()
    }
}
~~~

This queue removes async timing from tests and eliminates the need for `wait`.

---

## Example Test Without Waiting

~~~swift
@Test func immutableFlag_doesNotChangeAfterLaunch_whenRefreshed() async throws {
    // Given
    let immutableKey = FeatureFlagKey("immutable_flag", isRuntimeMutable: false)

    let manager = FeatureFlagManager(
        dataSource: InMemoryFlagDataSource(initial: [immutableKey: true]),
        queue: MockDispatchQueue()
    )
    manager.markDidFinishLaunch()
    manager.refreshProvider = {
        [immutableKey: false]
    }

    // When
    _ = try await manager.refresh()

    // Then
    #expect(manager.isEnabled(immutableKey) == true)
}
~~~

By controlling scheduling, the test stays synchronous and simple.

---

## Final Thoughts

In a TDD workflow, test runtime matters.

Even small delays add up when the test suite grows and CI runs frequently.

`DispatchQueue` should not be a reason to skip tests.
By injecting the queue and executing work inline in tests, we can:

- avoid `wait`
- keep tests fast and stable
- run tests safely in parallel
- and still verify the behavior we care about

For these reasons, this is the approach I chose for testing.
