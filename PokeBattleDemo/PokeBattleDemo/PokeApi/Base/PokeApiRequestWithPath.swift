// The MIT License (MIT)
//
// Copyright (c) 2015 pascaljette
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import Foundation

/// A request where we provide only the API path.  This is useful for static APIs
/// define in the app itself where we don't want/need to provide the base url string.
protocol PokeApiRequestWithPath : PokeApiRequestBase {
    
    /// Path of the function to call.
    var apiPath: String { get }
}

extension PokeApiRequestWithPath {
    
    /// Build absolute url based on all url components in the type.
    var absoluteUrl: NSURL? {
        
        let baseUrlString = GlobalConstants.POKEAPI_BASE_URL
        
        guard let url: NSURL = NSURL(string: baseUrlString) else {
            
            print("Could not form url from string \(baseUrlString)")
            return nil;
        }
        
        guard let components: NSURLComponents = NSURLComponents(URL: url, resolvingAgainstBaseURL: true) else {
            
            print("Could not find URL components from string \(baseUrlString)")
            return nil
        }
        
        // NSURLComponents does not get fully initialized, even passing a NSURL in its constructor.
        // We must do it manually.  There might be a better way (XCode 7.3)
        components.scheme = url.scheme
        components.host = url.host
        components.path = apiPath
        components.queryItems = queryItems
        
        return components.URL
    }
}
