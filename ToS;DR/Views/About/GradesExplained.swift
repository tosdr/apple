//
//  Grades.swift
//  ToS;DR
//
//  Created by Erik on 06.11.23.
//

import SwiftUI

struct GradesExplained: View {
    var body: some View {
        GroupedList {
            GroupedListSection {
                Text(String(localized: "grades_title"))
            } content: {
                GradeCard(
                    letter: "A",
                    title: String(localized: "grades_a"),
                    description: String(localized: "grades_a_desc"),
                    color: getColorForRating(rating: "A"),
                    isFirst: true
                )
                GradeCard(
                    letter: "B",
                    title: String(localized: "grades_b"),
                    description: String(localized: "grades_b_desc"),
                    color: getColorForRating(rating: "B")
                )
                GradeCard(
                    letter: "C",
                    title: String(localized: "grades_c"),
                    description: String(localized: "grades_c_desc"),
                    color: getColorForRating(rating: "C")
                )
                GradeCard(
                    letter: "D",
                    title: String(localized: "grades_d"),
                    description: String(localized: "grades_d_desc"),
                    color: getColorForRating(rating: "D")
                )
                GradeCard(
                    letter: "E",
                    title: String(localized: "grades_e"),
                    description: String(localized: "grades_e_desc"),
                    color: getColorForRating(rating: "E"),
                    isLast: true
                )
            }

            GroupedListSection {
                Text(String(localized: "grades_section_other"))
            } content: {
                GradeCard(
                    letter: "N/A",
                    title: String(localized: "grades_na"),
                    description: String(localized: "grades_na_desc"),
                    color: getColorForRating(rating: "N/A"),
                    isFirst: true,
                    isLast: true
                )
            }
        }
        .navigationTitle(String(localized: "grades_title"))
    }
}

private struct GradeCard: View {
    let letter: String
    let title: String
    let description: String
    let color: Color
    var isFirst: Bool = false
    var isLast: Bool = false

    var body: some View {
        HStack(spacing: 12) {
            Text(letter)
                .font(.title2)
                .fontWeight(.bold)
                .frame(width: 32, alignment: .leading)
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.caption)
            }
            Spacer()
        }

        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, innerPadding)
        .padding(.vertical, innerPadding)
        .background(color)
        .foregroundColor(.white)
        .overlay(
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(Color.platformSeparator)
                .opacity(isLast ? 0 : 1),
            alignment: .bottom
        )
    }
}

#Preview {
    GradesExplained()
}
