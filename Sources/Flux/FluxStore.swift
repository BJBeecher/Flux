//
//  File.swift
//  
//
//  Created by BJ Beecher on 6/10/21.
//

import Foundation
import Combine
import SwiftUI

public final class FluxStore<State : FluxState, Environment: FluxEnvironment> : ObservableObject {
    @Published public private (set) var state : State
    
    let reducer : FluxReducer<State>
    let middlewares : [FluxMiddleware<State, Environment>]
    let environment : Environment
    
    public init(initialState state: State, reducer: @escaping FluxReducer<State>, middlewares: [FluxMiddleware<State, Environment>] = [], environment: Environment){
        self.state = state
        self.reducer = reducer
        self.middlewares = middlewares
        self.environment = environment
    }
    
    var sideEffects = Set<AnyCancellable>()
    
    public func dispatch(_ action: FluxAction){
        for middleware in middlewares {
            if let action = middleware(state, action, environment) {
                dispatch(action)
            }
        }
        
        state = reducer(state, action)
        
        if let asyncAction = action as? FluxAsyncAction<State, Environment> {
            asyncAction.sideEffects(state: state, env: environment, dispatch: dispatch)
        }
    }
    
    public func scope<NewState: Equatable>(deriveState: @escaping (State, Environment) -> NewState) -> FluxScope<NewState> {
        let store : FluxScope<NewState> = .init(state: deriveState(state, environment), dispatch: dispatch)
        store.observe(statePub: $state, environment: environment, deriveState: deriveState)
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
