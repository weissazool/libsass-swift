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
    public static func compileFile(path: String, includePath: String? = nil) throws -> String {
        
        let context = sass_make_file_context(path)
        
        if let includePath = includePath {
            let options = sass_file_context_get_options(context)
            sass_option_set_include_path(options, includePath)
        }
        
        sass_compile_file_context(context)
        print("error status: \(sass_context_get_error_status(context))")
        if sass_context_get_error_status(context) == 1 {
            let message = String.fromCString(sass_context_get_error_message(context)) ?? "Unknown error"
            throw SassError.SyntaxError(message)
        }
        
        let output = sass_context_get_output_string(context)
        let outputString = String.fromCString(output)!
        
        sass_delete_file_context(context)
        
        return outputString
    }
    
    public static func compile(scss: String, includePath: String? = nil) throws -> String {
        
        let compiler = SassCompiler(string: scss)
        compiler.includePath = includePath
        return try compiler.compile()
    }
}

public struct SassCompilerOptions {
    public var includePath: String
    
    func applyToFileContext(context: COpaquePointer) {
        
    }
    
    func applyToDataContext(context: COpaquePointer) {
        
    }
    
    private func applyToOptions(options: COpaquePointer) {
        
    }
}

//protocol SassCompilerr {
//    func compile(options: SassCompilerOptions) throws -> String
//}
//
//
//private struct SassFileCompiler: SassCompilerr {
//    let filePath: String
//    
//    func compile(options: SassCompilerOptions) throws -> String {
//        let context = sass_make_file_context(self.filePath)
//        options.applyToFileContext(context)
//        
//        sass_compile_file_context(context)
//        
//        
//    }
//}
//


private enum SassCompilerType {
    case File
    case String
}

private class SassCompiler {
    private let type: SassCompilerType
    let filePath: String?
    let string: String?
    private let context: COpaquePointer
    
    var options: COpaquePointer {
        switch self.type {
        case .File:
            return sass_file_context_get_options(self.context)
        case .String:
            return sass_data_context_get_options(self.context)
        }
    }
    
    var includePath: String? {
        didSet {
            if let path = self.includePath {
                sass_option_set_include_path(self.options, path)
            }
        }
    }
    
    init(filePath: String) {
        self.type = .File
        self.filePath = filePath
        self.string = nil
        
        self.context = sass_make_file_context(filePath)
    }
    
    init(string: String) {
        self.type = .String
        self.string = string
        self.filePath = nil
        
        var cString = string.cStringUsingEncoding(NSUTF8StringEncoding)!
        // copy string to allow libsass to take ownership
        let pointer = UnsafeMutablePointer<Int8>.alloc(cString.count)
        memcpy(pointer, cString, cString.count)
        self.context = sass_make_data_context(pointer)
    }
    
    deinit {
        switch self.type {
        case .File:
            sass_delete_file_context(self.context)
        case .String:
            sass_delete_data_context(self.context)
        }
    }
    
    func compile() throws -> String {
        switch self.type {
        case .File:
            sass_compile_file_context(self.context)
        case .String:
            sass_compile_data_context(self.context)
        }
        
        if let error = String.fromCString(sass_context_get_error_message(context)) {
            print("error code: \(sass_context_get_error_status(context))")
            throw SassError.SyntaxError(error)
        }
        
        let output = sass_context_get_output_string(context)
        let outputString = String.fromCString(output)!
        
        return outputString
    }
}