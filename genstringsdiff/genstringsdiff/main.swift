//
//  main.swift
//  genstringsdiff
//
//  Created by Alexandru Tudose on 25/10/2017.
//  Copyright © 2017 Tapptitude. All rights reserved.
//

import Foundation

let apps = ["/Users/alextud/Projects/Localize-Swift/genstrings.swift",
            "/Users/alextud/Projects/Localize-Swift/genstringsfromxibs/bin/genstringsfromxibs"]

var currentLocalizableStrings: [String : String] = [:]
let path: String? = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : nil
for app in apps {
    let output = path != nil ? shell(app, path!) : shell(app)
    let outputDictionary = localizableDictionary(from: output)
    
    outputDictionary.forEach({ (key, value) in
        currentLocalizableStrings[key] = value
    })
}

let genStrings = GenStringsDiff()
genStrings.perform(path: path)

