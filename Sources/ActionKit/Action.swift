//
//  Action.swift
//  ActionKit
//
//  Created by yukonblue on 07/26/2023.
//

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
