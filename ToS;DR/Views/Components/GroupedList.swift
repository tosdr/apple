//
//  GroupedList.swift
//  ToS;DR
//
//  Created by Erik on 22/9/25.
//


import SwiftUI

let innerPadding: CGFloat = 16

struct GroupedList<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                content
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
        .frame(maxWidth: 600)
        .frame(maxWidth: .infinity)
        .background(Color.platformGroupedBackground)
    }
}

struct GroupedListSection<Header: View, Content: View>: View {
    let header: Header
    let content: Content
    
    init(@ViewBuilder header: () -> Header, @ViewBuilder content: () -> Content) {
        self.header = header()
        self.content = content()
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                header
                    .font(.subheadline)
                    .foregroundColor(.primary)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 8)
            .padding(.top, 8)
            
            // Content
            VStack(spacing: 0) {
                content
            }
            .background(Color.platformSecondaryGroupedBackground)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            #if os(macOS)
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(Color.platformSeparator.opacity(0.7), lineWidth: 0.5)
            )
            #endif
            .padding(.horizontal, 8)
            .padding(.bottom, 8)
        }
    }
}

struct GroupedListItem<Icon: View, Content: View, Trailing: View>: View {
    let icon: Icon
    let content: Content
    let trailing: Trailing
    let isFirst: Bool
    let isLast: Bool
    
    init(
        @ViewBuilder icon: () -> Icon,
        @ViewBuilder content: () -> Content,
        @ViewBuilder trailing: () -> Trailing,
        isFirst: Bool = false,
        isLast: Bool = false
    ) {
        self.icon = icon()
        self.content = content()
        self.trailing = trailing()
        self.isFirst = isFirst
        self.isLast = isLast
    }
    
    var body: some View {
        HStack {
            icon
                .frame(width: 20)
                .foregroundColor(.blue)
            
            content
            
            Spacer()
            
            trailing
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, innerPadding)
        .padding(.vertical, innerPadding)
        .background(Color.platformSecondaryGroupedBackground)
        .overlay(
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(Color.platformSeparator)
                .opacity(isLast ? 0 : 1),
            alignment: .bottom
        )
    }
}

struct GroupedListToggle<Icon: View, Content: View>: View {
    let icon: Icon
    let content: Content
    let isOn: Binding<Bool>
    let isFirst: Bool
    let isLast: Bool
    
    init(
        @ViewBuilder icon: () -> Icon,
        @ViewBuilder content: () -> Content,
        isOn: Binding<Bool>,
        isFirst: Bool = false,
        isLast: Bool = false
    ) {
        self.icon = icon()
        self.content = content()
        self.isOn = isOn
        self.isFirst = isFirst
        self.isLast = isLast
    }
    
    var body: some View {
        HStack {
            icon
                .frame(width: 20)
                .foregroundColor(.blue)
            
            content
            
            Spacer()
            
            Toggle("", isOn: isOn)
                .labelsHidden()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, innerPadding)
        .padding(.vertical, innerPadding)
        .background(Color.platformSecondaryGroupedBackground)
        .overlay(
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(Color.platformSeparator)
                .opacity(isLast ? 0 : 1),
            alignment: .bottom
        )
    }
}

struct GroupedListButton<Icon: View, Content: View>: View {
    let icon: Icon
    let content: Content
    let action: () -> Void
    let isFirst: Bool
    let isLast: Bool
    
    init(
        @ViewBuilder icon: () -> Icon,
        @ViewBuilder content: () -> Content,
        action: @escaping () -> Void,
        isFirst: Bool = false,
        isLast: Bool = false
    ) {
        self.icon = icon()
        self.content = content()
        self.action = action
        self.isFirst = isFirst
        self.isLast = isLast
    }
    
    var body: some View {
        Button(action: action) {
            HStack {
                icon
                    .frame(width: 20)
                    .foregroundColor(.blue)
                
                content
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, innerPadding)
            .padding(.vertical, innerPadding)
            .background(Color.platformSecondaryGroupedBackground)
            .overlay(
                Rectangle()
                    .frame(height: 0.5)
                    .foregroundColor(Color.platformSeparator)
                    .opacity(isLast ? 0 : 1),
                alignment: .bottom
            )
        }
        .buttonStyle(.plain)
        .foregroundColor(.primary)
    }
}

struct GroupedListNavigationLink<Icon: View, Content: View, Destination: View>: View {
    let icon: Icon
    let content: Content
    let destination: Destination
    let isFirst: Bool
    let isLast: Bool
    
    init(
        @ViewBuilder icon: () -> Icon,
        @ViewBuilder content: () -> Content,
        @ViewBuilder destination: () -> Destination,
        isFirst: Bool = false,
        isLast: Bool = false
    ) {
        self.icon = icon()
        self.content = content()
        self.destination = destination()
        self.isFirst = isFirst
        self.isLast = isLast
    }
    
