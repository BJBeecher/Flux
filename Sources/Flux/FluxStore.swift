//
//  File.swift
//  
//
//  Created by BJ Beecher on 6/10/21.
//

import Foundation
import Combine
import SwiftUI

public actor FluxStore<State: FluxState, Environment: FluxEnvironment> {
    
    @Published public private (set) var state : State
    
    let reducer : FluxReducer<State>
    let middlewares : [FluxMiddleware<State, Environment>]
    let environment : Environment
    
    public init(
        initialState state: State,
        reducer: @escaping FluxReducer<State>,
        middlewares: [FluxMiddleware<State, Environment>],
        environment: Environment
    ){
        self.state = state
        self.reducer = reducer
        self.middlewares = middlewares
        self.environment = environment
    }
    
    public func dispatch(_ action: FluxAction){
        for middleware in middlewares {
            middleware(state, action, environment)
        }
        
        state = reducer(state, action)
        
        if let asyncAction = action as? FluxAsyncAction<State, Environment> {
            Task {
                await asyncAction.execute(state: state, env: environment, dispatch: dispatch)
            }
        }
    }
    
    public func scope<NewState: Equatable>(deriveState: @escaping (State) -> NewState) -> FluxScope<NewState> {
        let store : FluxScope<NewState> = .init(state: deriveState(state), dispatch: dispatch)
        store.observe(statePub: $state, deriveState: deriveState)
        return store
    }
}
