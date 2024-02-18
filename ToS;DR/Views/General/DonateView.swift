//
//  DonateView.swift
//  ToS;DR
//
//  Created by Erik on 01.11.23.
//

import SwiftUI

struct DonateView: View {
    var store = Store()
    
    var body: some View {
        List {
            Section("Why Donate?") {
                HStack {
                    Image(systemName: "dollarsign").frame(width: 32, height: 32)
                    VStack(alignment: .leading) {
                        Text("Hello!").font(.title3)
                        Text("If you like this app, please consider donating to the ToS;DR project. Feel free to scroll down to see why and for what the money will be used for ☺️")
                    }
                }
                HStack {
                    Image(systemName: "server.rack").frame(width: 32, height: 32)
                    VStack(alignment: .leading) {
                        Text("Server Cost").font(.title3)
                        Text("ToS;DR's Servers are quite costly and our Team members subsidize them with their own income!")
                    }
                }
                HStack {
                    Image(systemName: "key").frame(width: 32, height: 32)
                    VStack(alignment: .leading) {
                        Text("Licenses").font(.title3)
                        Text("ToS;DR has some Licenses to uphold, like for publishing on App Stores, programming tools and more!")
                    }
                }
                HStack {
                    Image(systemName: "cup.and.saucer").frame(width: 32, height: 32)
                    VStack(alignment: .leading) {
                        Text("Personal Cost").font(.title3)
                        Text("ToS;DR Team Members and contributers do not get paid for their work generally. We still like to get Pizza and Coffee for our hard work we put in to achieve our goals!")
                    }
                }
            }
            
            Section("Donate") {
                if (store.products.isEmpty) {
                    Text("We are having trouble reaching the App store :(")
                }
                ForEach(store.products) {
                  product in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(product.displayName)
                            Text(product.description)
                                .font(.caption)
                            .foregroundColor(.secondary)}
                        Spacer()
                        Button(product.displayPrice) {
                            Task {
                                try await store.purchase(product)
                            }
                        }.buttonStyle(.borderedProminent)
                    }
                }

            }
        }
        .listRowSeparator(.hidden)
        .navigationTitle("Donate")
    }
}

#Preview {
    DonateView()
}
