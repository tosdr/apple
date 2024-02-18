//
//  PointView.swift
//  ToS;DR
//
//  Created by Erik on 06.11.23.
//

import SwiftUI

struct PointView: View {
    
    @Environment(\.openURL) var openURL

    private var pointSelected: Point
    
    @State private var showAlert = false
    
    init(point: Point) {
        self.pointSelected = point
    }
    
    private func getType(point: Point) -> some View {
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
        
        return Label(point.title, systemImage: icon).foregroundStyle(color).font(.title2)
        //return icon
    }
    
    var body: some View {
        List {
            Section("Point Details") {
                getType(point: pointSelected)
            }
            if (pointSelected.description != "") {
                Section("Description") {
                    Text(pointSelected.description)
                        .contextMenu(menuItems: {
                            Button {
                                #if os(iOS)
                                UIPasteboard.general.string = pointSelected.description
                                #else
                                NSPasteboard.general.clearContents()
                                NSPasteboard.general.setString(pointSelected.description, forType: NSPasteboard.PasteboardType.string)
                                #endif
                            } label: {
                                Label("Copy to Clipboard", systemImage: "doc.on.doc")
                            }
                        })
                }
            }
            if (pointSelected.quote != "") {
                Section("Quoted From") {
                    Button(pointSelected.quote) {
                        if pointSelected.quote.starts(with: "https://") {
                            openURL(URL(string: pointSelected.quote)!)
                        }
                    }
                }
            }
            if (pointSelected.tlDr != "" && pointSelected.tlDr != "Generated through the annotate view") {
                Section("TL;DR") {
                    Text(pointSelected.tlDr)
                }
            }
            Section {
                Button {
                    openURL(URL(string: "https://edit.tosdr.org/points/\(String(pointSelected.links))")!)
                } label: {
                    Label("Open on ToS;DR", systemImage: "globe")
                }
                .contentShape(Rectangle())
#if os(macOS)
                .buttonStyle(.plain)
#endif
            }
        }.navigationTitle("Viewing Point Details")
    }
}

#Preview {
    PointView(point: Point(title: "Test Point", tlDr: "Test Point TlDr", description: "Test Description", quote: "Test Quote", type: "blocker", links: "https://google.com"))
}
