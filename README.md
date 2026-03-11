# Hypatia

Hypatia is a low earth orbit (LEO) satellite network simulation framework. It pre-calculates network state over time, enables packet-level simulations using ns-3 and provides visualizations to aid understanding.

<a href="#"><img alt="Kuiper side-view" src="https://raw.githubusercontent.com/leosatsim/leosatsim.github.io/master/images/Kuiper_side_view.png" width="20%" /></a>
<a href="#"><img alt="Telesat top-view" src="https://raw.githubusercontent.com/leosatsim/leosatsim.github.io/master/images/Telesat_top_view.png" width="20%" /></a>
<a href="#"><img alt="starlink_paris_luanda_short" src="https://raw.githubusercontent.com/leosatsim/leosatsim.github.io/master/images/starlink_paris_luanda_short.png" width="10%" /></a>

It consists of four main components:

* `satgenpy` : Python framework to generate LEO satellite networks and generate 
  routing over time over a period of time. It additionally includes several 
  analysis tools to study individual cases. It makes use of several Python modules
  among which: numpy, astropy, ephem, networkx, sgp4, geopy, matplotlib, 
  statsmodels, cartopy (and its dependent (data) packages: libproj-dev, proj-data,
  proj-bin, libgeos-dev), and exputil.
  More information can be found in `satgenpy/README.md`.
  (license: MIT)

