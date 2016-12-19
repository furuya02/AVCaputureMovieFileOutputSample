//
//  ViewController.swift
//  AVCaputureMovieFileOutputSample
//
//  Created by hirauchi.shinichi on 2016/12/16.
//  Copyright © 2016年 SAPPOROWORKS. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

class ViewController: UIViewController, AVCaptureFileOutputRecordingDelegate {


    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var startStopButton: UIButton!
    
    var isRecoding = false
    
    var fileOutput: AVCaptureMovieFileOutput?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // セッションのインスタンス生成
        let captureSession = AVCaptureSession()

        // 入力（背面カメラ）
        let videoDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        let videoInput = try! AVCaptureDeviceInput.init(device: videoDevice)
        captureSession.addInput(videoInput)
        // 入力（マイク）
        let audioDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeAudio)
        let audioInput = try! AVCaptureDeviceInput.init(device: audioDevice)
        captureSession.addInput(audioInput);
        // 出力（動画ファイル）
        fileOutput = AVCaptureMovieFileOutput()
        captureSession.addOutput(fileOutput)
        // プレビュー
        if let videoLayer = AVCaptureVideoPreviewLayer.init(session: captureSession) {
            videoLayer.frame = previewView.bounds
            videoLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
            previewView.layer.addSublayer(videoLayer)
        }
        // セッションの開始
        DispatchQueue.global(qos: .userInitiated).async {
            captureSession.startRunning()
        }
        screenInitialization()
    }

    // 録画の開始・停止ボタン
    @IBAction func tapStartStopButton(_ sender: Any) {
        if isRecoding { // 録画終了
            fileOutput?.stopRecording()
        }
        else{ // 録画開始
            let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
            let documentsDirectory = paths[0] as String
            let filePath : String? = "\(documentsDirectory)/temp.mp4"
            let fileURL : NSURL = NSURL(fileURLWithPath: filePath!)
            fileOutput?.startRecording(toOutputFileURL: fileURL as URL!, recordingDelegate: self)
        }
        isRecoding = !isRecoding
        screenInitialization()
    }
    
    // 録画完了
    public func capture(_ captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAt outputFileURL: URL!, fromConnections connections: [Any]!, error: Error!) {
        // ライブラリへの保存
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: outputFileURL)
        }) { completed, error in
            if completed {
                print("Video is saved!")
            }
        }
    }

    func screenInitialization(){
        startStopButton.setImage(UIImage(named: isRecoding ? "startButton" : "stopButton"), for: .normal)
        headerView.alpha = isRecoding ? 0.6 : 1.0
        footerView.alpha = isRecoding ? 0.6 : 1.0
    }
}

