/// Lima fallback coordinates + Peru bounding-box validation.
///
/// Android emulators report fake GPS (e.g. Mountain View 37.42, -122.08).
/// We reject coordinates outside Peru so the map falls back to Lima during
/// testing. Real users inside Peru are unaffected.
const double limaLat = -12.046374;
const double limaLng = -77.042793;

bool isInPeru(double lat, double lng) {
  return lat >= -18.0 && lat <= -0.5 && lng >= -82.0 && lng <= -68.0;
}
