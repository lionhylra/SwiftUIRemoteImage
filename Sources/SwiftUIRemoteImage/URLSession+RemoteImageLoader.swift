//
//  URLSession+RemoteImageLoader.swift
//  SwiftUIRemoteImage
//
//  Created by Yilei He on 3/12/19.
//  Copyright © 2019 Yilei He. All rights reserved.
//

#if os(macOS)
import AppKit
#else
import UIKit
#endif

/// An example of `RemoteImageLoader` implementation
public final class URLSessionImageLoader: RemoteImageLoader {

    public static let shared = URLSessionImageLoader()

    private let urlSession: URLSession

    public init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }

    public func loadImage(url: URL?, completionHandler: @escaping (PlatformImage?, [RemoteImageUserInfoKey : Any]?) -> Void) {
        guard let url = url else {
            completionHandler(nil, nil)
            return
        }
        urlSession.dataTask(with: url) { (data, _, _) in
            DispatchQueue.main.async {
                if let data = data, let image = PlatformImage(data: data) {
                    completionHandler(image, nil)
                } else {
                    completionHandler(nil, nil)
                }
            }
        }.resume()
    }
}

/*
extension URLSession: RemoteImageLoader {
    public func loadImage(url: URL?, completionHandler: @escaping (PlatformImage?, [RemoteImageUserInfoKey : Any]?) -> Void) {
        guard let url = url else {
            completionHandler(nil, nil)
            return
        }
        dataTask(with: url) { (data, _, _) in
            if let data = data, let image = PlatformImage(data: data) {
                completionHandler(image, nil)
            } else {
                completionHandler(nil, nil)
            }
        }.resume()
    }
}
*/
