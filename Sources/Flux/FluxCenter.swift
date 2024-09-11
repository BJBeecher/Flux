//
//  File.swift
//  
//
//  Created by BJ Beecher on 6/10/21.
//

import Foundation
import Combine
import SwiftUI

public final class FluxCenter {
    public static let `default` = FluxCenter()
    
    var middlewares = [FluxMiddleware]()
    var actionSubject = PassthroughSubject<any FluxAction, Never>()
}

// MARK: Computed properties

public extension FluxCenter {
    var actions: AsyncPublisher<PassthroughSubject<any FluxAction, Never>> {
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
    func dispatch(_ action: any FluxAction) async {
        for middleware in self.middlewares {
            await middleware.execute(center: self, action: action)
        }
        
        actionSubject.send(action)
        
        await action.sideEffect(center: self)
    }
}
