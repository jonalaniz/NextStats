//
//  BaseDataSource.swift
//  NextStats
//
//  Created by Jon Alaniz on 6/27/25.
//  Copyright © 2025 Jon Alaniz. All rights reserved.
//

import UIKit

protocol BaseDataSource: UITableViewDataSource {
    var sections: [TableSection] { get set }
}
