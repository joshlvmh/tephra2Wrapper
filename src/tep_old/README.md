# TEPHRA2 implementations and optimisations

## Proposed changes
1. Compiler flags
2. Vectorisation
3. Broadwell specific flags - reduced portability, only run on BCp4?
4. Lookup table for exp()
5. Inline assembly / .S files for high % funcs

## Testing

- Correctness: testbench
- Optimisation: Bash script, intel advisor, optrpt, roofline

## Runtimes

### 30 Runs, T2_stor.txt
Original: 28m 44s

1. 
