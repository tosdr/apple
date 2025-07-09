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
            Section(String(localized: "donate_section_why")) {
                HStack {
                    Image(systemName: "dollarsign").frame(width: 32, height: 32)
                    VStack(alignment: .leading) {
                        Text(String(localized: "donate_hello_title")).font(.title3)
                        Text(String(localized: "donate_hello_desc"))
                    }
                }
#if os(macOS)
                .padding(.vertical, 6)
#endif
                HStack {
                    Image(systemName: "server.rack").frame(width: 32, height: 32)
                    VStack(alignment: .leading) {
                        Text(String(localized: "donate_server_title")).font(.title3)
                        Text(String(localized: "donate_server_desc"))
                    }
                }
#if os(macOS)
                .padding(.vertical, 6)
#endif
                HStack {
                    Image(systemName: "key").frame(width: 32, height: 32)
                    VStack(alignment: .leading) {
                        Text(String(localized: "donate_licenses_title")).font(.title3)
                        Text(String(localized: "donate_licenses_desc"))
                    }
                }
#if os(macOS)
                .padding(.vertical, 6)
#endif
                HStack {
                    Image(systemName: "cup.and.saucer").frame(width: 32, height: 32)
                    VStack(alignment: .leading) {
                        Text(String(localized: "donate_personal_title")).font(.title3)
                        Text(String(localized: "donate_personal_desc"))
                    }
                }
#if os(macOS)
                .padding(.vertical, 6)
#endif
            }
            
            Section(String(localized: "donate_section_donate")) {
                if (store.products.isEmpty) {
                    Text(String(localized: "donate_error_appstore"))
#if os(macOS)
                        .padding(.vertical, 6)
#endif
                }
                ForEach(store.products) { product in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(product.displayName)
                            Text(product.description)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Button(product.displayPrice) {
                            Task {
                                try await store.purchase(product)
                            }
                        }.buttonStyle(.borderedProminent)
                    }
#if os(macOS)
                    .padding(.vertical, 6)
#endif
                }
            }
        }
        .listRowSeparator(.hidden)
        .navigationTitle(String(localized: "label_donate"))
#if os(macOS)
        .listStyle(.insetGrouped)
        .padding(.horizontal)
#endif
    }
}

#Preview {
    DonateView()
}
