import Foundation
import Capacitor
import AMapFoundationKit
import AMapLocationKit

@objc(ValleyAmap)
public class ValleyAmap: CAPPlugin, AMapLocationManagerDelegate {
    var locationManager: AMapLocationManager? = nil;
    var isSingle: Bool = false;
    var pluginCall: CAPPluginCall? = nil;
    
    @objc override public func load() {
        // amap apikey
        AMapServices.shared().apiKey = "174f36faf8a9db6e72b2762314b8d6d1";
        locationManager = AMapLocationManager();
        locationManager!.delegate = self;
    }
    
    //MARK: - 单次定位
    @objc func singleLocation(_ call: CAPPluginCall) {
        isSingle = true;
        pluginCall = call;
        locationManager!.desiredAccuracy = kCLLocationAccuracyBest;
        locationManager!.locationTimeout = 10;
        locationManager!.reGeocodeTimeout = 10;
        
        //单次定位地理位置信息返回
        locationManager!.requestLocation(withReGeocode: true, completionBlock: { [weak self] (location: CLLocation?, reGeocode: AMapLocationReGeocode?, error: Error?) in
            
            if let error = error {
                let error = error as NSError
                
                if error.code == AMapLocationErrorCode.locateFailed.rawValue {
                    //定位错误：此时location和regeocode没有返回值，不进行annotation的添加
                    NSLog("定位错误:{\(error.code) - \(error.localizedDescription)};")
                }
                else if error.code == AMapLocationErrorCode.reGeocodeFailed.rawValue
                    || error.code == AMapLocationErrorCode.timeOut.rawValue
                    || error.code == AMapLocationErrorCode.cannotFindHost.rawValue
                    || error.code == AMapLocationErrorCode.badURL.rawValue
                    || error.code == AMapLocationErrorCode.notConnectedToInternet.rawValue
                    || error.code == AMapLocationErrorCode.cannotConnectToHost.rawValue {
                    
                    //逆地理错误：在带逆地理的单次定位中，逆地理过程可能发生错误，此时location有返回值，regeocode无返回值，进行annotation的添加
                    NSLog("逆地理错误:{\(error.code) - \(error.localizedDescription)};")
                }
                else {
                    
                }
            }
            
            if let location = location {
                NSLog("location:%@", location)
            }
            
            if let reGeocode = reGeocode {
                NSLog("reGeocode:%@", reGeocode)
            }
            if error == nil {
                if (reGeocode != nil && location != nil) {
                    let status = "定位成功";
                    let country: String = reGeocode?.country ?? "";
                    let province: String = reGeocode?.province ?? "";
                    let city: String = reGeocode?.city ?? "";
                    let citycode: String = reGeocode?.citycode ?? "";
                    let district: String = reGeocode?.district ?? "";
                    let adcode: String = reGeocode?.adcode ?? "";
                    let address: String = reGeocode?.formattedAddress ?? "";
                    let poi: String = reGeocode?.poiName ?? "";
                    let json: PluginResultData = [
                        "status": status,
                        "country": country,
                        "province": province,
                        "city": city,
                        "citycode": citycode,
                        "district": district,
                        "adcode": adcode,
                        "address": address,
                        "poi": poi
                    ];
                    self?.pluginCall?.resolve(json);
                } else {
                    self?.pluginCall?.reject("定位返回空对象", "500");
                }
            } else {
                let errors = error! as NSError;
                self?.pluginCall?.reject(errors.localizedDescription, String(errors.code));
            }
        })
    }
    
    //MARK: - 持续定位
    @objc func continuousLocation(_ call: CAPPluginCall) {
        isSingle = false;
        pluginCall = call;
        let isStart = call.getBool("isStart", false) ?? false;
        if isStart {
            locationManager!.distanceFilter = 6;
            locationManager!.locatingWithReGeocode = true;
            locationManager!.startUpdatingLocation();
        } else {
            locationManager!.stopUpdatingLocation();
        }
    }
    
    // serailLocation callback
    public func amapLocationManager(_ manager: AMapLocationManager!, didUpdate location: CLLocation!, reGeocode: AMapLocationReGeocode?) {
        NSLog("location:{lat:\(location.coordinate.latitude); lon:\(location.coordinate.longitude); accuracy:\(location.horizontalAccuracy)};");
        if let reGeocode = reGeocode {
            NSLog("reGeocode:%@", reGeocode);
        }
        if (reGeocode != nil && location != nil) {
            let status = "定位成功";
            let country: String = reGeocode?.country ?? "";
            let province: String = reGeocode?.province ?? "";
            let city: String = reGeocode?.city ?? "";
            let citycode: String = reGeocode?.citycode ?? "";
            let district: String = reGeocode?.district ?? "";
            let adcode: String = reGeocode?.adcode ?? "";
            let address: String = reGeocode?.formattedAddress ?? "";
            let poi: String = reGeocode?.poiName ?? "";
            let json: PluginResultData = [
                "status": status,
                "country": country,
                "province": province,
                "city": city,
                "citycode": citycode,
                "district": district,
                "adcode": adcode,
                "address": address,
                "poi": poi
            ];
            notifyListeners("valleyAmapEvent",data: json);
        } else {
            pluginCall?.reject("定位返回空对象", "500");
        }
        
    }
}
