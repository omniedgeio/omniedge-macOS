//
//  AuthService.swift
//  Omniedge
//
//  Created by Yanbo Dang on 16/7/2022.
//

import Foundation
import AppKit

protocol AuthServiceDelegate: AnyObject {
    func didLoginCompleted(token: String?)
}

protocol IAuthService: IService {
    var delegate: AuthServiceDelegate? { get set }
    func login()
}

class AuthService: BaseService, IAuthService {

    var token: String? {
        get {
            return self.authToken
        }
    }
    
    weak var delegate: AuthServiceDelegate?
    
    private var httpService: IHttpService
    private var authToken: String?
    
    init(httpService: IHttpService) {
        self.httpService = httpService
        super.init()
    }

    
    override func initService() {
    }
    
    func login() {
        
        self.httpService.sendGetRequest(url: ApiEndPoint.authSession, completed: {
            [weak self] (result: Result<Response<AuthModel>, Error>) in
            switch result {
            case .success(let response):
                self?.monitorSessionCodeWSEvent(sessionCode: response.data.sessionId)
                self?.onAuthurized(model: response.data)
            case .failure(let error):
                self?.handleError(error: error)
            }
        })
    }
    
    private func onAuthurized(model: AuthModel) {
        guard let url = URL(string: model.authUrl) else {
            return
        }
        
        NSWorkspace.shared.open(url)
    }
    
    private func monitorSessionCodeWSEvent(sessionCode: String) {
        self.httpService.listenSocket(url: "\(ApiEndPoint.wsEndPoint)/login/session/\(sessionCode)", received: {
            [weak self] result in
            
            switch result {
            case .success(let msgData):
                self?.didReceivedAuthSocketMessage(message: msgData)
            case .failure(let error):
                self?.handleError(error: error)
            }
        })
    }
    
    private func didReceivedAuthSocketMessage(message: Data?) {
        guard let message = message else {
            return
        }

        do {
            let result = try JSONDecoder().decode(Dictionary<String, String>.self, from: message)
            let token = result["token"]
            self.delegate?.didLoginCompleted(token: token)
        } catch let error {
            self.handleError(error: error)
        }
        
    }
}
