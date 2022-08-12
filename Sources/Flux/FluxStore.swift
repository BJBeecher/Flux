//
//  File.swift
//  
//
//  Created by BJ Beecher on 6/10/21.
//

import Foundation
import Combine
import SwiftUI

public final actor FluxStore<State: FluxState, Environment: FluxEnvironment> {
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
}

// computed properties

public extension FluxStore {
    func dispatch(_ action: FluxAction) async {
        for middleware in middlewares {
            await middleware(state, action, environment)
        }
        
        state = reducer(state, action)
        
        if let asyncAction = action as? FluxActionCreator<State, Environment> {
            await asyncAction.execute(state: state, env: environment, dispatch: dispatch)
        }
    }
    
    func scope<NewState: Equatable>(deriveState: @escaping (State) -> NewState) -> FluxScope<NewState> {
        let store : FluxScope<NewState> = .init(state: deriveState(state), dispatch: dispatch)
        store.observe(statePub: $state, deriveState: deriveState)
        return store
    }
}
