//
//  NoopAction.swift
//  ActionKit
//
//  Created by yukonblue on 07/26/2023.
//

import Combine

public class NoopAction<Value>: Action {

    public init() {}

    public var publisher: AnyPublisher<Value, Never> {
        Empty().eraseToAnyPublisher()
    }

    public func update(value: Value) {}
}
