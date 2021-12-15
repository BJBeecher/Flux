    import XCTest
    @testable import Flux

    final class FluxTests: XCTestCase {
        let store : TestStore = {
            TestStore(initialState: .init(), reducer: reduce, middlewares: [loggingMiddleware, analyticsMiddleware], environment: .init())
        }()
        
        func testSynch() async {
            await store.dispatch(ViewDidAppear())
            
            let newState = await store.state.isLoading
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                XCTAssertEqual(newState, true)
            }
        }
    }
