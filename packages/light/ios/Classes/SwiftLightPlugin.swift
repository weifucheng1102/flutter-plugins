import Flutter
import UIKit
    
public class SwiftLightPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "light.eventChannel", binaryMessenger: registrar.messenger())
    let instance = SwiftLightPlugin()
    instance.cameraBrightnessHandler = CameraBrightnessHandler()        
    eventChannel.setStreamHandler(StreamHandler(cameraBrightnessHandler: instance.cameraBrightnessHandler!))
    }  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    result("iOS " + UIDevice.current.systemVersion)
  }
}
class StreamHandler: NSObject, FlutterStreamHandler {
    private var cameraBrightnessHandler: CameraBrightnessHandler

    init(cameraBrightnessHandler: CameraBrightnessHandler) {
        self.cameraBrightnessHandler = cameraBrightnessHandler
    }

    public func onListen(withArguments arguments: Any?, eventSink: @escaping FlutterEventSink) -> FlutterError? {
        cameraBrightnessHandler.startCapturingBrightness(eventSink: eventSink)
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        cameraBrightnessHandler.stopCapturingBrightness()
        return nil
    }
}
