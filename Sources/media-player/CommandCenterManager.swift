import MediaPlayer
import SwiftUI

public class CommandCenterManager {
  let commandCenter = MPRemoteCommandCenter.shared()

  @ObservedObject var player: MediaPlayer
  var nextTrack: () -> Void
  var previousTrack: () -> Void

  public init(@ObservedObject player: MediaPlayer, nextTrack: @escaping () -> Void, previousTrack: @escaping () -> Void) {
    self.player = player
    self.nextTrack = nextTrack
    self.previousTrack = previousTrack
  }

  public func start() {
    UIApplication.shared.beginReceivingRemoteControlEvents()

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
    UIApplication.shared.endReceivingRemoteControlEvents()
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
      previousTrack()

      return .success
    }
  }

  private func setupNextTrackCommand() {
    commandCenter.nextTrackCommand.isEnabled = true

    commandCenter.nextTrackCommand.removeTarget(nil)

    commandCenter.nextTrackCommand.addTarget { [self] event in
      nextTrack()

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
