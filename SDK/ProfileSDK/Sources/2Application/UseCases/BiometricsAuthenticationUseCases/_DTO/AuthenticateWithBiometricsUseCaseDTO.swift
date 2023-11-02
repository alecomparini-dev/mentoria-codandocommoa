//  Created by Alessandro Comparini on 02/11/23.
//

import Foundation

public struct AuthenticateWithBiometricsUseCaseDTO {
    public let isAuthenticatedByBiometry: Bool?
    public let biometricType: BiometryTypes?
    public let emailAndPassword: Bool?
}
