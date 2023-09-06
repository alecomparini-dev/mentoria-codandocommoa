//
//  File.swift
//  
//
//  Created by Alessandro Comparini on 05/09/23.
//

import SwiftUI

class LoginViewControllerPreview {
    
    //  MARK: - PREVIEW AREA

    #if DEBUG
    struct ButtonBuilderPreview_SwiftUI: PreviewProvider {
        static var previews: some View {
            LoginViewController()
            .asSwiftUIViewController
        }
    }
    #endif

    
}
