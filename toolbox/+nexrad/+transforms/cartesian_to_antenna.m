function [ranges, azimuths, elevations] = cartesian_to_antenna(x, y, z)
% Returns antenna coordinates from Cartesian coordinates.
%
% Parameters
% ----------
% x, y, z : array
%     Cartesian coordinates in meters from the radar.
%
% Returns
% -------
% ranges : array
%     Distances to the center of the radar gates (bins) in m.
% azimuths : array
%     Azimuth angle of the radar in degrees. [-180., 180]
% elevations : array
%     Elevation angle of the radar in degrees.

ranges = sqrt(x^2.0 + y^2.0 + z^2.0);
elevations = rad2deg(atan(z / sqrt(x^2.0 + y^2.0)));
azimuths = rad2deg(atan2(x, y));  % [-180, 180]
azimuths(azimuths < 0.0) = azimuths(azimuths < 0.0) + 360.0;  % [0, 360]