//
//  File.swift
//  
//
//  Created by BJ Beecher on 7/8/21.
//

import Combine

open class FluxAsyncAction<State: FluxState, Environment: FluxEnvironment> : FluxAction {
    public init() {}
    
    open func sideEffects(state: State, env: Environment, dispatch: @escaping FluxDispatch) {
        fatalError("async action execute method not implemented")
    }
}
