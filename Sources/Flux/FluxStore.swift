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
    let stateSubject : CurrentValueSubject<State, Never>
    
    public private (set) var state : State {
        didSet {
            stateSubject.send(state)
        }
    }
    
    let reducer : FluxReducer<State>
    let middlewares : [FluxMiddleware<State, Environment>]
    public nonisolated let environment : Environment
    
    public init(
        initialState state: State,
        reducer: @escaping FluxReducer<State>,
        middlewares: [FluxMiddleware<State, Environment>],
        environment: Environment
    ){
        self.stateSubject = CurrentValueSubject(state)
        self.state = state
        self.reducer = reducer
        self.middlewares = middlewares
        self.environment = environment
    }
}

// computed properties

public extension FluxStore {
    private func defaultDispatch(_ action: any FluxDispatchable) async {
        for middleware in middlewares {
            await middleware(state, action, environment)
        }
        
        state = reducer(state, action)
    }
    
    func dispatch(_ action: any FluxAction) async {
        await defaultDispatch(action)
    }
    
    func dispatch<T: FluxActionCreator>(creator: T) async where T.State == State, T.Environment == Environment {
        await defaultDispatch(creator)
        await creator.execute(store: self)
    }
    
    nonisolated func scope<NewState: Equatable>(deriveState: @escaping (State) -> NewState) -> FluxScope<NewState> {
        let store : FluxScope<NewState> = .init(store: self, slice: deriveState(stateSubject.value))
        store.observe(stateSubject: stateSubject, deriveState: deriveState)
        return store
    }
}