* `ns3-sat-sim` : ns-3 based framework which takes as input the state generated 
  by `satgenpy` to perform packet-level simulations over LEO satellite networks.
  It makes use of the [`satellite`](https://gitlab.inesctec.pt/pmms/ns3-satellite)
  ns-3 module by Pedro Silva to calculate satellite locations over time.
  It uses the [`basic-sim`](https://github.com/snkas/basic-sim/tree/3b32597c183e1039be7f0bede17d36d354696776) 
  ns-3 module to make e.g., running end-to-end TCP flows easier, which makes use of several Python
  modules (e.g., numpy, statsmodels, exputil) as well as several other packages (e.g., OpenMPI, lcov, gnuplot).
  More information can be found in `ns3-sat-sim/README.md`.
  (license: GNU GPL version 2)
  
* `satviz` : Cesium visualization pipeline to generate interactive satellite network
  visualizations. It makes use of the online Cesium API by generating CesiumJS code.
  The API calls require its user to obtain a Cesium access token (via [https://cesium.com/]()).
  More information can be found in `satviz/README.md`.
  (license: MIT)

* `paper` : Experimental and plotting code to reproduce the experiments and 
  figures which are presented in the paper.
  It makes use of several Python modules among which: satgenpy, numpy, networkload, and exputil.
  It uses the gnuplot package for most of its plotting.
  More information can be found in `paper/README.md`.
  (license: MIT)
  
(there is a fifth folder called `integration_tests` which is used for integration testing purposes)

This is the code repository introduced and used in "Exploring the “Internet from space” with Hypatia" 
by Simon Kassing*, Debopam Bhattacherjee*, André Baptista Águas, Jens Eirik Saethre and Ankit Singla
(*equal contribution), which is published in the Internet Measurement Conference (IMC) 2020.

BibTeX citation:
```
@inproceedings {hypatia,
    author = {Kassing, Simon and Bhattacherjee, Debopam and Águas, André Baptista and Saethre, Jens Eirik and Singla, Ankit},
    title = {{Exploring the “Internet from space” with Hypatia}},
    booktitle = {{ACM IMC}},
    year = {2020}
}
```

## Getting started

1. System setup:
   - Python version 3.7+
   - Recent Linux operating system (e.g., Ubuntu 18+)

2. Install dependencies:
   ```
   bash hypatia_install_dependencies.sh
   ```
   
3. Build all four modules (as far as possible):
   ```
   bash hypatia_build.sh
   ```
   
4. Run tests:
   ```
   bash hypatia_run_tests.sh
   ```

5. The reproduction of the paper is essentially the tutorial for Hypatia.
   Please navigate to `paper/README.md`.

### Installation on RHEL / CentOS / HPC Systems

The default installation script (`hypatia_install_dependencies.sh`) is designed for Ubuntu/Debian systems. For RHEL-based systems (RHEL, CentOS, Rocky Linux, AlmaLinux) or HPC environments where you don't have sudo access, follow these steps:

#### Prerequisites

- Python 3.7+
- MPI library (OpenMPI or MVAPICH) - typically available via `module load` on HPC systems
- Boost library - typically available via `module load` on HPC systems
- C++ compiler (gcc or Intel icpc)

#### Step 1: Load Required Modules (HPC Systems)

```bash
# Example for systems with Lmod
module load openmpi/5.0.2
module load boost/1.83.0
```

#### Step 2: Install Python Dependencies

```bash
# Core dependencies
pip install --user numpy astropy ephem networkx sgp4 geopy matplotlib statsmodels

# Cartopy (requires proj/geos - usually pre-installed on RHEL)
pip install --user cartopy

# Custom packages
pip install --user git+https://github.com/snkas/exputilpy.git@v1.6
pip install --user git+https://github.com/snkas/networkload.git@v1.3
```

#### Step 3: Initialize Git Submodules

```bash
git submodule update --init --recursive
```

#### Step 4: Patch Boost Detection (Python 3 Compatibility)

The waf build system has a Python 3 compatibility issue in the boost detection code. Apply this patch:

```bash
# Edit ns3-sat-sim/simulator/waf-tools/boost.py
# Find line 186 (in function boost_get_toolset):
#   return isinstance(toolset, str) and toolset or toolset(self.env)
# Replace with:
#   if isinstance(toolset, str):
#       return toolset
#   else:
#       return toolset(self.env)
```

Or apply using sed:
```bash
sed -i 's/return isinstance(toolset, str) and toolset or toolset(self.env)/if isinstance(toolset, str):\n\t\treturn toolset\n\telse:\n\t\treturn toolset(self.env)/' ns3-sat-sim/simulator/waf-tools/boost.py
```

**Note:** This patch must be applied AFTER running `build.sh` because the build script extracts a fresh copy from `ns-3.31.zip`. For manual builds, patch the file after extraction.

#### Step 5: Build ns3-sat-sim

The standard `build.sh` script extracts a fresh copy and overwrites patches. For RHEL, build manually:

```bash
cd ns3-sat-sim

# If building for the first time, extract ns-3.31
unzip ns-3.31.zip
cp -r ns-3.31/* simulator/
rm -r ns-3.31

# Apply the boost.py patch HERE (after extraction, before configure)
cd simulator
# Apply the patch as described in Step 4

# Configure and build
./waf configure --build-profile=debug --enable-mpi --enable-examples --enable-tests --out=build/debug_all
./waf -j4
```

For optimized builds:
```bash
./waf configure --build-profile=optimized --enable-mpi --out=build/optimized
./waf -j4
```

#### Step 6: Run Tests

```bash
# Test satgenpy
cd satgenpy
python3 -m unittest discover -v -s tests
cd ..

# Test ns3-sat-sim
cd ns3-sat-sim/simulator
cd test_data && bash extract_test_data.sh && cd ..
python3 test.py -v -s "satellite-network"
cd ../..
```

#### Known Issues on RHEL/HPC

1. **Intel Compiler Warnings**: If using Intel icpc, you'll see deprecation warnings. These are informational only and don't affect the build.

2. **lcov Not Available**: Coverage reports require lcov which may not be installed. Tests will still pass without it.

3. **One satgenpy Test Failure**: `test_around_equator_connectivity_with_starlink` may fail due to a file format issue. This is a minor test data issue, not an installation problem.

4. **Package Names Differ**: RHEL uses different package names:
   - Ubuntu `libproj-dev` → RHEL `proj-devel`
   - Ubuntu `libgeos-dev` → RHEL `geos-devel`
   - Ubuntu `libopenmpi-dev` → RHEL `openmpi-devel`

#### Verification

```bash
# Verify Python dependencies
python3 -c "import numpy, astropy, ephem, networkx, sgp4, geopy, matplotlib, statsmodels, cartopy, exputil, networkload; print('All dependencies OK')"

# Verify ns3-sat-sim build
test -d ns3-sat-sim/simulator/build/debug_all && echo "Build OK" || echo "Build missing"
```

### Visualizations
Most of the visualizations in the paper are available [here](https://leosatsim.github.io/).
All of the visualizations can be regenerated using scripts available in `satviz` as discussed above.

Below are some examples of visualizations:

- SpaceX Starlink 5-shell side-view (left) and top-view (right). To know the configuration of the shells, click [here](https://leosatsim.github.io/).

  <a href="#"><img alt="Starlink side-view" src="https://raw.githubusercontent.com/leosatsim/leosatsim.github.io/master/images/Starlink_side_view.png" width="45%" /></a>
  <a href="#"><img alt="Starlink top-view" src="https://raw.githubusercontent.com/leosatsim/leosatsim.github.io/master/images/Starlink_top_view.png" width="45%" /></a>

- Amazon Kuiper 3-shell side-view (left) and top-view (right). To know the configuration of the shells, click [here](https://leosatsim.github.io/kuiper.html).

  <a href="#"><img alt="Kuiper side-view" src="https://raw.githubusercontent.com/leosatsim/leosatsim.github.io/master/images/Kuiper_side_view.png" width="45%" /></a>
  <a href="#"><img alt="Kuiper top-view" src="https://raw.githubusercontent.com/leosatsim/leosatsim.github.io/master/images/Kuiper_top_view.png" width="45%" /></a>

- RTT changes over time between Paris and Luanda over Starlink 1st shell. Left: 117 ms, Right: 85 ms. Click on the images for 3D interactive visualizations.

  <a href="https://leosatsim.github.io/starlink_550_path_Paris_1608_Luanda_1650_46800.html"><img alt="starlink_paris_luanda_long" src="https://raw.githubusercontent.com/leosatsim/leosatsim.github.io/master/images/starlink_paris_luanda_long.png" width="35%" /></a>
  <a href="https://leosatsim.github.io/starlink_550_path_Paris_1608_Luanda_1650_139900.html"><img alt="starlink_paris_luanda_short" src="https://raw.githubusercontent.com/leosatsim/leosatsim.github.io/master/images/starlink_paris_luanda_short.png" width="35%" /></a>

- Link utilizations change over time, even with the input traffic being static. For Kuiper 1st shell, path between Chicago and Zhengzhou at 10s (top) and 150s (bottom). Click on the images for 3D interactive visualizations.

  <a href="https://leosatsim.github.io/kuiper_630_path_wise_util_Chicago_1193_Zhengzhou_1243_10000.html"><img alt="kuiper_Chicago_Zhengzhou_10s" src="https://raw.githubusercontent.com/leosatsim/leosatsim.github.io/master/images/kuiper_Chicago_Zhengzhou_10s.png" width="90%" /></a>
  <a href="https://leosatsim.github.io/kuiper_630_path_wise_util_Chicago_1193_Zhengzhou_1243_150000.html"><img alt="kuiper_Chicago_Zhengzhou_150s" src="https://raw.githubusercontent.com/leosatsim/leosatsim.github.io/master/images/kuiper_Chicago_Zhengzhou_150s.png" width="90%" /></a>
