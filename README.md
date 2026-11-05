# systolic-array-int8-int4

Variable-precision systolic array (INT8/INT4) in SystemVerilog for quantized NN inference.

A small CNN is trained in PyTorch and quantized by hand (no built-in quantization tools).
A real layer is then run through a 4×4 output-stationary systolic array in simulation,
and the integer results are checked bit-exactly against a Python golden model.

## Goals
- Train a small CNN on MNIST and CIFAR-10 (FP32 baseline)
- Implement post-training quantization manually: scale / zero-point, per-tensor vs per-channel
- Measure accuracy in FP32, INT8 and INT4, and find where it breaks
- Design and verify an INT8 processing element (PE) and a 4×4 systolic array
- Add a dual-INT4 mode (two INT4 MACs per PE, selected by a configuration signal)
- Run a quantized layer through the array and match the Python golden model with zero errors
- Measure cycle count and, if possible, synthesize on FPGA (resources, max frequency)

## Progress
- [x] PyTorch basics and FP32 CNN on MNIST
- [x] FP32 CNN on CIFAR-10
- [x] INT8 PE with self-checking testbench
- [ ] Manual quantization (INT8, INT4, per-tensor / per-channel)
- [ ] Accuracy comparison FP32 / INT8 / INT4
- [ ] 4×4 systolic array verified on random matrices and edge cases
- [ ] Dual-INT4 mode in the PE
- [ ] Real layer exported from Python and matched in simulation
- [ ] Cycle count measurement

## Repository layout
- `rtl/`: SystemVerilog design (PE, systolic array)
- `tb/`: testbenches
- `python/`: training, quantization, export (`python/notebooks/` for Colab)
- `checkpoints/`: trained model weights (`mnist_fp32.pt`: FP32 baseline)
- `scripts/`: simulation and comparison scripts
- `results/`: tables and plots
- `docs/`: design notes and diagrams

## Design choices
- **Dataflow:** output-stationary (planned)
- **Arithmetic:** signed symmetric INT8, accumulator width `ACC_W` (parameter), input width `DATA_W` (parameter)

## How to run
### Training (Python)
1. Open `python/notebooks/01_mnist_fp32.ipynb` (or an other notebook) in Google Colab.
2. Select a GPU runtime (*Runtime → Change runtime type → T4 GPU*).
3. Run all cells. MNIST(or CIFAR10) is downloaded automatically.

### Simulation (SystemVerilog)
1. Download Verilator 5.0> and GTK Wave
2. Launch the script `pe_int8_tb.sv` (need wsl for Windows)
3. If the test are passed. PASS will be display else FAIL is display with an error description


## Results
### FP32 baseline

| Dataset | Model | Parameters | Size (FP32) | Test accuracy |
|---------|-------|------------|-------------|---------------|
| MNIST | 2 conv + 2 fc | 421,642 | 1.7 MB | 99.08% |
| CIFAR10 | 3 conv + 2 fc | 620,586 | 2.5 MB | 84.60% |

MNIST trained for 3 epochs (Adam, lr = 0.001, batch size 64): 51 s on a T4 GPU.
CIFAR10 trained for 30 epochs (Adam, lr = 0.001,weight_decay=0.0005, batch size 64): 6 min on a T4 GPU.

### PE verification

Run with `scripts/sim_pe_int8.sh [options]`.

| Test configuration | Purpose | Expected result | Observed |
|--------------------|---------|-----------------|----------|
| (default) |Functional tests: forwarding, signed products, marker, 576-MAC accumulation| PASS | PASS |
|--x-initial unique|Start-up without reset: registers start with random values (Verilator is 2-state; a 4-state simulator would show X)| PASS | PASS |
|-GACC_W=23|Verify overflow when the accumulator value reach its max| FAIL | FAIL |
|-GDATA_W=4 (change the value test to match INT4 requirement)|PE is working in INT4| PASS | PASS |


## References
- Jacob et al., *Quantization and Training of Neural Networks for Efficient Integer-Arithmetic-Only Inference*, CVPR 2018. https://arxiv.org/abs/1712.05877
- Nagel et al., *A White Paper on Neural Network Quantization*, 2021. https://arxiv.org/abs/2106.08295
- Jouppi et al., *In-Datacenter Performance Analysis of a Tensor Processing Unit*, ISCA 2017. https://arxiv.org/abs/1704.04760
- Sze et al., *Efficient Processing of Deep Neural Networks: A Tutorial and Survey*, Proc. IEEE 2017. https://arxiv.org/abs/1703.09039

- PyTorch Tutorials, *Learn the Basics*. https://docs.pytorch.org/tutorials/beginner/basics/intro.html
- torchvision documentation, *Transforming and augmenting images*. https://docs.pytorch.org/vision/stable/transforms.html