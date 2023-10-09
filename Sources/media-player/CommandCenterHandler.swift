import Foundation
import SwiftUI
import AVKit

public struct CommandCenterHandler: ViewModifier {
  @ObservedObject var player: MediaPlayer
  var stopOnLeave: Bool = true
  var playImmediately: Bool
  var commandCenterManager: CommandCenterManager

  public init(@ObservedObject player: MediaPlayer, stopOnLeave: Bool = true, playImmediately: Bool,
              commandCenterManager: CommandCenterManager) {
    self.player = player
    self.stopOnLeave = stopOnLeave
    self.playImmediately = playImmediately
    self.commandCenterManager = commandCenterManager
  }
    
  public func body(content: Content) -> some View {
    content
      .onAppear {
        setAudioSessionCategory(to: .playback)

        commandCenterManager.start()

        if playImmediately {
          player.play()
        }
      }
      .onDisappear {
        if stopOnLeave {
          player.pause()

          commandCenterManager.stop()

          setAudioSessionCategory(to: .ambient)
        }
      }
      .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
        //player.pause()
      }
      .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
        //player.play()
      }
  }

  private func setAudioSessionCategory(to value: AVAudioSession.Category) {
    let audioSession = AVAudioSession.sharedInstance()
    do {
      try audioSession.setCategory(value)
      try audioSession.setMode(AVAudioSession.Mode.default)
      try audioSession.setActive(true)
      try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
    } catch {
      print("Setting category to AVAudioSessionCategoryPlayback failed.")
    }
  }
}
