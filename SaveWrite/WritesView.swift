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
        @Presents var alert: AlertState<Action.Alert>?
        var writes: IdentifiedArrayOf<Write> = []
    }

    enum Action {
        case plusButtonTapped
        case addWrite(PresentationAction<AddWriteFeature.Action>)
        case alert(PresentationAction<Alert>)
        case toggleFavortie(Write)
        case deleteButtonTapped(Write)
        case canDeleteWrite(Write, Bool)
        enum Alert: Equatable {
            case informFavoriteStillHave(Write)
        }
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
                    state.alert = AlertState(title: {
                        TextState("\(write.content)라는 문장이 favorites 목록에 포함되어 있어서 지울 수 없습니다.")
                    })
                }
                return .none
            case .alert:
                return .none
            }
        }
        .ifLet(\.$addWrite, action: \.addWrite) {
            AddWriteFeature()
        }
        .ifLet(\.$alert, action: \.alert)
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
                item: $store.scope(state: \.addWrite, action: \.addWrite)
            ) { addWriteStore in
                NavigationStack {
                    AddWriteView(store: addWriteStore)
                }
            }
            .alert($store.scope(state: \.alert, action: \.alert))
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
