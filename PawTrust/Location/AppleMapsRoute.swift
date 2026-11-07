import MapKit
import PawTrustCore
import UIKit

enum AppleMapsRoute {
    /// Hands the destination to Apple Maps. No polyline is drawn in 爪印识途.
    static func openWalking(_ handoff: RouteHandoff) {
        let destination = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(
            latitude: handoff.coordinate.latitude,
            longitude: handoff.coordinate.longitude
        )))
        destination.name = handoff.placeName
        MKMapItem.openMaps(
            with: [MKMapItem.forCurrentLocation(), destination],
            launchOptions: [
                MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking,
            ]
        )
    }
}

enum SystemSettings {
    static func open() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
}
