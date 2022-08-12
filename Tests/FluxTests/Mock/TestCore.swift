//
//  File.swift
//  
//
//  Created by BJ Beecher on 12/8/21.
//

import Foundation
import Flux

typealias TestStore = FluxStore<TestState, TestEnvironment>

struct TestState : FluxState {
    var isLoading = false
}

class TestEnvironment : FluxEnvironment {}

func reduce(state: TestState, action: FluxAction) -> TestState {
    var newState = state
    
    switch action {
        case is ViewDidAppear:
            newState.isLoading = true
        
        default: break
    }
    
    return state
}

struct ViewDidAppear : FluxAction {}

class AsyncAction : FluxActionCreator<TestState, TestEnvironment> {
    override func execute(state: @autoclosure () -> TestState, env: TestEnvironment, dispatch: @escaping FluxDispatch) async {
        do {
            try await Task.sleep(nanoseconds: 5_000_000_000)
            await dispatch(ViewDidAppear())
        } catch {
            print(error)
        }
    }
}

let loggingMiddleware : FluxMiddleware<TestState, TestEnvironment> = { state, action, environment in
    print(action)
}

let analyticsMiddleware : FluxMiddleware<TestState, TestEnvironment> = { state, action, environment in
    print("Hi")
}
