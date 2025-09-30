//
//  DonateView.swift
//  ToS;DR
//
//  Created by Erik on 01.11.23.
//

import SwiftUI
import StoreKit

struct DonateView: View {
    @StateObject private var viewModel = DonateViewModel()
    @State private var showError = false

    var body: some View {
        GroupedList {
            GroupedListSection {
                Text(String(localized: "donate_section_why"))
            } content: {
                DonateInfoRow(
                    icon: "dollarsign",
                    title: String(localized: "donate_hello_title"),
                    description: String(localized: "donate_hello_desc"),
                    isFirst: true
                )
                DonateInfoRow(
                    icon: "server.rack",
                    title: String(localized: "donate_server_title"),
                    description: String(localized: "donate_server_desc")
                )
                DonateInfoRow(
                    icon: "key",
                    title: String(localized: "donate_licenses_title"),
                    description: String(localized: "donate_licenses_desc")
                )
                DonateInfoRow(
                    icon: "cup.and.saucer",
                    title: String(localized: "donate_personal_title"),
                    description: String(localized: "donate_personal_desc"),
                    isLast: true
                )
            }

            GroupedListSection {
                Text(String(localized: "donate_section_donate"))
            } content: {
                if viewModel.products.isEmpty {
                    GroupedListItem(
                        content: {
                            Text(String(localized: "donate_error_appstore"))
                                .foregroundColor(.secondary)
                        },
                        isFirst: true,
                        isLast: true
                    )
                } else {
                    ForEach(Array(viewModel.products.enumerated()), id: \.element.id) { index, product in
                        GroupedListItem(
                            content: {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(product.displayName)
                                        .font(.headline)
                                    Text(product.description)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            },
                            trailing: {
                                Button(product.displayPrice) {
                                    Task {
                                        await viewModel.purchase(product)
                                        showError = viewModel.errorMessage != nil
                                    }
                                }
                                .buttonStyle(.borderedProminent)
                            },
                            isFirst: index == 0,
                            isLast: index == viewModel.products.count - 1
                        )
                    }
                }
            }
        }
        .navigationTitle(String(localized: "label_donate"))
        .alert(isPresented: $showError) {
            Alert(
                title: Text(String(localized: "service_error_title")),
                message: Text(viewModel.errorMessage ?? ""),
                dismissButton: .default(Text(String(localized: "ok")))
            )
        }
    }
}

private struct DonateInfoRow: View {
    let icon: String
    let title: String
    let description: String
    var isFirst: Bool = false
    var isLast: Bool = false

    var body: some View {
        GroupedListItem(
            icon: { Image(systemName: icon) },
            content: {
                VStack(alignment: .leading) {
                    Text(title)
                        .font(.headline)
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            },
            isFirst: isFirst,
            isLast: isLast
        )
    }
}

#Preview {
    DonateView()
}
