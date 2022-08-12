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
    
    public let dispatch : FluxDispatch
    
    public init(state: State, dispatch: @escaping FluxDispatch){
        self.state = state
        self.dispatch = dispatch
    }
    
    var token : AnyCancellable?
    
    deinit {
        token?.cancel()
    }
    
    public func binding<Value>(for keypath: KeyPath<State, Value>, transform: @escaping (Value) -> FluxAction) -> Binding<Value> {
        Binding {
            self.state[keyPath: keypath]
        } set: { newValue in
            Task {
                await self.dispatch(transform(newValue))
            }
        }
    }
    
    func observe<S: FluxState>(stateSubject subject: CurrentValueSubject<S, Never>, deriveState: @escaping (S) -> State){
        token = subject
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
