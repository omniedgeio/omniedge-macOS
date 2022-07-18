//
//  VirtualNetworkService.swift
//  Omniedge
//
//  Created by Yanbo Dang on 16/7/2022.
//

import Foundation

protocol VirtualNetworkServiceDelegate: AnyObject {
    func didNetworkListLoaded(networks: [VirtualNetworkModel])
}

protocol IVirtualNetworkService {
    var delegate: VirtualNetworkServiceDelegate? { get set }
    func loadNetworks()
}

class VirtualNetworkService: BaseService, IVirtualNetworkService {
    
    weak var delegate: VirtualNetworkServiceDelegate?
    
    private var httpService: IHttpService
    
    init(httpService: IHttpService) {
        self.httpService = httpService
        super.init()
    }
    
    func loadNetworks() {
        
        self.httpService.sendGetRequest(url: ApiEndPoint.virtualNetworkList, completed: {
            [weak self] (result: Result<Response<[VirtualNetworkModel]>, Error>) in
            switch result {
            case .success(let response):
                if(response.code == 200) {
                    self?.didLoadNetworkList(networks: response.data)
                } else {
                    self?.handleError(error: OmniError(errorCode: response.code, message: nil))
                }
            case .failure(let error):
                self?.handleError(error: error)
            }
        })
    }
    
    // MARK: - Private Netowrks -
    private func didLoadNetworkList(networks: [VirtualNetworkModel]) {
        self.delegate?.didNetworkListLoaded(networks: networks)
    }
}
