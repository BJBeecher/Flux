//
//  File.swift
//  
//
//  Created by BJ Beecher on 6/14/21.
//

import Foundation

public protocol FluxAction: Sendable {
    func sideEffect(dispatcher: FluxDispatcher<Self>) async
}

public extension FluxAction {
    func sideEffect(dispatcher: FluxDispatcher<Self>) async {}
}
