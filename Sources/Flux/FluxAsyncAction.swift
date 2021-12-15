//
//  File.swift
//  
//
//  Created by BJ Beecher on 7/8/21.
//

import Combine

open class FluxAsyncAction<State: FluxState, Environment: FluxEnvironment> : FluxAction {
    public init() {}
    
    open func execute(state: @autoclosure () -> State, env: Environment, dispatch: @escaping FluxDispatch) async {
        fatalError("async action execute method not implemented")
    }
}
