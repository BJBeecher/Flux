//
//  File.swift
//  
//
//  Created by BJ Beecher on 4/15/24.
//

public protocol FluxFeature: Sendable {
    associatedtype Action: FluxAction
    
    mutating func reduce(action: Action)
}
