

# UART Transmitter-Receiver in Verilog 🛰️

This project simulates a complete **UART (Universal Asynchronous Receiver Transmitter)** system written in Verilog. It includes both transmitter and receiver logic inside a single `top` module, along with a testbench that simulates data transmission and reception.

---

## 🔧 Files

| File          | Description |
|---------------|-------------|
| `uart_tx_rx.v`      | Main module that contains both UART TX and RX logic. Handles baud rate timing, bit sampling, and shift operations. |
| `uart_tx_rx_tb.v` | Testbench that drives the `top` module, simulates transmission of random bytes, and verifies the loopback through TX-RX connection. |

---

## 🔁 Data Transmission Format

Each transmission includes:

- **1 Start Bit (0)**
- **8 Data Bits**
- **1 Stop Bit (1)**

Bit order: LSB first.

---

## ⏱ Baud Rate Timing

- Clock Frequency = `100_000 Hz`
- Baud Rate = `9600 bps`
- Calculated `wait_count` = `clk_value / baud = 100_000 / 9600 ≈ 10`  
- Bit transmission uses a finite state machine (FSM) synced with this count.

---

## ✅ How It Works

- TX module sends a 10-bit framed data (`start + 8-bit + stop`)
- RX module samples at the middle of each bit duration to reconstruct the byte
- Loopback is created by connecting `tx` directly to `rx`
- `rxdone` and `txdone` flags indicate transmission/reception completion
- Testbench sends random 8-bit data and waits for `rxdone` and `txdone` before proceeding to the next

---

## 📊 Simulation

To simulate:

1. Open ModelSim/Vivado/any simulator.
2. Run `uart_tx_rx_tb.v` as the top-level testbench.
3. Observe the waveforms or output data for verification.

---

