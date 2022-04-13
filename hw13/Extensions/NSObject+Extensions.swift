//
//  NSObject+Extensions.swift
//  hw13
//
//  Created by Chernousova Maria on 25.10.2021.
//

import Foundation

extension NSObject {
  static var id: String { "\(String(describing: self))Identifier" }
}
