//
//  LoginViewController.swift
//  DetailLayer
//
//  Created by Alessandro Comparini on 30/08/23.
//

import UIKit
import CustomComponentsSDK
import DSMMain
import ProfilePresenters


public protocol LoginViewControllerCoordinator: AnyObject {
    func gotoHome()
    func gotoLogin()
}

public final class LoginViewController: UIViewController {
    public weak var coordinator: LoginViewControllerCoordinator?
    
    private let loginPresenter: LoginPresenter
    
    public init(loginPresenter: LoginPresenter) {
        self.loginPresenter = loginPresenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var screen: LoginView = {
        let view = LoginView()
        return view
    }()
    
    
    //  MARK: - LIFE CYCLE
    
    public override func loadView() {
        self.view = self.screen
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
        screen.delegate = self
    }
    
    
}


//  MARK: - EXTENSION - LoginViewDelegate
extension LoginViewController: LoginViewDelegate {
    
    func signInTapped() {
        coordinator?.gotoHome()
    }
    
    func signUpTapped() {
        coordinator?.gotoLogin()
    }
    
}


