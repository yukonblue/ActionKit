//
//  ActionObserverTests.swift
//  ActionKit
//
//  Created by yukonblue on 07/13/2022.
//

import Combine

import XCTest
@testable import ActionKit

class ActionObserverTests: XCTestCase {

    func testActionObserver() throws {
        let valueToBeUpdated = 3

        let updatedReceivedExpectation = expectation(description: "Value updated")

        let action = MyAction(
            valueToBeUpdated: valueToBeUpdated,
            expectation: updatedReceivedExpectation
        )

        let observer = ActionObserver(
            initialValue: 0,
            action: action.toAnyAction
        )

        observer.binding.wrappedValue = valueToBeUpdated

        wait(
            for: [updatedReceivedExpectation],
            timeout: TimeInterval(valueToBeUpdated)+1
        )

        XCTAssertEqual(observer.value, valueToBeUpdated)
    }

    func testActionObserverThroughTogglingOnBindingsWrappedValue() throws {
        let valueToBeUpdated = true

        let updatedReceivedExpectation = expectation(description: "Value updated")

        let action = MyAction(
            valueToBeUpdated: valueToBeUpdated,
            expectation: updatedReceivedExpectation
        )

        let observer = ActionObserver(initialValue: false, action: action.toAnyAction)

        // Here we update the value this way instead of through assignment
        observer.binding.wrappedValue.toggle()

        wait(for: [updatedReceivedExpectation], timeout: 2)

        XCTAssertEqual(observer.value, valueToBeUpdated)
    }
}

extension ActionObserverTests {

    struct MyStruct {
        @ActionObserver var count: Int = 0
    }

    func test_actionObserverAsPropertyWrapper_andUpdateValueThroughProperty() throws {
        try _test_actionObserverAsPropertyWrapper { myStruct, valueToBeUpdated in
            myStruct.count = valueToBeUpdated
        }
    }

    func test_actionObserverAsPropertyWrapper_andUpdateValueThroughAction() throws {
        try _test_actionObserverAsPropertyWrapper { myStruct, valueToBeUpdated in
            myStruct.$count.action.update(value: valueToBeUpdated)
        }
    }

    func test_actionObserverAsPropertyWrapper_andUpdateValueThroughBinding() throws {
        try _test_actionObserverAsPropertyWrapper { myStruct, valueToBeUpdated in
            myStruct.$count.binding.wrappedValue = valueToBeUpdated
        }
    }

    private func _test_actionObserverAsPropertyWrapper(
        withUpdateHandler updateHandler: (MyStruct, Int) -> Void
    ) throws {
        let myStruct = MyStruct()

        // Check the initial value on the property.
        XCTAssertEqual(myStruct.count, 0)

        let valueToBeUpdated = 3

        let updatedReceivedExpectation = expectation(description: "Value updated")

        let action = MyAction(
            valueToBeUpdated: valueToBeUpdated,
            expectation: updatedReceivedExpectation
        )

        // Update the action on the struct to be the new action.
        myStruct.$count.action = action.toAnyAction

        updateHandler(myStruct, valueToBeUpdated)

        wait(
            for: [updatedReceivedExpectation],
            timeout: TimeInterval(valueToBeUpdated)+1
        )

        // Check the updated value of the property.
        XCTAssertEqual(myStruct.count, valueToBeUpdated)
    }
}

fileprivate class MyAction<Value: Equatable>: Action {

    private let subject: PassthroughSubject<Value, Never>

    private let valueToBeUpdated: Value
    private let expectation: XCTestExpectation

    init(
        valueToBeUpdated: Value,
        expectation: XCTestExpectation
    ) {
        self.valueToBeUpdated = valueToBeUpdated
        self.expectation = expectation

        self.subject = PassthroughSubject<Value, Never>()
    }

    var publisher: AnyPublisher<Value, Never> {
        subject.eraseToAnyPublisher()
    }

    func update(value: Value) {
        let queue = OperationQueue()
        queue.addOperation({
            self.delay(by: value)

            if value == self.valueToBeUpdated {
                self.subject.send(value)
                self.expectation.fulfill()
                self.subject.send(completion: .finished)
            }
        })
    }

    private func delay(by value: Value) {
        sleep(1)
    }

    private func delay(by value: Value) where Value == Int {
        sleep(UInt32(value))
    }
}
