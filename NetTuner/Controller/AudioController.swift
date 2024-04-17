//
//  AudioController.swift
//  NetTuner
//
//  Created by Vincenzo Garambone on 15/04/24.
//

import Combine
import AVFoundation
import AVKit

final class AudioController: ObservableObject {

    private var player : AVPlayer = AVPlayer()
    @Published var nowPlayingInfo : String?
    @Published var isPlaying: Bool = false

    private var subscriptions: Set<AnyCancellable> = Set<AnyCancellable>()
    
    func start(radio: RadioStation) {
        start(url: radio.url)
    }
    
    func start(urlString: String) {
        let testUrl: URL? = URL(string: urlString)
        if testUrl == nil {
            return
        }

        start(url: testUrl!)
    }
    
    func start(url: URL) {
        let asset = AVAsset(url: url)
        let playerItem = AVPlayerItem(
            asset: asset,
            automaticallyLoadedAssetKeys: [.tracks, .duration, .commonMetadata]
        )
        // Register to observe the status property before associating with player.
        playerItem.publisher(for: \.status)
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                guard let self else { return }
                switch status {
                case .readyToPlay:
                    nowPlayingInfo = playerItem.description
                case .failed:
                    nowPlayingInfo = "Load failed"
                default:
                    break
                }
            }
            .store(in: &subscriptions)
        
        // Set the item as the player's current item.
        player.replaceCurrentItem(with: playerItem)
        player.play()
        isPlaying = true
    }
    
    func setVolume(volume: Float) {
        player.volume = volume
    }
    
    private func observePlayingState() {
        player.publisher(for: \.timeControlStatus)
            .receive(on: DispatchQueue.main)
            .map { $0 == .playing }
            .assign(to: &$isPlaying)
    }

    func play() {
        if player.currentItem?.status == .readyToPlay {
            player.play()
            isPlaying = true
        }
    }

    func pause() {
        player.pause()
        isPlaying = false
    }

}
