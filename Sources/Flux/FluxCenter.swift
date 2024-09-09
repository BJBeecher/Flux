//
//  File.swift
//  
//
//  Created by BJ Beecher on 6/10/21.
//

import Foundation
import Combine
import SwiftUI

public actor FluxCenter {
    public static let `default` = FluxCenter()
    
    let actionSubject = PassthroughSubject<FluxAction, Never>()
    var middlewares = [FluxMiddleware]()
}

// MARK: Computed properties

public extension FluxCenter {
    var actions: AsyncPublisher<PassthroughSubject<FluxAction, Never>> {
        actionSubject.values
    }
}

// MARK: Setup

public extension FluxCenter {
    func use(_ middleware: FluxMiddleware) {
        self.middlewares.append(middleware)
    }
    
    func use(_ middlewares: [FluxMiddleware]) {
        self.middlewares.append(contentsOf: middlewares)
    }
}

// MARK: Dispatch methods

public extension FluxCenter {
    func dispatch(_ action: any FluxAction) async {
        var newAction = action
        
        for middleware in self.middlewares {
            newAction = await middleware.execute(action: newAction)
        }
        
        actionSubject.send(newAction)
    }
}
