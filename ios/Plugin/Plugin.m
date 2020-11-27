#import <Foundation/Foundation.h>
#import <Capacitor/Capacitor.h>
#import <AMapFoundationKit/AMapFoundationKit.h>
#import <AMapLocationKit/AMapLocationKit.h>

// Define the plugin using the CAP_PLUGIN Macro, and
// each method the plugin supports using the CAP_PLUGIN_METHOD macro.
CAP_PLUGIN(ValleyAmap, "ValleyAmap",
           CAP_PLUGIN_METHOD(singleLocation, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(continuousLocation, CAPPluginReturnPromise);
)
