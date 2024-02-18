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
                Label("Reviewed", systemImage: "checkmark.seal")
                    .padding(5)
                    .padding([.trailing], 6)
                    .foregroundColor(.white)
                    .background(Color.green)
                    .cornerRadius(15)
                    .onTapGesture {
                        showAlert.toggle()
                    }
                    .alert(isPresented: $showAlert, content: {
                        Alert(title: Text("Review Status"), message: Text("In ToS;DR clasically reffered to as 'Comprehensively Reviewed', meaning this service has enough curated points to be deemed accurate enough for an everyday rating."), dismissButton: .default(Text("OK")))
                    })
            }
            Label("Grade: \(String(serviceInfo.grade))", systemImage: "shield")
                .padding(5)
                .padding([.trailing], 6)
                .foregroundColor(.white)
                .background(getColorForRating(rating: serviceInfo.grade))
                .cornerRadius(20)
            
            Label("Points: \(String(serviceInfo.points.totalCount()))", systemImage: "exclamationmark.triangle.fill")
                .padding(5)
                .padding([.trailing], 6)
                .foregroundColor(.white)
                .background(Color.blue)
                .cornerRadius(20)
            Label("Open on ToS;DR", systemImage: "globe")
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
                }
            )
            .cornerRadius(6.0)
            .padding(12.0)
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

    init(serviceInfo: ToSDR, clickable: Bool) {
        self.serviceInfo = serviceInfo
        self.clickablePoints = clickable
    }
    
    func getCase(point: Point) -> some View {
        var icon = "questionmark"
        var color = Color.gray
        if (point.type == "blocker") {
            icon = "hand.raised.fill"
            color = Color.red
        } else if (point.type == "bad") {
            icon = "exclamationmark.triangle.fill"
            color = Color.orange
        } else if (point.type == "good") {
            icon = "hand.thumbsup"
            color = Color.green
        } else if (point.type == "neutral") {
            icon = "hand.point.up"
        }
        
        return HStack {
            Image(systemName: icon)
                .frame(width:24, height:24)
                .foregroundColor(color)
            Text(point.title)
#if os(macOS)
                .font(.title2)
#endif
        }
        //return icon
    }
    
    func getCaseClickable(point: Point) -> some View {
        return NavigationLink {
            PointView(point: point)
        } label: {
            getCase(point: point)
        }
    }
    
    
    var body: some View {
        Section(header: Text("Points for \(serviceInfo.name)")) {
            if (serviceInfo.points.keys.contains("blocker")) {
                Section(header: Text("Blocker")) {
                    ForEach(0...(serviceInfo.points["blocker"]?.count ?? 0)-1, id: \.self) {
                        if clickablePoints {
                            getCaseClickable(point: serviceInfo.points["blocker"]![$0])
                        } else {
                            getCase(point: serviceInfo.points["blocker"]![$0])
                        }
                    }
                }
            }
            if (serviceInfo.points.keys.contains("bad")) {
                Section(header: Text("Bad")) {
                    ForEach(0...(serviceInfo.points["bad"]?.count ?? 0)-1, id: \.self) {
                        if clickablePoints {
                            getCaseClickable(point: serviceInfo.points["bad"]![$0])
                        } else {
                            getCase(point: serviceInfo.points["bad"]![$0])
                        }                    }
                }
            }
            if (serviceInfo.points.keys.contains("good")) {
                Section(header: Text("Good")) {
                    ForEach(0...(serviceInfo.points["good"]?.count ?? 0)-1, id: \.self) {
                        if clickablePoints {
                            getCaseClickable(point: serviceInfo.points["good"]![$0])
                        } else {
                            getCase(point: serviceInfo.points["good"]![$0])
                        }                    }
                }
            }
            if (serviceInfo.points.keys.contains("neutral")) {
                Section(header: Text("Neutral")) {
                    ForEach(0...(serviceInfo.points["neutral"]?.count ?? 0)-1, id: \.self) {
                        if clickablePoints {
                            getCaseClickable(point: serviceInfo.points["neutral"]![$0])
                        } else {
                            getCase(point: serviceInfo.points["neutral"]![$0])
                        }                    }
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
