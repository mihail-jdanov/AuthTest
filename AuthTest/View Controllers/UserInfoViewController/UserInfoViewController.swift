//
//  UserInfoViewController.swift
//  AuthTest
//
//  Created by Михаил Жданов on 28.09.2022.
//

import UIKit
import SkeletonView

class UserInfoViewController: UIViewController {
    
    private let networkManager = NetworkManager()
    private let cellReuseIdentifier = "UITableViewCell"
    private let tableViewSkeletonRowsNumber = 21
    
    private let indicatorView = UIActivityIndicatorView(style: .medium)
        
    private var userData: UserData? {
        didSet {
            refreshWithUserData()
        }
    }

    @IBOutlet private weak var roleIdLabel: UILabel!
    @IBOutlet private weak var usernameLabel: UILabel!
    @IBOutlet private weak var emailLabel: UILabel!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var permissionsLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Инфо о пользователе"
        setupIndicator()
        setupTableView()
        fetchUserInfo()
        DispatchQueue.main.async {
            self.userData = self.networkManager.lastUserData
        }
    }
    
    private func setupIndicator() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: indicatorView)
        indicatorView.hidesWhenStopped = true
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
    }
    
    private func refreshWithUserData() {
        roleIdLabel.text = "roleId: " + (userData?.roleId ?? "–")
        usernameLabel.text = "username: " + (userData?.username ?? "–")
        emailLabel.text = "email: " + (userData?.email ?? "–")
        [roleIdLabel, usernameLabel, emailLabel, permissionsLabel].forEach {
            userData == nil ? $0?.showAnimatedGradientSkeleton() : $0?.hideSkeleton()
        }
        tableView.reloadData()
    }
    
    private func showErrorAlert(_ error: Error) {
        UIAlertController.presentErrorAlert(
            error,
            title: "Ошибка обновления данных",
            retryHandler: {
                self.fetchUserInfo()
            },
            closeHandler: self.userData == nil ? nil : {}
        )
    }
    
    private func fetchUserInfo() {
        indicatorView.startAnimating()
        networkManager.fetchUserInfo(completion: { error, userData in
            DispatchQueue.main.async {
                self.indicatorView.stopAnimating()
                if let error = error {
                    self.showErrorAlert(error)
                } else {
                    self.userData = userData
                }
            }
        })
    }

}

extension UserInfoViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userData?.permissions.count ?? tableViewSkeletonRowsNumber
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath)
        let label = cell.textLabel
        label?.isSkeletonable = true
        label?.text = userData?.permissions[indexPath.row] ?? " "
        userData == nil ? label?.showAnimatedGradientSkeleton() : label?.hideSkeleton()
        return cell
    }
    
}
