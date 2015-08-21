//
//  Sass.swift
//  swift-sass
//
//  Created by Niels de Hoog on 19/08/15.
//  Copyright © 2015 Invisible Pixel. All rights reserved.
//

import Foundation

enum SassError: ErrorType {
    case SyntaxError(String)
}

public struct Sass {
    public static func compileFile(path: String, options: SassOptions? = nil) throws -> String {
        let compiler = SassFileCompiler(filePath: path)
        return try compiler.compile(options)
    }
    
    public static func compile(scss: String, options: SassOptions? = nil) throws -> String {
        let compiler = SassStringCompiler(string: scss)
        return try compiler.compile(options)
    }
}

public struct SassOptions {
    public var includePath: String?
    public var precision: Int?
    
    func applyToFileContext(context: COpaquePointer) {
        let options = sass_file_context_get_options(context)
        self.applyToOptions(options)
    }
    
    func applyToDataContext(context: COpaquePointer) {
        let options = sass_data_context_get_options(context)
        self.applyToOptions(options)
    }
    
    private func applyToOptions(options: COpaquePointer) {
        if let path = self.includePath {
            sass_option_set_include_path(options, path)
        }
        
        if let precision = self.precision {
            sass_option_set_precision(options, Int32(precision))
        }
    }
}

protocol SassCompiler {
    func compile(options: SassOptions?) throws -> String
}


private struct SassFileCompiler: SassCompiler {
    let filePath: String
    
    func compile(options: SassOptions?) throws -> String {
        let context = sass_make_file_context(self.filePath)
        if let options = options {
            options.applyToFileContext(context)
        }
        
        sass_compile_file_context(context)
        
        return try SassValidator.validateOutput(context)
    }
}

private struct SassStringCompiler: SassCompiler {
    let string: String
    
    func createContext(string: String) -> COpaquePointer {
        // copy string to allow libsass to take ownership
        var cString = self.string.cStringUsingEncoding(NSUTF8StringEncoding)!
        let pointer = UnsafeMutablePointer<Int8>.alloc(cString.count)
        memcpy(pointer, cString, cString.count)
        
        return sass_make_data_context(pointer)
    }
    
    func compile(options: SassOptions?) throws -> String {
        let context = self.createContext(self.string)
        if let options = options {
            options.applyToDataContext(context)
        }
        
        sass_compile_data_context(context)
        
        return try SassValidator.validateOutput(context)
    }
}


private struct SassValidator {
    static func validateOutput(context: COpaquePointer) throws -> String {
        if let error = String.fromCString(sass_context_get_error_message(context)) {
            throw SassError.SyntaxError(error)
        }
        
        let output = sass_context_get_output_string(context)
        let outputString = String.fromCString(output)!
        
        return outputString
    }
}
