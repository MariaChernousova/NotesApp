//
//  FoldersViewController.swift
//  hw13
//
//  Created by Chernousova Maria on 25.10.2021.
//

import UIKit

protocol FoldersViewControllerRepresentable: AnyObject {
    func endRefreshing()
    
    func handleError(title: String, message: String)
    
    // Fetched Result Controller
    func prepareForChanges()
    func completeChanges()
    func insert(at indexPaths: [IndexPath])
    func delete(at indexPaths: [IndexPath])
    func update(at indexPaths: [IndexPath])
}

final class FoldersViewController: UIViewController {
    
    class DataSource: UITableViewDiffableDataSource<Section, FolderAdapter> {
        override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
            return true
        }
    }
    
    enum Section {
        case main
    }
    
    enum ActionType {
        case insert
        case update
    }
    
    private enum Constant {
        static let navigationItemTitle = "Folders"
        static let infoAlertTitle = "Folder info"
        static let presentAlertTitle = "Folder"
        static let presentAlertMessage = "Enter a title for a folder"
    }
    
    private let presenter: FoldersPresentable
    
    private lazy var tableView = UITableView(frame: .zero)
    private lazy var dataSource = DataSource(tableView: tableView) { [weak self] tableView, indexPath, folder in
        self?.providerCell(tableView: tableView, indexPath: indexPath, folder: folder)
    }
  
    private lazy var insertRowBarButtonItem: UIBarButtonItem = {
        var button = UIBarButtonItem(barButtonSystemItem: .add,
                                     target: self,
                                     action: #selector(insertRowBarButtonItemTapped))
        button.isEnabled = false
        return button
    }()
    
    private lazy var refreshControl: UIRefreshControl = {
        let control = UIRefreshControl(frame: .zero)
        control.addTarget(self,
                          action: #selector(handleRefreshControl),
                          for: .valueChanged)
        return control
    }()
    
    private lazy var sortByNameBarButtonItem =
    UIBarButtonItem(title: GlobalConstants.sortByNameBarButtonItemTitle,
                    style: .done,
                    target: self,
                    action: #selector(sortByNameBarButtonItemTapped))
    
    private lazy var sortByDateBarButtonItem =
    UIBarButtonItem(title: GlobalConstants.sortByDateBarButtonItemTitle,
                    style: .done,
                    target: self,
                    action: #selector(sortByDateBarButtonItemTapped))
    
    init(presenter: FoldersPresentable) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubviews()
        setupAutoLayout()
        
        presenter.didLoad()
    }
    
    private func setupSubviews() {
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.sectionHeaderHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = GlobalConstants.tableViewRowHeight
        
        tableView.backgroundColor = .systemBackground
        tableView.refreshControl = refreshControl
        
        tableView.registerCell(CustomTableViewCell.self)
        
        view.backgroundColor = .systemBackground
        
        navigationItem.title = Constant.navigationItemTitle
        navigationItem.rightBarButtonItem = insertRowBarButtonItem
        navigationController?.isToolbarHidden = false
        
        toolbarItems = [
            UIBarButtonItem.flexibleSpace(),
            sortByNameBarButtonItem,
            UIBarButtonItem.flexibleSpace(),
            sortByDateBarButtonItem,
            UIBarButtonItem.flexibleSpace()
        ]
    }
    
    private func setupAutoLayout() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView
                .topAnchor
                .constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView
                .leadingAnchor
                .constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView
                .trailingAnchor
                .constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView
                .bottomAnchor
                .constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func providerCell(tableView: UITableView,
                              indexPath: IndexPath,
                              folder: FolderAdapter) -> UITableViewCell? {
        guard let cell = tableView
                .dequeueReusableCell(withIdentifier: CustomTableViewCell.id,
                                     for: indexPath) as? CustomTableViewCell else {
                    return nil
                }
        cell.titleLabel.text = folder.title
        cell.completionHandler = { [weak self] in
            self?.presentInfoAlert(with: folder)
        }
        return cell
    }
    
    private func presentInfoAlert(with folder: FolderAdapter) {
        let totalNotesCount = folder.totalNotesCount
        let title = folder.title
        let creationDate = DateFormatter.localizedString(from: folder.creationDate,
                                                         dateStyle: .medium,
                                                         timeStyle: .short)
        let alert = UIAlertController(title: Constant.infoAlertTitle,
                                      message: """
                                      Total notes count: \(totalNotesCount),
                                      Title: \(title),
                                      Creation date: \(creationDate)
                                    """,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: GlobalConstants.alertActionDefaultTitle,
                                      style: .default))
        present(alert, animated: true)
    }
    
    private func presentAlert(with action: ActionType, at indexPath: IndexPath?) {
        let alert = UIAlertController(title: Constant.presentAlertTitle,
                                      message: Constant.presentAlertMessage,
                                      preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.text = ""
        }
        
        alert.addAction(UIAlertAction(title: GlobalConstants.alertActionDefaultTitle,
                                      style: .default,
                                      handler: { [weak alert] _ in
            guard let textFields = alert?.textFields,
                  let textFieldFirst = textFields.first else { return }
            let textField = textFieldFirst
            guard let title = textField.text else { return }
            
            switch action {
            case .insert:
                self.presenter.insertFolder(with: title)
            case .update:
                guard let indexPath = indexPath else { return }
                
                self.presenter.updateFolder(at: indexPath, with: title)
            }
            
        }))
        
        present(alert, animated: true, completion: nil)
        
    }
    
    @objc private func insertRowBarButtonItemTapped() {
        insertRowBarButtonItem.isEnabled = false
        
        presentAlert(with: .insert, at: nil)

    }
    
    @objc private func handleRefreshControl() {
        refreshControl.beginRefreshing()
        presenter.didLoad()
    }
    
    @objc private func sortByNameBarButtonItemTapped() {
        presenter.sortByName()
    }
    
    @objc private func sortByDateBarButtonItemTapped() {
        presenter.sortByDate()
    }
}

