//
//  AudioController.swift
//  NetTuner
//
//  Created by Vincenzo Garambone on 15/04/24.
//

import Combine
import AVFoundation
import AVKit

@Observable
final class AudioController {

    private var player : AVPlayer = AVPlayer()
    private var radioStation : RadioStation? = nil
    
    var status : AudioControllerStatus = .stopped
    var statusString : String {
        switch status {
        case .playing, .paused:
            return radioStation!.title
        case .loading, .ready:
            return "Loading..."
        case .failed:
            return "Load failed"
        case .stopped:
            return "Not Playing"
        }
    }

    private var subscriptions: Set<AnyCancellable> = Set<AnyCancellable>()
    
    func start(radio: RadioStation) {
        start(url: radio.url)
        radioStation = radio
    }
    
    func start(urlString: String) {
        let testUrl: URL? = URL(string: urlString)
        if testUrl == nil {
            return
        }

        start(url: testUrl!)
    }
    
    func start(url: URL) {
        stop()
        
        let asset = AVAsset(url: url)
        let playerItem = AVPlayerItem(
            asset: asset,
            automaticallyLoadedAssetKeys: [.tracks, .duration, .commonMetadata]
        )
        
        // Register to observe the status property before associating with player.
        playerItem.publisher(for: \.status)
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] playerItemStatus in
                guard let self else { return }
                switch playerItemStatus {
                case .readyToPlay:
                    status = .ready
                    play()
                case .failed:
                    if (playerItem.error as NSError?) != nil {
                        status = .failed
                    }
                    return
                case .unknown:
                    status = .loading
                default:
                    break
                }
            }
            .store(in: &subscriptions)
        
        // Set the item as the player's current item.
        player.replaceCurrentItem(with: playerItem)
//        player.play()
    }
    
    func setVolume(volume: Float) {
        player.volume = volume
    }

    func play() {
        if status == .ready || status == .paused {
            player.play()
            status = .playing
        }
    }

    func pause() {
        player.pause()
        status = .paused
    }

    func stop() {
        radioStation = nil
        status = .stopped
        player = AVPlayer()
    }
    
}

enum AudioControllerStatus : Equatable {
    case ready
    case playing
    case loading
    case failed
    case paused
    case stopped
}
