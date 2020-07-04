% Hn.lp
% I = 0

% lp(s0, 0)
val(colonel(c1), 0).
-val(observer(c1), 0).
-val(authorized(c1, m1), 0).
-val(commands(c1, m1), 0).

% lp(A0, 0)
occurs(authorize(c1, m1), 0).
