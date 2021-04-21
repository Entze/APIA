#program base.

% For the purposes of testing with fixed observations, this patch assists in handling non-determinism in choosing activities.
%   See corresponding patch in the APIA control loop
%
% TODO: Remove this file
attempt(start(Activity), Timestep) :-
    happened(start(Activity), Timestep).
