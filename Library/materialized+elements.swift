//
//  materialized+elements.swift
//  RxSwiftBook3Samples
//
//  Created by Yoshinori Imajo on 2019/01/01.
//  Copyright © 2019 Yoshinori Imajo. All rights reserved.
//

import Foundation
import RxSwift

extension RxSwift.ObservableType where E: RxSwift.EventConvertible {

    public func elements() -> RxSwift.Observable<E.ElementType> {
        return filter { $0.event.element != nil }
            .map { $0.event.element! }
    }

    public func errors() -> RxSwift.Observable<Swift.Error> {
        return filter { $0.event.error != nil }
            .map { $0.event.error! }
    }
}
