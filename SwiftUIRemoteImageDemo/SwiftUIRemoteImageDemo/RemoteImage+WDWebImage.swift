//
//  RemoteImage+WDWebImage.swift
//  SwiftUIRemoteImageDemo
//
//  Created by Yilei He on 4/12/19.
//  Copyright © 2019 Yilei He. All rights reserved.
//

// SwiftUIRemoteImage+SDWebImage.swift

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
/*
extension RemoteImage {
    init(url: URL?, content: @escaping (PlatformImage?, [RemoteImageUserInfoKey: Any]?) -> Content) {
        self.init(url: url, remoteImageLoader: SDWebImageLoader.shared, content: content)
    }
}
*/
