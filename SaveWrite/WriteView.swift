//
//  WriteView.swift
//  SaveWrite
//
//  Created by NewUser on 9/27/24.
//
import ComposableArchitecture
import SwiftUI

@Reducer
struct WriteFeature {
    @ObservableState
    struct State {
        var write: Write
        var isFavortie: Bool
    }

    enum Action {
        case favoriteButtonTapped
        case delegate

        enum Delegate: Hashable {
            case favoriteAdded
        }
    }
}

struct WriteView: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    WriteView()
}
