const { degrees, radians, atan2, sin, cos } = Math;
function calculateBearing(pointA, pointB) {
    const [lat1, lon1] = pointA.map(radians);
    const [lat2, lon2] = pointB.map(radians);
    const dLon = lon2 - lon1;

    const x = sin(dLon) * cos(lat2);
    const y = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);

    const bearing = atan2(x, y);
    return (degrees(bearing) + 360) % 360;
}

function isOnPath(current, A, B, tolerance = 0.05) {
    const bearingAB = calculateBearing(A, B);
    const bearingCurrentB = calculateBearing(current, B);
    return Math.abs(bearingAB - bearingCurrentB) <= tolerance;
}

module.exports =  isOnPath 