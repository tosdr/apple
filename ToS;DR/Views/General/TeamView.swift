//
//  TeamView.swift
//  ToS;DR
//
//  Created by Erik on 03.11.23.
//

import SwiftUI
import CachedAsyncImage

struct TeamView: View {
    @StateObject private var viewModel = TeamViewModel()

    var body: some View {
        Group {
            if let team = viewModel.team {
                GroupedList {
                    teamSection(title: String(localized: "team_section_founders"), members: team.founders)
                    teamSection(title: String(localized: "team_section_current"), members: team.current)
                    teamSection(title: String(localized: "team_section_past"), members: team.past)
                }
                .navigationTitle(String(localized: "label_team"))
                .refreshable {
                    await viewModel.refresh()
                }
            } else if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let error = viewModel.errorMessage {
                VStack(spacing: 12) {
                    Text(error)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                    Button(String(localized: "service_error_retry")) {
                        Task { await viewModel.refresh() }
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .task {
            await viewModel.loadTeam()
        }
    }

    private func teamSection(title: String, members: [TeamMember]) -> some View {
        GroupedListSection {
            Text(title)
        } content: {
            ForEach(Array(members.enumerated()), id: \.offset) { index, member in
                GroupedListItem(
                    content: {
                        TeamMemberRow(member: member)
                    },
                    isFirst: index == 0,
                    isLast: index == members.count - 1
                )
            }
        }
    }
}

private struct TeamMemberRow: View {
    @Environment(\.openURL) private var openURL
    let member: TeamMember

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 15) {
                CachedAsyncImage(
                    url: URL(string: member.photo),
                    content: { image in
                        image.resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 60, height: 60)
                            .clipShape(Circle())
                    },
                    placeholder: {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 60, height: 60)
                            .foregroundColor(.secondary)
                    }
                )

                VStack(alignment: .leading) {
                    Text(member.name)
                        .font(.headline)
                    if !member.title.isEmpty {
                        Text(member.title)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }

            Text(.init(member.description))
                .font(.body)
                .textSelection(.enabled)
                .fixedSize(horizontal: false, vertical: true)

            if !member.links.isEmpty {
                HStack(spacing: 15) {
                    if let email = member.links.email {
                        TeamLinkButton(image: Image(systemName: "envelope.fill")) {
                            openURL(URL(string: "mailto:\(email)")!)
                        }
                    }

                    if let github = member.links.github {
                        TeamLinkButton(image: Image("github").renderingMode(.template)) {
                            openURL(URL(string: github)!)
                        }
                    }

                    if let website = member.links.website {
                        TeamLinkButton(image: Image(systemName: "globe")) {
                            openURL(URL(string: website)!)
                        }
                    }

                    if let mastodon = member.links.mastodon {
                        TeamLinkButton(image: Image("mastodon").renderingMode(.template)) {
                            openURL(URL(string: mastodon)!)
                        }
                    }

                    if let twitter = member.links.twitter {
                        TeamLinkButton(image: Image(systemName: "bird.fill")) {
                            openURL(URL(string: twitter)!)
                        }
                    }
                }
            }
        }
    }
}

private struct TeamLinkButton: View {
    let image: Image
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            image
                .resizable()
                .scaledToFit()
                .frame(width: 15, height: 15)
                .foregroundColor(.accentColor)
                .frame(width: 44, height: 44)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

extension TeamMemberLinks {
    var isEmpty: Bool {
        email == nil && github == nil && twitter == nil && website == nil && mastodon == nil
    }
}

#Preview {
    TeamView()
}
