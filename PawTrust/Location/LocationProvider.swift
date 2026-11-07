import CoreLocation
import Foundation
import PawTrustCore

enum LocationEvent: Equatable {
    case requesting
    case granted(Coordinate)
    case denied
    case failed
}

/// Creates `CLLocationManager` only after a tap. The map itself does not request permission.
final class LocationProvider: NSObject, CLLocationManagerDelegate {
    var onEvent: (LocationEvent) -> Void = { _ in }

    private var manager: CLLocationManager?
    private var started = false

    func requestOnce() {
        let manager = ensureManager()
        started = true
        switch manager.authorizationStatus {
        case .notDetermined:
            emit(.requesting)
            manager.requestWhenInUseAuthorization()
        case .authorizedAlways, .authorizedWhenInUse:
            emit(.requesting)
            manager.requestLocation()
        case .denied:
            emit(.denied)
        case .restricted:
            emit(.failed)
        @unknown default:
            emit(.failed)
        }
    }

    private func ensureManager() -> CLLocationManager {
        if let manager {
            return manager
        }
        let manager = CLLocationManager()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        self.manager = manager
        return manager
    }

    private func emit(_ event: LocationEvent) {
        if Thread.isMainThread {
            onEvent(event)
        } else {
            DispatchQueue.main.async { [weak self] in
                self?.onEvent(event)
            }
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        guard started else { return }
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            manager.requestLocation()
        case .denied:
            emit(.denied)
        case .restricted:
            emit(.failed)
        case .notDetermined:
            break
        @unknown default:
            emit(.failed)
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            emit(.failed)
            return
        }
        emit(.granted(Coordinate(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude
        )))
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if let error = error as? CLError, error.code == .denied {
            emit(.denied)
        } else {
            emit(.failed)
        }
    }
}
