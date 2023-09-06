//
//  LoginViewController.swift
//  DetailLayer
//
//  Created by Alessandro Comparini on 30/08/23.
//

import UIKit

public protocol LoginViewControllerCoordinator: AnyObject {
    func gotoHome()
}

public final class LoginViewController: UIViewController {
    public weak var coordinator: LoginViewControllerCoordinator?
    
    lazy var login: LoginView = {
        let view = LoginView()
        return view
    }()
    
    
//  MARK: - LIFE CYCLE
    
    public override func loadView() {
        self.view = self.login
        overrideUserInterfaceStyle = .dark
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
//  MARK: - PRIVATE AREA
    private func configure() {
        configDelegate()
    }
    
    private func configDelegate() {
        login.delegate = self
    }
    
}


//  MARK: - EXTENSION - LoginViewDelegate
extension LoginViewController: LoginViewDelegate {
    
    func buttonTapped() {
        coordinator?.gotoHome()
    }
    
}


