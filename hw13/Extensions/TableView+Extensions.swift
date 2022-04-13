//
//  TableView+Extensions.swift
//  hw13
//
//  Created by Chernousova Maria on 25.10.2021.
//

import UIKit

extension UITableView {
  func registerCell<T: UITableViewCell>(_ cellClass: T.Type) {
    self.register(cellClass.self, forCellReuseIdentifier: cellClass.id)
  }
}
