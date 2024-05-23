import MediaPlayer
import SwiftUI
import item_navigator

public class CommandCenterManager<T: Identifiable> {
  let commandCenter = MPRemoteCommandCenter.shared()

  @ObservedObject var player: MediaPlayer
  var navigator: ItemNavigator<T>

  public init(@ObservedObject player: MediaPlayer, navigator: ItemNavigator<T>) {
    self.player = player
    self.navigator = navigator
  }

  public func start() {
#if os(iOS) || os(tvOS)
    UIApplication.shared.beginReceivingRemoteControlEvents()
#endif
    setupChangePlaybackPositionCommand()
    setupTogglePlayPauseCommand()
    setupPreviousTrackCommand()
    setupNextTrackCommand()
    setupPlayCommand()
    setupPauseCommand()

//      rcc.skipBackwardCommand.removeTarget(nil)
//      rcc.skipForwardCommand.removeTarget(nil)
  }

  public func stop() {
#if os(iOS) || os(tvOS)
    UIApplication.shared.endReceivingRemoteControlEvents()
#endif
  }

  private func setupChangePlaybackPositionCommand() {
    commandCenter.changePlaybackPositionCommand.isEnabled = true

    commandCenter.changePlaybackPositionCommand.removeTarget(nil)

    commandCenter.changePlaybackPositionCommand.addTarget { event in
      if let event = event as? MPChangePlaybackPositionCommandEvent {
        self.player.currentTime = event.positionTime
      }

      return .success
    }
  }

  private func setupTogglePlayPauseCommand() {
    commandCenter.togglePlayPauseCommand.isEnabled = true

    commandCenter.togglePlayPauseCommand.removeTarget(nil)

    commandCenter.togglePlayPauseCommand.addTarget { event in
      self.player.toggle()

      return .success
    }
  }

  private func setupPreviousTrackCommand() {
    commandCenter.previousTrackCommand.isEnabled = true

    commandCenter.previousTrackCommand.removeTarget(nil)

    commandCenter.previousTrackCommand.addTarget { [self] event in
      if let item = navigator.previous() {
        navigator.update(item: item, time: .zero)
      }

      return .success
    }
  }

  private func setupNextTrackCommand() {
    commandCenter.nextTrackCommand.isEnabled = true

    commandCenter.nextTrackCommand.removeTarget(nil)

    commandCenter.nextTrackCommand.addTarget { [self] event in
      if let item = navigator.next() {
        navigator.update(item: item, time: .zero)
      }

      return .success
    }
  }

  private func setupPlayCommand() {
    commandCenter.playCommand.isEnabled = true

    commandCenter.playCommand.removeTarget(nil)

    commandCenter.playCommand.addTarget { event in
      self.player.play()

      return .success
    }
  }

  private func setupPauseCommand() {
    commandCenter.pauseCommand.isEnabled = true

    commandCenter.pauseCommand.removeTarget(nil)

    commandCenter.pauseCommand.addTarget { event in
      self.player.pause()

      return .success
    }
  }
}
