FROM ubuntu:20.04

RUN apt-get update && \
    apt-get install -y wine64-development python msitools python-simplejson \
                       python-six ca-certificates curl p7zip && \
    apt-get clean -y && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /opt/msvc

COPY lowercase fixinclude install.sh vsdownload.py ./
COPY wrappers/* ./wrappers/
RUN curl -L --output ./llvm-clang-v1.0.0.7z \
    https://github.com/klezVirus/obfuscator/releases/download/v1.0.0/llvm-clang-v1.0.0.7z && \
    7zr x -bb0 llvm-clang-v1.0.0.7z && \
    mv llvm-clang llvm && rm -f llvm-clang-v1.0.0.7z

RUN PYTHONUNBUFFERED=1 ./vsdownload.py --accept-license --dest /opt/msvc && \
    ./install.sh /opt/msvc && \
    rm lowercase fixinclude install.sh vsdownload.py && \
    rm -rf wrappers

# Initialize the wine environment. Wait until the wineserver process has
# exited before closing the session, to avoid corrupting the wine prefix.
RUN wine64 wineboot --init && \
    while pgrep wineserver > /dev/null; do sleep 1; done

# Later stages which actually uses MSVC can ideally start a persistent
# wine server like this:
#RUN wineserver -p && \
#    wine64 wineboot && \
