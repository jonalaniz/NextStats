//
//  SelectionViewController.swift
//  NextStats
//
//  Created by Jon Alaniz on 3/24/24.
//  Copyright © 2024 Jon Alaniz. All rights reserved.
//

import UIKit

final class SelectionViewController: UITableViewController {

    // MARK: - Properties

    weak var delegate: SelectionViewDelegate?
    let selectionType: SelectionType
    var selectable: [String]
    var selections: Set<String>

    // MARK: - Init

    init(data: [String], type: SelectionType, selections: [String]?) {
        self.selectable = data
        self.selectionType = type
        self.selections = Set(selections ?? [])
        super.init(style: .insetGrouped)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = selectionType.title
    }

    override func viewWillDisappear(_ animated: Bool) {
        let selected = Array(selections).sorted()

        if selectionType == .quota {
            delegate?.selected(selected[0], type: selectionType)
        } else {
            delegate?.selected(selected, type: selectionType)
        }
    }

    // MARK: UITableView Overrides

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectable.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let isSelected = selections.contains(
            selectable[indexPath.row]
        )
        return BaseTableViewCell(
            style: .default,
            text: selectable[indexPath.row],
            accessoryType: isSelected ? .checkmark : .none
        )
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = selectable[indexPath.row]

        // If selectionType is quota, only one item is selectable
        guard selectionType != .quota else {
            selections = [selectedItem]
            navigationController?.popViewController(
                animated: true
            )
            return
        }

        if selections.contains(selectedItem) {
            selections.remove(selectedItem)
        } else {
            selections.insert(selectedItem)
        }

        tableView.reloadRows(
            at: [indexPath], with: .automatic
        )
    }
}

protocol SelectionViewDelegate: AnyObject {
    func selected(_ selected: [String], type: SelectionType)
    func selected(_ selection: String, type: SelectionType)
}
