import XCTest
@testable import SwiftTUI

@MainActor
private func buildView<V: View>(_ view: V) throws -> Control {
    let node = Node(view: VStack(content: view).view)
    node.build()
    return try XCTUnwrap(node.control?.children.first)
}

final class ViewBuildTests: XCTestCase {
    func test_VStack_TupleView2() throws {
        let result = MainActor.assumeIsolated {
            struct MyView: View {
                var body: some View {
                    VStack {
                        Text("One")
                        Text("Two")
                    }
                }
            }

            let control = try! buildView(MyView())

            return control.treeDescription
        }
        
        XCTAssertEqual(result, """
            → VStackControl
              → TextControl
              → TextControl
            """)
    }

    func test_conditional_VStack() throws {
        let result = MainActor.assumeIsolated {
            struct MyView: View {
                @State var value = true

                var body: some View {
                    if value {
                        VStack {
                            Text("One")
                        }
                    }
                }
            }

            let control = try! buildView(MyView())

            return control.treeDescription
        }
        
        XCTAssertEqual(result, """
            → VStackControl
              → TextControl
            """)
    }

}
