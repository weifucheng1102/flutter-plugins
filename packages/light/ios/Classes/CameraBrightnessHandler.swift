import AVFoundation
import Flutter

class CameraBrightnessHandler: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    private let captureSession = AVCaptureSession()
    private var eventSink: FlutterEventSink?

    func startCapturingBrightness(eventSink: @escaping FlutterEventSink) {
        self.eventSink = eventSink

        captureSession.sessionPreset = .low

        guard let camera = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: frontCamera) else {
            print("Failed to access the camera.")
            return
        }

        let output = AVCaptureVideoDataOutput()
        output.alwaysDiscardsLateVideoFrames = true
        output.setSampleBufferDelegate(self, queue: DispatchQueue(label: "cameraQueue"))

        captureSession.addInput(input)
        captureSession.addOutput(output)

        captureSession.startRunning()
    }

    func stopCapturingBrightness() {
        captureSession.stopRunning()
        eventSink = nil
    }

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        CVPixelBufferLockBaseAddress(imageBuffer, .readOnly)
        
        let baseAddress = CVPixelBufferGetBaseAddress(imageBuffer)
        let bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer)
        let width = CVPixelBufferGetWidth(imageBuffer)
        let height = CVPixelBufferGetHeight(imageBuffer)
        
        var brightness: Float = 0.0
        var totalPixelValue: Float = 0.0
        
        for y in 0..<height {
            for x in 0..<width {
                let pixelOffset = (y * bytesPerRow) + x * 4
                let pixel = baseAddress![pixelOffset]
                totalPixelValue += Float(pixel)
            }
        }
        
        let totalPixelCount = Float(width * height)
        brightness = totalPixelValue / (totalPixelCount * 255.0)
        
        CVPixelBufferUnlockBaseAddress(imageBuffer, .readOnly)
        
        eventSink?(brightness*1000.0)
    }
}
