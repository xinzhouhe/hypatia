# Undo everything installed by hypatia_install_dependencies_fedora.sh
echo "Hypatia: uninstalling dependencies (Fedora 43)"
echo ""
echo "WARNING: This removes packages that were installed for Hypatia."
echo "If any of these were already on your system before, they will be removed too."
echo ""

# pip packages
echo "Removing pip packages..."
pip uninstall -y \
    cartopy \
    networkload \
    exputil \
    statsmodels \
    matplotlib \
    geopy \
    sgp4 \
    networkx \
    ephem \
    astropy \
    numpy

# dnf packages
echo "Removing dnf packages..."
sudo dnf remove -y \
    proj-devel \
    proj-data \
    proj \
    geos-devel \
    openmpi \
    openmpi-devel \
    lcov \
    gnuplot

sudo dnf autoremove -y

echo ""
echo "Hypatia dependencies have been removed."
