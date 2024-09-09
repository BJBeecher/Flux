//
//  File.swift
//  
//
//  Created by BJ Beecher on 4/15/24.
//

public protocol FluxFeature {
    associatedtype State: FluxState
    
    init()
    
    func reduce(state: inout State, action: FluxAction) async
}
