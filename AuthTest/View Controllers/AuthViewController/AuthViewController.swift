//
//  AuthViewController.swift
//  AuthTest
//
//  Created by Михаил Жданов on 22.09.2022.
//

import UIKit

class AuthViewController: UIViewController {
    
    private let networkManager = NetworkManager()
    
    private var loaderVC: UIViewController?
    
    private var isLoginAndPasswordEntered: Bool {
        let login = loginTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        return !login.isEmpty && !password.isEmpty
    }
    
    @IBOutlet private weak var loginTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    @IBOutlet private weak var authButton: UIButton!
    @IBOutlet private weak var authButtonBottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addObservers()
        loginTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    private func addObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    private func moveAuthButton(byKeyboardHeight keyboardHeight: CGFloat) {
        authButtonBottomConstraint.constant = keyboardHeight + 32
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc
    private func keyboardWillShow(_ notification: Notification) {
        let nsValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
        let keyboardHeight = nsValue?.cgRectValue.height ?? 0
        moveAuthButton(byKeyboardHeight: keyboardHeight - view.safeAreaInsets.bottom)
    }
    
    @objc
    private func keyboardWillHide(_ notification: Notification) {
        moveAuthButton(byKeyboardHeight: 0)
    }
    
    private func updateAuthButtonAppearance() {
        authButton.isEnabled = isLoginAndPasswordEntered
    }
    
    private func showErrorAlert(_ error: Error) {
        UIAlertController.presentErrorAlert(
            error,
            title: "Ошибка авторизации",
            retryHandler: nil,
            closeHandler: {
                self.loaderVC?.dismiss(animated: true, completion: nil)
            }
        )
    }
    
    private func authorize() {
        guard isLoginAndPasswordEntered else { return }
        loaderVC = LoaderViewController.present(over: self)
        networkManager.authorize(
            username: loginTextField.text ?? "",
            password: passwordTextField.text ?? "",
            completion: { error in
                DispatchQueue.main.async {
                    if let error = error {
                        self.showErrorAlert(error)
                    } else {
                        self.presentUserInfo()
                    }
                }
            }
        )
    }
    
    private func presentUserInfo() {
        let navController = UINavigationController()
        navController.modalTransitionStyle = .crossDissolve
        navController.modalPresentationStyle = .fullScreen
        navController.viewControllers = [UserInfoViewController()]
        UIViewController.topViewController()?.present(navController, animated: true, completion: nil)
    }
    
}

private extension AuthViewController {
    
    @IBAction func loginTextFieldChangedAction(_ sender: Any) {
        updateAuthButtonAppearance()
    }
    
    @IBAction func passwordTextFieldChangedAction(_ sender: Any) {
        updateAuthButtonAppearance()
    }
    
    @IBAction func authButtonAction(_ sender: Any) {
        authorize()
    }
    
}

extension AuthViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case loginTextField:
            passwordTextField.becomeFirstResponder()
        case passwordTextField:
            authorize()
        default:
            break
        }
        return true
    }
    
}
