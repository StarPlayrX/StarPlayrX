//
//  Errno.swift
//  Swifter
//
//  Copyright © 2016 Damian Kołakowski. All rights reserved.
//

import Foundation

public class Errno {
    public class func description() -> String {
        // https://forums.developer.apple.com/thread/113919
        String(cString: strerror(errno))
    }
}
