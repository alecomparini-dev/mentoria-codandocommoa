//  Created by Alessandro Comparini on 30/08/23.
//

import UIKit
import DesignerSystemSDKComponent
import CustomComponentsSDK


protocol SignInViewDelegate: AnyObject {
    func signInTapped()
    func signUpTapped()
    func forgotPasswordButtonTapped()
}

class SignInView: UIView {
    weak var delegate: SignInViewDelegate?
    
    init() {
        super.init(frame: .zero)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
        
//  MARK: - LAZY AREA
    
    lazy var backgroundView: CustomView = {
        let comp = CustomView()
            .setAutoLayout { build in
                build
                    .pin.equalToSuperview()
            }
        return comp
    }()
    
    lazy var signInCustomTextTitle: CustomTextTitle = {
        let comp = CustomTextTitle()
            .setText("Entrada")
            .setTextAlignment(.center)
            .setConstraints { build in
                build
                    .setTop.equalToSafeArea(24)
                    .setLeading.setTrailing.equalToSafeArea(16)
            }
        return comp
    }()
    
    lazy var emailLoginView: EmailLoginTextFieldView = {
        let comp = EmailLoginTextFieldView()
            .setConstraints { build in
                build
                    .setTop.equalTo(signInCustomTextTitle.get, .bottom, 56)
                    .setLeading.setTrailing.equalTo(signInCustomTextTitle.get)
                    .setHeight.equalToConstant(80)
            }
        return comp
    }()
    
    lazy var passwordLoginView: PasswordLoginTextFieldView = {
        let comp = PasswordLoginTextFieldView()
            .setConstraints { build in
                build
                    .setTop.equalTo(emailLoginView.get, .bottom, 24)
                    .setLeading.setTrailing.equalTo(emailLoginView.get)
                    .setHeight.equalToConstant(80)
            }
        return comp
    }()
    
    lazy var rememberSwitch: CustomSwitchSecondary = {
        let comp = CustomSwitchSecondary()
            .setConstraints { build in
                build
                    .setTop.equalTo(passwordLoginView.get, .bottom, 24)
                    .setLeading.equalTo(passwordLoginView.get, .leading)
            }
        return comp
    }()

    lazy var rememberText: CustomTextSecondary = {
        let label = CustomTextSecondary()
            .setText("Lembrar")
            .setConstraints { build in
                build
                    .setLeading.equalTo(rememberSwitch.get, .trailing, 8)
                    .setVerticalAlignmentY.equalTo(rememberSwitch.get)
            }
        return label
    }()
    
    lazy var forgotPasswordButton: CustomButtonSecondary = {
        let comp = CustomButtonSecondary("Esqueceu a senha?")
            .setTitleSize(13)
            .setAlpha(0.8)
            .setBorder({ build in
                build.setWidth(0)
            })
            .setConstraints { build in
                build
                    .setVerticalAlignmentY.equalTo(rememberText.get)
                    .setTrailing.equalTo(passwordLoginView.passwordTextField.get, .trailing, -4)
                    .setHeight.equalToConstant(25)
            }
        comp.get.addTarget(self, action: #selector(forgotPasswordButtonTapped), for: .touchUpInside)
        return comp
    }()
    @objc private func forgotPasswordButtonTapped() {
        delegate?.forgotPasswordButtonTapped()
    }
    
    lazy var signInButton: CustomButtonPrimary = {
        let comp = CustomButtonPrimary("Entrar")
            .setConstraints { build in
                build
                    .setTop.equalTo(rememberSwitch.get, .bottom, 48)
                    .setLeading.setTrailing.equalToSafeArea(44)
                    .setHeight.equalToConstant(48)
            }
        comp.get.addTarget(self, action: #selector(signInTapped), for: .touchUpInside)
        return comp
    }()
    @objc private func signInTapped() {
        delegate?.signInTapped()
    }
    
    lazy var signUpButton: CustomButtonSecondary = {
        let comp = CustomButtonSecondary("Cadastra-se")
            .setConstraints { build in
                build
                    .setTop.equalTo(signInButton.get, .bottom, 16)
                    .setLeading.setTrailing.setHeight.equalTo(signInButton.get)
            }
        comp.get.addTarget(self, action: #selector(signUpTapped), for: .touchUpInside)
        return comp
    }()
    @objc private func signUpTapped() {
        delegate?.signUpTapped()
    }
    

//  MARK: - PRIVATE AREA
    public func configure() {
        setBackgroundColor(hexColor: "#282A35")
        addElements()
        configConstraints()
    }
    
    private func addElements() {
        backgroundView.add(insideTo: self)
        signInCustomTextTitle.add(insideTo: self)
        emailLoginView.add(insideTo: self)
        passwordLoginView.add(insideTo: self)
        rememberSwitch.add(insideTo: self)
        rememberText.add(insideTo: self)
        forgotPasswordButton.add(insideTo: self)
        signInButton.add(insideTo: self)
        signUpButton.add(insideTo: self)
    }
    
    private func configConstraints() {
        backgroundView.applyAutoLayout()
        signInCustomTextTitle.applyConstraint()
        emailLoginView.applyConstraint()
        passwordLoginView.applyConstraint()
        rememberSwitch.applyConstraint()
        rememberText.applyConstraint()
        forgotPasswordButton.applyConstraint()
        signInButton.applyConstraint()
        signUpButton.applyConstraint()
    }
    
    
}
