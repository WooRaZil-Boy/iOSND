//
//  RecordSoundsViewController.swift
//  PitchPerfect
//
//  Created by 근성가이 on 2017. 2. 24..
//  Copyright © 2017년 근성가이. All rights reserved.
//

import UIKit
import AVFoundation

class RecordSoundsViewController: UIViewController {
    //MARK: - Properties
    @IBOutlet weak var recordingLabel: UILabel!
    @IBOutlet weak var recordingButton: UIButton!
    @IBOutlet weak var stopRecordingButton: UIButton!
    
    var audioRecorder: AVAudioRecorder!
    
    //MARK: - ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        stopRecordingButton.isEnabled = false
    }
}

//MARK: - AVAudioRecorderDelegate
extension RecordSoundsViewController: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        guard flag else {
            let alert = UIAlertController(title: "Error", message: "Recording was not successful", preferredStyle: .alert)
            let doneAction = UIAlertAction(title: "Done", style: .default)
            alert.addAction(doneAction)
            present(alert, animated: true)
            
            return
        }
        
        performSegue(withIdentifier: "stopRecording", sender: audioRecorder.url)
    }
}

//MARK: - Actions
extension RecordSoundsViewController {
    @IBAction func recordAudio(_ sender: Any) {
        print("Recording button was pressed")
        
        recordingSetting()
        
        //저장할 디렉토리와 파일이름 설정
        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let recordingName = "recordedVoice.wav"
        let pathArray = [dirPath, recordingName]
        let filePath = URL(string: pathArray.joined(separator: "/")) //배열의 문자열 separatot로 구분하면서 합치기
        
        let session = AVAudioSession.sharedInstance()
        try! session.setCategory(AVAudioSessionCategoryPlayAndRecord, with: .defaultToSpeaker)
        
        try! audioRecorder = AVAudioRecorder(url: filePath!, settings: [:])
        audioRecorder.delegate = self
        audioRecorder.isMeteringEnabled = true
        audioRecorder.prepareToRecord()
        audioRecorder.record()
    }
    
    @IBAction func stopRecording(_ sender: Any) {
        print("Stop Recording button was pressed")
        
        recordingSetting()
        
        audioRecorder.stop()
        let audioSession = AVAudioSession.sharedInstance()
        try! audioSession.setActive(false)
    }
    
    func recordingSetting() {
        recordingButton.isEnabled = !recordingButton.isEnabled
        stopRecordingButton.isEnabled = !stopRecordingButton.isEnabled
        recordingLabel.text = stopRecordingButton.isEnabled ? "Recording in Progress" : "Tap to Record"
    }
}

//MARK: - Navigations
extension RecordSoundsViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "stopRecording" {
            let playSoundsViewController = segue.destination as! PlaySoundsViewController
            let recordedAudioURL = sender as! URL
            playSoundsViewController.recordedAudioURL = recordedAudioURL
        }
    }
}

