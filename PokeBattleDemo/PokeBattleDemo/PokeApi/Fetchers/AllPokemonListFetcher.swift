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

/// Delegate for a fetcher that retrieves a list of all available pokemon.
protocol AllPokemonListFetcherDelegate: class {
    
    /// Did get the list of all possible pokemon.
    ///
    /// - parameter success: Whether the list retrieval succeeded.
    /// - parameter result: Retrieved list or nil on failure.
    /// - parameter error: Error object or nil on failure.
    func didGetAllPokemonList(success: Bool, result: AllPokemonList?, error: NSError?)
}

/// Fetches the list of all available pokemon in the API using a GetAllPokemonListRequest
class AllPokemonListFetcher : PokemonFetcherProtocol {
    
    //
    // MARK: PokemonFetcherProtocol implementation
    //
    
    /// Request type
    typealias RequestType = GetAllPokemonListRequest
    
    /// Response type
    typealias ResponseType = GetAllPokemonListResponse
    
    //
    // MARK: Stored properties
    //
    
    /// Weak reference on the delegate.
    weak var delegate: AllPokemonListFetcherDelegate?
    
}


extension AllPokemonListFetcher {
    
    //
    // MARK: Public functions
    //
    
    /// Fetch the data and calls the delegate on completion.
    func fetch() {
        
        let call: ConnectionType = ConnectionType()
        
        call.onCompletion = { [weak self] (status, error, response) in
            
            guard let strongSelf = self else {
                
                return
            }
            
            switch status {
                
            case .Success:
                strongSelf.delegate?.didGetAllPokemonList(true, result: response?.model, error: nil)
                
            case .ConnectionError:
                strongSelf.delegate?.didGetAllPokemonList(false, result: nil, error: error)
                
            case .UrlError:
                strongSelf.delegate?.didGetAllPokemonList(false, result: nil, error: error)
            }
        }
        
        call.execute(RequestType())
    }
}

