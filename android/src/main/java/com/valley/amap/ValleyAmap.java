package com.valley.amap;

import android.Manifest;

import com.amap.api.location.AMapLocation;
import com.amap.api.location.AMapLocationClient;
import com.amap.api.location.AMapLocationClientOption;
import com.amap.api.location.AMapLocationListener;
import com.getcapacitor.JSObject;
import com.getcapacitor.NativePlugin;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginMethod;

@NativePlugin(
        permissions = {
                Manifest.permission.ACCESS_COARSE_LOCATION,
                Manifest.permission.ACCESS_FINE_LOCATION,
                Manifest.permission.WRITE_EXTERNAL_STORAGE,
                Manifest.permission.READ_EXTERNAL_STORAGE,
                Manifest.permission.READ_PHONE_STATE
        }
)
public class ValleyAmap extends Plugin {
    // 声明AMapLocationClient类对象
    private AMapLocationClient locationClient = null;
    // 声明定位参数
    private AMapLocationClientOption locationOption = null;
    // 是否是单次定位
    private static boolean isSingle = false;
    // js回调接口
    private static PluginCall pluginCall = null;

    @PluginMethod
    public void singleLocation(PluginCall call) {
        pluginCall = call;
        isSingle = true;
        initLocation();
        startLocation();
    }

    @PluginMethod
    public void continuousLocation(PluginCall call) {
        pluginCall = call;
        isSingle = false;
        boolean isStart = call.getBoolean("isStart", false);
        initLocation();
        if (isStart) {
            startLocation();
        } else {
            stopLocation();
        }
    }

    private void initLocation() {
        if (locationClient == null) {
            locationClient = new AMapLocationClient(getContext());
            // 设置定位参数
            locationClient.setLocationOption(getDefaultOption());
            // 设置定位监听
            locationClient.setLocationListener(locationListener);
        }
    }

    /**
     * 开始定位
     */
    private void startLocation() {
        locationClient.startLocation();
    }

    /**
     * 停止定位
     */
    private void stopLocation() {
        locationClient.stopLocation();
        locationClient.onDestroy();
        locationClient = null;
        locationOption = null;
    }

    private AMapLocationClientOption getDefaultOption() {
        AMapLocationClientOption mOption = new AMapLocationClientOption();
        mOption.setLocationMode(AMapLocationClientOption.AMapLocationMode.Hight_Accuracy);// 可选，设置定位模式，可选的模式有高精度、仅设备、仅网络。默认为高精度模式
        mOption.setGpsFirst(false);// 可选，设置是否gps优先，只在高精度模式下有效。默认关闭
        mOption.setHttpTimeOut(30000);// 可选，设置网络请求超时时间。默认为30秒。在仅设备模式下无效
        // mOption.setInterval(2000);//可选，设置定位间隔。默认为2秒
        mOption.setNeedAddress(true);// 可选，设置是否返回逆地理地址信息。默认是true
        mOption.setOnceLocation(isSingle);// 可选，设置是否单次定位。默认是false
        mOption.setOnceLocationLatest(false);// 可选，设置是否等待wifi刷新，默认为false.如果设置为true,会自动变为单次定位，持续定位时不要使用
        AMapLocationClientOption.setLocationProtocol(AMapLocationClientOption.AMapLocationProtocol.HTTP);// 可选， 设置网络请求的协议。可选HTTP或者HTTPS。默认为HTTP
        mOption.setSensorEnable(false);// 可选，设置是否使用传感器。默认是false
        mOption.setWifiScan(true); // 可选，设置是否开启wifi扫描。默认为true，如果设置为false会同时停止主动刷新，停止以后完全依赖于系统刷新，定位位置可能存在误差
        mOption.setLocationCacheEnable(false); // 可选，设置是否使用缓存定位，默认为true
        return mOption;
    }

    /**
     * 定位监听
     */
    AMapLocationListener locationListener = new AMapLocationListener() {

        @Override
        public void onLocationChanged(AMapLocation location) {
            JSObject json = new JSObject();
            if (null != location) {
                // 解析定位结果
                // errCode等于0代表定位成功，其他的为定位失败，具体的可以参照官网定位错误码说明
                if (location.getErrorCode() == 0) {
                    json.put("status", "定位成功");
                    // 定位之后的回调时间
                    json.put("backtime", System.currentTimeMillis());
                    // 定位类型
                    json.put("type", location.getLocationType());
                    // 纬度
                    json.put("latitude", location.getLatitude());
                    // 经度
                    json.put("longitude", location.getLongitude());
                    // 精度
                    json.put("accuracy", location.getAccuracy());
                    // 角度
                    json.put("bearing", location.getBearing());
                    // 获取当前提供定位服务的卫星个数
                    // 星数
                    json.put("satellites", location.getSatellites());
                    // 国家
                    json.put("country", location.getCountry());
                    // 省
                    json.put("province", location.getProvince());
                    // 市
                    json.put("city", location.getCity());
                    // 城市编码
                    json.put("citycode", location.getCityCode());
                    // 区
                    json.put("district", location.getDistrict());
                    // 区域码
                    json.put("adcode", location.getAdCode());
                    // 地址
                    json.put("address", location.getAddress());
                    // 兴趣点
                    json.put("poi", location.getPoiName());
                    // 定位时间
                    json.put("time", location.getTime());
                    if (isSingle) {
                        pluginCall.resolve(json);
                        stopLocation();
                    } else {
                        notifyListeners("valleyAmapEvent", json);
                    }
                } else {
                    pluginCall.reject(location.getErrorInfo(), String.valueOf(location.getErrorCode()));
                }
            } else {
                pluginCall.reject("定位返回对象为空", "500");
            }
        }
    };
}
