function [x, y, z] = antenna_vectors_to_cartesian(ranges, azimuths, elevations, edges)
% Calculate Cartesian coordinate for gates from antenna coordinate vectors.
%
% Calculates the Cartesian coordinates for the gate centers or edges for
% all gates from antenna coordinate vectors assuming a standard atmosphere
% (4/3 Earth's radius model). See :py:func:`pyart.util.antenna_to_cartesian`
% for details.
%
% Parameters
% ----------
% ranges : array, 1D.
%     Distances to the center of the radar gates (bins) in meters.
% azimuths : array, 1D.
%     Azimuth angles of the rays in degrees.
% elevations : array, 1D.
%     Elevation angles of the rays in degrees.
% edges : bool, optional
%     True to calculate the coordinates of the gate edges by interpolating
%     between gates and extrapolating at the boundaries. False to
%     calculate the gate centers.
%
% Returns
% -------
% x, y, z : array, 2D
%     Cartesian coordinates in meters from the center of the radar to the
%     gate centers or edges.
if nargin < 4, edges = false; end

if edges
	% if length(ranges) ~= 1
	%     ranges = interpolate_range_edges(ranges);
	% end
	% if length(elevations) ~= 1
	%     elevations = interpolate_elevation_edges(elevations);
	% end
	% if length(azimuths) ~= 1
	%     azimuths = interpolate_azimuth_edges(azimuths);
	% end
end

[~, azg] = meshgrid(ranges, azimuths);
[rg, eleg] = meshgrid(ranges, elevations);

[x, y, z] = nexrad.transforms.antenna_to_cartesian(rg / 1000.0, azg, eleg);