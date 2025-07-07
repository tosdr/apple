//
//  AboutView.swift
//  ToS;DR
//
//  Created by Erik on 01.11.23.
//

import SwiftUI

struct AboutView: View {
    @Environment(\.openURL) var openURL

    var body: some View {
        List {
            // Welcome Section
            Section(header: 
                HStack {
                    Image(systemName: "hand.wave")
                        .foregroundStyle(.yellow)
                    Text(String(localized: "about_section_welcome"))
                        .font(.headline)
                        .fontWeight(.semibold)
                    Spacer()
                }
            ) {
                HeroWelcomeView()
            }
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
            
            // Organization Information
            Section(header: 
                HStack {
                    Image(systemName: "building.2")
                        .foregroundStyle(.blue)
                    Text(String(localized: "about_section_organization"))
                        .font(.headline)
                        .fontWeight(.semibold)
                    Spacer()
                }
            ) {
                VStack(alignment: .leading, spacing: 16) {
                    InfoCardView(
                        icon: "info.circle",
                        iconColor: .blue,
                        content: String(localized: "about_organization_desc1")
                    )
                    
                    InfoCardView(
                        icon: "globe",
                        iconColor: .green,
                        content: String(localized: "about_organization_desc2")
                    )
                }
                .padding(.vertical, 8)
            }
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
            
            // Terminology Section
            Section(header: 
                HStack {
                    Image(systemName: "book")
                        .foregroundStyle(.purple)
                    Text(String(localized: "about_section_terminology"))
                        .font(.headline)
                        .fontWeight(.semibold)
                    Spacer()
                }
            ) {
                NavigationLink(destination: GradesExplained()) {
                    TerminologyRowView(
                        icon: "graduationcap.fill",
                        iconColor: .blue,
                        title: String(localized: "about_terminology_grades"),
                        subtitle: "Learn about our grading system"
                    )
                }
                
                NavigationLink(destination: PointsExplained()) {
                    TerminologyRowView(
                        icon: "text.quote",
                        iconColor: .orange,
                        title: String(localized: "about_terminology_points"),
                        subtitle: "Understand how we analyze ToS"
                    )
                }
                
                NavigationLink(destination: ServicesExplained()) {
                    TerminologyRowView(
                        icon: "server.rack",
                        iconColor: .green,
                        title: String(localized: "about_terminology_services"),
                        subtitle: "How we categorize services"
                    )
                }
            }
            
            // Contribute Section
            Section(header: 
                HStack {
                    Image(systemName: "heart.fill")
                        .foregroundStyle(.red)
                    Text(String(localized: "about_section_contribute"))
                        .font(.headline)
                        .fontWeight(.semibold)
                    Spacer()
                }
            ) {
                Button {
                    openURL(URL(string: "https://edit.tosdr.org")!)
                } label: {
                    ContributeRowView(
                        icon: "text.magnifyingglass",
                        iconColor: .blue,
                        title: String(localized: "about_contribute_curate"),
                        subtitle: "Help us review and improve terms"
                    )
                }
#if os(macOS)
                .buttonStyle(.plain)
#endif
            }
            
            // App Section
            Section(header: 
                HStack {
                    Image(systemName: "app.badge")
                        .foregroundStyle(.purple)
                    Text(String(localized: "about_section_app"))
                        .font(.headline)
                        .fontWeight(.semibold)
                    Spacer()
                }
            ) {
                NavigationLink(destination: ThanksView()) {
                    TerminologyRowView(
                        icon: "heart.fill",
                        iconColor: .red,
                        title: String(localized: "about_app_thanks"),
                        subtitle: "Credits and acknowledgments"
                    )
                }
            }
            
            // Footer
            Section {
                FooterView()
            }
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
        }
        .navigationTitle(String(localized: "label_about"))
#if os(macOS)
        .listStyle(.insetGrouped)
        .frame(minWidth: 500)
#endif
    }
}

// MARK: - Supporting Views

struct HeroWelcomeView: View {
    var body: some View {
        VStack(spacing: 16) {
            // App icon or logo
            Image(systemName: "shield.lefthalf.filled")
                .font(.system(size: 60))
                .foregroundStyle(.blue.gradient)
                .padding(.bottom, 8)
            
            VStack(spacing: 8) {
                Text(String(localized: "about_welcome"))
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text(String(localized: "about_welcome_desc"))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
        }
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
    }
}

struct InfoCardView: View {
    let icon: String
    let iconColor: Color
    let content: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(iconColor)
                .font(.title2)
                .frame(width: 24, height: 24)
            
            Text(content)
                .font(.subheadline)
                .foregroundStyle(.primary)
                .multilineTextAlignment(.leading)
            
            Spacer()
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .stroke(iconColor.opacity(0.2), lineWidth: 1)
        )
    }
}

struct TerminologyRowView: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(iconColor)
                .font(.title2)
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundStyle(.secondary)
                .font(.caption)
        }
        .padding(.vertical, 4)
    }
}

struct ContributeRowView: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(iconColor)
                .font(.title2)
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "arrow.up.right")
                .foregroundStyle(.blue)
                .font(.caption)
        }
        .padding(.vertical, 4)
    }
}

struct FooterView: View {
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("ToS;DR")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(.blue)
                
                Spacer()
                
                Text("Terms of Service; Didn't Read")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Divider()
            
            HStack {
                Text("© 2024 ToS;DR Contributors")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                Text("v1.0")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.gray.opacity(0.1))
                    .clipShape(Capsule())
            }
        }
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    AboutView()
}
