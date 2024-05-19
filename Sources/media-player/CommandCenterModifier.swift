import AVKit
import SwiftUI

struct CommandCenterModifier: ViewModifier {
  var commandCenterManager: CommandCenterManager {
    CommandCenterManager(player: player, nextTrack: nextTrack, previousTrack: previousTrack)
  }

  @ObservedObject var player: MediaPlayer
  var stopOnLeave: Bool
  var playImmediately: Bool
  var nextTrack: () -> Void
  var previousTrack: () -> Void

  public init(@ObservedObject player: MediaPlayer, stopOnLeave: Bool = true, playImmediately: Bool,
              nextTrack: @escaping () -> Void, previousTrack: @escaping () -> Void) {
    self.player = player
    self.stopOnLeave = stopOnLeave
    self.playImmediately = playImmediately
    self.nextTrack = nextTrack
    self.previousTrack = previousTrack
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

extension View {
  public func commandCenter(player: MediaPlayer, stopOnLeave: Bool, playImmediately: Bool,
                            nextTrack: @escaping () -> Void, previousTrack: @escaping () -> Void) -> some View {
    self.modifier(CommandCenterModifier(player: player, stopOnLeave: stopOnLeave, playImmediately: playImmediately,
        nextTrack: nextTrack, previousTrack: previousTrack))
  }
}

