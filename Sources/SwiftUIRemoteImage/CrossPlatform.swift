//
//  CrossPlatform.swift
//  SwiftUIRemoteImage
//
//  Created by Yilei He on 4/12/19.
//  Copyright © 2019 Yilei He. All rights reserved.
//

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
