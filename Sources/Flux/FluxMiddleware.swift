//
//  File.swift
//  
//
//  Created by BJ Beecher on 7/8/21.
//

public protocol FluxMiddleware {
    func execute(action: any FluxAction) async -> any FluxAction
}
