//  genstringsfromxibs
//
//  Created by Alexandru Tudose on 09/11/2016.
//  Copyright © 2016 Tapptitude. All rights reserved.
//

import Foundation

class XMLObject {
    
    let xml: XMLIndexer
    let name: String
    
    init(xml: XMLIndexer) {
        self.xml = xml
        self.name = xml.element!.name
    }
    
    func searchAll(_ attributeKey: String, attributeValue: String? = nil) -> [XMLIndexer]? {
        return searchAll(self.xml, attributeKey: attributeKey, attributeValue: attributeValue)
    }
    
    func searchAll(_ root: XMLIndexer, attributeKey: String, attributeValue: String? = nil) -> [XMLIndexer]? {
        var result = Array<XMLIndexer>()
        for child in root.children {
            
            for childAtLevel in child.all {
                if let attributeValue = attributeValue {
                    if let element = childAtLevel.element, element.attributes[attributeKey] == attributeValue {
                        result += [childAtLevel]
                    }
                } else if let element = childAtLevel.element, element.attributes[attributeKey] != nil {
                    result += [childAtLevel]
                }
                
                if let found = searchAll(childAtLevel, attributeKey: attributeKey, attributeValue: attributeValue) {
                    result += found
                }
            }
        }
        return result.count > 0 ? result : nil
    }
    
    func searchNamed(_ name: String) -> [XMLIndexer]? {
        return self.searchNamed(self.xml, name: name)
    }
    
    func searchNamed(_ root: XMLIndexer, name: String) -> [XMLIndexer]? {
        var result = Array<XMLIndexer>()
        for child in root.children {
            
            for childAtLevel in child.all {
                if let elementName = childAtLevel.element?.name, elementName == name {
                    result += [child]
                }
                if let found = searchNamed(childAtLevel, name: name) {
                    result += found
                }
            }
        }
        return result.count > 0 ? result : nil
    }
    
    func searchById(_ id: String) -> XMLIndexer? {
        return searchAll("id", attributeValue: id)?.first
    }
}

extension XMLElement {
    func localizedTexts() -> [String]? {
        // if a custom localizedText is set, use that one
        let runtimeAttr = children.first(where: { $0.name == "userDefinedRuntimeAttributes" })
        let userAttr = runtimeAttr?.children.first(where: { $0.name == "userDefinedRuntimeAttribute" && $0.attributes["keyPath"] == "localizedText" })
        if let text = userAttr?.attributes["value"], !text.isEmpty {
            return [text]
        }
        
        
        switch name {
        case "button":
            return children.filter({ $0.name == "state" }).flatMap({ $0.attributes["title" ]})
        case "label", "textView", "textField":
            return attributes["text"].flatMap({ [ $0 ] }) ?? children.filter({ $0.name == "string" }).flatMap({ $0.text })
        case "barButtonItem", "navigationItem", "tabBarItem":
            return attributes["title"].flatMap({ [ $0 ] })
        default:
            return nil
        }
    }
}


class Xib: XMLObject {
    weak var file: XibFile?
    
    override init(xml: XMLIndexer) {
        super.init(xml: xml)
    }
    
    lazy var localizedElements: [XMLElement]? = {
        return self.searchAll("keyPath", attributeValue: "localizedText")?.flatMap({ $0.element?.parent?.parent })
    }()
    
    func process() -> [String] {
        var allStrings: [String] = []
        localizedElements?.forEach({ (element) in
            if let strings = element.localizedTexts() {
                let processNewLines = strings.map({ $0.replacingOccurrences(of: "\n", with: "\\n") })
                allStrings.append(contentsOf: processNewLines)
            } else {
                print("-------Not supported----- - \(element.name) - \(file!.filePath)")
            }
        })
        
        return allStrings
        
    }
}


class XibFile {
    let data: Data
    let name: String
    let filePath: String
    let xib: Xib
    
    init(filePath: String) {
        self.filePath = filePath
        self.data = try! Data(contentsOf: URL(fileURLWithPath: filePath))
        self.name = ((filePath as NSString).lastPathComponent as NSString).deletingPathExtension
        self.xib = Xib(xml:SWXMLHash.parse(self.data))
        self.xib.file = self
    }
}


//MARK: Functions

func findFiles(_ rootPath: String, fileExtensions: [String]) -> [String]? {
    var result: [String] = []
    let fm = FileManager.default
    if let paths = fm.subpaths(atPath: rootPath) {
        let filePaths = fileExtensions.map({  fileExtension in
            return paths.filter({ return $0.hasSuffix(fileExtension)})
        }).reduce([], +)
        
        for p in filePaths {
            result.append((rootPath as NSString).appendingPathComponent(p))
        }
    }
    return result.count > 0 ? result : nil
}

func processXibs(_ xibs: [XibFile]) {
    // We use a set to avoid duplicates
    var localizableStrings = Set<String>()
    xibs.forEach({   localizableStrings = localizableStrings.union($0.xib.process()) })
    
    // We sort the strings
    let sortedStrings = localizableStrings.sorted(by: { $0 < $1 })
    var processedStrings = String()
    for string in sortedStrings {
        processedStrings.append("\"\(string)\" = \"\(string)\"; \n")
    }
    print(processedStrings)
}

