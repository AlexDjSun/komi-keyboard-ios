// KeyboardHeightDetector.swift

import UIKit

class Calculator {
    /**
     @return height of the view containing the keyboard buttons
     */
    static func getKeyboardHeight(isLandscape: Bool) -> CGFloat {
        if UIDevice.current.userInterfaceIdiom == .phone {
            if #available(iOSApplicationExtension 26.0, *) {
                return isLandscape ? 162 : 225
            }
            return isLandscape ? 162 : 216
        }
        return isLandscape ? 353 : 265
    }
    
    /**
     @return the height of the  toolbar
     */
    static func getToolbarHeight(isLandscape: Bool) -> CGFloat {
        if UIDevice.current.userInterfaceIdiom == .phone {
            if #available(iOSApplicationExtension 26.0, *) {
                return isLandscape ? 38 : 46
            }
            return isLandscape ? 38 : 45
        }
        return 55
    }
}
