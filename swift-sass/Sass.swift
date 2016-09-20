//
//  Sass.swift
//  swift-sass
//
//  Created by Niels de Hoog on 19/08/15.
//  Copyright © 2015 Invisible Pixel. All rights reserved.
//

import Foundation

enum SassError: Error {
    case syntaxError(String)
}

public struct Sass {
    public static func compileFile(_ path: String, options: SassOptions? = nil) throws -> String {
        let compiler = SassFileCompiler(filePath: path)
        return try compiler.compile(options)
    }
    
    public static func compile(_ scss: String, options: SassOptions? = nil) throws -> String {
        let compiler = SassStringCompiler(string: scss)
        return try compiler.compile(options)
    }
}

public struct SassOptions {
    public var includePath: String?
    public var precision: Int?
    
    public init() {}
    
    func applyToFileContext(_ context: OpaquePointer) {
        let options = sass_file_context_get_options(context)
        self.applyToOptions(options!)
    }
    
    func applyToDataContext(_ context: OpaquePointer) {
        let options = sass_data_context_get_options(context)
        self.applyToOptions(options!)
    }
    
    fileprivate func applyToOptions(_ options: OpaquePointer) {
        if let path = self.includePath {
            sass_option_set_include_path(options, path)
        }
        
        if let precision = self.precision {
            sass_option_set_precision(options, Int32(precision))
        }
    }
}

protocol SassCompiler {
    func compile(_ options: SassOptions?) throws -> String
}


private struct SassFileCompiler: SassCompiler {
    let filePath: String
    
    func compile(_ options: SassOptions?) throws -> String {
        let context = sass_make_file_context(self.filePath)
        defer { sass_delete_file_context(context) }
        if let options = options {
            options.applyToFileContext(context!)
        }
        
        sass_compile_file_context(context)
        
        return try SassValidator.validateOutput(context!)
    }
}

private struct SassStringCompiler: SassCompiler {
    let string: String
    
    func createContext(_ string: String) -> OpaquePointer {
        // copy string to allow libsass to take ownership
        let cString = self.string.cString(using: String.Encoding.utf8)!
        let pointer = UnsafeMutablePointer<Int8>.allocate(capacity: cString.count)
        memcpy(pointer, cString, cString.count)
        
        return sass_make_data_context(pointer)
    }
    
    func compile(_ options: SassOptions?) throws -> String {
        let context = self.createContext(self.string)
        defer { sass_delete_data_context(context) }
        if let options = options {
            options.applyToDataContext(context)
        }
        
        sass_compile_data_context(context)
        
        return try SassValidator.validateOutput(context)
    }
}


private struct SassValidator {
    static func validateOutput(_ context: OpaquePointer) throws -> String {
        if let rawError = sass_context_get_error_message(context), let error = String(validatingUTF8: rawError) {
            throw SassError.syntaxError(error)
        }
        
        let output = sass_context_get_output_string(context)
        let outputString = String(cString: output!)
        
        return outputString
    }
}
