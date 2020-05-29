//
//  NetworkManager.swift
//  sudofm
//
//  Created by phucld on 6/4/20.
//  Copyright © 2020 Dwarves Foundation. All rights reserved.
//

import Foundation

class NetworkManager {
    
    static let shared = NetworkManager()
    private let baseURL = Environment.baseURL
    
    private init() {}
    
    func getMoods(completed: @escaping (Result<[MoodData], SError>) -> Void) {
        let endpoint = baseURL + "/moods"
        
        guard let url = URL(string: endpoint) else {
            completed(.failure(.invalidResponse))
            return
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            if let _ = error {
                completed(.failure(.unableToComplete))
                return
            }
            
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                completed(.failure(.invalidResponse))
                return
            }
            
            guard let data = data else {
                completed(.failure(.invalidData))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                decoder.dateDecodingStrategy = .iso8601
                
                let articles = try decoder.decode([MoodData].self, from: data)
                completed(.success(articles))
            } catch {
                completed(.failure(.invalidData))
            }
        }
        
        task.resume()
    }
}
