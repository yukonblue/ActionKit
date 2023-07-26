//
//  ActionObserverTests.swift
//  ActionKit
//
//  Created by yukonblue on 07/13/2022.
//

import Combine

import XCTest
@testable import ActionKit

class MyAction: Action {

    private let subject: PassthroughSubject<Int, Never>

    private let valueToBeUpdated: Int
    private let expectation: XCTestExpectation

    init(valueToBeUpdated: Int, expectation: XCTestExpectation) {
        self.valueToBeUpdated = valueToBeUpdated
        self.expectation = expectation

        self.subject = PassthroughSubject<Int, Never>()
    }

    var publisher: AnyPublisher<Int, Never> {
        subject.eraseToAnyPublisher()
    }

    func update(value: Int) {
        let queue = OperationQueue()
        queue.addOperation({
            sleep(UInt32(value))

            if value == self.valueToBeUpdated {
                self.subject.send(value)
                self.expectation.fulfill()
                self.subject.send(completion: .finished)
            }
        })
    }
}

class MyAction2: Action {

    private let subject: PassthroughSubject<Bool, Never>

    private let valueToBeUpdated: Bool
    private let expectation: XCTestExpectation

    init(valueToBeUpdated: Bool, expectation: XCTestExpectation) {
        self.valueToBeUpdated = valueToBeUpdated
        self.expectation = expectation

        self.subject = PassthroughSubject<Bool, Never>()
    }

    var publisher: AnyPublisher<Bool, Never> {
        subject.eraseToAnyPublisher()
    }

    func update(value: Bool) {
        let queue = OperationQueue()
        queue.addOperation({
            sleep(1)

            if value == self.valueToBeUpdated {
                self.subject.send(value)
                self.expectation.fulfill()
                self.subject.send(completion: .finished)
            }
        })
    }
}

class ActionObserverTests: XCTestCase {

    func testActionObserver() throws {
        let valueToBeUpdated = 3

        let updatedReceivedExpectation = XCTestExpectation(description: "Value updated")

        let action = MyAction(valueToBeUpdated: valueToBeUpdated, expectation: updatedReceivedExpectation)

        let observer = ActionObserver(initialValue: 0, action: action.toAnyAction)

        observer.binding.wrappedValue = valueToBeUpdated

        wait(for: [updatedReceivedExpectation], timeout: TimeInterval(valueToBeUpdated)+1)

        XCTAssertEqual(observer.value, valueToBeUpdated)
    }

    func testActionObserverThroughTogglingOnBindingsWrappedValue() throws {
        let valueToBeUpdated = true

        let updatedReceivedExpectation = XCTestExpectation(description: "Value updated")

        let action = MyAction2(valueToBeUpdated: valueToBeUpdated, expectation: updatedReceivedExpectation)

        let observer = ActionObserver(initialValue: false, action: action.toAnyAction)

        observer.binding.wrappedValue.toggle() // Here we update the value this way instead of through assignment

        wait(for: [updatedReceivedExpectation], timeout: 2)

        XCTAssertEqual(observer.value, valueToBeUpdated)
    }
}

extension ActionObserverTests {
    
    struct MyStruct {
        @ActionObserver var count: Int = 0
    }
    
    func test_actionObserverAsPropertyWrapper_andUpdateValueThroughProperty() throws {
        let myStruct = MyStruct()
        
        // Check the initial value on the property.
        XCTAssertEqual(myStruct.count, 0)
        
        let valueToBeUpdated = 3
        
        let updatedReceivedExpectation = XCTestExpectation(description: "Value updated")
        
        let action = MyAction(valueToBeUpdated: valueToBeUpdated, expectation: updatedReceivedExpectation)
        
        myStruct.$count = action.toAnyAction
        
        myStruct.count = valueToBeUpdated
        
        wait(for: [updatedReceivedExpectation], timeout: TimeInterval(valueToBeUpdated)+1)
        
        // Check the updated value of the property.
        XCTAssertEqual(myStruct.count, valueToBeUpdated)
    }

    func test_actionObserverAsPropertyWrapper_andUpdateValueThroughAction() throws {
        let myStruct = MyStruct()

        // Check the initial value on the property.
        XCTAssertEqual(myStruct.count, 0)

        let valueToBeUpdated = 3

        let updatedReceivedExpectation = XCTestExpectation(description: "Value updated")

        let action = MyAction(valueToBeUpdated: valueToBeUpdated, expectation: updatedReceivedExpectation)

        myStruct.$count = action.toAnyAction

        myStruct.$count.update(value: valueToBeUpdated)

        wait(for: [updatedReceivedExpectation], timeout: TimeInterval(valueToBeUpdated)+1)

        // Check the updated value of the property.
        XCTAssertEqual(myStruct.count, valueToBeUpdated)
    }
}
