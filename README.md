## SwiftUIRemoteImage

SwiftUIRemoteImage is a light implementation that allows you to load an image (UIImage/NSImage) asynchronously.

## TL;DR

```swift
    var body: some View {
        RemoteImage(url: url, remoteImageLoader: URLSessionImageLoader.shared) { image in
            Image(uiImage: image ?? UIImage())
            // on macOS, the above line will be written as:
            // Image(nsImage: image ?? NSImage())
        }
    }
```

With a `convenient init` implemented in RemoteImage extension by yourself, using it can be even simpler.

```swift
    var body: some View {
        RemoteImage(url: url) { image in
            Image(uiImage: image ?? UIImage())
            // on macOS, the above line will be written as:
            // Image(nsImage: image ?? NSImage())            
        }
    }
```

It leaves the maximum flexibility to you to decide how to display an image.

## Features

- [x] Lightweight, as easy to use as `GeometryReader` in swift.
- [x] Flexible, leave the appearance of the image to your control.
- [x] Extendable, works well with other great image libraries like Kingfisher, SDWebImage, AlamofireImage, etc.

## Requirements

+ Xcode 11+
+ iOS 13+
+ macOS 10.15+
+ tvOS 13+
+ watchOS 6+
+ Swift 5.1+

## Install

SWiftUIRemoteImage can be installed using [Swift Package Manager](https://swift.org/package-manager/).

```swift
let package = Package(
    dependencies: [
        .package(url: "https://github.com/lionhylra/SwiftUIRemoteImage.git", from: "1.0.0")
    ],
)
```

## Usage

#### Work with URLSession

To use `RemoteImage`, you need to implement a class conforming to protocol `RemoteImageLoader` first. Your class is responssible to fetch an image by downloading from server or loading from cache.

For example, the library implements a `URLSessionImageLoader` which looks like this:

```swift
public final class URLSessionImageLoader: RemoteImageLoader {

    public static let shared = URLSessionImageLoader()

    private let urlSession: URLSession
    private var tasks: [URL: URLSessionTask] = [:]

    public init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }

    public func loadImage(url: URL?, completionHandler: @escaping (PlatformImage?, [RemoteImageUserInfoKey : Any]?) -> Void) {
        guard let url = url else {
            completionHandler(nil, nil)
            return
        }
        let task = urlSession.dataTask(with: url) { (data, _, _) in
            DispatchQueue.main.async {
                if let data = data, let image = PlatformImage(data: data) {
                    completionHandler(image, nil)
                } else {
                    completionHandler(nil, nil)
                }
            }
        }
        task.resume()
        tasks[url] = task
    }

    public func cancelLoadingImage(url: URL) {
        tasks[url]?.cancel()
    }
}
```

Then when you initialise `RemoteImage`, pass your class in the initialiser.

```swift
RemoteImage(url: url, remoteImageLoader: URLSessionImageLoader.shared) { image in
    
}
```

#### Work with SDWebImage

Create a file *SwiftUIRemoteImage+SDWebImage.swift* in your project:

```swift
// SwiftUIRemoteImage+SDWebImage.swift

import SwiftUIRemoteImage
import SDWebImage

extension RemoteImageUserInfoKey {
    static let progress: RemoteImageUserInfoKey = "progress"
    static let cacheType: RemoteImageUserInfoKey = "cacheType"
    static let error: RemoteImageUserInfoKey = "error"
}

class SDWebImageLoader: RemoteImageLoader {
    static let shared = SDWebImageLoader()
    private let manager: SDWebImageManager
    private var tasks: [URL: SDWebImageOperation] = [:]

    init(manager: SDWebImageManager = .shared) {
        self.manager = manager
    }

    public func loadImage(url: URL?, completionHandler: @escaping (PlatformImage?, [RemoteImageUserInfoKey : Any]?) -> Void) {
        guard let url = url else {
            completionHandler(nil, nil)
            return
        }
        tasks[url] = manager.loadImage(with: url, options: [], context: nil, progress: { (receivedSize, expectedSize, _) in
            let progress: CGFloat
            if (expectedSize > 0) {
                progress = CGFloat(receivedSize) / CGFloat(expectedSize)
            } else {
                progress = 0
            }
            DispatchQueue.main.async {
                completionHandler(nil, [.progress: progress])
            }
        }) { (image, data, error, cacheType, finished, _) in
            let progress: CGFloat = image == nil ? 0 : 1
            completionHandler(image, [.error: error as Any, .cacheType: cacheType, .progress: progress])
        }
    }

    public func cancelLoadingImage(url: URL) {
        tasks[url]?.cancel()
    }
}

extension RemoteImage {
    init(url: URL?, content: @escaping (PlatformImage?, [RemoteImageUserInfoKey: Any]?) -> Content) {
        self.init(url: url, remoteImageLoader: SDWebImageLoader.shared, content: content)
    }
}
```

Then you can use it as usual and take advantage from library:

```swift
    var body: some View {
        RemoteImage(url: url) { image, userInfo in
            VStack {
                Image(uiImage: image ?? UIImage())
                ProgressView(progress: userInfo[.progress] as! CGFloat)
            }
        }
    }
```

#### Work with Kingfisher

```swift
import Kingfisher
import SwiftUIRemoteImage

class KingfisherImageLoader: RemoteImageLoader {
    static let shared = KingfisherImageLoader()
    private let manager: KingfisherManager
    private var tasks: [URL: DownloadTask] = [:]

    init(manager: KingfisherManager = .shared) {
        self.manager = manager
    }

    func loadImage(url: URL?, completionHandler: @escaping (PlatformImage?, [RemoteImageUserInfoKey : Any]?) -> Void) {
        guard let url = url else {
            completionHandler(nil, nil)
            return
        }
        tasks[url] = manager.retrieveImage(with: url, completionHandler: { (result) in
            DispatchQueue.main.async {
                if case .success(let value) = result {
                    completionHandler(value.image, nil)
                } else {
                    completionHandler(nil, nil)
                }
            }
        }) // Optionally you can implement DownloadProgressBlock parameter and other parameter to pass back more data in userInfo
    }

    func cancelLoadingImage(url: URL) {
        tasks[url]?.cancel()
    }
}

extension RemoteImage {
    init(url: URL?, content: @escaping (PlatformImage?, [RemoteImageUserInfoKey: Any]?) -> Content) {
        self.init(url: url, remoteImageLoader: KingfisherImageLoader.shared, content: content)
    }
}
```
