//
//  File.swift
//  
//
//  Created by BJ Beecher on 7/8/21.
//

import Combine

public typealias FluxMiddleware<State: FluxState, Environment: FluxEnvironment> = (State, FluxAction, Environment) -> FluxAction?
