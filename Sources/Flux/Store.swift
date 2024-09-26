//
//  File.swift
//  
//
//  Created by BJ Beecher on 9/9/24.
//

import Combine
import SwiftUI

@Observable
public final class Store<Feature: FluxFeature> {
    let fluxCenter = FluxCenter.default
    
    public var state: Feature
    
    var cancellable: AnyCancellable?
    
    public init(_ feature: Feature) {
        self.state = feature
        
        self.cancellable = fluxCenter.actionSubject
            .compactMap { $0 as? Feature.Action }
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
        await fluxCenter.dispatch(action)
    }
    
    public func dispatch(global action: any FluxAction) async {
        await fluxCenter.dispatch(action)
    }
    
    @discardableResult
    public func dispatch(_ action: Feature.Action) -> Task<Void, Never> {
        Task(priority: .userInitiated) {
            await dispatch(action)
        }
    }
    
    @discardableResult
    public func dispatch(global action: any FluxAction) -> Task<Void, Never> {
        Task(priority: .userInitiated) {
            await dispatch(global: action)
        }
    }
}
