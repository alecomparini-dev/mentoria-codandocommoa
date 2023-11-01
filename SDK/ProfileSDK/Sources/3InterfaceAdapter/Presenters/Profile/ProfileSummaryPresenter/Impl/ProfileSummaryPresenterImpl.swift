//  Created by Alessandro Comparini on 18/10/23.
//

import Foundation

import ProfileUseCases

public protocol ProfileSummaryPresenterOutput: AnyObject {
    func successGetUserAuthenticated(_ profilePresenterDTO: ProfilePresenterDTO?)
    func errorGetUserAuthenticated(title: String, message: String)
    
    func successGetUserProfile(_ profilePresenterDTO: ProfilePresenterDTO?)
    func errorGetUserProfile(title: String, message: String)
    
    func successSaveProfileImage(_ profilePresenterDTO: ProfilePresenterDTO?)
    func errorSaveProfileImage(title: String, message: String)
    
    func successLogout()
    func errorLogout()
}


public class ProfileSummaryPresenterImpl: ProfileSummaryPresenter {

    public weak var outputDelegate: ProfileSummaryPresenterOutput?
    
    private let getUserAuthUseCase: GetUserAuthenticatedUseCase
    private let getProfileUseCase: GetProfileUseCase
    private let createProfileUseCase: CreateProfileUseCase
    private let logoutUseCase: LogoutUseCase
    private let masks: [TypeMasks: Masks]
    
    public init(getUserAuthUseCase: GetUserAuthenticatedUseCase, getProfileUseCase: GetProfileUseCase, createProfileUseCase: CreateProfileUseCase, logoutUseCase: LogoutUseCase, masks: [TypeMasks : Masks]) {
        self.getUserAuthUseCase = getUserAuthUseCase
        self.getProfileUseCase = getProfileUseCase
        self.createProfileUseCase = createProfileUseCase
        self.logoutUseCase = logoutUseCase
        self.masks = masks
    }
    
    public func getUserAuthenticated() {
        Task {
            do {
                let userAuth: UserAuthenticatedUseCaseDTO.Output =  try await getUserAuthUseCase.getUser()
                DispatchQueue.main.async { [weak self] in
                    self?.outputDelegate?.successGetUserAuthenticated(ProfilePresenterDTO(userIDAuth: userAuth.userIDAuth))
                }
            } catch let error {
                debugPrint(error.localizedDescription)
                DispatchQueue.main.async { [weak self] in
                    self?.outputDelegate?.errorGetUserAuthenticated(title: "Aviso", message: "Não foi possível recuperar o Usuário Logado")
                }
            }
        }
    }
    
