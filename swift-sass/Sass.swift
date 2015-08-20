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
    public static func compileFile(path: String) throws -> String {
        
        let context = sass_make_file_context(path)
        let compiler = sass_make_file_compiler(context)
        sass_compiler_parse(compiler)
        sass_compiler_execute(compiler)
        
        if let error = String.fromCString(sass_context_get_error_message(context)) {
            print("error happened \(error)")
            throw SassError.SyntaxError(error)
        }
        
        let output = sass_context_get_output_string(context)
        let outputString = String.fromCString(output)!
        print("output: \(outputString)")
        
        sass_delete_compiler(compiler)
        
        return outputString
    }
    
    public static func compile(scss: String) throws -> String {
        
        var string = scss.cStringUsingEncoding(NSUTF8StringEncoding)!
        let context = sass_make_data_context(&string)
        let compiler = sass_make_data_compiler(context)
        sass_compiler_parse(compiler)
        sass_compiler_execute(compiler)
        
        if let error = String.fromCString(sass_context_get_error_message(context)) {
            print("error happened \(error)")
            throw SassError.SyntaxError(error)
        }
        
        let output = sass_context_get_output_string(context)
        let outputString = String.fromCString(output)!
        print("output: \(outputString)")
        
//        sass_delete_compiler(compiler)
        
        return outputString
    }
}