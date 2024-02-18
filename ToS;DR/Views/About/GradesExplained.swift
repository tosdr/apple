//
//  Grades.swift
//  ToS;DR
//
//  Created by Erik on 06.11.23.
//

import SwiftUI

struct GradesExplained: View {
    var body: some View {
        List {
            Section("Grades") {
                HStack() {
                    Text("A").font(.title2).padding([.trailing], 10)
                    VStack(alignment: .leading) {
                        Text("Excellent")
                        Text("Our best grade: This service respects your privacy.").font(.caption)
                    }
                }
                .contentShape(Rectangle())
                .listRowBackground(getColorForRating(rating: "A"))
                    .foregroundStyle(Color.white)
                
                HStack() {
                    Text("B").font(.title2).padding([.trailing], 10)
                    VStack(alignment: .leading) {
                        Text("Good")
                        Text("A pretty good grade: This service are fair for the user and could use minor adjustments.").font(.caption)
                    }
                }
                .contentShape(Rectangle())
                .listRowBackground(getColorForRating(rating: "B"))
                    .foregroundStyle(Color.white)
                
                HStack() {
                    Text("C").font(.title2).padding([.trailing], 10)
                    VStack(alignment: .leading) {
                        Text("Okay")
                        Text("This service is okay. The terms are okay, but some issues need your consideration.").font(.caption)
                    }
                }
                .contentShape(Rectangle())
                .listRowBackground(getColorForRating(rating: "C"))
                    .foregroundStyle(Color.white)
                
                HStack() {
                    Text("D").font(.title2).padding([.trailing], 10)
                    VStack(alignment: .leading) {
                        Text("Bad")
                        Text("This service's terms are uneven or there are some issues that need your attention.").font(.caption)
                    }
                }
                .contentShape(Rectangle())
                .listRowBackground(getColorForRating(rating: "D"))
                    .foregroundStyle(Color.white)
                
                HStack() {
                    Text("E").font(.title2).padding([.trailing], 10)
                    VStack(alignment: .leading) {
                        Text("Awful")
                        Text("Our worst grade: This service raises some serious concerns regarding privacy.").font(.caption)
                    }
                }
                .contentShape(Rectangle())
                .listRowBackground(getColorForRating(rating: "E"))
                    .foregroundStyle(Color.white)
            }
            Section("Other") {
                HStack() {
                    Text("N/A").font(.title2).padding([.trailing], 10)
                    VStack(alignment: .leading) {
                        Text("Not Available")
                        Text("This service has not received enough curated points to display an accurate grade. Feel free to contribute!").font(.caption)
                    }
                }
                .contentShape(Rectangle())
                .listRowBackground(getColorForRating(rating: "N/A"))
                    .foregroundStyle(Color.white)
            }
        }.navigationTitle("Grades")
    }
}

#Preview {
    GradesExplained()
}
