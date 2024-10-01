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

extension WritesFeature {

}


@Reducer
struct WritesFeature {
    @ObservableState
    struct State: Equatable {
        var writes: IdentifiedArrayOf<Write> = []
        @Presents var destination: Destination.State?
    }

    enum Action {
        case plusButtonTapped
        case toggleFavortie(Write)
        case deleteButtonTapped(Write)
        case canDeleteWrite(Write, Bool)
        case destination(PresentationAction<Destination.Action>)
    }

    @Reducer
    enum Destination {
        case addWrite(AddWriteFeature)
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .plusButtonTapped:
                state.destination = .addWrite(AddWriteFeature.State(
                    write: Write(id: UUID(), content: "")
                ))
                return .none
            case .toggleFavortie:
                return .none
            case .deleteButtonTapped:
                return .none
            case let .canDeleteWrite(write, canDelete):
                if canDelete {
                    state.writes.remove(write)
                }
                return .none
            case let .destination(.presented(.addWrite(.delegate(.saveWrite(write))))):
                guard let write = state.addWrite?.write
                else { return .none }
                state.writes.append(write)
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
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
            .buttonStyle(BorderlessButtonStyle())   // 이거 덕분에 list의 Row가 전체 선택이 안된다.
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
                item: $store.scope(state: \.destination?.addWrite, action: \.destination.addWrite)
            ) { addWriteStore in
                NavigationStack {
                    AddWriteView(store: addWriteStore)
                }
            }
            .alert($store.scope(state: \.destination?.alert, action: \.destination.alert))
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
