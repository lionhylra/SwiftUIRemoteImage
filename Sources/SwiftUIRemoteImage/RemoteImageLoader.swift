//
//  RemoteImageLoader.swift
//  SwiftUIRemoteImage
//
//  Created by Yilei He on 4/12/19.
//  Copyright © 2019 Yilei He. All rights reserved.
//

import Foundation

public protocol RemoteImageLoader {

    /// A object that can load image asynchronously. The image could be load either from a cache store or from server
    /// - Parameters:
    ///   - url: The url to of the image
    ///   - completionHandler: A callback that contains the loaded image and other data that is associated with image
    ///   - image: The downloaded image
    ///   - userInfo: Any other data
    func loadImage(url: URL?, completionHandler: @escaping (_ image: PlatformImage?, _ userInfo: [RemoteImageUserInfoKey: Any]?) -> Void)
}

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

