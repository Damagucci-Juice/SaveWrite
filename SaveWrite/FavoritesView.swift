//
//  FavoritesView.swift
//  SaveWrite
//
//  Created by NewUser on 9/27/24.
//
import ComposableArchitecture
import SwiftUI

@Reducer
struct FavoritesFeature {
    @ObservableState
    struct State: Equatable {
        var writes: IdentifiedArrayOf<Write> = []
    }

    enum Action {
        case favoriteTapped(Write)
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .favoriteTapped(write):
                if state.writes.contains(write) {
                    state.writes.remove(write)
                } else {
                    state.writes.append(write)
                }
                return .none
            }
        }
    }
}


struct FavoritesView: View {
    @Bindable var store: StoreOf<FavoritesFeature>

    var body: some View {
        NavigationStack {
            List(store.writes) { write in
                HStack {
                    Text(write.content)
                    Spacer()
                    Button {
                        store.send(.favoriteTapped(write))
                    } label: {
                        Image(systemName: "trash")
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle("Favorites")
        }
    }
}

#Preview {
    let store = Store(initialState: FavoritesFeature.State(
        writes: [
            Write(id: UUID(), content: "Hello World"),
            Write(id: UUID(), content: "I'm hero"),
            Write(id: UUID(), content: "Good Morning My Friends")
        ]
    )) {
        FavoritesFeature()
    }

    return NavigationStack {
        FavoritesView(store: store)
    }
}
