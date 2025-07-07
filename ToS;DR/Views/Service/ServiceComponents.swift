//
//  ServiceComponents.swift
//  ToS;DR
//
//  Created by Erik on 07.11.23.
//

import SwiftUI
import CachedAsyncImage

struct ServiceHeader: View {
    @Environment(\.openURL) var openURL

    var serviceInfo: ToSDR
    var scrollable = false
    var noSpacing = false

    @State private var showAlert = false
    
    init(serviceInfo: ToSDR, scrollable: Bool? = nil, nospacing: Bool = false) {
        self.serviceInfo = serviceInfo
        #if os(iOS)
        self.scrollable = true
        #endif
        if (scrollable != nil) {
            self.scrollable = scrollable!
        }
        self.noSpacing = nospacing
    }
    
    func badges() -> some View {
        HStack(spacing: 15) {
            // a invisible box for padding
            if (!noSpacing) {
                Spacer()
            }
            if (serviceInfo.reviewed) {
                Label(String(localized: "service_badge_reviewed"), systemImage: "checkmark.seal")
                    .padding(5)
                    .padding([.trailing], 6)
                    .foregroundColor(.white)
                    .background(Color.green)
                    .cornerRadius(15)
                    .onTapGesture {
                        showAlert.toggle()
                    }
                    .accessibilityLabel(String(localized: "service_badge_reviewed_a11y"))
                    .accessibilityHint(String(localized: "service_badge_reviewed_hint"))
                    .alert(isPresented: $showAlert, content: {
                        Alert(
                            title: Text(String(localized: "service_review_title")), 
                            message: Text(String(localized: "service_review_message")), 
                            dismissButton: .default(Text(String(localized: "ok")))
                        )
                    })
            }
            Label(String(format: String(localized: "service_badge_grade"), String(serviceInfo.grade)), systemImage: "shield")
                .padding(5)
                .padding([.trailing], 6)
                .foregroundColor(.white)
                .background(getColorForRating(rating: serviceInfo.grade))
                .cornerRadius(20)
                .accessibilityLabel(String(format: String(localized: "service_badge_grade_a11y"), String(serviceInfo.grade)))
                .accessibilityAddTraits(.isButton)
            
            Label(String(format: String(localized: "service_badge_points"), String(serviceInfo.points.totalCount())), systemImage: "exclamationmark.triangle.fill")
                .padding(5)
                .padding([.trailing], 6)
                .foregroundColor(.white)
                .background(Color.blue)
                .cornerRadius(20)
            Label(String(localized: "service_badge_open"), systemImage: "globe")
                .padding(5)
                .padding([.trailing], 6)
                .foregroundColor(.white)
                .background(Color.blue)
                .cornerRadius(20)
                .onTapGesture {
                    openURL(URL(string: "https://tosdr.org/en/service/\(String(serviceInfo.id))")!)
                }
            if (!noSpacing) {
                Spacer()
            }
        }.padding([.bottom], 12.0)
    }

    var body: some View {
        VStack(alignment: .center) {
            CachedAsyncImage(
                url: URL(string: serviceInfo.icon),
                content: { image in
                    image.resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: 75, maxHeight: 75)
                },
                placeholder: {
                    Image(systemName: "display")
                        .frame(width: 75, height: 75)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(6.0)
                }
            )
            .cornerRadius(6.0)
            .padding(12.0)
            .accessibilityLabel(String(format: String(localized: "service_icon_a11y"), serviceInfo.name))
            Text(serviceInfo.name)
                .font(.title)
            //.padding([.top], 12.0)
            if (scrollable) {
                ScrollView(.horizontal,showsIndicators: false) {
                    if (!noSpacing) {
                        badges()
                            .mask(
                            HStack(spacing: 0) {
                                
                                
                                LinearGradient(gradient:
                                                Gradient(
                                                    colors: [Color.black.opacity(0), Color.black]),
                                               startPoint: .leading, endPoint: .trailing
                                )
                                .frame(width: 10)
                                
                                
                                Rectangle().fill(Color.black)
                                
                                
                                LinearGradient(gradient:
                                                Gradient(
                                                    colors: [Color.black, Color.black.opacity(0)]),
                                               startPoint: .leading, endPoint: .trailing
                                )
                                .frame(width: 10)
                            }
                        )
                    } else {
                        badges()
                    }
                    
                }
            } else {
                badges()
            }
        }
    }
}

struct ServicePoints: View {
    @Environment(\.openURL) var openURL
    
