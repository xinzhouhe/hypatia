# Main information
echo "Hypatia: installing dependencies (Fedora 43)"
echo ""
echo "This script is adapted for Fedora 43 from the original Ubuntu-based script."
echo "Python version 3.7+ is required."
echo ""

# General
sudo dnf check-update; true   # non-zero exit on available updates is normal; don't abort

# satgenpy
echo "Installing dependencies for satgenpy..."
pip install numpy astropy ephem networkx sgp4 geopy matplotlib statsmodels || exit 1
sudo dnf install -y proj-devel proj-data proj geos-devel || exit 1
pip install git+https://github.com/snkas/exputilpy.git@v1.6 || exit 1
pip install cartopy || exit 1

# ns3-sat-sim
echo "Installing dependencies for ns3-sat-sim..."
sudo dnf install -y openmpi openmpi-devel lcov gnuplot || exit 1
# On Fedora, load the OpenMPI environment module so mpicc/mpirun are on PATH:
#   module load mpi/openmpi-x86_64
# You can add this to your ~/.bashrc or source it before building.
pip install numpy statsmodels || exit 1
pip install git+https://github.com/snkas/exputilpy.git@v1.6 || exit 1
git submodule update --init --recursive || exit 1

# satviz
echo "There are currently no dependencies for satviz."

# paper
echo "Installing dependencies for paper..."
pip install numpy || exit 1
pip install git+https://github.com/snkas/exputilpy.git@v1.6 || exit 1
pip install git+https://github.com/snkas/networkload.git@v1.3 || exit 1
sudo dnf install -y gnuplot

# Confirmation dependencies are installed
echo ""
echo "Hypatia dependencies have been installed."
echo ""
echo "IMPORTANT: Before building ns3-sat-sim, load the OpenMPI module:"
echo "  module load mpi/openmpi-x86_64"
