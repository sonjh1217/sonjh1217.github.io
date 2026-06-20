---
title: "Migrating XIB + MVVM CollectionView Screens to SwiftUI Without Rewriting the Shared Delegate"

categories:
  - iOS
  - SwiftUI
tags:
  - UIKit
  - UICollectionView
  - MVVM
  - SwiftUI
---

When a codebase already uses `xib + MVVM + shared collectionView delegate`, the hardest part of SwiftUI migration is usually not SwiftUI itself.

It is the shared delegate.

The common failure mode is this:

1. the shared delegate starts learning feature-specific details
1. `cellForItemAt` grows a big switch over use cases
1. the "shared" layer slowly stops being shared

If the goal is to support iOS 14 and migrate incrementally, I would avoid that path.

## The requirement

The real requirement is usually more specific than "use SwiftUI in a collection view."

It is this:

1. keep the existing shared collection view delegate
1. keep supporting legacy UIKit/XIB cells
1. let some items move to SwiftUI one by one
1. support iOS 14 through iOS 16+
1. avoid teaching the shared delegate about feature-level cell types like banner, profile, sleep, and so on

That last point matters a lot.

If the shared delegate needs to know every feature cell type, the migration creates architectural debt even if the SwiftUI code itself looks clean.

## Why this gets confusing

At first, it feels like the migration should be simple:

1. the view model already returns a view class name
1. if it is a legacy view, keep the UIKit path
1. if it is a SwiftUI view, just render that view

That intuition is reasonable.

The confusing part is that UIKit and SwiftUI do not work the same way here.

UIKit is naturally identifier-driven:

```swift
let cell = collectionView.dequeueReusableCell(
    withReuseIdentifier: viewModel.className,
    for: indexPath
)
```

SwiftUI is not.

A SwiftUI view is usually a typed value like:

```swift
BannerView(viewModel: bannerViewModel)
```

So the shared layer does not only need the view's name. It also needs a way to actually build the view.

That is why `"just return the SwiftUI view name"` is not quite enough by itself.

## The least disruptive approach

I would not redesign the whole rendering system around a large enum like `CellRenderInfo`.

That makes too many common files change at once.

Instead, I would keep the existing `className` contract and add one small SwiftUI-specific bridge.

For example:

```swift
protocol CollectionCellViewModel {
    var className: String { get }
}

protocol SwiftUIRenderableCellViewModel: CollectionCellViewModel {
    func makeHostedView() -> AnyView
}
```

This keeps the current architecture mostly intact:

1. legacy cells still work with `className`
1. only SwiftUI-backed view models opt into the extra protocol
1. the shared delegate still does not know the feature type

## How the shared delegate stays generic

With that structure, the shared delegate only needs one additional branch:

1. if the view model is a legacy UIKit one, use the old path
1. if the view model conforms to `SwiftUIRenderableCellViewModel`, use the SwiftUI bridge path

That means the shared delegate still does **not** need to know whether the item is:

- a banner
- a profile card
- a promotion
- a sleep card

It only knows whether the item is:

- legacy UIKit
- or SwiftUI-backed

That is the right abstraction boundary for this kind of migration.

## Shared delegate example

The shared `cellForItemAt` can stay relatively small:

```swift
@available(iOS 16.0, *)
private var swiftUIHostingCellRegistration:
UICollectionView.CellRegistration<UICollectionViewCell, SwiftUIRenderableCellViewModel> = {
    .init { cell, _, item in
        cell.contentConfiguration = UIHostingConfiguration {
            item.makeHostedView()
        }
    }
}()

func collectionView(
    _ collectionView: UICollectionView,
    cellForItemAt indexPath: IndexPath
) -> UICollectionViewCell {
    let viewModel = items[indexPath.item]

    if let swiftUIViewModel = viewModel as? SwiftUIRenderableCellViewModel {
        if #available(iOS 16.0, *) {
            return collectionView.dequeueConfiguredReusableCell(
                using: swiftUIHostingCellRegistration,
                for: indexPath,
                item: swiftUIViewModel
            )
        } else {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: viewModel.className,
                for: indexPath
            ) as! HostingCollectionViewCell

            cell.configure(
                rootView: swiftUIViewModel.makeHostedView(),
                parentViewController: parentViewController
            )

            return cell
        }
    }

    let cell = collectionView.dequeueReusableCell(
        withReuseIdentifier: viewModel.className,
        for: indexPath
    )

    (cell as? ConfigurableCell)?.configure(with: viewModel)
    return cell
}
```

