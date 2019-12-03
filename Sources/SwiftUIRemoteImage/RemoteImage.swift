//
//  RemoteImage.swift
//  SwiftUIRemoteImage
//
//  Created by Yilei He on 3/12/19.
//  Copyright © 2019 Yilei He. All rights reserved.
//

import SwiftUI
#if os(macOS)
import AppKit
#else
import UIKit
#endif

#if os(macOS)
public typealias PlatformImage = NSImage
#else
public typealias PlatformImage = UIImage
#endif

public struct RemoteImageUserInfoKey: RawRepresentable, Hashable, ExpressibleByStringLiteral {

    public typealias StringLiteralType = String
    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    public init(stringLiteral: String) {
        self.rawValue = stringLiteral
    }
}

public protocol RemoteImageLoader {

    /// A object that can load image asynchronously. The image could be load either from a cache store or from server
    /// - Parameters:
    ///   - url: The url to of the image
    ///   - completionHandler: A callback that contains the loaded image and other data that is associated with image
    ///   - image: The downloaded image
    ///   - userInfo: Any other data
    func loadImage(url: URL?, completionHandler: @escaping (_ image: PlatformImage?, _ userInfo: [RemoteImageUserInfoKey: Any]?) -> Void)
}

public struct RemoteImage<Content: View>: View {

    @ObservedObject private var remoteImageProvider: RemoteImageProvider
    private let content: (PlatformImage?, [RemoteImageUserInfoKey: Any]?) -> Content

    /// Create a RemoteImage.
    /// - Parameters:
    ///   - url: The url of remote image
    ///   - remoteImageLoader: The object to download image
    ///   - content: The view's body
    public init(url: URL?, remoteImageLoader: RemoteImageLoader, content: @escaping (PlatformImage?, [RemoteImageUserInfoKey: Any]?) -> Content) {
        self.content = content
        remoteImageProvider = RemoteImageProvider(url: url, remoteImageLoader: remoteImageLoader)
    }

    /// Convenience Initialiser
    /// - Parameters:
    ///   - url: The url of remote image
    ///   - remoteImageLoader: The object to download image
    ///   - content: The view's body
    public init(url: URL?, remoteImageLoader: RemoteImageLoader, content: @escaping (PlatformImage?) -> Content) {
        self.init(url: url, remoteImageLoader: remoteImageLoader) { image, _ in
            content(image)
        }
    }

    public var body: some View {
        content(remoteImageProvider.image, remoteImageProvider.userInfo)
    }
}

extension RemoteImage {
    private final class RemoteImageProvider: ObservableObject {

        @Published fileprivate var image: PlatformImage?
        @Published fileprivate var userInfo: [RemoteImageUserInfoKey: Any]?

        fileprivate init(url: URL?, remoteImageLoader: RemoteImageLoader) {
            remoteImageLoader.loadImage(url: url) { (image, userInfo)  in
                self.image = image
                self.userInfo = userInfo
            }
        }
    }
}

// MARK: - Preview

// Utility extension just for preview
extension Image {
    fileprivate init(platformImage: PlatformImage) {
        #if os(macOS)
        self.init(nsImage: platformImage)
        #else
        self.init(uiImage: platformImage)
        #endif
    }
}

private struct RemoteImage_Previews: PreviewProvider {

    static let url = URL(string: "https://media.caradvice.com.au/image/private/c_fill,q_auto,f_auto,w_640,ar_640:373/zl2efhrl2ag5mfne9inj.jpg")!

    static var previews: some View {
        RemoteImage<Image>(url: url, remoteImageLoader: URLSessionImageLoader.shared) { image in
            Image(platformImage: image ?? PlatformImage())
        }
    }
}
