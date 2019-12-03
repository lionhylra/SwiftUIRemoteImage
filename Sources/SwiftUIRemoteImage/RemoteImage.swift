//
//  RemoteImage.swift
//  SwiftUIRemoteImage
//
//  Created by Yilei He on 3/12/19.
//  Copyright © 2019 Yilei He. All rights reserved.
//

import Foundation
import SwiftUI

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
            .onDisappear {
                self.remoteImageProvider.cancelLoadingImage()
        }
    }
}

extension RemoteImage {
    private final class RemoteImageProvider: ObservableObject {

        @Published fileprivate var image: PlatformImage?
        @Published fileprivate var userInfo: [RemoteImageUserInfoKey: Any]?
        private let remoteImageLoader: RemoteImageLoader
        private let url: URL?

        fileprivate init(url: URL?, remoteImageLoader: RemoteImageLoader) {
            self.url = url
            self.remoteImageLoader = remoteImageLoader
            remoteImageLoader.loadImage(url: url) { (image, userInfo)  in
                self.image = image
                self.userInfo = userInfo
            }
        }

        fileprivate func cancelLoadingImage() {
            guard let url = url else {
                return
            }
            remoteImageLoader.cancelLoadingImage(url: url)
        }
    }
}
