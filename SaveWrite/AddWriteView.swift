//
//  AddWriteView.swift
//  SaveWrite
//
//  Created by NewUser on 9/27/24.
//
import ComposableArchitecture
import SwiftUI

@Reducer
struct AddWriteFeature {
    @ObservableState
    struct State: Equatable {
        var write: Write
    }

    enum Action {
        case cancelButtonTapped
        case saveButtonTapped
        case setContent(String)
        case delegate(Delegate)

        enum Delegate: Equatable {
            case saveWrite(Write)
        }
    }

    @Dependency(\.dismiss) var dismiss

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .cancelButtonTapped:
                return .run { _ in await self.dismiss() }
            case .delegate:
                return .none
            case .saveButtonTapped:
                return .run { [write = state.write] send in
                    await send(.delegate(.saveWrite(write)))
                    await self.dismiss()
                }
            case let .setContent(content):
                state.write.content = content
                return .none
            }
        }
    }
}

struct AddWriteView: View {
    @Bindable var store: StoreOf<AddWriteFeature>

    var body: some View {
        Form {
            TextField("Content", text: $store.write.content.sending(\.setContent))
            Button("Save") {
                store.send(.saveButtonTapped)
            }
        }
        .toolbar {
            Button("Cancel") {
                store.send(.cancelButtonTapped)
            }
        }
    }
}

#Preview {
    let store = Store(initialState: AddWriteFeature.State(write: Write(id: UUID(), content: "Hello"))) {
        AddWriteFeature()
    }

    return NavigationStack { AddWriteView(store: store) }
}
