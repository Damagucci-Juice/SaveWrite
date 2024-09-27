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
        case deleteButtonTapped(Write)
        case canDeleteWrite(Write, Bool)
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
            case .toggleFavortie:
                return .none

            case .deleteButtonTapped:
                return .none
            case let .canDeleteWrite(write, canDelete):
                if canDelete {
                    state.writes.remove(write)
                } else {
                    // Alert 창
                    print("Alert 창 띄워보시죠 ~ 나이수 ~")
                }
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
                    Button {
                        store.send(.deleteButtonTapped(write))
                    } label: {
                        Image(systemName: "trash")
                            .foregroundStyle(.red)
                    }

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
