//
//  readLocalDataFile.swift
//  StarPlayrX
//
//  Created by Todd Bruss on 7/29/19.
//  Copyright © 2019 Todd Bruss. All rights reserved.
//

import Foundation

func readLocalDataFile(filename:String) -> Data?  {

    try? NSData(contentsOfFile: Bundle.main.path(forResource: filename, ofType: "dms")!) as Data
}