    public func getProfile(_ userIDAuth: String) {
        Task {
            do {
                let getProfileUseCaseDTO: ProfileUseCaseDTO? = try await getProfileUseCase.getProfile(userIDAuth)
                
                var profilePresenter: ProfilePresenterDTO = MappersProfilePresenter.mapperTo(profileUseCaseDTO: getProfileUseCaseDTO)
                
                let cellPhoneMask = masks[TypeMasks.cellPhoneMask]
                profilePresenter.cellPhoneNumber = cellPhoneMask?.formatString(profilePresenter.cellPhoneNumber)
                
                let CPFMask = masks[TypeMasks.CPFMask]
                profilePresenter.cpf = CPFMask?.formatString(profilePresenter.cpf)
                
                profilePresenter.dateOfBirth = configDateOfBirth(profilePresenter.dateOfBirth)
                
                let CEPMask = masks[TypeMasks.CEPMask]
                let cep = CEPMask?.formatString(profilePresenter.address?.cep)
                profilePresenter.address?.cep = cep
                
                DispatchQueue.main.sync { [weak self] in
                    self?.outputDelegate?.successGetUserProfile(profilePresenter)
                }
                
            } catch let error {
                debugPrint(error.localizedDescription)
                DispatchQueue.main.sync { [weak self] in
                    self?.outputDelegate?.errorGetUserProfile(title: "Aviso", message: "Não foi possível recuperar o profile do usuário. Tente novamente mais tarde")
                }
            }
        }
        
    }

//    TODO: - CODIGO DUPLICADO EXTRAIR
    public func saveProfileImageData(_ profilePresenterDTO: ProfilePresenterDTO?) {
        guard let profilePresenterDTO else {return}
        
        Task {
            do {
                let profileDTO = try await createProfileUseCase.create(
                    ProfileUseCaseDTO(
                        userIDAuth: profilePresenterDTO.userIDAuth,
                        userID: profilePresenterDTO.userIDProfile,
                        name: profilePresenterDTO.name,
                        image: profilePresenterDTO.imageProfile,
                        cpf: removeMask(typeMask: .CPFMask, profilePresenterDTO.cpf),
                        phone: removeMask(typeMask: .cellPhoneMask, profilePresenterDTO.cellPhoneNumber),
                        fieldOfWork: profilePresenterDTO.fieldOfWork,
                        dateOfBirth: configDateToSave(profilePresenterDTO.dateOfBirth),
                        profileAddress: ProfileAddressUseCaseDTO(
                            cep: removeMask( typeMask: .CEPMask, profilePresenterDTO.address?.cep),
                            street: profilePresenterDTO.address?.street,
                            number: profilePresenterDTO.address?.number,
                            neighborhood: profilePresenterDTO.address?.neighborhood,
                            city: profilePresenterDTO.address?.city,
                            state: profilePresenterDTO.address?.state)
                    )
                )
                
                var profilePresenter: ProfilePresenterDTO = MapperProfileUseCaseDTOToProfilePresenterDTO.mapper(profileUseCaseDTO: profileDTO)
                let cellPhoneMask = masks[TypeMasks.cellPhoneMask]
                profilePresenter.cellPhoneNumber = cellPhoneMask?.formatString(profilePresenter.cellPhoneNumber)
                
                let CPFMask = masks[TypeMasks.CPFMask]
                profilePresenter.cpf = CPFMask?.formatString(profilePresenter.cpf)
                
                profilePresenter.dateOfBirth = configDateOfBirth(profilePresenter.dateOfBirth)
                
                let CEPMask = masks[TypeMasks.CEPMask]
                let cep = CEPMask?.formatString(profilePresenter.address?.cep)
                profilePresenter.address?.cep = cep
                
                DispatchQueue.main.sync { [weak self] in
                    self?.outputDelegate?.successSaveProfileImage(profilePresenter)
                }

            } catch let error {
                debugPrint(error.localizedDescription)
                DispatchQueue.main.sync { [weak self] in
                    self?.outputDelegate?.errorSaveProfileImage(title: "Aviso", message: "Não foi possível salvar a imagem do perfil. Favor tentar novamente mais tarde")
                }
            }
        }
        
    }
    
    public func getProfileImageData(_ profilePresenterDTO: ProfilePresenterDTO?) -> Data? {
        guard let profilePresenterDTO else {return nil}
        if let imageProfile = profilePresenterDTO.imageProfile {
            return Data(base64Encoded: imageProfile, options: .ignoreUnknownCharacters)
        }
        return nil
    }
    
    public func logout() {
        Task {
            do {
                try logoutUseCase.logout()
                DispatchQueue.main.async { [weak self] in
                    self?.outputDelegate?.successLogout()
                }
            } catch let error {
                debugPrint(error.localizedDescription)
                DispatchQueue.main.async { [weak self] in
                    self?.outputDelegate?.errorLogout()
                }
            }
        }
    }
        
    
//  MARK: - PRIVATE AREA
    
    //TODO: - CRIAR UM COMPONENT PARA CONFIGURAR DATAS -
    private func configDateOfBirth(_ date: String?) -> String? {
        guard let date else {return nil}
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        
        if let date = dateFormatter.date(from: date) {
            let outputDateFormatter = DateFormatter()
            outputDateFormatter.dateFormat = "dd/MM/yyyy"
            return outputDateFormatter.string(from: date)
        }
        
        return nil
    }
    
    private func configDateToSave(_ date: String?) -> String? {
        guard let date else {return date}
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        if let date = dateFormatter.date(from: date) {
            dateFormatter.dateFormat = "yyyy-MM-dd"
            return dateFormatter.string(from: date)
        }
        return nil
    }
    
    private func getDocumentsDirectory() -> URL? {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    }
    
    //    TODO: - CODIGO DUPLICADO EXTRAIR
    private func removeMask(typeMask: TypeMasks,_ text: String?) -> String? {
        guard let text else {return nil}
        let mask = getMask(typeMask)
        return mask?.cleanText(text)
    }
    
    //    TODO: - CODIGO DUPLICADO EXTRAIR
    private func getMask(_ typeMask: TypeMasks) -> Masks? {
        switch typeMask {
            case .cellPhoneMask:
                return masks[TypeMasks.cellPhoneMask]
            case .CPFMask:
                return masks[TypeMasks.CPFMask]
            case .dateMask:
                return masks[TypeMasks.dateMask]
            case .CEPMask:
                return masks[TypeMasks.CEPMask]
        }
    }
    
}
