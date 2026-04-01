---
title: "When AASA Breaks Universal Link Login"

categories:
  - iOS
  - Troubleshooting
tags:
  - AASA
  - UniversalLink
  - Login
  - Incident
---

This is a sanitized incident note that excludes company-specific details.

## Symptoms

1. The login success rate drops.
1. The gap between login attempts and `(success + failure)` grows.
1. That gap can mean more users are starting login but never reaching a completion event.
1. If the product supports login via another app, it is worth checking whether the redirect back to the app is broken.

## Possible Cause

1. If the return path after external-app login depends on a Universal Link, the issue may be related to `apple-app-site-association` (AASA).
1. If the server blocks requests from Apple's CDN, AASA may stop working correctly.
1. In that case, the Universal Link does not open the app, so users fail to land back in the app after login.

## How To Check

1. On an iPhone, tap the affected Universal Link from another app such as Messages or Notes.
1. If tapping the link does not land in the app, suspect a Universal Link failure.
1. Do not test by typing the URL directly into Safari.
1. Entering the URL in Safari is different from a real link tap and is not a reliable way to validate Universal Link behavior.

## Why Recovery May Still Be Delayed

1. Even after the server-side fix, some users may continue to see the issue if they already hit the broken state during the outage window.
1. One possible reason is Apple CDN cache. Apple has said that the CDN cache is invalidated periodically, but it does not publish the details ([Apple Developer Forums](https://developer.apple.com/forums/thread/651737)).
1. Another possible reason is device-side associated-domain data that has not been refreshed yet.
1. Apple has also described states where associated-domain data can remain unavailable for hours or days until the system next updates it ([WWDC20: What's new in Universal Links](https://developer.apple.com/videos/play/wwdc2020/10098/?time=958)).
1. In practice, recovery timing is not something app developers can predict precisely, so some users may recover quickly while others may continue to fail longer.

## Possible Actions

1. Releasing a new app version can refresh the cache when users update the app.
1. Because of that, one practical action for app developers is to ship a new version quickly and request an expedited review if needed.
1. At the same time, the server team should verify that requests from Apple's CDN are no longer blocked.

## Summary

1. If login success drops while redirect completions disappear, consider a Universal Link incident.
1. If external-app login exists, check AASA and the server policy for Apple's CDN first.
1. Even after a server-side fix, user recovery can still be delayed by CDN cache or device-side associated-domain data.
1. In practice, it is often worth considering both the server fix and an app release.
