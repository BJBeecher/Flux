//
//  File.swift
//  
//
//  Created by BJ Beecher on 7/9/21.
//

import Foundation
import SwiftUI
import Combine

public final class FluxScope<State: Equatable> : ObservableObject {
    @Published public private (set) var state : State
    
    let _dispatch : FluxDispatch
    
    init(state: State, dispatch: @escaping FluxDispatch){
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
    
    func observe<T: FluxState>(statePub publisher: Published<T>.Publisher, deriveState: @escaping (T) -> State){
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
