import SwiftUI
import PawTrustCore
import UIKit

struct PlacePhoto: View {
    let place: Place
    var cornerRadius: CGFloat = 12

    var body: some View {
        ZStack {
            PhotoArtwork(place: place)
            if UIImage(named: place.photoName) != nil {
                Image(place.photoName)
                    .resizable()
                    .scaledToFill()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipped()
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .accessibilityLabel("\(place.name)，\(DemoCopy.photoExplanation)")
    }
}

/// Drawn locally so a missing asset still shows a finished photo card.
struct PhotoArtwork: View {
    let place: Place

    var body: some View {
        let sky = place.water
            ? Color(red: 0.73, green: 0.84, blue: 0.80)
            : Color(red: 0.83, green: 0.88, blue: 0.74)
        let ground = place.water
            ? Color(red: 0.45, green: 0.66, blue: 0.74)
            : Color(red: 0.55, green: 0.70, blue: 0.50)
        ZStack {
            LinearGradient(colors: [sky, ground], startPoint: .top, endPoint: .bottom)
            VStack {
                Spacer()
                Capsule()
                    .fill(Color.white.opacity(0.38))
                    .frame(height: 14)
                    .padding(.horizontal, 28)
                    .padding(.bottom, 16)
            }
            Image(systemName: "dog.fill")
                .font(.system(size: 42))
                .foregroundStyle(Color.white.opacity(0.95))
                .shadow(radius: 2, y: 1)
                .accessibilityHidden(true)
        }
        .accessibilityHidden(true)
    }
}
