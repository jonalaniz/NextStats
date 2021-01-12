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
}

extension InfoViewController {
    // TableView Overrides
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return infoModel.numberOfSections()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return infoModel.numberOfRows(in: section)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        if indexPath.section == 2 {
            cell.accessoryType = .disclosureIndicator
        }
        
        cell.textLabel?.text = infoModel.titleLabelFor(row: indexPath.row, section: indexPath.section)
        cell.detailTextLabel?.text = infoModel.detailLabelFor(row: indexPath.row, section: indexPath.section)

        return cell
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return infoModel.title(for: section)
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return infoModel.footer(for: section)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.section {
        case 2:
            // Show proper license information
            let vc = WebViewController()
            vc.passedURLString = infoModel.licenseURLFor(row: indexPath.row)
            self.navigationController?.pushViewController(vc, animated: true)
        default:
            return
        }
    }
}
