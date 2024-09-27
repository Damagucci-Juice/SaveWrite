//
//  SaveWriteApp.swift
//  SaveWrite
//
//  Created by NewUser on 9/27/24.
//
import ComposableArchitecture
import SwiftUI

@main
struct SaveWriteApp: App {
    static let store = Store(initialState: AppFeature.State(), reducer: {
        AppFeature()
            ._printChanges()
    })

    var body: some Scene {
        WindowGroup {
            AppView(store: SaveWriteApp.store)
        }
    }
}
