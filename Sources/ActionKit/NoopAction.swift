//
//  NoopAction.swift
//  ActionKit
//
//  Created by yukonblue on 07/26/2023.
//

import Combine

public class NoopAction<Value>: Action {

    private let subject = PassthroughSubject<Value, Never>()

    public init() {
    }

    public var publisher: AnyPublisher<Value, Never> {
        subject.eraseToAnyPublisher()
    }

    public func update(value: Value) {
        subject.send(value)
    }
}
