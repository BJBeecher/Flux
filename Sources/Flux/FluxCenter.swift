//
//  File.swift
//  
//
//  Created by BJ Beecher on 6/10/21.
//

import Dependencies
import Foundation
import Combine
import SwiftUI

public final class FluxCenter {
    public static let `default` = FluxCenter()
    
    var middlewares = [FluxMiddleware]()
    var actionSubject = PassthroughSubject<(storeId: UUID?, action: any FluxAction), Never>()
}

// MARK: Computed properties

public extension FluxCenter {
    var actions: AsyncPublisher<PassthroughSubject<(storeId: UUID?, action: any FluxAction), Never>> {
        actionSubject.values
    }
}

// MARK: Middleware

public extension FluxCenter {
    func use(_ middleware: any FluxMiddleware) {
        self.middlewares.append(middleware)
    }
    
    func use(_ middlewares: [any FluxMiddleware]) {
        self.middlewares.append(contentsOf: middlewares)
    }
}

// MARK: Dispatch methods

public extension FluxCenter {
    func dispatch<Action: FluxAction>(storeId: UUID?, action: Action) async {
        for middleware in self.middlewares {
            await middleware.execute(center: self, action: action)
        }
        
        actionSubject.send((storeId, action))
        
        let dispatcher = FluxDispatcher(
            dispatch: { [weak self] (action: Action) in
                await self?.dispatch(storeId: storeId, action: action)
            },
            dispatchGlobal: { [weak self] action in
                await self?.dispatch(global: action)
            }
        )
        
        await action.sideEffect(dispatcher: dispatcher)
    }
    
    func dispatch<Action: FluxAction>(global action: Action) async {
        await dispatch(storeId: nil, action: action)
    }
}

// MARK: Dependency

extension FluxCenter: DependencyKey {
    public static let liveValue = FluxCenter.default
}
