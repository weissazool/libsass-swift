//
//  SwiftSassTests.swift
//  SwiftSassTests
//
//  Created by Niels de Hoog on 20/08/15.
//  Copyright © 2015 Invisible Pixel. All rights reserved.
//

import XCTest
@testable import SwiftSass

class SwiftSassTests: XCTestCase {
    
    func testFile() {
        let path = NSBundle(forClass: self.dynamicType).pathForResource("main", ofType: "scss")
        try! Sass.compileFile(path!)
    }
    
    func testString() {
        let path = NSBundle(forClass: self.dynamicType).pathForResource("main", ofType: "scss")
        let string = try! String(contentsOfFile: path!)
        try! Sass.compile(string)
    }
}
