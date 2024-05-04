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
    private var radioStation : RadioStation? = nil
    
    @Published var status : AudioControllerStatus = .stopped
    @Published var statusString : String = "Not Playing"

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
                    status = .playing
                    statusString = radioStation!.title

                case .failed:
                    if (playerItem.error as NSError?) != nil {
                        status = .failed
                        statusString = "Load failed."
                    }
                case .unknown:
                    status = .loading
                    statusString = "Loading..."
                default:
                    statusString = "Not Playing."
                    break
                }
            }
            .store(in: &subscriptions)
        
        // Set the item as the player's current item.
        player.replaceCurrentItem(with: playerItem)
        player.play()
    }
    
    func setVolume(volume: Float) {
        player.volume = volume
    }

    func play() {
        if player.currentItem?.status == .readyToPlay {
            player.play()
        }
    }

    func stop() {
        player.pause()
        radioStation = nil
        status = .stopped
        player = AVPlayer()
    }

}

enum AudioControllerStatus : Equatable {
    case playing
    case loading
    case failed
    case stopped
}
