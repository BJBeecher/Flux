//
//  File.swift
//  
//
//  Created by BJ Beecher on 7/8/21.
//

import Combine

public protocol FluxAsyncAction : FluxAction {
    func execute(state: FluxState) -> AnyPublisher<FluxAction, Never>
}
