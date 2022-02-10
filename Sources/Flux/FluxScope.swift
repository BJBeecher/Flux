//
//  File.swift
//  
//
//  Created by BJ Beecher on 7/9/21.
//

import Foundation
import SwiftUI
import Combine

// interface

public protocol FluxScopeInterface : ObservableObject {
    associatedtype State : Equatable
    var state : State { get }
    func dispatch(_ action: FluxAction)
}

// implementation

public final class FluxScope<State: Equatable> : FluxScopeInterface {
    @Published public private (set) var state : State
    
    let _dispatch : FluxDispatch
    
    public init(state: State, dispatch: @escaping FluxDispatch){
        self.state = state
        self._dispatch = dispatch
    }
    
    var token : AnyCancellable?
    
    deinit {
        token?.cancel()
    }
    
    public func dispatch(_ action: FluxAction){
        _dispatch(action)
    }
    
    public func binding<Value>(for keypath: KeyPath<State, Value>, transform: @escaping (Value) -> FluxAction) -> Binding<Value> {
        Binding {
            self.state[keyPath: keypath]
        } set: { newValue in
            self.dispatch(transform(newValue))
        }
    }
    
    func observe<S: FluxState>(statePub publisher: Published<S>.Publisher, deriveState: @escaping (S) -> State){
        token = publisher
            .map(deriveState)
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] output in
                withAnimation {
                    self?.state = output
                }
            }
    }
}
