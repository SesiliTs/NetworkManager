// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation


enum NetworkError: Error {
    case decodeError
    case wrongResponse
    case wrongStatusCode(code: Int)
}

public class NetworkService {
    
    public static var shared = NetworkService()
    
    let session: URLSession
    
    public init() {
        let urlSessionConfiguration = URLSessionConfiguration.default
        let urlSession = URLSession(configuration: urlSessionConfiguration)
        self.session = urlSession
    }
    
    func getData<T: Codable>(urlString: String, completion: @escaping (Result<T, Error>) -> Void) {
        let url = URL(string: urlString)!

        session.dataTask(with: URLRequest(url: url)) { data, response, error in

            if let error = error {
                print("Error: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }

            guard let response = response as? HTTPURLResponse else {
                print("No HTTPURLResponse")
                completion(.failure(NetworkError.wrongResponse))
                return
            }

            guard (200...299).contains(response.statusCode) else {
                print("Wrong response status code: \(response.statusCode)")
                completion(.failure(NetworkError.wrongStatusCode(code: response.statusCode)))
                return
            }

            guard let data = data else {
                print("No data")
                return
            }

            do {
                let decoder = JSONDecoder()
                let object = try decoder.decode(T.self, from: data)

                DispatchQueue.main.async {
                    completion(.success(object))
                }
            } catch {
                print("Decoding error: \(error.localizedDescription)")
                completion(.failure(NetworkError.decodeError))
            }
        }.resume()
    }

}