This is the important part:

- the shared delegate stays generic
- it does not switch over feature cell types
- the SwiftUI migration logic is centralized in one bridge path

## iOS 16 and later

For iOS 16+, it is still a good idea to use `dequeueConfiguredReusableCell(using:for:item:)` together with [`UIHostingConfiguration`](https://developer.apple.com/documentation/swiftui/uihostingconfiguration).

In the shared delegate example above, this line:

```swift
return collectionView.dequeueConfiguredReusableCell(
    using: swiftUIHostingCellRegistration,
    for: indexPath,
    item: swiftUIViewModel
)
```

directly corresponds to the iOS 14-15 fallback below:

```swift
cell.configure(
    rootView: swiftUIViewModel.makeHostedView(),
    parentViewController: parentViewController
)
```

The only difference is where the hosting work happens:

1. on iOS 16+, inside the shared `CellRegistration`
1. on iOS 14-15, inside the shared `HostingCollectionViewCell`

This is different from the WWDC sample, where each feature usually gets its own strongly typed registration like:

```swift
cell.contentConfiguration = UIHostingConfiguration {
    HeartRateCellView(data: item)
}
```

That WWDC style is great when the view controller is allowed to know each item type.

But when the delegate must remain generic, a single shared SwiftUI registration is often a better fit.

## iOS 14 and 15

For iOS 14 and 15, the fallback is a shared hosting cell backed by [`UIHostingController`](https://developer.apple.com/documentation/swiftui/uihostingcontroller).

```swift
import SwiftUI
import UIKit

final class HostingCollectionViewCell: UICollectionViewCell {
    private var hostingController: UIHostingController<AnyView>?

    func configure(
        rootView: AnyView,
        parentViewController: UIViewController
    ) {
        if let hostingController {
            hostingController.rootView = rootView
            hostingController.view.invalidateIntrinsicContentSize()
            return
        }

        let hostingController = UIHostingController(rootView: rootView)
        hostingController.view.backgroundColor = .clear

        parentViewController.addChild(hostingController)
        contentView.addSubview(hostingController.view)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: contentView.topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])

        hostingController.didMove(toParent: parentViewController)
        self.hostingController = hostingController
    }

}
```

This fallback is less elegant than `UIHostingConfiguration`, but it works well enough for gradual migration on iOS 14 and 15.

One detail matters here.

Even if the UIKit cell class is the same `HostingCollectionViewCell`, I would still keep different reuse identifiers per SwiftUI view type.

For example:

```swift
collectionView.register(
    HostingCollectionViewCell.self,
    forCellWithReuseIdentifier: String(describing: BannerView.self)
)

collectionView.register(
    HostingCollectionViewCell.self,
    forCellWithReuseIdentifier: String(describing: ProfileView.self)
)
```

Then the shared delegate can keep using `viewModel.className` consistently for both legacy and SwiftUI-backed items.

That keeps the migration closer to the original architecture:

1. different view models still produce different identifiers
1. the shared delegate still stays generic
1. only the actual cell implementation changes for iOS 14-15 SwiftUI rendering

I would also be careful about resetting the hosted SwiftUI content in `prepareForReuse()`.

You may see examples like:

```swift
override func prepareForReuse() {
    super.prepareForReuse()
    hostingController?.rootView = AnyView(EmptyView())
}
```

I would treat that as optional defensive code, not as the default design.

In many cases, it is cleaner to let `configure(rootView:parentViewController:)` replace the old hosted view directly with the new one.

That keeps the update path as:

1. old hosted view
1. new hosted view

instead of:

1. old hosted view
1. `EmptyView`
1. new hosted view

## What SwiftUI-backed view models look like

The simplest implementation is to let the SwiftUI-backed view model build its own hosted view.

For example:

```swift
final class BannerViewModel: ObservableObject, SwiftUIRenderableCellViewModel {
    let title: String

    init(title: String) {
        self.title = title
    }

    var className: String {
        String(describing: BannerView.self)
    }

    func makeHostedView() -> AnyView {
        AnyView(BannerView(viewModel: self))
    }
}
```

And the SwiftUI view stays ordinary:

```swift
struct BannerView: View {
    @ObservedObject var viewModel: BannerViewModel

    var body: some View {
        Text(viewModel.title)
    }
}
```

This is why `@ObservedObject` is usually the right choice here.

The model is owned outside the SwiftUI view, and the SwiftUI view only observes it.

## When this approach is a bad fit

This bridge works best for relatively self-contained cells.

It is a worse fit when one collection view cell is already acting like a scrolling container of its own.

For example:

1. the screen uses a vertical `UICollectionView`
1. one cell inside it contains a horizontally scrolling content area
1. that SwiftUI view is not just a simple card but effectively a full horizontal lane

In that case, the hosted SwiftUI content can be much heavier.

Even if reuse is working correctly:

1. iOS 16+ still reconfigures the cell through `UIHostingConfiguration`
1. iOS 14-15 still swaps the hosted `rootView`
1. the outer collection view still triggers repeated cell configuration during scrolling

So the real question is not only "can this be reused?"

It is also:

1. how expensive is the hosted SwiftUI subtree?
1. how many items does that horizontal lane render?
1. does it use `HStack` or a lazy container?
1. how much work happens when the cell comes back on screen?

If a single hosted cell is effectively rendering a horizontally scrolling section, I would treat it as a high-risk migration target.

In practice, I would usually do one of these:

1. keep that heavy horizontal container cell in UIKit for now
1. migrate lighter, simpler cells first
1. if SwiftUI is required there, profile it carefully with Instruments before committing to the migration

So this bridge is a good incremental migration tool, but not every cell is a good first candidate.

## About "returning the SwiftUI view type"

Another tempting design is to make each SwiftUI view conform to a protocol like:

```swift
protocol ViewModelConfigurableSwiftUIView: View {
    associatedtype ViewModel
    init(viewModel: ViewModel)
}
```

That works nicely in strongly typed code such as:

```swift
cell.contentConfiguration = UIHostingConfiguration {
    BannerView(viewModel: item)
}
```

But that pattern fits best when the caller already knows the concrete item type.

In a truly generic shared delegate, it is usually easier to bridge through `AnyView` than to make the shared layer carry all those concrete SwiftUI types around.

That is the main tradeoff.

## Does SwiftUI optimize view-to-view replacement?

To a degree, yes.

When `rootView` or `contentConfiguration` is replaced with a new SwiftUI view value, SwiftUI does not necessarily treat that as "destroy everything and rebuild everything."

It still performs its own update and reconciliation work.

But I would be careful not to overestimate that optimization.

For heavy hosted cells, the question is not only whether SwiftUI can compare the old and new view trees.

It is also:

1. how large the hosted subtree is
1. whether child identity is stable
1. whether the view body performs expensive work
1. whether the hosted content is itself a scrolling container

So yes, there is still update logic on the SwiftUI side.

But I would not treat that as a free performance pass for large hosted cells.

## Recommended migration rule

If I were documenting this for a team, I would summarize the rule like this:

1. Keep the existing shared collection view delegate.
1. Keep the existing `className` contract for legacy UIKit cells.
1. Add a small SwiftUI-specific protocol only for view models that migrate to SwiftUI.
1. In the shared delegate, branch only on `legacy UIKit` versus `SwiftUI-backed`.
1. On iOS 16+, use `dequeueConfiguredReusableCell(using:for:item:)` with `UIHostingConfiguration`.
1. On iOS 14-15, use a shared `HostingCollectionViewCell` backed by `UIHostingController`.
1. Pass the existing external view model into the SwiftUI view with `@ObservedObject`.

That keeps the migration incremental, preserves the shared delegate, and avoids turning the generic collection view layer into a feature-specific switch statement.
