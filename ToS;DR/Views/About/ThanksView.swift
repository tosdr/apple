//
//  ThanksView.swift
//  ToS;DR
//
//  Created by Erik on 31.12.23.
//

import SwiftUI

struct ThanksView: View {
    @Environment(\.openURL) var openURL

    var body: some View {
        List {
            Label("Thank you!", systemImage: "heart.fill").font(.title3)
            Text("Thanks to these things this app came to be!")
            
            Section("ToS;DR Team") {
                Text("Thanks to the ToS;DR Team for being filled with so much kindness and empathy throughout the development of the app while I was facing personal dilemmas.")
            }
            
            Section("Open Source Libraries") {
                fossButton(url: "https://github.com/stephencelis/SQLite.swift", name: "SQLite.swift")
                fossButton(url: "https://github.com/lorenzofiamingo/swiftui-cached-async-image", name: "swiftui-cached-async-image")
                fossButton(url: "https://github.com/SwiftyJSON/SwiftyJSON", name: "SwiftyJSON")
                fossButton(url: "https://github.com/weichsel/ZIPFoundation", name: "ZIPFoundation")
            }
            
            Text("...and of course you!")
        }.navigationTitle("Thanks")
    }
    
    func fossButton(url: String, name: String) -> some View {
        Button {
            openURL(URL(string: url)!)
        } label: {
            HStack {
                Text(name)
                Spacer()
                Image(systemName: "globe")
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    ThanksView()
}
