//
//  File.swift
//  
//
//  Created by BJ Beecher on 9/9/24.
//

import Combine
import SwiftUI

@propertyWrapper
public final class FeatureState<Feature: FluxFeature>: DynamicProperty where Feature: Observable {
    let fluxCenter = FluxCenter.default
    
    @State public var state: Feature
    
    var task: Task<Void, Never>?
    
    public init(_ featureType: Feature.Type) {
        self.state = Feature()
        
        task = Task { [weak self] in
            guard let self else {
                return
            }
            
            for await action in fluxCenter.actions {
                debugPrint("Recieved:" + "\(action)")
                if let featureAction = action as? Feature.Action {
                    state.reduce(action: featureAction)
                }
            }
        }
        debugPrint("init: \(Feature.self)")
    }
    
    deinit {
        task?.cancel()
        debugPrint("deinit: \(Feature.self)")
    }
    
    public var wrappedValue: FeatureState<Feature> {
        self
    }
    
    public var projectedValue: Binding<Feature> {
        Binding {
            self.state
        } set: { newValue in
            self.state = newValue
        }
    }
    
    public func dispatch(_ action: Feature.Action) async {
        debugPrint("dispatch: \(action)")
        await fluxCenter.dispatch(action)
    }
    
    public func dispatch(_ action: any FluxAction) async {
        debugPrint("dispatch: \(action)")
        await fluxCenter.dispatch(action)
    }
    
    public func dispatch(_ action: Feature.Action) {
        Task(priority: .userInitiated) {
            await dispatch(action)
        }
    }
    
    public func dispatch(_ action: any FluxAction) {
        Task(priority: .userInitiated) {
            await dispatch(action)
        }
    }
}
