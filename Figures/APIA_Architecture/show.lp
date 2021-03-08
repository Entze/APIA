%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% #show statements %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

#show ("holds", Timestep, Fluent) : holds(Fluent, Timestep).
#show ("holds", Timestep, -Fluent) : -holds(Fluent, Timestep).

#show ("obs", Timestep, Fluent) : observed(Fluent, Timestep).
#show ("obs", Timestep, -Fluent) : -observed(Fluent, Timestep).

#show ("occurs", Timestep, Action) : occurs(Action, Timestep).
#show ("occurs", Timestep, -Action) : -occurs(Action, Timestep).

#show ("hpd", Timestep, Action) : happened(Action, Timestep).
#show ("hpd", Timestep, -Action) : -happened(Action, Timestep).

#show ("attempt", Timestep, Action) : attempt(Action, Timestep).
#show ("attempt", Timestep, -Action) : -attempt(Action, Timestep).

#show ("permitted", Timestep, Action) : permitted(Action, Timestep).
#show ("permitted", Timestep, -Action) : -permitted(Action, Timestep).

#show ("obl", Timestep, Happening) : obl(Happening, Timestep).
#show ("-obl", Timestep, Happening) : -obl(Happening, Timestep).

#show ("prefer", Preferred, Other) : prefer(Preferred, Other).
