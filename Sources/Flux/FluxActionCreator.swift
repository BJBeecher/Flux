//
//  File.swift
//  
//
//  Created by BJ Beecher on 7/8/21.
//

import Combine

public protocol FluxActionCreator: FluxDispatchable {
    associatedtype State: FluxState
    associatedtype Environment: FluxEnvironment
    
    func execute(store: FluxStore<State, Environment>) async
}
