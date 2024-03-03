//
//  File.swift
//  
//
//  Created by BJ Beecher on 7/9/21.
//

import Foundation
import SwiftUI
import Combine

extension FluxStore {
    @Observable
    public final class FluxScope<Slice: Equatable> {
        private let store: FluxStore<State, Environment>
        
        public private (set) var state : Slice
        
        public init(store: FluxStore<State, Environment>, slice: Slice){
            self.store = store
            self.state = slice
        }
        
        var token : AnyCancellable?
        
        deinit {
            token?.cancel()
        }
        
        public func dispatch(_ action: any FluxAction) async {
            await store.dispatch(action)
        }
        
        public func dispatch<T: FluxActionCreator>(creator: T) async where T.State == State, T.Environment == Environment {
            await store.dispatch(creator: creator)
        }
        
        public func binding<Value>(for keypath: KeyPath<Slice, Value>, action: @escaping (Value) -> FluxAction) -> Binding<Value> {
            Binding {
                self.state[keyPath: keypath]
            } set: { newValue in
                Task {
                    await self.store.dispatch(action(newValue))
                }
            }
        }
        
        func observe(stateSubject subject: CurrentValueSubject<State, Never>, deriveState: @escaping (State) -> Slice){
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
}