extension FoldersViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter.numberOfRows()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        providerCell(tableView: tableView,
                     indexPath: indexPath,
                     folder: presenter.folder(for: indexPath)) ?? UITableViewCell()
    }
}

extension FoldersViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        presenter.selectFolder(at: indexPath)
    }
    
    func tableView(_ tableView: UITableView,
                   leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let updateAction =
        UIContextualAction(style: .normal,
                           title: GlobalConstants
                            .leadingSwipeActionTitle) { _, _, completion in
            self.presentAlert(with: .update, at: indexPath)
            completion(true)
        }
        
        return UISwipeActionsConfiguration(actions: [updateAction])
    }
    
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction =
        UIContextualAction(style: .destructive,
                           title: GlobalConstants
                            .trailingSwipeActionTitle) {[weak presenter] _, _, completion in
            presenter?.deleteFolder(at: indexPath)
            completion(true)
        }
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}

extension FoldersViewController: FoldersViewControllerRepresentable {
    func endRefreshing() {
        refreshControl.endRefreshing()
        insertRowBarButtonItem.isEnabled = true
    }
    
    func handleError(title: String, message: String) {
        let action = UIAlertAction(title: GlobalConstants.alertActionDefaultTitle,
                                   style: .cancel)
        let alertController = UIAlertController(title: title,
                                                message: message,
                                                preferredStyle: .alert)
        alertController.addAction(action)
        present(alertController, animated: true)
    }
    
    func prepareForChanges() {
        tableView.beginUpdates()
    }
    
    func completeChanges() {
        tableView.endUpdates()
    }
    
    func insert(at indexPaths: [IndexPath]) {
        tableView.insertRows(at: indexPaths, with: .fade)
    }
    
    func delete(at indexPaths: [IndexPath]) {
        tableView.deleteRows(at: indexPaths, with: .fade)
    }
    
    func update(at indexPaths: [IndexPath]) {
        tableView.reloadRows(at: indexPaths, with: .fade)
    }
}
