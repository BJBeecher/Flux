//
//  File.swift
//  
//
//  Created by BJ Beecher on 4/15/24.
//

public protocol FluxFeature {
    associatedtype Action: FluxAction
    init()
    func reduce(action: Action)
}
