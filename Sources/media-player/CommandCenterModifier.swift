import AVKit
import SwiftUI
import item_navigator

struct CommandCenterModifier<T: Identifiable>: ViewModifier {
  var commandCenterManager: CommandCenterManager<T> {
    CommandCenterManager<T>(player: player, navigator: navigator)
  }

  @ObservedObject var player: MediaPlayer
  var navigator: ItemNavigator<T>
  var stopOnLeave: Bool
  var playImmediately: Bool

  public init(@ObservedObject player: MediaPlayer, navigator: ItemNavigator<T>, stopOnLeave: Bool = true,
              playImmediately: Bool = false) {
    self.player = player
    self.navigator = navigator
    self.stopOnLeave = stopOnLeave
    self.playImmediately = playImmediately
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
#if os(iOS) || os(tvOS)
      .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
        //player.pause()
      }
      .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
        //player.play()
      }
#endif
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
  public func commandCenter<T>(player: MediaPlayer, navigator: ItemNavigator<T>, stopOnLeave: Bool,
                               playImmediately: Bool) -> some View {
    self.modifier(CommandCenterModifier(player: player, navigator: navigator, stopOnLeave: stopOnLeave,
        playImmediately: playImmediately))
  }
}

