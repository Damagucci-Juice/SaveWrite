//
//  AppView.swift
//  SaveWrite
//
//  Created by NewUser on 9/27/24.
//
import ComposableArchitecture
import SwiftUI

@Reducer
struct AppFeature {
    @ObservableState
    struct State: Equatable {
        var writesTab = WritesFeature.State()
        var favoritesTab = FavoritesFeature.State()
    }

    enum Action {
        case writesTab(WritesFeature.Action)
        case favoritesTab(FavoritesFeature.Action)
    }

    var body: some ReducerOf<Self> {
        Scope(state: \.writesTab, action: \.writesTab) {
            WritesFeature()
        }

        Scope(state: \.favoritesTab, action: \.favoritesTab) {
            FavoritesFeature()
        }

        Reduce { state, action in
            switch action {
            case let .writesTab(writeAction):
                switch writeAction {
                case let .toggleFavortie(write):
                    return .send(.favoritesTab(.favoriteTapped(write)))
                case let .deleteButtonTapped(write):
                    let canDelete = !state.favoritesTab.writes.contains(write)
                    return .send(.writesTab(.canDeleteWrite(write, canDelete)))
                default:
                    break
                }
                return .none
            case .favoritesTab:
                return .none
            }
        }
    }
}

struct AppView: View {
    let store: StoreOf<AppFeature>

    var body: some View {
        TabView {
            WritesView(store: store.scope(state: \.writesTab, action: \.writesTab))
                .tabItem {
                    Text("Writes")
                }

            FavoritesView(store: store.scope(state: \.favoritesTab, action: \.favoritesTab))
                .tabItem {
                    Text("Favorites")
                }
        }
    }
}

#Preview {
    AppView(store: Store(initialState: AppFeature.State(), reducer: {
        AppFeature()
    }))
}
