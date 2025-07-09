//
//  TeamView.swift
//  ToS;DR
//
//  Created by Erik on 03.11.23.
//

import SwiftUI
import CachedAsyncImage

struct TeamView: View {
    @State private var team: Team?
    @Environment(\.openURL) var openURL
    
    var body: some View {
        if let team = team {
            List {
                Section(String(localized: "team_section_founders")) {
                    ForEach(team.founders, id: \.name) { member in
                        TeamMemberView(member: member)
                    }
                }
                
                Section(String(localized: "team_section_current")) {
                    ForEach(team.current, id: \.name) { member in
                        TeamMemberView(member: member)
                    }
                }
                
                Section(String(localized: "team_section_past")) {
                    ForEach(team.past, id: \.name) { member in
                        TeamMemberView(member: member)
                    }
                }
            }
            #if os(iOS)
            .listStyle(.grouped)
            #elseif os(macOS)
            .listStyle(.insetGrouped)
            .padding(.horizontal)
            #endif
            .navigationTitle(String(localized: "label_team"))
        } else {
            ProgressView()
                .task {
                    team = await GetTeam()
                }
        }
    }
}

struct TeamMemberView: View {
    @Environment(\.openURL) var openURL
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
                        Button {
                            openURL(URL(string: "mailto:\(email)")!)
                        } label: {
                            Image(systemName: "envelope.fill")
                                .foregroundColor(.accentColor)
                                .frame(width: 44, height: 44)
                                .contentShape(Rectangle())
                        }
                    }
                    
                    if let github = member.links.github {
                        Button {
                            openURL(URL(string: github)!)
                        } label: {
                            Image("github")
                                .renderingMode(.template)
                                .resizable()
                                .frame(width: 15, height: 15)
                                .foregroundColor(.accentColor)
                                .frame(width: 44, height: 44)
                                .contentShape(Rectangle())
                        }
                    }
                    
                    if let website = member.links.website {
                        Button {
                            openURL(URL(string: website)!)
                        } label: {
                            Image(systemName: "globe")
                                .foregroundColor(.accentColor)
                                .frame(width: 44, height: 44)
                                .contentShape(Rectangle())
                        }
                    }
                    
                    if let mastodon = member.links.mastodon {
                        Button {
                            openURL(URL(string: mastodon)!)
                        } label: {
                            Image("mastodon")
                                .renderingMode(.template)
                                .resizable()
                                .frame(width: 15, height: 15)
                                .foregroundColor(.accentColor)
                                .frame(width: 44, height: 44)
                                .contentShape(Rectangle())
                        }
                    }
                    
                    if let twitter = member.links.twitter {
                        Button {
                            openURL(URL(string: twitter)!)
                        } label: {
                            Image(systemName: "bird.fill")
                                .foregroundColor(.accentColor)
                                .frame(width: 44, height: 44)
                                .contentShape(Rectangle())
                        }
                    }
                }
            }
        }
        .padding()
        .listRowInsets(EdgeInsets())
        .buttonStyle(PlainButtonStyle())
#if os(macOS)
        .listRowBackground(Color(.controlBackgroundColor))
#endif
    }
}

extension TeamMemberLinks {
    var isEmpty: Bool {
        return email == nil && github == nil && twitter == nil && website == nil && mastodon == nil
    }
}

#Preview {
    TeamView()
}
