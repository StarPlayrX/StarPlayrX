//
//  iPhone.swift
//  For Apple devices models visit: https://www.theiphonewiki.com/wiki/Models
//


import UIKit

public enum Model : String {
    
    //Simulator
    case simulator     = "simulator/sandbox",
    
    //iPod
    iPod1              = "iPod 1",
    iPod2              = "iPod 2",
    iPod3              = "iPod 3",
    iPod4              = "iPod 4",
    iPod5              = "iPod 5",
    
    //iPad2
    iPad               = "iPad 2",
    iPad3              = "iPad 3",
    iPad4              = "iPad 4",
    iPadAir            = "iPad Air ",
    iPadAir2           = "iPad Air 2",
    iPadAir3           = "iPad Air 3",
    iPad5              = "iPad 5", //iPad 2017
    iPad6              = "iPad 6", //iPad 2018
    
    //iPad Mini
    iPadMini           = "iPad Mini",
    iPadMini2          = "iPad Mini 2",
    iPadMini3          = "iPad Mini 3",
    iPadMini4          = "iPad Mini 4",
    iPadMini5          = "iPad Mini 5",
    
    //iPad Pro
    iPadPro9_7         = "iPad Pro 9.7\"",
    iPadPro10_5        = "iPad Pro 10.5\"",
    iPadPro11          = "iPad Pro 11\"",
    iPadPro12_9        = "iPad Pro 12.9\"",
    iPadPro2_12_9      = "iPad Pro 2 12.9\"",
    iPadPro3_12_9      = "iPad Pro 3 12.9\"",
    
    //iPhone
    iPhone4            = "iPhone 4",
    iPhone4S           = "iPhone 4S",
    iPhone5            = "iPhone 5",
    iPhone5S           = "iPhone 5S",
    iPhone5C           = "iPhone 5C",
    iPhone6            = "iPhone 6",
    iPhone6Plus        = "iPhone 6 Plus",
    iPhone6S           = "iPhone 6S",
    iPhone6SPlus       = "iPhone 6S Plus",
    iPhoneSE           = "iPhone SE",
    iPhone7            = "iPhone 7",
    iPhone7Plus        = "iPhone 7 Plus",
    iPhone8            = "iPhone 8",
    iPhone8Plus        = "iPhone 8 Plus",
    iPhoneX            = "iPhone X",
    iPhoneXS           = "iPhone XS",
    iPhoneXSMax        = "iPhone XS Max",
    iPhoneXR           = "iPhone XR",
    
    //Apple TV
    AppleTV            = "Apple TV",
    AppleTV_4K         = "Apple TV 4K",
    unrecognized       = "?unrecognized?"
}

// #-#-#-#-#-#-#-#-#-#-#-#-#
// MARK: UIDevice extensions
// #-#-#-#-#-#-#-#-#-#-#-#-#

public extension UIDevice {
    
    var type: Model {
        var systemInfo = utsname()
        uname(&systemInfo)
        let modelCode = withUnsafePointer(to: &systemInfo.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: 1) {
                ptr in String.init(validatingUTF8: ptr)
            }
        }
        
