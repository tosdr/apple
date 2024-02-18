//
//  PointsExplained.swift
//  ToS;DR
//
//  Created by Erik on 06.11.23.
//

import SwiftUI

struct PointsExplained: View {
    var body: some View {
        List {
            Section("Classifications") {
                HStack() {
                    VStack(alignment: .leading) {
                        Label("Blocker", systemImage: "hand.raised.fill").font(.title2)
                        Text("This point has severe effects on your user rights and/or privacy. This point immediately classifies a service as having the worst grade.").font(.caption)
                    }
                }
                .contentShape(Rectangle())
                .listRowBackground(Color.red)
                    .foregroundStyle(Color.white)
                
                HStack() {
                    VStack(alignment: .leading) {
                        Label("Bad", systemImage: "exclamationmark.triangle.fill").font(.title2)
                        Text("This point negatively impacts your user rights and/or privacy. Be advised.").font(.caption)
                    }
                }
                .contentShape(Rectangle())
                .listRowBackground(Color.orange)
                    .foregroundStyle(Color.white)
                
                HStack() {
                    VStack(alignment: .leading) {
                        Label("Good", systemImage: "hand.thumbsup").font(.title2)
                        Text("This point stands out as being valuable and good for your user rights and/or privacy!").font(.caption)
                    }
                }
                .contentShape(Rectangle())
                .listRowBackground(Color.green)
                    .foregroundStyle(Color.white)
                
                HStack() {
                    VStack(alignment: .leading) {
                        Label("Neutral", systemImage: "hand.point.up").font(.title2)
                        Text("This point is neither good nor bad for your user rights and/or privacy.").font(.caption)
                    }
                }
                .contentShape(Rectangle())
                .listRowBackground(Color.gray)
                    .foregroundStyle(Color.white)
                
                
            }
            Section("Grade Calculation") {
                Text("The grade for an Service is calculated based on how many points it has and what type they are. These calculations change frequently, however, the general idea is as follows:").font(.caption)
                Text("Services with many great points for the user should be classified as an A").font(.caption)
                Text("Services with many great points and some negative ones should be classified as an B").font(.caption)
                Text("Services with some great points and some negative ones should be classified as an C").font(.caption)
                Text("Services with few great points and many negative ones should be classified as an D").font(.caption)
                Text("Services with a blocker should be classified as an E").font(.caption)
            }
        }.navigationTitle("Points")
    }
}

#Preview {
    PointsExplained()
}
