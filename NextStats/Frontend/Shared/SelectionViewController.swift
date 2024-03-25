//
//  SelectionViewController.swift
//  NextStats
//
//  Created by Jon Alaniz on 3/24/24.
//  Copyright © 2024 Jon Alaniz. All rights reserved.
//

import UIKit

enum SelectionType {
    case groups, subAdmin, quota
}

/// Creates a TableView with one section, displays
class SelectionViewController: UITableViewController {
    weak var delegate: SelectionViewDelegate?
    let selectionType: SelectionType
    var selectable: [String]
    var selections = Set<String>()

    init(data: [String], type: SelectionType) {
        self.selectable = data
        self.selectionType = type
        super.init(style: .insetGrouped)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        switch selectionType {
        case .groups: title = "Groups"
        case .subAdmin: title = "Admin of"
        case .quota: title = "Quota"
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        var selected = Array(selections)
        selected.sort()

        if selectionType == .quota {
            delegate?.selected(selected[0], type: selectionType)
        } else {
            delegate?.selected(selected, type: selectionType)
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectable.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
        var content = cell.defaultContentConfiguration()
        content.text = selectable[indexPath.row]
        cell.contentConfiguration = content

        if selections.contains(selectable[indexPath.row]) { cell.accessoryType = .checkmark }

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard !selections.contains(selectable[indexPath.row]) else {
            print("\(selectable[indexPath.row]) removed")
            selections.remove(selectable[indexPath.row])
            tableView.reloadData()
            return
        }

        // If selectionType is quota, only one item is selectable
        guard selectionType != .quota else {
            print("Quota \(selectable[indexPath.row]) selected")
            selections.removeAll()
            selections.insert(selectable[indexPath.row])
            tableView.reloadData()
            navigationController?.popViewController(animated: true)
            return
        }

        print("\(selectable[indexPath.row]) selected")
        selections.insert(selectable[indexPath.row])
        tableView.reloadData()
    }
}

protocol SelectionViewDelegate: AnyObject {
    func selected(_ selected: [String], type: SelectionType)
    func selected(_ selection: String, type: SelectionType)
}
