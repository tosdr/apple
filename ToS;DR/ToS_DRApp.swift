//
//  ToS_DRApp.swift
//  ToS;DR
//
//  Created by Erik on 01.11.23.
//

import SwiftUI
import SwiftData

@main
struct ToS_DRApp: App {
    let container: ModelContainer
    
    init() {
        do {
            let schema = Schema([
                ServiceModel.self,
            ])
            let modelConfiguration = ModelConfiguration(schema: schema)
            container = try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Failed to initialize ModelContainer: \(error)")
        }
        unlockBetaIconIfTesting()
        updateDBIfOld()
    }
    
    func unlockBetaIconIfTesting() {
        let isTestFlight = Bundle.main.appStoreReceiptURL?.lastPathComponent == "sandboxReceipt"
        
        if isTestFlight {
            UserDefaults.standard.set(true, forKey: "isBetaTester")
        }
    }
    
    func updateDBIfOld() {
        let lastUpdate = UserDefaults.standard.string(forKey: "lastPull")
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let lastUpdateDate = dateFormatter.date(from: lastUpdate ?? "1970-01-01")
        let lastUpdateInt = Int(lastUpdateDate?.timeIntervalSince1970 ?? 0)
        let now = Int(Date().timeIntervalSince1970)
        
        if (now - lastUpdateInt > 604800) {
            print("Updating DB")
            Task {
                _ = await updateDB(context: ModelContext(container))
            }
        }
    }
    
    @AppStorage("firstStart") var firstStart = true

    var body: some Scene {
        WindowGroup {
            #if os(macOS)
            ContentView()
                .onAppear {
                    unlockBetaIconIfTesting()
                    updateDBIfOld()
                }
                .frame(minWidth: 700)
            #else
            if firstStart {
                OnboardingView()
                    .onAppear {
                        unlockBetaIconIfTesting()
                        updateDBIfOld()
                    }
            } else {
                ContentView()
                    .onAppear {
                        unlockBetaIconIfTesting()
                        updateDBIfOld()
                    }
            }
            #endif
        }
        .modelContainer(container)
    }
}
