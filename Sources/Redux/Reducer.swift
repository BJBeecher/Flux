//
//  File.swift
//  
//
//  Created by BJ Beecher on 6/10/21.
//

public typealias Reducer<State, Action> = (inout State, Action) -> Void
