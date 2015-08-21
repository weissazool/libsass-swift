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
        XCTempAssertNoThrowError() {
            let output = try Sass.compileFile(path!)
            print("output: \(output)")
        }
    }
    
    func testString() {
        let path = NSBundle(forClass: self.dynamicType).pathForResource("main", ofType: "scss")
        let string = try! String(contentsOfFile: path!)
        XCTempAssertNoThrowError() {
            var options = SassOptions()
            options.includePath = path!.stringByDeletingLastPathComponent
            let output = try Sass.compile(string, options: options)
            print("output: \(output)")
        }
    }
}
