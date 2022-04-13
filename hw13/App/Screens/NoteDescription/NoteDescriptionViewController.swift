//
//  NoteDescriptionViewController:.swift
//  hw13
//
//  Created by Chernousova Maria on 25.10.2021.
//

import UIKit

protocol NoteDescriptionViewControllerRepresentable: AnyObject {
    func update(name: String)
    func update(content: String)
    func handleError(title: String, message: String)
}

final class NoteDescriptionViewController: UIViewController {
    private enum Constant {
        static let titleTextFieldHeight = 44.0
        static let titleTextFieldInsets = UIEdgeInsets(top: 20, left: 20, bottom: 0, right: 20)
        static let descriptionTextViewInsets = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
        static let borderWidth = 1.0
        static let navigationItemTitle = "Content"
    }
    
    private let presenter: NoteDescriptionPresenter
    
    private lazy var titleTextField: UITextField = {
        let textField = UITextField(frame: .zero)
        textField.layer.borderWidth = Constant.borderWidth
        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.addTarget(self, action: #selector(textFieldDidChanged), for: .editingChanged)
        return textField
    }()
    
    private lazy var descriptionTextView: UITextView = {
        let textView = UITextView(frame: .zero)
        textView.layer.borderWidth = Constant.borderWidth
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.delegate = self
        return textView
    }()

    
    init(presenter: NoteDescriptionPresenter) {
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
        
        presenter.load()
        
        NotificationCenter.default.addObserver(self, selector: #selector(NoteDescriptionViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(NoteDescriptionViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        presenter.save()
    }
    
    private func setupSubviews() {
        view.addSubview(titleTextField)
        view.addSubview(descriptionTextView)
        
        view.backgroundColor = .systemBackground
        navigationItem.title = Constant.navigationItemTitle
    }
    
    private func setupAutoLayout() {
        titleTextField.translatesAutoresizingMaskIntoConstraints = false
        descriptionTextView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleTextField.heightAnchor.constraint(equalToConstant: Constant.titleTextFieldHeight),
            titleTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
                                                constant: Constant.titleTextFieldInsets.top),
            titleTextField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                                                    constant: Constant.titleTextFieldInsets.left),
            titleTextField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                                                     constant: -Constant.titleTextFieldInsets.right),
            
            descriptionTextView.topAnchor.constraint(equalTo: titleTextField.bottomAnchor,
                                                     constant: Constant.descriptionTextViewInsets.top),
            descriptionTextView.leadingAnchor.constraint(equalTo: titleTextField.leadingAnchor),
            descriptionTextView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                                        constant: -Constant.descriptionTextViewInsets.bottom),
            descriptionTextView.trailingAnchor.constraint(equalTo: titleTextField.trailingAnchor)
        ])
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification
                                    .userInfo?[UIResponder
                                                .keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        
        let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardSize.height , right: 0.0)
        descriptionTextView.contentInset = contentInsets
        descriptionTextView.scrollIndicatorInsets = contentInsets
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
        
        descriptionTextView.contentInset = contentInsets
        descriptionTextView.scrollIndicatorInsets = contentInsets
    }

    @objc private func textFieldDidChanged(_ textField: UITextField) {
        guard let title = textField.text else { return }
        presenter.update(title: title)
    }
    
    deinit {
        print("\(String(describing: self)) deinit")
    }
}

extension NoteDescriptionViewController: NoteDescriptionViewControllerRepresentable {
    func update(name: String) {
        titleTextField.text = name
    }
    
    func update(content: String) {
        descriptionTextView.text = content
    }
    
    func handleError(title: String, message: String) {
        let action = UIAlertAction(title: GlobalConstants.alertActionDefaultTitle, style: .cancel)
        let alertController = UIAlertController(title: title,
                                                message: message,
                                                preferredStyle: .alert)
        alertController.addAction(action)
        present(alertController, animated: true)
    }
}

extension NoteDescriptionViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        presenter.update(content: textView.text)
    }
}
