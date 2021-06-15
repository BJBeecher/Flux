//
//  File.swift
//  
//
//  Created by BJ Beecher on 6/10/21.
//

import Combine

public typealias FluxReducer<State: FluxState, Action: FluxAction, Environment: FluxEnvironment> = (inout State, Action, Environment) -> AnyPublisher<Action, Never>?
