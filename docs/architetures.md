# Architecture

## Processing element (PE)
- Interface (ports, parameters)
- Timing: a/b forwarding registered, 1-cycle latency
- Reset / clear / enable behavior

## Accumulator width
- K: number of products summed per output (reduction dimension);
  for a convolution, K = kernel_h × kernel_w × C_in
- Scope: the array accelerates convolution layers only (~95% of MACs);
  fully connected layers (~5% of MACs) run on another component (e.g. host CPU)
- Worst case: conv3, K = 3×3×64 = 576 → 16 + ceil(log2 576) = 26 bits
- Choice: ACC_W = 32 (parameter) to generalize this PE to larger models (K<2^32=65,536) and stay on a conventional dimension

## Optimization
- Usually, we use a wire to signal that the accumulated result in the PE is ready to be transmitted.
- We can also observe that we reset a PE only when the accumulated result is ready and at the start. 
- For the input, the most negative value in the range is not used (INT8->-128).
- We can use this value as a reset and as a signal to send the result.

### Trade-offs
- One idle cycle per tile (negligible compared to K = 576 MACs)
- A marker detector per PE (an 8-input AND gate), comparable in area to the flip-flop a propagated clear wire would need
- Inputs must never contain −128: the golden model checks this
- No reset in the PE: the stream must start with a marker; outputs are
  ignored until the first marker has propagated through the array

## Dataflow
- Output-stationary 4×4 array (to be completed)

## Mixed-precision PE
- (to be completed)