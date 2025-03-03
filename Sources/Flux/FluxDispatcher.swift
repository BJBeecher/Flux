//
//  FluxDispatcher.swift
//  Flux
//
//  Created by BJ Beecher on 3/3/25.
//

public struct FluxDispatcher<LocalAction: FluxAction> {
    let dispatch: (LocalAction) async -> Void
    let dispatchGlobal: (any FluxAction) async -> Void
    
    public func dispatch(_ action: LocalAction) async {
        await dispatch(action)
    }
    
    public func dispatch(global action: any FluxAction) async {
        await dispatchGlobal(action)
    }
}
