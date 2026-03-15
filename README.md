# TENDL Cross Section Data (Arrow format)

Pre-built TENDL nuclear cross section data in Apache Arrow IPC format, converted using [nuclear_data_to_yamc_format](https://github.com/fusion-neutronics/nuclear_data_to_yamc_format).

## Download

Grab the latest release artifact from the [Releases](https://github.com/fusion-neutronics/cross_section_data_tendl_2021_arrow/releases) page.

## Building locally

### Prerequisites

- Python 3.9+
- NJOY2016 on PATH (`njoy` binary)
- OpenMC Python package

### Install system packages

```bash
sudo apt-get install -y cmake gfortran git
```

### Build and install NJOY2016

```bash
git clone https://github.com/njoy/NJOY2016.git
cd NJOY2016 && mkdir build && cd build
cmake -DCMAKE_BUILD_TYPE=Release ..
make -j$(nproc)
sudo cp njoy /usr/local/bin/
cd ../..
```

### Install Python dependencies

```bash
pip install "nuclear_data_to_yamc_format>=0.1.3"
pip install --extra-index-url https://shimwell.github.io/wheels openmc
```

### Convert all nuclides

```bash
convert-tendl --release 2023
```

This downloads ~3 GB of ENDF data (if not already present), then converts all isotopes through NJOY at 6 temperatures. Output goes to `tendl-2023-arrow/`.

To convert a single nuclide for testing:

```bash
convert-tendl --release 2023 --nuclides Fe56
```

### Compress and upload to a release

```bash
tar -czf tendl-2023-arrow.tar.gz tendl-2023-arrow/
gh release upload <TAG> tendl-2023-arrow.tar.gz \
  --repo fusion-neutronics/cross_section_data_tendl_2021_arrow \
  --clobber
```

Replace `<TAG>` with the release tag (e.g. `0.0.7`).

### Clean up source files

```bash
rm -rf tendl-2023-endf tendl-2023-download
```
