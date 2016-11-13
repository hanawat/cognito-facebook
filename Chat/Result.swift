//
//  Result.swift
//  Chat
//
//  Created by Hanawa Takuro on 2016/11/14.
//  Copyright © 2016年 Hanawa Takuro. All rights reserved.
//

import Foundation

public enum Result<T, E: Error> {
    case success(T)
    case failure(E)

    var value: T? {
        switch self {
        case .success(let value):
            return value
        case .failure:
            return nil
        }
    }

    var error: E? {
        switch self {
        case .success:
            return nil
        case .failure(let error):
            return error
        }
    }
}
