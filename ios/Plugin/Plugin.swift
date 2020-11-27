import Foundation
import Capacitor
import AMapFoundationKit
import AMapLocationKit

@objc(ValleyAmap)
public class ValleyAmap: CAPPlugin {
    var locationManager: AMapLocationManager? = nil;
    var isSingle: Bool = false;
    var pluginCall: CAPPluginCall? = nil;
    
    @objc override public func load() {
        // amap apikey
        AMapServices.shared().apiKey = "";
        locationManager = AMapLocationManager();
        locationManager!.delegate = self as? AMapLocationManagerDelegate;
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
                    if (reGeocode != nil && location != nil) {
                        let mDict:NSMutableDictionary = NSMutableDictionary();
                        mDict.setValue("定位成功", forKey: "status");
                        mDict.setValue(reGeocode?.country, forKey: "country");
                        mDict.setValue(reGeocode?.province, forKey: "province");
                        mDict.setValue(reGeocode?.city, forKey: "city");
                        mDict.setValue(reGeocode?.citycode, forKey: "citycode");
                        mDict.setValue(reGeocode?.district, forKey: "district");
                        mDict.setValue(reGeocode?.adcode, forKey: "adcode");
                        mDict.setValue(reGeocode?.formattedAddress, forKey: "address");
                        mDict.setValue(reGeocode?.poiName, forKey: "poi");
                        mDict.setValue(location?.timestamp, forKey: "time");
                        self?.pluginCall?.resolve(mDict as! PluginResultData);
                    } else {
                        self?.pluginCall?.reject("定位返回空对象", "500");
                    }
                }
            }
            
            if let location = location {
                NSLog("location:%@", location)
            }
            
            if let reGeocode = reGeocode {
                NSLog("reGeocode:%@", reGeocode)
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
    func amapLocationManager(_ manager: AMapLocationManager!, didUpdate location: CLLocation!, reGeocode: AMapLocationReGeocode?, didFailWithError error: Error?) {
        NSLog("location:{lat:\(location.coordinate.latitude); lon:\(location.coordinate.longitude); accuracy:\(location.horizontalAccuracy)};");
        if let reGeocode = reGeocode {
            NSLog("reGeocode:%@", reGeocode);
        }
        let error = error! as NSError;
        if (error.code == 0) {
            if (reGeocode != nil && location != nil) {
                let mDict:NSMutableDictionary = NSMutableDictionary();
                mDict.setValue("定位成功", forKey: "status");
                mDict.setValue(reGeocode?.country, forKey: "country");
                mDict.setValue(reGeocode?.province, forKey: "province");
                mDict.setValue(reGeocode?.city, forKey: "city");
                mDict.setValue(reGeocode?.citycode, forKey: "citycode");
                mDict.setValue(reGeocode?.district, forKey: "district");
                mDict.setValue(reGeocode?.adcode, forKey: "adcode");
                mDict.setValue(reGeocode?.formattedAddress, forKey: "address");
                mDict.setValue(reGeocode?.poiName, forKey: "poi");
                mDict.setValue(location.timestamp, forKey: "time");
                notifyListeners("valleyAmapEvent",data: mDict as? [String : Any]);
            } else {
                pluginCall?.reject("定位返回空对象", "500");
            }
        } else {
            pluginCall?.reject(error.localizedDescription, String(error.code));
        }
        
    }
}
