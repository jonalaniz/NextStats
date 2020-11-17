//
//  InfoViewController.swift
//  NextStats
//
//  Created by Jon Alaniz on 11/8/20.
//  Copyright © 2020 Jon Alaniz. All rights reserved.
//

import UIKit

class InfoViewController: UITableViewController {
    let infoModel = InfoModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Setup Top Bar
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissController))
        
    }
    
    @objc func dismissController() {
        dismiss(animated: true, completion: nil)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return infoModel.getNumberOfSections()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return infoModel.getNumberOfRowsInSection(section: section)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        cell.textLabel?.text = infoModel.getTitleFor(row: indexPath.row, inSection: indexPath.section)
        cell.detailTextLabel?.text = infoModel.getDetailsFor(row: indexPath.row, inSection: indexPath.section)

        return cell
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return infoModel.getSectionTitle(for: section)
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return infoModel.getSectionFooter(for: section)
    }
}
