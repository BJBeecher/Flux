//
//  File.swift
//  
//
//  Created by BJ Beecher on 9/9/24.
//

import Dependencies
import Combine
import SwiftUI

// global actions go to all observing stores. Others are specific to each store.

@Observable
public final class Store<Feature: FluxFeature> {
    let storeId = UUID()
    public var state: Feature
    
    @ObservationIgnored
    var cancellable: AnyCancellable?
    
    @ObservationIgnored
    @Dependency(\.fluxCenter) private var fluxCenter
    
    public init(_ feature: Feature) {
        self.state = feature
        
        self.cancellable = fluxCenter.actionSubject
            .filter { [weak self] in
                $0.storeId == nil || $0.storeId == self?.storeId
            }
            .compactMap { $0.action as? Feature.Action }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] action in
                withAnimation {
                    self?.state.reduce(action: action)
                }
            }
    }
    
    deinit {
        self.cancellable?.cancel()
    }
    
    public func dispatch(_ action: Feature.Action) async {
        await fluxCenter.dispatch(storeId: storeId, action: action)
    }
    
    public func dispatch(global action: any FluxAction) async {
        await fluxCenter.dispatch(global: action)
    }
    
    @discardableResult
    public func dispatch(_ action: Feature.Action) -> Task<Void, Never> {
        Task(priority: .high) {
            await fluxCenter.dispatch(storeId: storeId, action: action)
        }
    }
    
    @discardableResult
    public func dispatch(global action: any FluxAction) -> Task<Void, Never> {
        Task(priority: .high) {
            await dispatch(global: action)
        }
    }
}
