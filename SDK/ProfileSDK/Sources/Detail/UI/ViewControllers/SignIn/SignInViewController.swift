//  Created by Alessandro Comparini on 30/08/23.
//

import UIKit
import CustomComponentsSDK
import DesignerSystemSDKComponent
import ProfilePresenters


public protocol SignInViewControllerCoordinator: AnyObject {
    func gotoHome()
    func gotoLogin()
    func gotoForgotPassword(_ userEmail: String?)
}

public final class SignInViewController: UIViewController {
    public weak var coordinator: SignInViewControllerCoordinator?
    
    private var signInPresenter: SignInPresenter
    
    public init(signInPresenter: SignInPresenter) {
        self.signInPresenter = signInPresenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var screen: SignInView = {
        let view = SignInView()
        return view
    }()
    
    
    //  MARK: - LIFE CYCLE
    
    public override func loadView() {
        self.view = screen
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getEmailKeyChain()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        biometricsFlow()
    }
    
    
    
//  MARK: - PRIVATE AREA
    private func configure() {
        configDelegate()
    }
    
    private func configDelegate() {
        screen.delegate = self
        signInPresenter.outputDelegate = self
    }
    
    private func getEmailKeyChain() {
        if let email = signInPresenter.getEmailKeyChain() {
            screen.emailLoginView.emailTextField.get.text = email
            screen.rememberSwitch.setIsOn(true)
            return
        }
        screen.emailLoginView.emailTextField.get.text = ""
        screen.rememberSwitch.setIsOn(false)
    }
    
    private func biometricsFlow() {
        if !isEmailFilledIn() { return }
        signInPresenter.biometricsFlow()
    }
    
    private func isEmailFilledIn() -> Bool {
        guard let email = screen.emailLoginView.emailTextField.get.text else {return false}
        return !email.isEmpty
    }
    
    private func loadingSignInButton(_ isLoading: Bool) {
        if isLoading {
            screen.signInButton.setShowLoadingIndicator()
            return
        }
        screen.signInButton.setHideLoadingIndicator()
    }
        
}


//  MARK: - EXTENSION - LoginViewDelegate
extension SignInViewController: SignInViewDelegate {

    func signInTapped() {
        if let email = screen.emailLoginView.emailTextField.get.text,
           let password = screen.passwordLoginView.passwordTextField.get.text {
            screen.signInButton.setShowLoadingIndicator { build in
                build
                    .setColor(hexColor: "#282a36")
                    .setHideWhenStopped(true)
            }
            let rememberEmail = screen.rememberSwitch.get.isOn
            signInPresenter.login(email: email, password: password, rememberEmail: rememberEmail)
        }
    }
    
    func signUpTapped() {
        coordinator?.gotoLogin()
    }
    
    func forgotPasswordButtonTapped() {
        coordinator?.gotoForgotPassword(screen.passwordLoginView.passwordTextField.get.text)
    }

    
}



//  MARK: - EXTENSION - LoginPresenterOutput
extension SignInViewController: SignInPresenterOutput {
    public func loadingLogin(_ isLoading: Bool) {
        loadingSignInButton(isLoading)
    }
    
    
    public func successSingIn(_ userId: String) {
        coordinator?.gotoHome()
    }

    public func errorSingIn(_ error: String) {
        let alert = UIAlertController(title: "Aviso", message: error, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        alert.addAction(action)
        present(alert, animated: true)
        screen.signInButton.setHideLoadingIndicator()
    }
    
}
