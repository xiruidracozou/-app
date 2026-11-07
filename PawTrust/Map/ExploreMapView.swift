import MapKit
import SwiftUI
import PawTrustCore

struct ExploreMapView: View {
    @Bindable var model: ExploreModel
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Map(position: $model.camera, interactionModes: [.pan, .zoom]) {
            ForEach(orderedPlaces) { place in
                Annotation(place.name, coordinate: place.clCoordinate, anchor: .bottom) {
                    PawMarker(
                        place: place,
                        selected: model.state.selectedPlaceID == place.id,
                        dimmed: ExploreLogic.unknownPlaceIDs(model.state).contains(place.id),
                        reduceMotion: reduceMotion
                    ) {
                        model.toggleSelection(place.id)
                    }
                }
            }
            if model.state.locationAuth == .granted, let coordinate = model.state.userCoordinate {
                Annotation("我的位置", coordinate: coordinate.clCoordinate, anchor: .center) {
                    UserDot()
                }
            }
        }
        .mapStyle(.standard(elevation: .flat, pointsOfInterest: .excludingAll, showsTraffic: false))
        .onMapCameraChange(frequency: .onEnd) { context in
            model.noteMapCenter(context.region.center)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("上海示例公园地图")
    }

    private var orderedPlaces: [Place] {
        let visible = model.visiblePlaces
        guard let selected = visible.first(where: { $0.id == model.state.selectedPlaceID }) else {
            return visible
        }
        return visible.filter { $0.id != selected.id } + [selected]
    }
}

struct PawMarker: View {
    let place: Place
    let selected: Bool
    var dimmed = false
    var reduceMotion: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                if selected {
                    HStack(spacing: 8) {
                        PlacePhoto(place: place, cornerRadius: 12)
                            .frame(width: 54, height: 54)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .stroke(Color.white, lineWidth: 2)
                            )
                            .shadow(color: .black.opacity(0.16), radius: 8, y: 4)
                        Text(place.name)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(PawTheme.ink)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 8)
                            .background(Color.white, in: Capsule())
                            .overlay(Capsule().strokeBorder(PawTheme.line, lineWidth: 1))
                            .shadow(color: .black.opacity(0.08), radius: 6, y: 3)
                    }
                    .accessibilityHidden(true)
                }
                ZStack {
                    if selected {
                        Circle()
                            .fill(PawTheme.cobalt.opacity(0.22))
                            .frame(width: 68, height: 68)
                        Circle()
                            .fill(PawTheme.cobalt)
                            .frame(width: 44, height: 44)
                            .shadow(color: PawTheme.cobalt.opacity(0.35), radius: 8, y: 2)
                        Image(systemName: "pawprint.fill")
                            .font(.body.weight(.bold))
                            .foregroundStyle(.white)
                    } else {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 36, height: 36)
                            .overlay(Circle().strokeBorder(PawTheme.cobalt.opacity(0.2), lineWidth: 1))
                            .shadow(color: .black.opacity(0.14), radius: 4, y: 2)
                        Image(systemName: "pawprint.fill")
                            .font(.footnote.weight(.bold))
                            .foregroundStyle(PawTheme.cobalt)
                    }
                }
                .frame(minWidth: 44, minHeight: 44)
            }
        }
        .buttonStyle(.plain)
        .opacity(dimmed && !selected ? 0.55 : 1)
        .animation(reduceMotion ? nil : .spring(response: 0.32, dampingFraction: 0.78), value: selected)
        .accessibilityIdentifier("marker.\(place.id)")
        .accessibilityLabel(selected ? "\(place.name)，已选中" : place.name)
        .accessibilityHint(dimmed ? "条件未知，不能当作满足" : (selected ? "取消选择" : "查看示例详情"))
        .accessibilityAddTraits(selected ? [.isButton, .isSelected] : .isButton)
    }
}

struct UserDot: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(PawTheme.cobalt.opacity(0.18))
                .frame(width: 36, height: 36)
            Circle()
                .fill(PawTheme.cobalt)
                .frame(width: 14, height: 14)
                .overlay(Circle().strokeBorder(Color.white, lineWidth: 2))
        }
        .accessibilityLabel("我的位置")
    }
}

extension Place {
    var clCoordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

extension Coordinate {
    var clCoordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
