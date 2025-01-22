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
            Section(String(localized: "grades_title")) {
                HStack() {
                    Text("A").font(.title2).padding([.trailing], 10)
                    VStack(alignment: .leading) {
                        Text(String(localized: "grades_a"))
                        Text(String(localized: "grades_a_desc")).font(.caption)
                    }
                }
                .contentShape(Rectangle())
                .listRowBackground(getColorForRating(rating: "A"))
                .foregroundStyle(Color.white)
                
                HStack() {
                    Text("B").font(.title2).padding([.trailing], 10)
                    VStack(alignment: .leading) {
                        Text(String(localized: "grades_b"))
                        Text(String(localized: "grades_b_desc")).font(.caption)
                    }
                }
                .contentShape(Rectangle())
                .listRowBackground(getColorForRating(rating: "B"))
                .foregroundStyle(Color.white)
                
                HStack() {
                    Text("C").font(.title2).padding([.trailing], 10)
                    VStack(alignment: .leading) {
                        Text(String(localized: "grades_c"))
                        Text(String(localized: "grades_c_desc")).font(.caption)
                    }
                }
                .contentShape(Rectangle())
                .listRowBackground(getColorForRating(rating: "C"))
                .foregroundStyle(Color.white)
                
                HStack() {
                    Text("D").font(.title2).padding([.trailing], 10)
                    VStack(alignment: .leading) {
                        Text(String(localized: "grades_d"))
                        Text(String(localized: "grades_d_desc")).font(.caption)
                    }
                }
                .contentShape(Rectangle())
                .listRowBackground(getColorForRating(rating: "D"))
                .foregroundStyle(Color.white)
                
                HStack() {
                    Text("E").font(.title2).padding([.trailing], 10)
                    VStack(alignment: .leading) {
                        Text(String(localized: "grades_e"))
                        Text(String(localized: "grades_e_desc")).font(.caption)
                    }
                }
                .contentShape(Rectangle())
                .listRowBackground(getColorForRating(rating: "E"))
                .foregroundStyle(Color.white)
            }
            Section(String(localized: "grades_section_other")) {
                HStack() {
                    Text("N/A").font(.title2).padding([.trailing], 10)
                    VStack(alignment: .leading) {
                        Text(String(localized: "grades_na"))
                        Text(String(localized: "grades_na_desc")).font(.caption)
                    }
                }
                .contentShape(Rectangle())
                .listRowBackground(getColorForRating(rating: "N/A"))
                .foregroundStyle(Color.white)
            }
        }.navigationTitle(String(localized: "grades_title"))
    }
}

#Preview {
    GradesExplained()
}
