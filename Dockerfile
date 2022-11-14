FROM ubuntu:20.04

RUN apt-get update && \
    apt-get install -y wine64-development python3 msitools python3-simplejson \
                       python3-six ca-certificates && \
    apt-get clean -y && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /opt
RUN curl -L --output ./obfuscator-llvm-v12.0.0.7z \
    https://github.com/hudjefa/obfuscator-llvm/releases/download/v12.0.0/obfuscator-llvm-v12.0.0.7z && \
    7zr x -bb0 obfuscator-llvm-v12.0.0.7z && rm -f obfuscator-llvm-v12.0.0.7z

WORKDIR /opt/msvc
COPY lowercase fixinclude install.sh vsdownload.py ./
COPY wrappers/* ./wrappers/

RUN PYTHONUNBUFFERED=1 ./vsdownload.py --accept-license --dest /opt/msvc && \
    ./install.sh /opt/msvc && \
    rm lowercase fixinclude install.sh vsdownload.py && \
    rm -rf wrappers

COPY msvcenv-native.sh /opt/msvc

# Initialize the wine environment. Wait until the wineserver process has
# exited before closing the session, to avoid corrupting the wine prefix.
RUN wine64 wineboot --init && \
    while pgrep wineserver > /dev/null; do sleep 1; done

# Later stages which actually uses MSVC can ideally start a persistent
# wine server like this:
#RUN wineserver -p && \
#    wine64 wineboot && \
