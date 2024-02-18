//
//  ServiceView.swift
//  ToS;DR
//
//  Created by Erik on 01.11.23.
//

import SwiftUI
import CachedAsyncImage

struct ServiceView: View {
    @Environment(\.openURL) var openURL
    
    private var searchResult: SearchResult?
    
    @State var serviceInfo: ToSDR?
    
    @State private var showAlertError = false
    
    @State private var error = ""
    @State var errorAcknowledge = false
    
    init(searchResult: SearchResult?) {
        if (searchResult != nil) {
            self.searchResult = searchResult!
        } else {
            self.searchResult = nil
        }
    }
    
    var grade = ""
    
    var body: some View {
        if (searchResult == nil) {
            Text("No service has been selected!")
        } else if (serviceInfo == nil) {
            if (!errorAcknowledge) {
                ProgressView().frame(minWidth: 100, minHeight: 100).task(id: serviceInfo?.id) {
                    Task {
                        let service = await GetServicePageById(service: searchResult!.id)
                        if (service.error) {
                            error = service.message ?? "No error message provided"
                            print(error)
                            showAlertError.toggle()
                            return
                        }
                        serviceInfo = service.response
                    }
                }
                .alert(isPresented: $showAlertError, content: {
                    Alert(title: Text("Error!"), message: Text("The API has not completed successfully. Please E-Mail Justin Back immedietly.\nError: \(error)"), dismissButton: .default(
                        Text("OK"),
                        action: {
                            errorAcknowledge.toggle()
                        }
                    ))
                })
            } else {
                GeometryReader { geometry in
                    ScrollView {
                        VStack(alignment: .center)  {
                            Image(systemName: "pc")
                                .font(.system(size: 150))
                                .padding([.bottom], 12.0)
                            Text("Error!")
#if os(macOS)
                            Button("Retry") {
                                errorAcknowledge.toggle()
                                error = ""
                            }
#else
                            Text("Please pull down to retry.")
#endif
                        }
                        .padding()
                        .frame(width: geometry.size.width)
                        .frame(minHeight: geometry.size.height)
                    }
                    .refreshable {
                        errorAcknowledge.toggle()
                        error = ""
                    }
                }
            }
        } else {
            List {
                HStack {
                    ServiceHeader(serviceInfo: serviceInfo!)
                }.listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets())
                ServicePoints(serviceInfo: serviceInfo!, clickable: true)
            }
        }
    }
}

#Preview {
    ServiceView(searchResult: SearchResult(name: "Steam", id: 180, icon: "", grade: "D", reviewed: true))
}
