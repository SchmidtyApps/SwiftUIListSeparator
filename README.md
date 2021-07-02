Help support my open source work!

<p float="left">
<a href="https://www.buymeacoffee.com/SchmidtyApps" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/v2/arial-black.png" alt="Buy Me A Coffee" width="200px" ></a>
  </p>

# iOS15
List finally supports setting list row separator color and style as of iOS15! They still don't support list inset because....reasons? Here is a quick tutorial of how to use the new functionality in iOS15 and if you need custom insets you can always hide the lines and then use a custom Divider on each cell. Now this hack of repo can die the slow painful death it deserves.
https://www.hackingwithswift.com/quick-start/swiftui/how-to-adjust-list-row-separator-visibility-and-color

# Disclaimer
So while this project seems to work fairly well for many implementations it is clear that depending on specific setups sometimes the underlying UIKit code backing the SwiftUI list changes and ends up breaking this workaround. If it is not working my current suggestion would be to log an issue with specifics and instead do something along the lines of:

```
if #available(iOS 14, *) {
   LazyVStack { content() }
} else {
   List { content() }
}

func content() -> some View {
 //Table rows go here
}
```
<br />

# SwiftUI List Separator
> View extension to hide/modify List separators in SwiftUI iOS13 and iOS14.

[![Swift Version][swift-image]][swift-url]
[![License][license-image]][license-url]
[![Platform](https://img.shields.io/cocoapods/p/LFAlertController.svg?style=flat)](http://cocoapods.org/pods/LFAlertController)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=flat-square)](http://makeapullrequest.com)

SwiftUI List lacks the customizations necessary to hide/modify row separator lines. There are known workarounds with setting appearance for UITableView but many times this sets it for all UITableViews in the app and this workaround has also stopped working in iOS14. This project allows full customization of the separators on List and has been tested and works in both iOS13 and iOS14 when compiled with either Xcode 11 or Xcode 12.

<p float="left">
  <img src="/Screenshots/None.png" width="30%" />
  <img src="/Screenshots/SingleLine.png" width="30%" /> 
  <img src="/Screenshots/RedInset.png" width="30%" />
</p>

## Requirements

- iOS 13.0+
- Xcode 11.0+

## Installation

#### Manually
1. Download and drop ```List+Separator.swift``` in your project.  
2. Congratulations!  

#### Swift Package Manager
https://developer.apple.com/documentation/xcode/adding_package_dependencies_to_your_app

## Usage example

Show the standard single divider line (Note: this is equivalent to the sytem default so omitting is the same thing)
```swift
List { <content> }
    .listSeparatorStyle(.singleLine)
```

Hide separators on the List
```swift
List { <content> }
    .listSeparatorStyle(.none)
```

Show a single divider line with configurable color and insets
```swift
List { <content> }
    .listSeparatorStyle(.singleLine, color: .red, inset: EdgeInsets(top: 0, leading: 50, bottom: 0, trailing: 20)
```

Show a single divider line and hide the separator on empty rows in the footer
```swift
List { <content> }
    .listSeparatorStyle(.singleLine, hideOnEmptyRows: true)
```

## Contribute

We would love you for the contribution to **SwiftUIListSeparator**, check the ``LICENSE`` file for more info.

## Meta

Michael Schmidt – [@FindMyClass](https://twitter.com/findmyclass) – KineticSparks@gmail.com

Distributed under the MIT license. See ``LICENSE`` for more information.

[https://github.com/SchmidtyApps](https://github.com/SchmidtyApps)

[swift-image]:https://img.shields.io/badge/swift-5.0-orange.svg
[swift-url]: https://swift.org/
[license-image]: https://img.shields.io/badge/License-MIT-blue.svg
[license-url]: LICENSE
[codebeat-image]: https://codebeat.co/badges/c19b47ea-2f9d-45df-8458-b2d952fe9dad
[codebeat-url]: https://codebeat.co/projects/github-com-vsouza-awesomeios-com
