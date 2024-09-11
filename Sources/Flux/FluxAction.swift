//
//  File.swift
//  
//
//  Created by BJ Beecher on 6/14/21.
//

import Foundation

public protocol FluxAction: Sendable {
    func sideEffect(center: FluxCenter) async
}

public extension FluxAction {
    func sideEffect(center: FluxCenter) async {}
}
