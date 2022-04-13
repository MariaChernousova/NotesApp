//
//  NotesTableViewController.swift
//  hw13
//
//  Created by Chernousova Maria on 25.10.2021.
//

import UIKit

protocol NotesViewControllerRepresentable: AnyObject {
    func endRefreshing() 
    func apply(notes: [NoteAdapter])
    func handleError(title: String, message: String)
}

final class NotesTableViewController: UIViewController {
    enum Section {
        case main
    }

    class DataSource: UITableViewDiffableDataSource<Section, NoteAdapter> {
        override func tableView(_ tableView: UITableView,
                                canEditRowAt indexPath: IndexPath) -> Bool {
            return true
        }
    }

    private enum Constant {
        static let navigationItemTitle = "Notes"
        static let defaultNoteTitle = "New note"
    }

    private let presenter: NotesTablePresenter
    
    private lazy var dataSource = DataSource(tableView: tableView) { [weak self] tableView, indexPath, note in
        self?.providerCell(tableView: tableView, indexPath: indexPath, note: note)
    }

    private lazy var tableView = UITableView(frame: .zero)
    private lazy var insertRowBarButtonItem: UIBarButtonItem = {
        var barButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
                                            target: self,
                                            action: #selector(insertRowBarButtonItemTapped))
        barButtonItem.isEnabled = false
        return barButtonItem
    }()

    private lazy var refreshControl: UIRefreshControl = {
        let control = UIRefreshControl(frame: .zero)
        control.addTarget(self,
                          action: #selector(handleRefreshControl),
                          for: .valueChanged)
        return control
    }()

    private lazy var sortByNameBarButtonItem: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem(title: GlobalConstants.sortByNameBarButtonItemTitle,
                                            style: .done,
                                            target: self,
                                            action: #selector(sortByNameBarButtonItemTapped))
        return barButtonItem
    }()

    private lazy var sortByDateBarButtonItem: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem(title: GlobalConstants.sortByDateBarButtonItemTitle,
                                            style: .done,
                                            target: self,
                                            action: #selector(sortByDateBarButtonItemTapped))
        return barButtonItem
    }()
    
    init(presenter: NotesTablePresenter) {
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
    }

    override func viewWillAppear(_ animated: Bool) {
        presenter.load()
    }

    private func setupSubviews() {
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = dataSource

        tableView.rowHeight = UITableView.automaticDimension
        tableView.sectionHeaderHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = GlobalConstants.tableViewRowHeight

        tableView.registerCell(CustomTableViewCell.self)

        tableView.backgroundColor = .systemBackground
        tableView.refreshControl = refreshControl

        view.backgroundColor = .systemBackground

        navigationItem.title = Constant.navigationItemTitle
        navigationItem.rightBarButtonItem = insertRowBarButtonItem
        toolbarItems = [
            sortByNameBarButtonItem,
            UIBarButtonItem.flexibleSpace(),
            sortByDateBarButtonItem
        ]
    }

    private func setupAutoLayout() {
        tableView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    private func providerCell(tableView: UITableView,
                              indexPath: IndexPath,
                              note: NoteAdapter) -> UITableViewCell? {
        let cell = tableView
                .dequeueReusableCell(withIdentifier: CustomTableViewCell.id,
                                     for: indexPath)
        var content = cell.defaultContentConfiguration()
        content.text = note.name
        cell.contentConfiguration = content

        return cell
    }

    @objc private func insertRowBarButtonItemTapped() {
        insertRowBarButtonItem.isEnabled = false
        presenter.insertNote(with: Constant.defaultNoteTitle)
    }

    @objc private func handleRefreshControl() {
        refreshControl.beginRefreshing()
        presenter.load()
    }

    @objc private func sortByNameBarButtonItemTapped() {
        presenter.sortByName()
    }

    @objc private func sortByDateBarButtonItemTapped() {
        presenter.sortByDate()
    }
    
    deinit {
        print("\(String(describing: self)) deinit")
    }
}

extension NotesTableViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        presenter.selectNote(at: indexPath)
    }

    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive,
                                              title: GlobalConstants
                                                .trailingSwipeActionTitle) { [weak presenter] _, _, completion in
            presenter?.deleteNote(at: indexPath)
            completion(true)
        }

        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}

extension NotesTableViewController: NotesViewControllerRepresentable {
    func endRefreshing() {
        refreshControl.endRefreshing()
        insertRowBarButtonItem.isEnabled = true
    }
    
    func apply(notes: [NoteAdapter]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, NoteAdapter>()
        snapshot.appendSections([.main])
        snapshot.appendItems(notes, toSection: .main)
        dataSource.apply(snapshot)
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
}
