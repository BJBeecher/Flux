//
//  File.swift
//  
//
//  Created by BJ Beecher on 6/10/21.
//

import Foundation
import Combine
import SwiftUI

public final class FluxStore<State : FluxState> : ObservableObject {
    @Published public private (set) var state : State
    
    let reducer : FluxReducer<State>
    let middlewares : [FluxMiddleware<State>]
    
    public init(initialState state: State, reducer: @escaping FluxReducer<State>, middlewares: [FluxMiddleware<State>] = []){
        self.state = state
        self.reducer = reducer
        self.middlewares = middlewares
    }
    
    var sideEffects = Set<AnyCancellable>()
    
    public func dispatch(_ action: FluxAction){
        for middleware in middlewares {
            if let action = middleware(state, action) {
                dispatch(action)
            }
        }
        
        if let asyncAction = action as? FluxAsyncAction {
            asyncAction
                .execute(state: state)
                .receive(on: DispatchQueue.main)
                .sink(receiveValue: dispatch)
                .store(in: &sideEffects)
        }
        
        withAnimation {
            state = reducer(state, action)
        }
    }
    
    public func derived<NewState: Equatable>(deriveState: @escaping (State) -> NewState) -> FluxStore<NewState> {
        let reducer : FluxReducer<NewState> = { state, action in
            self.dispatch(action)
            return state
        }
        
        let store : FluxStore<NewState> = .init(initialState: deriveState(state), reducer: reducer)
        
        $state
            .map(deriveState)
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .assign(to: &store.$state)
        
        return store
    }
    
    public func binding<Value>(for keypath: KeyPath<State, Value>, transform: @escaping (Value) -> FluxAction) -> Binding<Value> {
        Binding {
            self.state[keyPath: keypath]
        } set: { newValue in
            self.dispatch(transform(newValue))
        }
    }
}
