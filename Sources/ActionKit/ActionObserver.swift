//
//  ActionObserver.swift
//  ActionKit
//
//  Created by yukonblue on 07/13/2022.
//

import Foundation
import SwiftUI
import Combine

public protocol Action: AnyObject, ActionConvertible {

    associatedtype Value

    var publisher: AnyPublisher<Value, Never> { get }

    func update(value: Value)
}

public extension Action {

    var toAnyAction: AnyAction<Value> {
        AnyAction(self)
    }
}

public protocol ActionConvertible {

    associatedtype Value

    var toAnyAction: AnyAction<Value> { get }
}

fileprivate class AnyStorage<Value> {

    var publisher: AnyPublisher<Value, Never> {
        fatalError()
    }

    func update(value: Value) {
        fatalError()
    }
}

fileprivate final class Storage<A: Action>: AnyStorage<A.Value> {

    let action: A

    init(action: A) {
        self.action = action
    }

    override var publisher: AnyPublisher<A.Value, Never> {
        self.action.publisher
    }

    override func update(value: A.Value) {
        self.action.update(value: value)
    }
}

public struct AnyAction<Value>: ActionConvertible {

    private let storage: AnyStorage<Value>

    private init(storage: AnyStorage<Value>) {
        self.storage = storage
    }

    public init<A>(_ action: A) where A.Value == Value, A: Action {
        self.init(storage: Storage<A>(action: action))
    }

    public var publisher: AnyPublisher<Value, Never> {
        self.storage.publisher
    }

    public func update(value: Value) {
        self.storage.update(value: value)
    }

    public var toAnyAction: AnyAction<Value> {
        self
    }
}

//@propertyWrapper
public class ActionObserver<Value> {

//    public typealias PublisherType = AnyPublisher<Value, Never>

    private(set) var value: Value

    private let action: AnyAction<Value>?

    private var cancellable: AnyCancellable? = nil

    public var binding: Binding<Value> {
        Binding<Value> {
            self.value
        } set: { valueToBeUpdatedTo in
            self.action?.update(value: valueToBeUpdatedTo)
        }
    }

    public init(initialValue: Value, action: AnyAction<Value>? = nil) {
        self.value = initialValue

        self.action = action

        self.cancellable = self.action?.publisher.sink { newValue in
            self.value = newValue
        }
    }
}

public class NoopAction<Value>: Action {

    private let subject = PassthroughSubject<Value, Never>()

    public var publisher: AnyPublisher<Value, Never> {
        subject.eraseToAnyPublisher()
    }

    public func update(value: Value) {
        subject.send(value)
    }
}
