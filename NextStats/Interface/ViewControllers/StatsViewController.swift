//
//  StatsViewController.swift
//  NextStats
//
//  Created by Jon Alaniz on 1/11/20.
//  Copyright © 2021 Jon Alaniz.
//

import UIKit

/// A view controller that displays the statistics of the corresponding Nextcloud Server
class StatsViewController: BaseDataTableViewController {
    // MARK: - Coordinator

    weak var coordinator: MainCoordinator?

    // MARK: - Properties

    private let dataSource = StatisticsDataSource()

    // MARK: - Views

    let headerView = ServerHeaderView()
    let loadingView = LoadingViewController()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        delegate = self
        tableStyle = .insetGrouped
        super.viewDidLoad()
        add(loadingView)
        tableView.isHidden = true
        tableView.dataSource = dataSource
    }

    // MARK: - Configurtion

    override func setupNavigationController() {
        let moreButton = UIBarButtonItem(
            image: UIImage(systemName: "ellipsis.circle"),
            style: .plain,
            target: self,
            action: #selector(menuTapped)
        )

        navigationItem.rightBarButtonItem = moreButton
        navigationItem.largeTitleDisplayMode = .never

        if isMacCatalyst() {
            self.navigationController?.setNavigationBarHidden(
                true, animated: true
            )
        } else {
            navigationController?.isNavigationBarHidden = false
        }
    }

    override func setupToolbar() {
        guard SystemVersion.isiOS26 else { return }
        let usersButtonView = createToolbarButton(
            image: ServerHeaderIcon.user.name,
            text: .localized(.users),
            action: #selector(userManagementPressed)
        )
        let visitButtonView = createToolbarButton(
            image: ServerHeaderIcon.safari.name,
            action: #selector(openInSafari)
        )

        toolbarItems = [
            .flexibleSpace(),
            usersButtonView,
            .fixedSpace(10),
            visitButtonView
        ]
        navigationController?.isToolbarHidden = false
    }

    override func registerCells() {
        tableView.register(
            GenericCell.self,
            forCellReuseIdentifier: GenericCell.reuseIdentifier
            )
        tableView.register(
            ProgressCell.self,
            forCellReuseIdentifier: ProgressCell.reuseIdentifier
        )
    }

    // MARK: - UI Updates

    func updateUIFor(_ newServer: NextServer) {
        headerView.setupHeaderWith(
            name: newServer.name,
            address: newServer.friendlyURL,
            image: newServer.serverImage())
        headerView.users.addTarget(
            self,
            action: #selector(userManagementPressed),
            for: .touchUpInside
        )
        headerView.visitServerButton.addTarget(
            self,
            action: #selector(openInSafari),
            for: .touchUpInside
        )
        headerView.frame.size.height = headerView.systemLayoutSizeFitting(
            UIView.layoutFittingCompressedSize
        ).height
        tableViewHeaderView = headerView
    }

    func updateDataSource(with sections: [TableSection]) {
        dataSource.sections = sections
        showTableView()
    }

    // MARK: - Visibility

    func showLoadingView() {
        guard let tableView = tableView else { return }
        tableView.isHidden = true
        add(loadingView)
    }

    private func showTableView() {
        tableView.isHidden = false
        loadingView.remove()
        tableView.reloadData()
    }

    // MARK: - Actions

    override func canPerformAction(
        _ action: Selector, withSender sender: Any?
    ) -> Bool {
        let validActions: [Selector] = [
            #selector(reload), #selector(openInSafari)
        ]
        return validActions.contains(action) && (
            dataSource.sections.isEmpty == false
        )
    }

    @objc func openInSafari() {
        coordinator?.openInSafari()
    }

    @objc func menuTapped() {
        let alertController = makeAlertController()
        present(alertController, animated: true)
    }

    @objc func reload() {
        coordinator?.reload()
    }

    @objc func userManagementPressed() {
        coordinator?.showUsersView()
    }

    // MARK: - Helper Methods

    private func createToolbarButton(
        image: String, text: String? = nil, action: Selector
    ) -> UIBarButtonItem {
        let button = UIButton(type: .system)
        button.addTarget(self, action: action, for: .touchUpInside)

        if let systemImage = UIImage(systemName: image) {
            button.setImage(systemImage, for: .normal)
        }

        if let text = text {
            button.setTitle(" \(text)", for: .normal)
            button.titleLabel?.font = .preferredFont(
                forTextStyle: .headline
            )
        }

        return UIBarButtonItem(customView: button)
    }

    private func makeAlertController() -> UIAlertController {
        let alert = UIAlertController(
            title: nil, message: nil, preferredStyle: .actionSheet
        )
        alert.addAction(UIAlertAction(
            title: .localized(.statsActionRename),
            style: .default,
            handler: showRenameSheet
        ))
        alert.addAction(UIAlertAction(
            title: .localized(.statsActionDelete),
            style: .destructive,
            handler: delete
        ))
        alert.addAction(UIAlertAction(
            title: .localized(.statsActionCancel),
            style: .cancel
        ))

        let popover = alert.popoverPresentationController

        if #available(iOS 16.0, *) {
            popover?.sourceItem = navigationItem.rightBarButtonItem
        } else {
            popover?.barButtonItem = navigationItem.rightBarButtonItem
        }

        return alert
    }
}

// MARK: - UITableViewDelegate

extension StatsViewController: UITableViewDelegate {
    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        return StatsSection(
            rawValue: indexPath.section
        )?.rowHeight ?? UITableView.automaticDimension
    }
}
