import AVFoundation
import SwiftUI

struct ContextCapsuleVideoLoopView: View {
    @StateObject private var model = ContextCapsuleVideoLoopModel()

    var body: some View {
        Group {
            if model.isAvailable {
                CapsuleVideoLayerView(player: model.player)
            } else {
                Image("ContextCapsule")
                    .resizable()
                    .scaledToFill()
            }
        }
        .onAppear(perform: model.play)
        .onDisappear(perform: model.pause)
        .allowsHitTesting(false)
    }
}

@MainActor
private final class ContextCapsuleVideoLoopModel: ObservableObject {
    let player = AVQueuePlayer()
    private var looper: AVPlayerLooper?

    var isAvailable: Bool {
        looper != nil
    }

    init(resourceName: String = "ContextCapsuleLoop", fileExtension: String = "mp4") {
        player.isMuted = true
        player.actionAtItemEnd = .none
        player.preventsDisplaySleepDuringVideoPlayback = false

        guard let url = Bundle.main.url(forResource: resourceName, withExtension: fileExtension) else {
            return
        }

        let item = AVPlayerItem(url: url)
        looper = AVPlayerLooper(player: player, templateItem: item)
    }

    func play() {
        player.play()
    }

    func pause() {
        player.pause()
    }
}

#if os(iOS)
private struct CapsuleVideoLayerView: UIViewRepresentable {
    let player: AVQueuePlayer

    func makeUIView(context: Context) -> PlayerLayerUIView {
        let view = PlayerLayerUIView()
        view.playerLayer.player = player
        return view
    }

    func updateUIView(_ uiView: PlayerLayerUIView, context: Context) {
        uiView.playerLayer.player = player
    }
}

private final class PlayerLayerUIView: UIView {
    override static var layerClass: AnyClass {
        AVPlayerLayer.self
    }

    var playerLayer: AVPlayerLayer {
        layer as! AVPlayerLayer
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }

    private func configure() {
        backgroundColor = .clear
        isUserInteractionEnabled = false
        playerLayer.videoGravity = .resizeAspectFill
        playerLayer.backgroundColor = UIColor.clear.cgColor
    }
}
#elseif os(macOS)
private struct CapsuleVideoLayerView: NSViewRepresentable {
    let player: AVQueuePlayer

    func makeNSView(context: Context) -> PlayerLayerNSView {
        let view = PlayerLayerNSView()
        view.playerLayer.player = player
        return view
    }

    func updateNSView(_ nsView: PlayerLayerNSView, context: Context) {
        nsView.playerLayer.player = player
    }
}

private final class PlayerLayerNSView: NSView {
    let playerLayer = AVPlayerLayer()

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }

    override func layout() {
        super.layout()
        playerLayer.frame = bounds
    }

    private func configure() {
        wantsLayer = true
        layer = playerLayer
        playerLayer.videoGravity = .resizeAspectFill
        playerLayer.backgroundColor = NSColor.clear.cgColor
    }
}
#endif
