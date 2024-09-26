//
//  File.swift
//  
//
//  Created by BJ Beecher on 6/14/21.
//

import Foundation

public protocol FluxAction: Sendable {
    func sideEffect(dispatch: FluxDispatch) async
}

public extension FluxAction {
    func sideEffect(dispatch: FluxDispatch) async {}
}
