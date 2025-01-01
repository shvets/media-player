import AVFoundation
import SwiftUI
import media_player

open class MediaPlayerHelper {
  @ObservedObject var player: MediaPlayer

  public init(@ObservedObject player: MediaPlayer) {
    self.player = player
  }

  public var currentTime: Double {
    player.currentTime
  }

  public var leftTime: Double {
    if let duration = player.currentItemDuration {
      return duration - currentTime
    }
    else {
      return 0
    }
  }

//  var duration: Double {
//    player.duration ?? 0
//  }

  public func handleAVAudioSessionInterruption(_ notification : Notification) {
#if os(iOS) || os(tvOS)
    guard let userInfo = notification.userInfo as? [String: AnyObject] else { return }

    guard let rawInterruptionType = userInfo[AVAudioSessionInterruptionTypeKey] as? NSNumber else { return }
    guard let interruptionType = AVAudioSession.InterruptionType(rawValue: rawInterruptionType.uintValue) else { return }

    switch interruptionType {
    case .began: //interruption started
      player.pause()

    case .ended: //interruption ended
      if let rawInterruptionOption = userInfo[AVAudioSessionInterruptionOptionKey] as? NSNumber {
        let interruptionOption = AVAudioSession.InterruptionOptions(rawValue: rawInterruptionOption.uintValue)
        if interruptionOption == AVAudioSession.InterruptionOptions.shouldResume {
          player.toggle()
        }
      }
    @unknown default:
      fatalError()
    }
#endif
  }

  public func formatTime(_ time: Double) -> String {
    let (hours, minutes, seconds) = timeToHoursMinutesSeconds(time: Int(time))

    if hours > 0 {
      return String(format: "%i:%02i:%02i", hours, minutes, seconds)
    }
    else {
      return String(format: "%02i:%02i", minutes, seconds)
    }
  }

  func timeToHoursMinutesSeconds (time: Int) -> (Int, Int, Int) {
    (time / 3600, (time % 3600) / 60, (time % 3600) % 60)
  }
}
