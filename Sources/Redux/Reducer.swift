//
//  File.swift
//  
//
//  Created by BJ Beecher on 6/10/21.
//

import Combine

public typealias Reducer<State, Action, Environment> = (inout State, Action, Environment) -> AnyPublisher<Action, Never>?
