import SwiftUI
import AudioToolbox

enum ButtonTapSound {
    static func play() {
        // System "Tock" style tap sound.
        AudioServicesPlaySystemSound(1104)
    }
}

struct SoundPlainButtonStyle: PrimitiveButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .contentShape(Rectangle())
            .onTapGesture {
                ButtonTapSound.play()
                configuration.trigger()
            }
    }
}
