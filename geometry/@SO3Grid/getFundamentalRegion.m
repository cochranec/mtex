function [q,omega] = getFundamentalRegion(S3G,varargin)
% projects orientations to a fundamental region
%
%% Input
%  S3G - @SO3Grid
%
%% Options
%  CENTER - reference orientation
%
%% Output
%  q     - @quaterion
%  omega - rotational angle

q_ref = get_option(varargin,'center',idquaternion);

q = symmetriceQuat(S3G.CS,symmetry,S3G.Grid);
omega = rotangle(q * inverse(q_ref));

[omega,q] = selectMinbyRow(omega,q);