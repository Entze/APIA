[`tests.lp`]: tests.lp

# Example S

## Usage

Running:

```bash
AUTHORIZATION_MODE=paranoid
OBLIGATION_MODE=subordinate

./run.sh "run_${AUTHORIZATION_MODE}_${OBLIGATION_MODE}_observations.lp" \
    --authorization-mode "${AUTHORIZATION_MODE}" \
    --obligation-mode "${OBLIGATION_MODE}"
```

Testing (See [`tests.lp`]):

```bash
# Replace the all-caps arguments with 1, 2, etc.
# They are optional.
#   If not specified, you can type in their value via stdin

./test.sh TEST_NUM

../../../Implementation/diff_test.sh ./test.sh PREVIOUS_TEST_NUMBER NEW_TEST_NUMBER

../../../Implementation/walk_through_test.sh ./test.sh STARTING_TEST_NUMBER
```
