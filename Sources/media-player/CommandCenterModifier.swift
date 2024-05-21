import AVKit
import SwiftUI

struct CommandCenterModifier<T>: ViewModifier {
  var commandCenterManager: CommandCenterManager<T> {
    CommandCenterManager(player: player, nextMedia: nextMedia, previousMedia: previousMedia, update: update)
  }

  @ObservedObject var player: MediaPlayer
  var stopOnLeave: Bool
  var playImmediately: Bool
  var nextMedia: () -> T?
  var previousMedia: () -> T?
  var update: (T, Double) -> Void

  public init(@ObservedObject player: MediaPlayer, stopOnLeave: Bool = true, playImmediately: Bool,
              nextMedia: @escaping () -> T?, previousMedia: @escaping () -> T?,
              update: @escaping (T, Double) -> Void) {
    self.player = player
    self.stopOnLeave = stopOnLeave
    self.playImmediately = playImmediately
    self.nextMedia = nextMedia
    self.previousMedia = previousMedia
    self.update = update
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
  public func commandCenter<T>(player: MediaPlayer, stopOnLeave: Bool, playImmediately: Bool,
                               nextMedia: @escaping () -> T?, previousMedia: @escaping () -> T?,
                               update: @escaping (T, Double) -> Void) -> some View {
    self.modifier(CommandCenterModifier(player: player, stopOnLeave: stopOnLeave, playImmediately: playImmediately,
        nextMedia: nextMedia, previousMedia: previousMedia, update: update))
  }
}

