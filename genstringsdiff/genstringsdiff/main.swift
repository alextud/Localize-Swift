//
//  main.swift
//  genstringsdiff
//
//  Created by Alexandru Tudose on 25/10/2017.
//  Copyright © 2017 Tapptitude. All rights reserved.
//

import Foundation


let path: String? = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : nil
let genStrings = GenStringsDiff()
genStrings.perform(path: path)

