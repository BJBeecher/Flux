//
//  File.swift
//  
//
//  Created by BJ Beecher on 6/10/21.
//

import Combine

public typealias Middleware<State, Action> = (State, Action) -> AnyPublisher<Action, Never>?
