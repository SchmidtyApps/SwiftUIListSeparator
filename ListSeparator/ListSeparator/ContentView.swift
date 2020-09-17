//
//  ContentView.swift
//  ListSeparator
//
//  Created by Mike Schmidt on 9/10/20.
//  Copyright © 2020 SchmidtyApps. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: ListWithoutSeparator()) {
                    ContentCell(title: "No Line", subtitle: ".separator(style: .none)")
                }

                NavigationLink(destination: ListWithSeparator()) {
                    ContentCell(title: "Single Line", subtitle: ".separator(style: .singleLine)")
                }

                NavigationLink(destination: ListWithRedInsetSeparator()) {
                    ContentCell(title: "Single Line, Red, Inset", subtitle: ".separator(style: .singleLine, color: .red, inset: EdgeInsets(top: 0, leading: 50, bottom: 0, trailing: 20))")
                }

                NavigationLink(destination: ListWithSeparatorIgnoringEmptyRows()) {
                    ContentCell(title: "Single Line, Ignoring Empty Rows", subtitle: ".separator(style: .singleLine, hideOnEmptyRows: true)")
                }
            }
            .navigationBarTitle(Text("List Separator Style"))
        }
    }

    struct ContentCell: View {
        let title: String
        let subtitle: String

        var body: some View {
            VStack(alignment: .leading) {
                Text(title)
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
    }
}

struct ListWithSeparator: View {
    var body: some View {
        List {
            ForEach(0..<5) { index in
                Text("Row \(index)")
            }
        }
        .listSeparatorStyle(.singleLine)
        .navigationBarTitle(Text("Single Line"))
    }
}

struct ListWithRedInsetSeparator: View {
    var body: some View {
        List {
            ForEach(0..<5) { index in
                NavigationLink("Row \(index)", destination: Text("Row \(index)"))
            }
        }
        .listSeparatorStyle(.singleLine, color: .red, inset: EdgeInsets(top: 0, leading: 50, bottom: 0, trailing: 20), hideOnEmptyRows: true)
        .navigationBarTitle(Text("Single Line/Red/Inset"))
    }
}

struct ListWithSeparatorIgnoringEmptyRows: View {
    var body: some View {
        List {
            ForEach(0..<5) { index in
                Text("Row \(index)")
            }
        }
        .listSeparatorStyle(.singleLine, hideOnEmptyRows: true)
        .navigationBarTitle(Text("Single Line/No Empty Rows"))
    }
}

struct ListWithoutSeparator: View {
    var body: some View {
        List {
            ForEach(0..<5) { index in
                Text("Row \(index)")
            }
        }
        .listSeparatorStyle(.none)
        .navigationBarTitle(Text("None"))
    }
}
