package com.valley.amap;

import com.getcapacitor.JSObject;
import com.getcapacitor.NativePlugin;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginMethod;

@NativePlugin
public class ValleyAmap extends Plugin {

    @PluginMethod
    public void singleLocation(PluginCall call) {
        call.success();
    }

    @PluginMethod
    public void continuousLocation(PluginCall call) {
        boolean isStart = call.getBoolean("isStart", false);
        call.success();
    }
}
