//
//  RemoteImage+Kingfisher.swift
//  SwiftUIRemoteImageDemo
//
//  Created by Yilei He on 4/12/19.
//  Copyright © 2019 Yilei He. All rights reserved.
//

import Foundation
import Kingfisher

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
        })
    }

    func cancelLoadingImage(url: URL) {
        tasks[url]?.cancel()
    }
}

/*
extension RemoteImage {
    init(url: URL?, content: @escaping (PlatformImage?, [RemoteImageUserInfoKey: Any]?) -> Content) {
        self.init(url: url, remoteImageLoader: KingfisherImageLoader.shared, content: content)
    }
}
*/