        let modelMap : [String: Model] = [
            
            //Simulator
            "i386"      : .simulator,
            "x86_64"    : .simulator,
            
            //iPod
            "iPod1,1"   : .iPod1,
            "iPod2,1"   : .iPod2,
            "iPod3,1"   : .iPod3,
            "iPod4,1"   : .iPod4,
            "iPod5,1"   : .iPod5,
            
            //iPad
            "iPad2,1"   : .iPad,//.iPad2,
            "iPad2,2"   : .iPad,//.iPad2,
            "iPad2,3"   : .iPad,//.iPad2,
            "iPad2,4"   : .iPad,//.iPad2,
            "iPad3,1"   : .iPad,//.iPad3,
            "iPad3,2"   : .iPad,//.iPad3,
            "iPad3,3"   : .iPad,//.iPad3,
            "iPad3,4"   : .iPad,//.iPad4,
            "iPad3,5"   : .iPad,//.iPad4,
            "iPad3,6"   : .iPad,//.iPad4,
            "iPad4,1"   : .iPad,//.iPadAir,
            "iPad4,2"   : .iPad,//.iPadAir,
            "iPad4,3"   : .iPad,//.iPadAir,
            "iPad5,3"   : .iPad,//.iPadAir2,
            "iPad5,4"   : .iPad,//.iPadAir2,
            "iPad6,11"  : .iPad,//.iPad5, //iPad 2017
            "iPad6,12"  : .iPad,//.iPad5,
            "iPad7,5"   : .iPad,//.iPad6, //iPad 2018
            "iPad7,6"   : .iPad,//.iPad6,
            
            //iPad Mini
            "iPad2,5"   : .iPad,//.iPadMini,
            "iPad2,6"   : .iPad,//.iPadMini,
            "iPad2,7"   : .iPad,//.iPadMini,
            "iPad4,4"   : .iPad,//.iPadMini2,
            "iPad4,5"   : .iPad,//.iPadMini2,
            "iPad4,6"   : .iPad,////.iPadMini2,
            "iPad4,7"   : .iPad,////.iPadMini3,
            "iPad4,8"   : .iPad,////.iPadMini3,
            "iPad4,9"   : .iPad,////.iPadMini3,
            "iPad5,1"   : .iPad,////.iPadMini4,
            "iPad5,2"   : .iPad,////.iPadMini4,
            "iPad11,1"  : .iPad,////.iPadMini5,
            "iPad11,2"  : .iPad,////.iPadMini5,
            
            //iPad Pro
            "iPad6,3"   : .iPad,////.iPadPro9_7,
            "iPad6,4"   : .iPad,////.iPadPro9_7,
            "iPad7,3"   : .iPad,////.iPadPro10_5,
            "iPad7,4"   : .iPad,////.iPadPro10_5,
            "iPad6,7"   : .iPad,////.iPadPro12_9,
            "iPad6,8"   : .iPad,////.iPadPro12_9,
            "iPad7,1"   : .iPad,////.iPadPro2_12_9,
            "iPad7,2"   : .iPad,////.iPadPro2_12_9,
            "iPad8,1"   : .iPad,////.iPadPro11,
            "iPad8,2"   : .iPad,////.iPadPro11,
            "iPad8,3"   : .iPad,////.iPadPro11,
            "iPad8,4"   : .iPad,////.iPadPro11,
            "iPad8,5"   : .iPad,////.iPadPro3_12_9,
            "iPad8,6"   : .iPad,////.iPadPro3_12_9,
            "iPad8,7"   : .iPad,////.iPadPro3_12_9,
            "iPad8,8"   : .iPad,////.iPadPro3_12_9,
            
            //iPad Air
            "iPad11,3"  : .iPadAir3,
            "iPad11,4"  : .iPadAir3,
            
            //iPhone
            "iPhone3,1" : .iPhone4,
            "iPhone3,2" : .iPhone4,
            "iPhone3,3" : .iPhone4,
            "iPhone4,1" : .iPhone4S,
            "iPhone5,1" : .iPhoneSE,//.iPhone5,
            "iPhone5,2" : .iPhoneSE,//.iPhone5,
            "iPhone5,3" : .iPhoneSE,//.iPhone5C,
            "iPhone5,4" : .iPhoneSE,//.iPhone5C,
            "iPhone6,1" : .iPhoneSE,//.iPhone5S,
            "iPhone6,2" : .iPhoneSE,//.iPhone5S,
            "iPhone7,1" : .iPhone8Plus,//.iPhone6Plus,
            "iPhone7,2" : .iPhone8,//.iPhone6,
            "iPhone8,1" : .iPhone8,//.iPhone6S,
            "iPhone8,2" : .iPhone8Plus,//.iPhone6SPlus,
            "iPhone8,4" : .iPhoneSE,
            "iPhone9,1" : .iPhone8,//.iPhone7,
            "iPhone9,3" : .iPhone8,//.iPhone7,
            "iPhone9,2" : .iPhone8Plus,//.iPhone7Plus,
            "iPhone9,4" : .iPhone8Plus,//.iPhone7Plus,
            "iPhone10,1" : .iPhone8,
            "iPhone10,4" : .iPhone8,
            "iPhone10,2" : .iPhone8Plus,
            "iPhone10,5" : .iPhone8Plus,
            "iPhone10,3" : .iPhoneX,
            "iPhone10,6" : .iPhoneX,
            "iPhone11,2" : .iPhoneX,//.iPhoneXS,
            "iPhone11,4" : .iPhoneXSMax,//.iPhoneXSMax,
            "iPhone11,6" : .iPhoneXSMax,//.iPhoneXSMax,
            "iPhone11,8" : .iPhoneX,//.iPhoneXR,
            "iPhone12,1" : .iPhoneX,//.iPhone 11,
            "iPhone12,3" : .iPhoneX,//.iPhone 11 Pro,
            "iPhone12,5" : .iPhoneXSMax, //.iPhone 11 Pro Max
            
            //Apple TV
            "AppleTV5,3" : .AppleTV,
            "AppleTV6,2" : .AppleTV_4K
        ]
        
        if let model = modelMap[String.init(validatingUTF8: modelCode!)!] {
            if model == .simulator {
                if let simModelCode = ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] {
                    if let simModel = modelMap[String.init(validatingUTF8: simModelCode)!] {
                        return simModel
                    }
                }
            }
            return model
        }
        return Model.unrecognized
    }
}
