<p align="center">
  <img width=65% height=65% src="https://github.com/vincentneo/Avenue-GPX-Viewer/blob/master/Resources/AvenueNewBadge.png"/>
  <br/>
  <b> A simple GPS exchange format viewer for macOS. </b>
  <br/>
  <a href="https://github.com/vincentneo/Avenue-GPX-Viewer/actions">
    <img src="https://github.com/vincentneo/Avenue-GPX-Viewer/actions/workflows/swift.yml/badge.svg"/>
  </a>
  <a href="https://github.com/vincentneo/CoreGPX">
    <img src="https://img.shields.io/badge/CoreGPX-v0.9.0-yellow.svg"/>
  </a>
  <a href="https://swift.org">
    <img src="https://img.shields.io/badge/Swift-5.2-orange.svg"/>
  </a>
  <a href="https://github.com/vincentneo/Avenue-GPX-Viewer/blob/master/LICENSE">
    <img src="https://img.shields.io/badge/license-GPLv3-red.svg"/>
  </a>
  <a href="https://support.apple.com/en-us/HT208202">
    <img src="https://img.shields.io/badge/platform-macOS >= 10.12-purple.svg"/>
  </a>
  <a href="https://github.com/vincentneo/Avenue-GPX-Viewer/releases/latest">
    <img src="https://img.shields.io/github/v/release/vincentneo/Avenue-GPX-Viewer?include_prereleases"/>
  </a>
  <br/>
  <a href="https://apps.apple.com/app/apple-store/id1523681067?pt=121799545&ct=WebsiteLink&mt=8">
    <img src="https://raw.githubusercontent.com/vincentneo/vincentneo.github.io/master/images/mac-appstore-black.svg"/>
  </a>
  
</p>

Avenue is a GPX file viewer that aims to allow quick and easy access to the data in a GPX file. 

Requires macOS 10.12 Sierra and above.
<p align="center">
  <img width=65% height=65% src="https://github.com/vincentneo/Avenue-GPX-Viewer/blob/master/Resources/Screenshot.png"/>
</p>

For easier management, future updates will be distributed on the Mac App Store. You can still build your own copy using Xcode, if you wish.

Avenue is based on some codes over at [iOS-Open-GPX-Tracker](https://github.com/merlos/iOS-Open-GPX-Tracker).
This application was developed by the contributor of the project (me), initally as a personal use app,
eventually it is developed to being more complete, and that it can be expected to be improved on as time goes by.

## Features
- Shows GPX file contents on Apple Maps (Waypoint and Track point support)
- Display of total distance of the tracks 
- Dark mode support
- Minimap for easier locating in complicated tracks (can be disabled)
- Auto restore of previous settings when reopened (like chosen map source, etc)
- Support for third-party map sources
  - Open Street Map
  - Carto DB (with Retina Support)
  - OpenTopoMap
  - Wikimedia Foundation (with Retina Support)

## Upcoming features
- Display of total tracked time
- Documentation

## Contributing
Contributions to this project will be more than welcomed. Feel free to add a pull request or open an issue.
If you require a feature that has yet to be available, do open an issue, describing why and what the feature could bring and how it would help you!

Please do note that by contributing, you are providing me (Vincent Neo) the rights to include and distribute those changes on the binary app published on the App Store (which is released under Apple's Standard License Agreement).

## Like the project? Check out these too!
- [iOS-Open-GPX-Tracker](https://github.com/merlos/iOS-Open-GPX-Tracker), an awesome open-sourced GPS tracker for iOS and watchOS.
- [LocaleComplete](https://github.com/vincentneo/LocaleComplete), a small library to make `Locale` identifier hunting more easy and straightforward.
- [CoreGPX](https://github.com/vincentneo/CoreGPX), a library for parsing and creation of GPX files.

## License
Avenue GPX Viewer for macOS. 

Copyright © 2020 Vincent Neo, with certain codes belonging to Juan M. Merlos (@merlos) from [iOS-Open-GPX-Tracker](https://github.com/merlos/iOS-Open-GPX-Tracker), used with permission.

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program. If not, see http://www.gnu.org/licenses/.

Please note that this source code was released under the GPL license. So any change on the code shall be made publicly available and distributed under the GPL license (this does not apply to the swift packages included in the project which have their own license).

## Dependency
- [CoreGPX](https://github.com/vincentneo/CoreGPX), used for parsing and handling of GPX files.
- [MapCache](https://github.com/merlos/MapCache), awesome third-party map caching library.
