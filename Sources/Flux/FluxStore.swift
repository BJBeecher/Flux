//
//  File.swift
//  
//
//  Created by BJ Beecher on 6/10/21.
//

import Foundation
import Combine
import SwiftUI

public final class FluxStore<State : FluxState, Action: FluxAction, Environment: FluxEnvironment> : ObservableObject {
    @Published public private (set) var state : State
    
    let reducer : FluxReducer<State, Action, Environment>
    let environment : Environment
    
    public init(initialState state: State, reducer: @escaping FluxReducer<State, Action, Environment>, environment: Environment){
        self.state = state
        self.reducer = reducer
        self.environment = environment
    }
    
    var sideEffects = Set<AnyCancellable>()
    
    public func dispatch(_ action: Action){
        guard let sideEffect = reducer(&state, action, environment) else { return }
        
        sideEffect
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: dispatch)
            .store(in: &sideEffects)
    }
    
    public func derived<DerivedState: Equatable, ExtractedAction>(
        deriveState: (State) -> DerivedState,
        embedAction: @escaping (ExtractedAction) -> Action
    ) -> FluxStore<DerivedState, ExtractedAction, Environment> {
        .init(initialState: deriveState(state), reducer: { _, action, _ in
            self.dispatch(embedAction(action))
            return nil
        }, environment: environment)
    }
    
    public func binding<Value>(for keypath: KeyPath<State, Value>, transform: @escaping (Value) -> Action) -> Binding<Value> {
        Binding {
            self.state[keyPath: keypath]
        } set: { newValue in
            self.dispatch(transform(newValue))
        }
    }
}