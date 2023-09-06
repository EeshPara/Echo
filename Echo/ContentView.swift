//
//  ContentView.swift
//  Echo
//
//  Created by Eeshwar Parasuramuni on 9/5/23.
//

import SwiftUI
import AVFoundation
import Speech
import SwiftyTranslate
struct ContentView: View {
    @State private var isRecording = false
     @State private var audioEngine = AVAudioEngine()
     @State private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
     @State private var recognitionTask: SFSpeechRecognitionTask?
     @State private var transcription = ""
    @State private var translated = ""
    
    var body: some View {
        VStack {
            HStack{
                Text("Echo")
                    .bold()
                    .font(.title)
                    .padding(.leading)
                    .padding(.bottom)
                    .padding(.top)
                Image(systemName: "waveform")
                Spacer()
             
                
                
                Button{
                    if self.isRecording {
                                  self.stopRecording()
                        print("stopped recording")
                        SwiftyTranslate.translate(text: transcription, from: "en", to: "hi") { result in
                            switch result {
                            case .success(let translation):
                               translated = translation.translated
                                print(translated)
                            case .failure(let error):
                                print("Error: \(error)")
                            }
                        }
                              } else {
                                  AVAudioSession.sharedInstance().requestRecordPermission { (granted) in
                                      if granted {
                                          // Microphone access granted, you can proceed with audio recording
                                         
                                          print("granted")
                                          self.startRecording()
                                      } else {
                                          // Microphone access denied, handle it accordingly (e.g., show a message to the user)
                                          print("access not granted")
                                      }
                                  }
                                 
                                  print("recording")
                              }
                              self.isRecording.toggle()
                    
                } label: {
                    Image(systemName: "mic")
                        .padding()
                        .foregroundColor(isRecording ? .red : .blue)
                }
                
              
            }
            ScrollView{
                VStack(alignment: .leading) {
                    HStack{
                        Text("English: \(transcription) ")
                            .padding()
                            .bold()
                        Spacer()
                    }
                    HStack{
                        Text("Hindi: \(translated) ")
                            .padding()
                            .bold()
                        Spacer()
                    }
                    Button("Clear"){
                        translated = ""
                        transcription = ""
                    }
                    .padding()
                }
                    
            }
         
            
            
        }
        .padding()
    }
    func startRecording() {
           do {
          
               let audioSession = AVAudioSession.sharedInstance()
               try audioSession.setCategory(.record, mode: .default, options: [])
               try audioSession.setActive(true, options: .notifyOthersOnDeactivation)

               let inputNode = audioEngine.inputNode
               recognitionRequest = SFSpeechAudioBufferRecognitionRequest()

               guard let recognitionRequest = recognitionRequest else { return }
               recognitionRequest.shouldReportPartialResults = true

               recognitionTask = SFSpeechRecognizer(locale: Locale(identifier: "en_US"))?.recognitionTask(with: recognitionRequest) { result, error in
                   if let result = result {
                       self.transcription = result.bestTranscription.formattedString
                       print(self.transcription)
                   } else if let error = error {
                       print("Recognition error: \(error)")
                   }
               }

               let recordingFormat = inputNode.outputFormat(forBus: 0)
               inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
                   recognitionRequest.append(buffer)
               }

               audioEngine.prepare()
               try audioEngine.start()
           } catch {
               print("Audio recording setup error: \(error)")
           }
       }
        
        func stopRecording() {
            audioEngine.inputNode.removeTap(onBus: 0)
            recognitionRequest?.endAudio()
            audioEngine.stop()
            audioEngine.inputNode.reset()
            recognitionTask?.cancel()
        }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
