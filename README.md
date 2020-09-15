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