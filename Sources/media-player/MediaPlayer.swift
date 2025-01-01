import AVKit
import AVFoundation
import SwiftUI
import Combine

public class MediaPlayer: ObservableObject {
  @Published public var player = AVPlayer()

  @Published public var isPlaying = false
  @Published public var currentTime: Double = .zero
  @Published public var periodicSavedTime: Double = .zero
  @Published public var duration: Double?
  @Published public var isInPipMode: Bool = false
  @Published public var isEditingCurrentTime = false

  private var subscriptions: Set<AnyCancellable> = []

  let currentTimeInterval = CMTime(seconds: 1, preferredTimescale: 600)
  let periodicSavedTimeInterval = CMTime(seconds: 20, preferredTimescale: 600)

  private var currentTimeObserver: Any?
  private var periodicSavedTimeObserver: Any?

  public var requestHeaders: [String: String] = [:]

  private var _url: URL?

  public var url: URL? {
    get {
      _url
    }
    set {
      _url = newValue

      if let newValue = newValue {
        let options = requestHeaders.isEmpty ? nil : ["AVURLAssetHTTPHeaderFieldsKey": requestHeaders]

        let asset = AVURLAsset(url: newValue, options: options)
        let playerItem = AVPlayerItem(asset: asset)

        if isPlaying {
          pause()

          seek(0)

          setCurrentItem(playerItem)

          play()
        }
        else {
          setCurrentItem(playerItem)
        }
      }
    }
  }

  public var currentItemDuration: Double? {
    player.currentItem?.asset.duration.seconds
  }

  private func setCurrentItem(_ item: AVPlayerItem) {
    duration = nil
    player.replaceCurrentItem(with: item)

    item.publisher(for: \.status)
      .filter { $0 == .readyToPlay }
      .map { p in
        item.asset.duration.seconds - self.currentTime
      }
      .assign(to: &$duration)
    //     .assign(to: \MyViewModel.filterString, on: myViewModel)
//      .sink(receiveValue: { [weak self] _ in
//        self?.duration = item.asset.duration.seconds - (self?.currentTime ?? .zero)
//      })
//      .store(in: &subscriptions)
  }

  public init() {
#if os(iOS) || os(tvOS)
    UIApplication.shared.beginReceivingRemoteControlEvents()
#endif

    $isEditingCurrentTime
      .dropFirst()
      .filter { $0 == false }
      .sink(receiveValue: { [weak self] _ in
        guard let self = self else { return }

        self.seek(self.currentTime)

        if self.player.rate != 0 {
          self.player.play()
        }
      })
      .store(in: &subscriptions)

      player.publisher(for: \.timeControlStatus)
        .compactMap { status in
            switch status {
              case .playing:
                return true
              case .paused:
                return false
              case .waitingToPlayAtSpecifiedRate:
                return nil
              @unknown default:
                return nil
            }
          }
        .assign(to: &$isPlaying)

//      .sink { [weak self] status in
//        switch status {
//        case .playing:
//          self?.isPlaying = true
//        case .paused:
//          self?.isPlaying = false
//        case .waitingToPlayAtSpecifiedRate:
//          break
//        @unknown default:
//          break
//        }
//      }
//      .store(in: &subscriptions)

    currentTimeObserver = player.addPeriodicTimeObserver(forInterval: currentTimeInterval, queue: .main) { [weak self] time in
      guard let self = self else { return }

      if self.isEditingCurrentTime == false {
        self.currentTime = time.seconds
      }
    }

    periodicSavedTimeObserver = player.addPeriodicTimeObserver(forInterval: periodicSavedTimeInterval, queue: .main) { [weak self] time in
      guard let self = self else { return }

      self.periodicSavedTime = time.seconds
    }
  }

  deinit {
    if let timeObserver = currentTimeObserver {
      player.removeTimeObserver(timeObserver)
    }

    if let timeObserver = periodicSavedTimeObserver {
      player.removeTimeObserver(timeObserver)
    }

#if os(iOS) || os(tvOS)
    UIApplication.shared.endReceivingRemoteControlEvents()
#endif
  }

  public func toggle() {
    let status = player.timeControlStatus

    switch status {
    case .waitingToPlayAtSpecifiedRate:
      play()

    case .playing:
      pause()

    case .paused:
      play()

    @unknown default:
      fatalError()
    }
  }

  public func play() {
    isPlaying = true

    player.play()
  }

  public func pause() {
    isPlaying = false

    player.pause()
  }

  public func stop() {
    pause()

    player.replaceCurrentItem(with: nil)
  }

  public func toEnd() {
    pause()

    if let currentItem = player.currentItem {
      setCurrentTime(currentItem.asset.duration.seconds)
    }
  }

  public func replay() {
    pause()

    seek(0)

    play()
  }

  public func reload(url: URL?) {
    if let url = url {
      stop()

      self.url = url
      setCurrentTime(.zero)

      player.play()
    }
  }

  public func skipSeconds(_ value: Double) {
    pause()

    updateCurrentTime(value)

    play()
  }

  public func updateCurrentTime(_ value: Double) {
    isEditingCurrentTime = true

    currentTime = currentTime + value
    periodicSavedTime = currentTime

    isEditingCurrentTime = false
  }

  public func setCurrentTime(_ value: Double) {
    isEditingCurrentTime = true

    currentTime = value
    periodicSavedTime = currentTime

    isEditingCurrentTime = false
  }

  public func getPlayerPosition(_ value: Double) -> Double {
    if let currentItem = player.currentItem {
      let duration = currentItem.asset.duration.seconds

      return value * duration
    }
    else {
      return 0
    }
  }

  public func seek(_ seconds: Double) {
    //player.seek(to: CMTimeMake(value: Int64(seconds), timescale: 1))
    player.seek(to: CMTime(seconds: seconds, preferredTimescale: 1), toleranceBefore: .zero, toleranceAfter: .zero)
  }

  public func update(url: URL, startTime: Double) {
    //if self.url == nil || self.url != url {
      if isPlaying {
        player.pause()
      }

      self.url = url

      setCurrentTime(startTime)
    //}
  }

//  public func update(mediaSource: MediaSource, startTime: Double) {
//    if isNewMediaSource(mediaSource: mediaSource) {
//      if isPlaying {
//        player.pause()
//      }
//
//      self.mediaSource = mediaSource
//
//      setCurrentTime(startTime)
//    }
//  }

//  private func isNewMediaSource(mediaSource: MediaSource) -> Bool {
//    if let playerMediaSource = self.mediaSource {
//      if mediaSource.id != nil && playerMediaSource.id != nil {
//        return mediaSource.id != playerMediaSource.id
//      }
//      else {
//        return mediaSource.url != playerMediaSource.url
//      }
//    }
//    else {
//      return true
//    }
//  }

//  public func volume(volume: Float) {
//    player.volume = volume
//  }
//
//  public func decrementVolume() {
//    player.volume = player.volume - 1
//  }
//
//  public func incrementVolume() {
//    player.volume = player.volume + 1
//  }
//
//  public func status() -> AVPlayer.Status? {
//    player.status
//  }
}
