//
//  Color+Platform.swift
//  ToS;DR
//
//  Created by Erik on 20/7/25.
//

import SwiftUI

extension Color {
    static var platformSystemBackground: Color {
#if os(iOS)
        return Color(UIColor.systemBackground)
#elseif os(macOS)
        return Color(nsColor: NSColor.windowBackgroundColor)
#else
        return Color.white
#endif
    }
    static var platformGroupedBackground: Color {
#if os(iOS)
        return Color(UIColor.systemGroupedBackground)
#elseif os(macOS)
        return Color(nsColor: NSColor.windowBackgroundColor)
#else
        return Color.gray // Fallback
#endif
    }
    
    static var platformSecondaryBackground: Color {
#if os(iOS)
        return Color(UIColor.secondarySystemGroupedBackground)
#elseif os(macOS)
        return Color(nsColor: NSColor.underPageBackgroundColor)
#else
        return Color.gray
#endif
    }
    
    static var platformSecondaryGroupedBackground: Color {
#if os(iOS)
        return Color(UIColor.secondarySystemGroupedBackground)
#elseif os(macOS)
        return Color(nsColor: NSColor.quaternaryLabelColor).opacity(0.1)
#else
        return Color.gray
#endif
    }
    
    static var platformSeparator: Color {
#if os(iOS)
        return Color(UIColor.separator)
#elseif os(macOS)
        return Color(nsColor: NSColor.separatorColor)
#else
        return Color.gray.opacity(0.3)
#endif
    }
    
    static var platformSystemGray6: Color {
#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
        return Color(UIColor.systemGray6)
#else
        return Color(nsColor: NSColor.windowBackgroundColor)
#endif
    }
    
    static var platformSystemGray5: Color {
#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
        return Color(UIColor.systemGray5)
#else
        return Color(nsColor: NSColor.windowBackgroundColor)
#endif
    }
    
    static var platformSystemGray4: Color {
#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
        return Color(UIColor.systemGray4)
#else
        return Color(nsColor: NSColor.windowBackgroundColor)
#endif
    }
}
