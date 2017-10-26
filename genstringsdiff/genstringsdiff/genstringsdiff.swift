#!/usr/bin/swift
/// comment code above when working from a xcode project

import Foundation

class GenStringsDiff {
    let apps = ["./genstrings.swift", "./genstringsfromxibs"]
    let mainLanguageDirectory = ["en.lproj"]
    
    let fileManager = FileManager.default
    let acceptedFileExtensions = ["strings"]
    let excludedFolderNames = ["Carthage"]
    let excludedFileNames = [""]
    
    
    // Performs the genstrings functionality
    func perform(path: String? = nil) {
        let directoryPath = path ?? fileManager.currentDirectoryPath
        let rootPath = URL(fileURLWithPath:directoryPath)
        let allFiles = fetchFilesInFolder(rootPath: rootPath).filter({
            mainLanguageDirectory.contains($0.deletingLastPathComponent().lastPathComponent)
        })
        
        let newDictionary = newLocalizedDictionary(path: path)
        
        let processedStrings = localizableString(from: newDictionary)
        guard !processedStrings.isEmpty else {
            print("============ no text found for localization ===========")
            return
        }
        
        guard !allFiles.isEmpty else {
            print("============ did not found ", mainLanguageDirectory.first ?? "en.lproj", " ===========")
            print("============ 1 create ", mainLanguageDirectory.first ?? "en.lproj", " directory ===========")
            print("============ 2 add contents below into Localizable.string ===========")
            print(processedStrings)
            return
        }
        
        //
        for filePath in allFiles {
            let fileContentsData = try! Data(contentsOf: filePath)
            guard let fileContentsString = NSString(data: fileContentsData, encoding: String.Encoding.utf8.rawValue) else {
                continue
            }
            let oldDictionary = localizableDictionary(from: fileContentsString as String)
            let diff = difference(new: newDictionary, old: oldDictionary)
            
            let processedStrings = localizableString(from: diff)
            let directoryPath = filePath.deletingLastPathComponent().lastPathComponent
            if !processedStrings.isEmpty {
                print("============ ", directoryPath, " difference ===========")
                print("== ", filePath, " ==")
                print("==== new items below that should be inserted in .string file ====\n")
                print(processedStrings)
            } else {
                print("============ no changes found in ", directoryPath, " ===========")
                print("== ", filePath, " ==\n")
            }
        }
    }
    
    func newLocalizedDictionary(path: String? = nil) -> [String: String] {
        var currentLocalizableStrings: [String : String] = [:]
        for app in apps {
            let output = path != nil ? shell(app, path!) : shell(app)
            let outputDictionary = localizableDictionary(from: output)
            
            outputDictionary.forEach({ (key, value) in
                currentLocalizableStrings[key] = value
            })
        }
        return currentLocalizableStrings
    }
    
    func difference(new: [String: String], old: [String: String]) -> [String: String] {
        var diff: [String: String] = [:]
        for (key, value) in new {
            if old[key] == nil {
                diff[key] = value
            }
        }
        
        return diff
    }
    
    //MARK: File manager
    
    func fetchFilesInFolder(rootPath: URL) -> [URL] {
        var files = [URL]()
        do {
            let directoryContents = try fileManager.contentsOfDirectory(at: rootPath as URL, includingPropertiesForKeys: [], options: .skipsHiddenFiles)
            for urlPath in directoryContents {
                let stringPath = urlPath.path
                let lastPathComponent = urlPath.lastPathComponent
                let pathExtension = urlPath.pathExtension
                var isDir : ObjCBool = false
                if fileManager.fileExists(atPath: stringPath, isDirectory:&isDir) {
                    if isDir.boolValue {
                        if !excludedFolderNames.contains(lastPathComponent) {
                            let dirFiles = fetchFilesInFolder(rootPath: urlPath)
                            files.append(contentsOf: dirFiles)
                        }
                    } else {
                        if acceptedFileExtensions.contains(pathExtension) && !excludedFileNames.contains(lastPathComponent)  {
                            files.append(urlPath)
                        }
                    }
                }
            }
        } catch {}
        return files
    }
    
}

@discardableResult
func shell(_ args: String...) -> String {
    let task = Process()
    task.launchPath = "/usr/bin/env"
    task.arguments = args
    
    let pipe = Pipe()
    task.standardOutput = pipe
    
    task.launch()
    task.waitUntilExit()
    
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    
    guard let output: String = String(data: data, encoding: .utf8) else {
        return ""
    }
    return output
}

func localizableDictionary(from: String) -> [String: String] {
    var localizableStrings = [String: String]()
    for line in from.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: ";") {
        let lineComponents = line.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: " = ")
        if lineComponents.count == 2 {
            let key = lineComponents[0]
            let value = lineComponents[1]
            localizableStrings[key] = value
        } else {
            if !line.isEmpty {
                print("Corrupted line --->", line)
            }
        }
    }
    
    return localizableStrings
}

func localizableString(from: [String: String]) -> String {
    var processedStrings = String()
    for (key, value) in from.sorted(by: { $0.key < $1.key  }) {
        processedStrings.append("\(key) = \(value); \n")
    }
    return processedStrings
}


/// comment code below when working from a xcode project
let path: String? = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : nil
let genStrings = GenStringsDiff()
genStrings.perform(path: path)

