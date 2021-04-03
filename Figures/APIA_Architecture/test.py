#script(python)
# See p. 74 of dissertation for AIA control loop

from itertools import chain

import clingo

from apia_control_loop import \
    ASPSubprogramInstantiation, \
    AIALoopStep, \
    APIAAuthorizationSetting, \
    APIAObligationSetting, \
    APIAConfiguration, \
    GroundingContext, \
    generate_aia_subprograms_to_ground


def main(clingo_control: clingo.Control):
    max_test_number = clingo_control.get_const('test').number
    current_timestep = (max_test_number - 1) // 4
    max_timestep = clingo_control.get_const('max_timestep').number
    aia_step_number = AIALoopStep(((max_test_number - 1) % 4) + 1)

    configuration = APIAConfiguration(authorization=APIAAuthorizationSetting.BEST_EFFORT,
                                      obligation=APIAObligationSetting.BEST_EFFORT)

    aia_subprograms_to_ground = generate_aia_subprograms_to_ground(current_timestep, max_timestep, aia_step_number,
                                                                    configuration)

    # test_X
    subprograms_to_ground = tuple(chain(
        aia_subprograms_to_ground,
        (ASPSubprogramInstantiation(name=f'test_{test_number}', arguments=())
         for test_number in range(1, max_test_number + 1)),
    ))
    print('Grounding:')
    for subprogram in subprograms_to_ground:
        print(f'    {subprogram!r}')
    clingo_control.ground(subprograms_to_ground, GroundingContext)
    solve_handle = clingo_control.solve(yield_=True, async_=True)

    stable_models = 0
    optimal_stable_models = 0
    for model in solve_handle:
        print()
        print(f'Answer: {model.number} (Optimal: {model.optimality_proven})')
        if model.optimality_proven == True:
            optimal_stable_models += 1
        else:
            stable_models += 1
        for symbol in model.symbols(shown=True):
            print(symbol)

    solve_result = solve_handle.get()
    print()
    print('Summary:')
    print(f'Solve result: {solve_result}')
    print(f'Enumerated models: {stable_models + optimal_stable_models}')
    print(f'  Normal models: {stable_models}')
    print(f'  Optimal models: {optimal_stable_models}')

#end.
