# Boot Timer with grabserial

This project sets up a conda environment to measure boot time on embedded devices via serial output. Specifically, it captures the time between:

- `Starting kernel...`
- `Welcome to Buildroot`

## 🧪 Requirements

- Conda (Miniconda or Anaconda)
- Serial access to your device (e.g. `/dev/ttyUSB0`)

## ⚙️ Setup

1. Create the conda environment:
   ```bash
   conda env create -f environment.yml
   ```
