//
//  ActionObserver.swift
//  ActionKit
//
//  Created by yukonblue on 07/13/2022.
//

import SwiftUI
import Combine

//@propertyWrapper
public class ActionObserver<Value> {

//    public typealias PublisherType = AnyPublisher<Value, Never>

    public private(set) var value: Value

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
