//
//  main.swift
//  genstringsfromxibs
//
//  Created by Alexandru Tudose on 09/11/2016.
//  Copyright © 2016 Tapptitude. All rights reserved.
//

import Foundation

let argument = CommandLine.arguments.count == 2 ? CommandLine.arguments[1] : "."
var filePaths:[String] = []

// storyboards
let extensions = [".storyboard", ".xib"]
if let _ = extensions.first(where: { argument.hasSuffix($0) }) {
    filePaths = [argument]
} else if let s = findFiles(argument, fileExtensions: extensions) {
    filePaths = s
}
let xibFiles = filePaths.map { XibFile(filePath: $0) }
processXibs(xibFiles)


exit(0)