    var body: some View {
        NavigationLink(destination: destination) {
            HStack {
                icon
                    .frame(width: 20)
                    .foregroundColor(.blue)
                
                content
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, innerPadding)
            .padding(.vertical, innerPadding)
            .background(Color.platformSecondaryGroupedBackground)
            .overlay(
                Rectangle()
                    .frame(height: 0.5)
                    .foregroundColor(Color.platformSeparator)
                    .opacity(isLast ? 0 : 1),
                alignment: .bottom
            )
        }
        .buttonStyle(.plain)
        .foregroundColor(.primary)
    }
}

// MARK: - Convenience Initializers

extension GroupedListItem where Trailing == EmptyView {
    init(
        @ViewBuilder icon: () -> Icon,
        @ViewBuilder content: () -> Content,
        isFirst: Bool = false,
        isLast: Bool = false
    ) {
        self.icon = icon()
        self.content = content()
        self.trailing = EmptyView()
        self.isFirst = isFirst
        self.isLast = isLast
    }
}

extension GroupedListItem where Icon == EmptyView {
    init(
        @ViewBuilder content: () -> Content,
        @ViewBuilder trailing: () -> Trailing,
        isFirst: Bool = false,
        isLast: Bool = false
    ) {
        self.icon = EmptyView()
        self.content = content()
        self.trailing = trailing()
        self.isFirst = isFirst
        self.isLast = isLast
    }
}

extension GroupedListItem where Icon == EmptyView, Trailing == EmptyView {
    init(
        @ViewBuilder content: () -> Content,
        isFirst: Bool = false,
        isLast: Bool = false
    ) {
        self.icon = EmptyView()
        self.content = content()
        self.trailing = EmptyView()
        self.isFirst = isFirst
        self.isLast = isLast
    }
}

extension GroupedListToggle where Icon == EmptyView {
    init(
        @ViewBuilder content: () -> Content,
        isOn: Binding<Bool>,
        isFirst: Bool = false,
        isLast: Bool = false
    ) {
        self.icon = EmptyView()
        self.content = content()
        self.isOn = isOn
        self.isFirst = isFirst
        self.isLast = isLast
    }
}

extension GroupedListButton where Icon == EmptyView {
    init(
        @ViewBuilder content: () -> Content,
        action: @escaping () -> Void,
        isFirst: Bool = false,
        isLast: Bool = false
    ) {
        self.icon = EmptyView()
        self.content = content()
        self.action = action
        self.isFirst = isFirst
        self.isLast = isLast
    }
}

extension GroupedListNavigationLink where Icon == EmptyView {
    init(
        @ViewBuilder content: () -> Content,
        @ViewBuilder destination: () -> Destination,
        isFirst: Bool = false,
        isLast: Bool = false
    ) {
        self.icon = EmptyView()
        self.content = content()
        self.destination = destination()
        self.isFirst = isFirst
        self.isLast = isLast
    }
}

// MARK: - Preview
#Preview {
    GroupedList {
        GroupedListSection {
            Text("Profile")
        } content: {
            GroupedListItem(
                icon: { Image(systemName: "person.circle.fill") },
                content: {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Age: 25 years")
                            .font(.body)
                            .fontWeight(.medium)
                        
                        Text("Born: Jan 1, 1999")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                },
                trailing: {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("75.2 years")
                            .font(.body)
                            .fontWeight(.semibold)
                        
                        Text("Life Expectancy")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                },
                isFirst: true,
                isLast: true
            )
        }
        
        GroupedListSection {
            Text("Preferences")
        } content: {
            GroupedListToggle(
                icon: { Image(systemName: "speaker.wave.2") },
                content: {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Sound Effects")
                            .font(.body)
                        
                        Text("Play ticking sounds on countdown")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                },
                isOn: .constant(true),
                isFirst: true,
                isLast: false
            )
            
            GroupedListToggle(
                icon: { Image(systemName: "eye.slash") },
                content: {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Hide Impact Percentages")
                            .font(.body)
                        
                        Text("Hide percentage impacts during questionnaire")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                },
                isOn: .constant(false),
                isFirst: false,
                isLast: true
            )
        }
        
        GroupedListSection {
            Text("About")
        } content: {
            GroupedListButton(
                icon: { Image(systemName: "info.circle") },
                content: { Text("About Memento") },
                action: { print("About tapped") },
                isFirst: true,
                isLast: false
            )
            
            GroupedListItem(
                icon: { Image(systemName: "app.badge") },
                content: { Text("Version") },
                trailing: { Text("1.0.0").foregroundColor(.secondary) },
                isFirst: false,
                isLast: true
            )
        }
    }
} 
