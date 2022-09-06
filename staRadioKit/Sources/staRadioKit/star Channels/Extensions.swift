//
//  Extensions.swift
//  COpenSSL
//
//  Created by Todd Bruss on 5/12/20.
//

import Foundation

extension Data {
    var prettyPrintedJSONString: NSString? { /// NSString gives us a nice sanitized debugDescription
        guard let object = try? JSONSerialization.jsonObject(with: self, options: []),
            let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
            let prettyPrintedString = NSString(data: data, encoding: String.Encoding.utf8.rawValue) else { return nil }
        return prettyPrintedString
    }
}

extension URL {
    func valueOf(_ queryParamaterName: String) -> String? {
        guard let url = URLComponents(string: self.absoluteString) else { return nil }
        return url.queryItems?.first(where: { $0.name == queryParamaterName })?.value
    }
}

//maybe shorten this down sometime
/*func generateJSON(data: Data) {
    
    let bytes: Data = data
    
    if  let string = String(data: bytes, encoding: .utf8),
        let str = string.data(using: .utf8)?.prettyPrintedJSONString {
        debugPrint(str)
    }
}*/
