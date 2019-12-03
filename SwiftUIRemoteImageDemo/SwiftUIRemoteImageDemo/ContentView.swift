//
//  ContentView.swift
//  SwiftUIRemoteImageDemo
//
//  Created by Yilei He on 4/12/19.
//  Copyright © 2019 Yilei He. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    let url = URL(string: "https://media.caradvice.com.au/image/private/c_fill,q_auto,f_auto,w_640,ar_640:373/zl2efhrl2ag5mfne9inj.jpg")!
    var body: some View {
        RemoteImage<Image>(url: url,
                           remoteImageLoader: URLSessionImageLoader.shared) { image in
                            Image(uiImage: image ?? PlatformImage())
        }

    }}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
