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

protocol PokemonFetcherDelegate: class {
    
    func didGetPokemon(success: Bool, result: Pokemon?, error: NSError?)
}

enum PokemonFetcherMode {
    
    // TODO We are not using manual anywhere, consider letting it go.
    case MANUAL(String)
    case RANDOM(AllPokemonList)
}

class PokemonFetcher {
    
    typealias GetPokemonConnection = PokeApiConnection<GetPokemonRequest, GetPokemonResponse>
    
    weak var delegate: PokemonFetcherDelegate?
 
    var pokemonUrl: String
    
    // TODO: AllPokemonList stays immutable for the whole lifecycle of the application.
    // Consider making it a singleton to avoid passing it all the time.
    private var allPokemonList: AllPokemonList
    
    // TODO there really is no reason to keep this here.  Consider making separate classes for random and non random.
    private var fetcherMode: PokemonFetcherMode
    
    init(fetcherMode: PokemonFetcherMode) {
        
        self.fetcherMode = fetcherMode
        
        switch fetcherMode {
            
        case .MANUAL(let pokemonUrl):
            
            // AllPokemonList is not needed for a manual load
            self.allPokemonList = AllPokemonList()
            self.pokemonUrl = pokemonUrl
            
        case .RANDOM(let allPokemonList):
            
            self.allPokemonList = allPokemonList
            
            // TODO will be randomized later (very bad practice, needs to be fixed)
            self.pokemonUrl = ""
        }
    }
}

extension PokemonFetcher {
    
    func randomize() {
        
        self.pokemonUrl = allPokemonList.pokemonUrlStrings[Int(arc4random_uniform(UInt32(allPokemonList.pokemonUrlStrings.count)))]
    }
    
    func fetch() {
        
        switch fetcherMode {
            
        case .RANDOM(_):
            randomize()
            
        case .MANUAL(_):
            break
            
        }
        
        let call: GetPokemonConnection = GetPokemonConnection()
        let getPokemonRequest = GetPokemonRequest(fullUrl: pokemonUrl)
        
        call.onCompletion = { [weak self] (status, error, response) in
            
            guard let strongSelf = self else {
                
                return
            }
            
            switch status {
                
            case .Success:
                strongSelf.delegate?.didGetPokemon(true, result: response?.model, error: nil)
                
            case .ConnectionError:
                strongSelf.delegate?.didGetPokemon(false, result: nil, error: error)
                
            case .UrlError:
                strongSelf.delegate?.didGetPokemon(false, result: nil, error: error)
            }
        }
        
        call.execute(getPokemonRequest)
    }
}

