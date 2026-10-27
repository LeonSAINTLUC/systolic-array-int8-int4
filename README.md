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
- [ ] FP32 CNN on CIFAR-10
- [ ] INT8 PE with self-checking testbench
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
- **Arithmetic:** signed symmetric INT8, accumulator width `ACC_W` (parameter)

## How to run
### Training (Python)
1. Open `python/notebooks/01_mnist_fp32.ipynb` in Google Colab.
2. Select a GPU runtime (*Runtime → Change runtime type → T4 GPU*).
3. Run all cells. MNIST is downloaded automatically.

### Simulation (SystemVerilog)
*To be completed.*

## Results
### FP32 baseline

| Dataset | Model | Parameters | Size (FP32) | Test accuracy |
|---------|-------|------------|-------------|---------------|
| MNIST | 2 conv + 2 fc | 421,642 | 1.7 MB | 99.08% |

Trained for 3 epochs (Adam, lr = 0.001, batch size 64): 51 s on a T4 GPU.

## References
- Jacob et al., *Quantization and Training of Neural Networks for Efficient Integer-Arithmetic-Only Inference*, CVPR 2018. https://arxiv.org/abs/1712.05877
- Nagel et al., *A White Paper on Neural Network Quantization*, 2021. https://arxiv.org/abs/2106.08295
- Jouppi et al., *In-Datacenter Performance Analysis of a Tensor Processing Unit*, ISCA 2017. https://arxiv.org/abs/1704.04760
- Sze et al., *Efficient Processing of Deep Neural Networks: A Tutorial and Survey*, Proc. IEEE 2017. https://arxiv.org/abs/1703.09039