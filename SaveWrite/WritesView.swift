//
//  WritesView.swift
//  SaveWrite
//
//  Created by NewUser on 9/27/24.
//

import SwiftUI
import ComposableArchitecture

struct Write: Equatable, Identifiable {
    let id: UUID
    var content: String
}

@Reducer
struct WritesFeature {
    @ObservableState
    struct State: Equatable {
        @Presents var addWrite: AddWriteFeature.State?
        var writes: IdentifiedArrayOf<Write> = []
    }

    enum Action {
        case plusButtonTapped
        case addWrite(PresentationAction<AddWriteFeature.Action>)
        case toggleFavortie(Write)
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .plusButtonTapped:
                state.addWrite = AddWriteFeature.State(
                    write: Write(id: UUID(), content: "")
                )
                return .none
            case let .addWrite(.presented(.delegate(.saveWrite(write)))):
                guard let write = state.addWrite?.write
                else { return .none }
                state.writes.append(write)
                return .none
            case .addWrite:
                return .none
            case let .toggleFavortie(write):
                print("\(write.content) did Tap")
                return .none
            }
        }
        .ifLet(\.$addWrite, action: \.addWrite) {
            AddWriteFeature()
        }
    }
}



struct WritesView: View {
    @Bindable var store = Store(initialState: WritesFeature.State()) {
        WritesFeature()
    }

    var body: some View {
        NavigationStack {
            List(store.writes) { write in
                HStack {
                    Text(write.content)

                    Spacer()

                    Button {
                        store.send(.toggleFavortie(write))
                    } label: {
                        Image(systemName: "star")
                            .foregroundStyle(.yellow)
                    }
                }
            }
            .navigationTitle("Writes")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        store.send(.plusButtonTapped)
                    } label: {
                        Image(systemName: "plus")
                            .resizable()
                    }
                }
            }
            .sheet(
                item: $store.scope(state: \.addWrite, action: \.addWrite)
            ) { addWriteStore in
                NavigationStack {
                    AddWriteView(store: addWriteStore)
                }
            }
        }
    }
}

#Preview {
    let store = Store(initialState: WritesFeature.State()) {
        WritesFeature()
    }

    return NavigationStack {
        WritesView(store: store)
    }
}
