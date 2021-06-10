//
//  File.swift
//  
//
//  Created by BJ Beecher on 6/10/21.
//

import Foundation
import Combine

public final class Store<State, Action> : ObservableObject {
    @Published public private (set) var state : State
    
    let reducer : Reducer<State, Action>
    
    let middlewares : [Middleware<State, Action>]
    
    public init(initialState state: State, reducer: @escaping Reducer<State, Action>, middlewares: [Middleware<State, Action>]){
        self.state = state
        self.reducer = reducer
        self.middlewares = middlewares
    }
    
    var tokens = Set<AnyCancellable>()
    
    public func dispatch(_ action: Action){
        reducer(&state, action)
        
        for perform in middlewares {
            if let sideEffect = perform(state, action) {
                sideEffect
                    .receive(on: DispatchQueue.main)
                    .sink(receiveValue: dispatch)
                    .store(in: &tokens)
            }
        }
    }
    
    public func derived<DerivedState: Equatable, ExtractedAction>(deriveState: (State) -> DerivedState, embedAction: @escaping (ExtractedAction) -> Action) -> Store<DerivedState, ExtractedAction> {
        return .init(initialState: deriveState(state), reducer: { self.dispatch(embedAction($1)) }, middlewares: [])
    }
}
