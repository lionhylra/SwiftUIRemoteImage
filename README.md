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

#### Basic

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


