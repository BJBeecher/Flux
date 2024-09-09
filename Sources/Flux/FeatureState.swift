//
//  File.swift
//  
//
//  Created by BJ Beecher on 9/9/24.
//

import SwiftUI

@propertyWrapper
public class FeatureState<Feature: FluxFeature>: DynamicProperty where Feature.State: Observable {
    let fluxCenter = FluxCenter.default
    let feature: Feature
    
    @State public var state = Feature.State()
    
    public var wrappedValue: FeatureState<Feature> {
        self
    }
    
    public var projectedValue: Binding<Feature.State> {
        Binding {
            self.state
        } set: { newValue in
            self.state = newValue
        }
    }
    
    public init(_ featureType: Feature.Type) {
        self.feature = featureType.init()
        
        Task(priority: .high) {
            await setupFeature()
        }
    }
    
    func setupFeature() async {
        for await action in await fluxCenter.actions {
            await feature.reduce(state: &state, action: action)
        }
    }
    
    public func dispatch(_ action: any FluxAction) async {
        await fluxCenter.dispatch(action)
    }
    
    public func dispatch(_ action: any FluxAction) {
        Task(priority: .userInitiated) {
            await dispatch(action)
        }
    }
}
