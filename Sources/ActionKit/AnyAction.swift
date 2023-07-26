//
//  AnyAction.swift
//  ActionKit
//
//  Created by yukonblue on 07/26/2023.
//

import Combine

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

fileprivate class AnyStorage<Value> {

    var publisher: AnyPublisher<Value, Never> {
        fatalError()
    }

    func update(value: Value) {
        fatalError()
    }
}

fileprivate final class Storage<A: Action>: AnyStorage<A.Value> {

    private let action: A

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