    var serviceInfo: ToSDR
    var clickablePoints: Bool
    @Binding var showLocalizedTitles: Bool
    
    init(serviceInfo: ToSDR, clickable: Bool, showLocalizedTitles: Binding<Bool>) {
        self.serviceInfo = serviceInfo
        self.clickablePoints = clickable
        self._showLocalizedTitles = showLocalizedTitles
    }
    
    func getPointIcon(for type: String) -> (systemImage: String, color: Color) {
        switch type {
        case "blocker":
            return ("hand.raised.fill", .red)
        case "bad":
            return ("exclamationmark.triangle.fill", .orange)
        case "good":
            return ("checkmark.circle.fill", .green)
        case "neutral":
            return ("info.circle.fill", .blue)
        default:
            return ("questionmark.circle.fill", .gray)
        }
    }
    
    func getPointCard(point: Point) -> some View {
        let iconInfo = getPointIcon(for: point.type)
        
        return VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: iconInfo.systemImage)
                    .font(.title2)
                    .foregroundStyle(iconInfo.color)
                    .frame(width: 24, height: 24)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(showLocalizedTitles && point.localizedTitle != nil ? point.localizedTitle! : point.title)
                        .font(.headline)
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.leading)
                    
                    if let description = point.description {
                        Text(description)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.leading)
                            .lineLimit(3)
                    }
                }
                
                Spacer()
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .stroke(iconInfo.color.opacity(0.2), lineWidth: 1)
        )
    }
    
    func getPointClickableCard(point: Point) -> some View {
        return NavigationLink {
            PointView(point: point)
        } label: {
            getPointCard(point: point)
        }
        .buttonStyle(.plain)
    }
    
    var body: some View {
        Section(header: 
            HStack {
                Text(String(format: String(localized: "points_section_for"), serviceInfo.name))
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }
        ) {
            // Blocker points
            if let blockerPoints = serviceInfo.points["blocker"], !blockerPoints.isEmpty {
                Section(header: 
                    HStack {
                        Image(systemName: "hand.raised.fill")
                            .foregroundStyle(.red)
                        Text(String(localized: "points_type_blocker"))
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Spacer()
                        Text("\(blockerPoints.count)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.red.opacity(0.1))
                            .clipShape(Capsule())
                    }
                ) {
                    ForEach(blockerPoints.indices, id: \.self) { index in
                        if clickablePoints {
                            getPointClickableCard(point: blockerPoints[index])
                        } else {
                            getPointCard(point: blockerPoints[index])
                        }
                    }
                }
            }
            
            // Bad points
            if let badPoints = serviceInfo.points["bad"], !badPoints.isEmpty {
                Section(header: 
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(.orange)
                        Text(String(localized: "points_type_bad"))
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Spacer()
                        Text("\(badPoints.count)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.orange.opacity(0.1))
                            .clipShape(Capsule())
                    }
                ) {
                    ForEach(badPoints.indices, id: \.self) { index in
                        if clickablePoints {
                            getPointClickableCard(point: badPoints[index])
                        } else {
                            getPointCard(point: badPoints[index])
                        }
                    }
                }
            }
            
            // Good points
            if let goodPoints = serviceInfo.points["good"], !goodPoints.isEmpty {
                Section(header: 
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                        Text(String(localized: "points_type_good"))
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Spacer()
                        Text("\(goodPoints.count)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.green.opacity(0.1))
                            .clipShape(Capsule())
                    }
                ) {
                    ForEach(goodPoints.indices, id: \.self) { index in
                        if clickablePoints {
                            getPointClickableCard(point: goodPoints[index])
                        } else {
                            getPointCard(point: goodPoints[index])
                        }
                    }
                }
            }
            
            // Neutral points
            if let neutralPoints = serviceInfo.points["neutral"], !neutralPoints.isEmpty {
                Section(header: 
                    HStack {
                        Image(systemName: "info.circle.fill")
                            .foregroundStyle(.blue)
                        Text(String(localized: "points_type_neutral"))
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Spacer()
                        Text("\(neutralPoints.count)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.blue.opacity(0.1))
                            .clipShape(Capsule())
                    }
                ) {
                    ForEach(neutralPoints.indices, id: \.self) { index in
                        if clickablePoints {
                            getPointClickableCard(point: neutralPoints[index])
                        } else {
                            getPointCard(point: neutralPoints[index])
                        }
                    }
                }
            }
        }
    }
}

extension Dictionary where Value: Collection, Value.Element == Point {
    func totalCount() -> Int {
        var count = 0
        for value in values {
            count += value.count
        }
        return count
    }
}
