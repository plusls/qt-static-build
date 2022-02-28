#!bin/bash

if [ -z "$1" ]
then
    echo "Missing argument for target Qt version tag."
    exit 1
fi

CMAKE_VERSION="3.22.2"

export DEBIAN_FRONTEND=noninteractive

apt-get update && apt-get -y dist-upgrade && \
apt install -y zstd git libicu-dev wget ninja-build build-essential libfontconfig1-dev libfreetype6-dev libx11-dev  \
    libxext-dev libxfixes-dev '^libxcb.*-dev' libx11-xcb-dev libglu1-mesa-dev libxrender-dev libxi-dev libxkbcommon-dev libxkbcommon-x11-dev

wget "https://github.com/Kitware/CMake/releases/download/v$CMAKE_VERSION/cmake-$CMAKE_VERSION-linux-x86_64.tar.gz"

tar -xvf "cmake-$CMAKE_VERSION-linux-x86_64.tar.gz"

export PATH="$(pwd)/cmake-$CMAKE_VERSION-linux-x86_64/bin:$PATH"


git clone https://github.com/qt/qtbase --branch $1 --verbose --depth 1
mkdir qt-build && cd qt-build
cmake ../qtbase \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_SHARED_LIBS=OFF \
    -DQT_FEATURE_sql=OFF \
    -DQT_FEATURE_dbus=OFF \
    -DQT_FEATURE_testlib=OFF \
    -DQT_FEATURE_qmake=OFF \
    -DCMAKE_INSTALL_PREFIX=../installed-static \
    -GNinja
cmake --build . --parallel
cmake --install .
cd ..

git clone https://github.com/qt/qtsvg --branch $1 --verbose --depth 1
mkdir qtsvg-build && cd qtsvg-build
../installed-static/bin/qt-configure-module ../qtsvg/
cmake --build . --parallel
cmake --install .
cd ..

git clone https://github.com/qt/qtdeclarative --branch $1 --verbose --depth 1
mkdir qtdeclarative-build && cd qtdeclarative-build
../installed-static/bin/qt-configure-module ../qtdeclarative/
cmake --build . --parallel
cmake --install .
cd ..

git clone https://github.com/qt/qtwayland --branch $1 --verbose --depth 1
mkdir qtwayland-build && cd qtwayland-build
../installed-static/bin/qt-configure-module ../qtwayland/
cmake --build . --parallel
cmake --install .
cd ..

git clone https://github.com/qt/qt5compat --branch $1 --verbose --depth 1
mkdir qt5compat-build && cd qt5compat-build
../installed-static/bin/qt-configure-module ../qt5compat/
cmake --build . --parallel
cmake --install .
cd ..
