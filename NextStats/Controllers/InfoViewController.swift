//
//  InfoViewController.swift
//  NextStats
//
//  Created by Jon Alaniz on 11/8/20.
//  Copyright © 2020 Jon Alaniz. All rights reserved.
//

import UIKit

class InfoViewController: UITableViewController {
    
    let sections = ["Development", "Translations", "License", "Support NextStats"]
    let developmentTitles = ["Developer"]
    let developmentDescriptions = ["Jon Alaniz"]
    let translationTitles = ["", ""]
    let licenseTitles = ["MIT License", "GNU AGPLv3 License"]
    let supportTitles = ["Small Tip", "Medium Tip", "Large Tip", "Big Chungus Tip"]

    override func viewDidLoad() {
        super.viewDidLoad()

        // Setup Top Bar
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissController))
        
    }
    
    @objc func dismissController() {
        dismiss(animated: true, completion: nil)
    }
    
    func getArrayFor(section: Int) -> [String] {
        switch section {
        case 0:
            return developmentTitles
        case 1:
            return translationTitles
        case 2:
            return licenseTitles
        case 3:
            return supportTitles
        default:
            return []
        }
    }
    
    func getDetailArrayFor(section: Int, row: Int) -> String? {
        switch section {
        case 0:
            return developmentDescriptions[row]
        default:
            return ""
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        getArrayFor(section: section).count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        cell.textLabel?.text = getArrayFor(section: indexPath.section)[indexPath.row]
        
        if let detailText = getDetailArrayFor(section: indexPath.section, row: indexPath.row) {
            cell.detailTextLabel?.text = detailText
        }
        

        return cell
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch section {
        case 2:
            return "NextStats is provided under the MIT License. Nextcloud itself is provided by Nextcloud GmbH under the AGPLv3 License"
        case 3:
            return "NextStats is and will always be free. If you find the app usefull, please considering leaving a tip to help further its development."
        default:
            return ""
        }
    }
}
