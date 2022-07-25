//
//  HttpService.swift
//  Omniedge
//
//  Created by Yanbo Dang on 15/7/2022.
//

import Foundation

protocol IHttpService: IService {
    var token: String? { get set }
    
    func sendGetRequest<T: Decodable>(url: String, completed: @escaping (Result<Response<T>, Error>) -> Void)
    func sendPostRequest<T: Decodable, S: Encodable>(url: String, payload: S, completed: @escaping (Result<Response<T>, Error>) -> Void)
    
    func listenSocket(url: String, received: @escaping (Result<Data?, Error>) -> Void)
}

class HttpService: BaseService, IHttpService {
    
    enum HttpMethodType: String {
        case httpGet = "GET"
        case httpPost = "POST"
    }
    
    var token: String?
    
    private var session: URLSession?
    private var baseEndPoint = ApiEndPoint.baseApi
    private var jsonDecoder: JSONDecoder = JSONDecoder()
    
    override init() {
        super.init()
    }
    
    override func initService() {
        self.session = URLSession(configuration: URLSessionConfiguration.default, delegate: nil, delegateQueue: nil)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        self.jsonDecoder.dateDecodingStrategy = .formatted(dateFormatter)
    }
    
    func sendGetRequest<T: Decodable>(url: String, completed: @escaping (Result<Response<T>, Error>) -> Void) {
        
        guard let session = self.session,
              let request = self.generateRequest(url: url, httpMethodType: .httpGet) else {
            // TODO: call completed
            return
        }
        
        let task = session.dataTask(with: request) { (data, response, error) in
            if error != nil {
                completed(.failure(error!))
                return
            }
            
            guard let data = data else {
                // TODO: call completed
                return
            }
            
            #if DEBUG
            data.printJson()
            #endif
            
            do {
                let response = try self.jsonDecoder.decode(Response<T>.self, from: data)
                completed(.success(response))
            } catch let error {
                completed(.failure(error))
            }
        }
        
        task.resume()
    }
    
    func sendPostRequest<T: Decodable, S: Encodable>(url: String, payload: S, completed: @escaping (Result<Response<T>, Error>) -> Void) {
        guard let session = self.session,
              var request = self.generateRequest(url: url, httpMethodType: .httpPost) else {
            // TODO: call completed
            return
        }
        
        do {
            let jsonData = try JSONEncoder().encode(payload)
            request.httpBody = jsonData
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        } catch let error {
            completed(.failure(error))
            return
        }
        
        let task = session.dataTask(with: request) { (data, response, error) in
            if error != nil {
                completed(.failure(error!))
                return
            }
            
            guard let data = data else {
                return
            }
            
            #if DEBUG
            data.printJson()
            #endif
            
            do {

                let restReponse = try self.jsonDecoder.decode(Response<T>.self, from: data)
                if(restReponse.code == 200) {
                    completed(.success(restReponse))
                } else {
                    completed(.failure(OmniError(errorCode: restReponse.code, message: nil)))
                }
            } catch let error {
                print(error)
                completed(.failure(error))
            }
        }
        
        task.resume()
    }
    
    
    
    func listenSocket(url: String, received: @escaping (Result<Data?, Error>) -> Void ) {
        let urlSession = URLSession(configuration: URLSessionConfiguration.default)
        guard let url = URL(string: url) else {
            return
        }

        let sokcetTask = urlSession.webSocketTask(with: url)
        sokcetTask.resume()
        sokcetTask.receive { result in
            switch result {
            case .success(let message):
                self.didReceivedSocketMessage(message: message, completed: received)
            case .failure(let error):
                self.handleError(error: error)
            }
        }
    }
    
    private func didReceivedSocketMessage(message: URLSessionWebSocketTask.Message, completed: (Result<Data?, Error>) -> Void ) {
        switch message {
        case .string(let msg):
            completed(.success(msg.data(using: .utf8)))
        case .data(let data):
            completed(.success(data))
        @unknown default:
            fatalError()
        }
    }
    
    private func generateRequest(url: String, httpMethodType: HttpMethodType) -> URLRequest? {
        guard let url = URL(string: ApiEndPoint.baseApi + url) else {
            // TODO: call completed
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = httpMethodType.rawValue
        guard let token = token else {
            return request
        }
        
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}
