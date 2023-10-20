//  Created by Alessandro Comparini on 13/10/23.
//

import Foundation
import ProfileUI
import ProfilePresenters

class ProfileRegistrationStep2Coordinator: Coordinator {
    var childCoordinator: Coordinator?
    
    unowned let navigationController: NavigationController
    
    var dataTransfer: Any?
    
    required init(_ navigationController: NavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        childCoordinator = self
        var controller = ProfileRegistrationStep2Factory.make()
        controller = navigationController.pushViewController(controller)
        controller.setDataTransfer(dataTransfer)
        controller.coordinator = self
    }

}



//  MARK: - EXTENSION LoginViewControllerCoordinator
extension ProfileRegistrationStep2Coordinator: ProfileRegistrationStep2ViewControllerCoordinator {

    func gotoProfileRegistrationStep1(_ profilePresenterDTO: ProfilePresenterDTO?) {
        let coordinator = ProfileRegistrationStep1Coordinator(navigationController)
        coordinator.dataTransfer = profilePresenterDTO
        coordinator.start()
        childCoordinator = nil
    }
    
    func gotoProfileHomeTabBar() {
        let coodinator = HomeTabBarCoordinator(navigationController)
        coodinator.start()
        coodinator.selectedTabBarItem(0)
        childCoordinator = nil
    }
    
        
}
