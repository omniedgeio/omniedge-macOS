//
//  DeviceService.swift
//  Omniedge
//
//  Created by Yanbo Dang on 18/7/2022.
//

import Foundation

protocol DeviceServiceDelegate: AnyObject {
    func didRegisteredDevice()
    func didJoinedDevice()
}

protocol IDeviceService: IService {
    var delegate: DeviceServiceDelegate? { get set }
    func registerDevice()
    func joinDeviceInNetwork(networkUuid: String)
}

class DeviceService: BaseService, IDeviceService {
    
    weak var delegate: DeviceServiceDelegate?
    
    private var httpService: IHttpService
    private var deviceModel: DeviceModel?
    private var deviceRegisterModel: DeviceRegisterModel?
    private var deviceJoinedModel: JoinDeviceMode?
    
    init(httpService: IHttpService) {
        self.httpService = httpService
        super.init()
    }
    
    override func initService() {
        self.deviceModel = self.getDeviceInfo()
    }
    
    func registerDevice() {
        self.httpService.sendPostRequest(url: ApiEndPoint.registerDevice, payload: self.deviceModel) {
            [weak self] (result: Result<Response<DeviceRegisterModel>, Error>) in
            switch result {
            case .success(let response):
                self?.onDeviceRegister(model: response.data)
            case .failure(let error):
                self?.handleError(error: error)
            }
        }
    }
    
    func joinDeviceInNetwork(networkUuid: String) {
        guard let deviceId = self.deviceRegisterModel?.deviceId else {
            return
        }
        let payload: [String: String] = ["deviceId" : deviceId]
        let joinUrl = "\(networkUuid)/devices/\(deviceId)/join";
        self.httpService.sendPostRequest(url: joinUrl, payload: payload) {
            [weak self] (result: Result< Response<JoinDeviceMode>, Error>) in
            switch result {
            case .success(let response):
                self?.onDeviceJoined(model: response.data)
            case .failure(let error):
                self?.handleError(error: error)
            }
        }
    }
    
    private func getDeviceInfo() -> DeviceModel? {
        let deviceName = ProcessInfo.processInfo.hostName
        // let osVersion = ProcessInfo.processInfo.operatingSystemVersionString
        guard let hardwareUUID = self.getHardwareUUID() else {
            return nil
        }

        return DeviceModel(deviceName: deviceName, deviceUuid: hardwareUUID, deviceOS: "macOS")
    }
    
    private func getHardwareUUID() -> String? {
        let dev = IOServiceMatching("IOPlatformExpertDevice")
        let platformExpert: io_service_t = IOServiceGetMatchingService(kIOMasterPortDefault, dev)
        let serialNumberAsCFString = IORegistryEntryCreateCFProperty(platformExpert, kIOPlatformUUIDKey as CFString, kCFAllocatorDefault, 0)
        IOObjectRelease(platformExpert)
        let ser: CFTypeRef? = serialNumberAsCFString?.takeUnretainedValue()

        guard let result = ser as? String else {
            return nil
        }

        return result
    }
    
    private func onDeviceRegister(model: DeviceRegisterModel) {
        self.deviceRegisterModel = model
        self.delegate?.didRegisteredDevice()
    }
    
    private func onDeviceJoined(model: JoinDeviceMode) {
        self.deviceJoinedModel = model
        self.delegate?.didJoinedDevice()
    }
}
