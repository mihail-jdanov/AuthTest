//
//  LoaderViewController.swift
//  AuthTest
//
//  Created by Михаил Жданов on 28.09.2022.
//

import UIKit

class LoaderViewController: UIViewController {
    
    @discardableResult
    static func present(over viewController: UIViewController) -> LoaderViewController {
        let loaderVC = LoaderViewController()
        loaderVC.modalTransitionStyle = .crossDissolve
        loaderVC.modalPresentationStyle = .overFullScreen
        viewController.present(loaderVC, animated: true, completion: nil)
        return loaderVC
    }
    
    private var indicatorView: UIActivityIndicatorView?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black.withAlphaComponent(0.5)
        createIndicator()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        indicatorView?.startAnimating()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        indicatorView?.stopAnimating()
    }
    
    private func createIndicator() {
        let indicatorView = UIActivityIndicatorView(style: .large)
        indicatorView.color = .white
        indicatorView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(indicatorView)
        NSLayoutConstraint.activate([
            indicatorView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            indicatorView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        self.indicatorView = indicatorView
    }

}
