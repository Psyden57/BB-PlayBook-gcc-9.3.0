# GCC 9.3.0 Toolchain for BlackBerry Playbook (QNX 6.5.0)

This repository contains the build scripts and pre-compiled binaries for a fully cross-compiled GCC 9.3.0 toolchain tailored specifically for the BlackBerry Playbook's OMAP 4430 architecture (ARM Cortex-A9, NEON VFPv3 FPU) running QNX 6.5.0.

This toolchain brings modern C++11/C++14/C++17 features to the Playbook, overcoming the limitations of the ancient GCC 4.4 compiler originally shipped with the NDK.

## Downloads
You can download the pre-compiled toolchain and runtime libraries from the **[Releases](../../releases)** page.
- **Toolchain:** `playbook-gcc-9.3.0-linux-x86_64.tar.gz` (For 64-bit Linux hosts)
- **Runtime Libraries:** `playbook-runtime-libs.tar.gz` (For the Playbook device)

---

## 1. Installation (Linux Host)

Extract the toolchain to a directory of your choice. For example, to `/opt/playbook-gcc9`:
```bash
sudo mkdir -p /opt/playbook-gcc9
sudo tar -xzf playbook-gcc-9.3.0-linux-x86_64.tar.gz -C /opt/playbook-gcc9
```

## 2. Environment Setup

To use the cross-compiler, you need to add its `bin` directory to your path and set up the QNX environment variables.

Create a script `env.sh` (or add to your `.bashrc`):
```bash
#!/bin/bash
export QNX_TARGET="/opt/playbook-gcc9/qnx650"
export PATH="${QNX_TARGET}/bin:${PATH}"

# The compiler binaries use this prefix
export CXX="arm-blackberry-qnx8eabi-g++"
export CC="arm-blackberry-qnx8eabi-gcc"
```

Source the script to activate the toolchain:
```bash
source env.sh
```

## 3. Compiling Modern C++

You can now compile modern C++ code targeting the Playbook! The compiler automatically links against the correct QNX 6.5.0 sysroot and targets the Playbook's Cortex-A9 architecture.

```cpp
// test.cpp
#include <iostream>
#include <thread>
#include <vector>

int main() {
    std::cout << "Hello Playbook from GCC 9.3!" << std::endl;
    return 0;
}
```

Compile it using C++14 or C++17:
```bash
arm-blackberry-qnx8eabi-g++ -std=c++14 -pthread test.cpp -o test_app
```

## 4. Deploying to the Playbook

Because you compiled the application using a modern GCC, it requires modern C++ standard libraries (`libstdc++.so.6` and `libgcc_s.so.1`) at runtime. The Playbook's native OS does not have these.

> **WARNING:** Do NOT overwrite the system libraries in `/usr/lib/` or `/lib/` on your Playbook. Doing so may break native system applications that rely on the old GCC 4.4 ABI.

**Step A: Transfer the Runtime Libraries**
Extract `playbook-runtime-libs.tar.gz` and transfer the `.so` files to your Playbook. We recommend keeping them in an isolated folder like `/tmp/pb_libs` or bundled inside your app's directory.

```bash
scp libstdc++.so.6 libgcc_s.so.1 devuser@<playbook-ip>:/tmp/pb_libs/
```

**Step B: Transfer and Run Your Application**
Transfer your compiled executable (`test_app`) to the Playbook.

```bash
scp test_app devuser@<playbook-ip>:/tmp/
```

SSH into your Playbook and use `LD_LIBRARY_PATH` to instruct the dynamic linker to load the modern libraries before checking the system directories:

```bash
cd /tmp
chmod +x test_app
LD_LIBRARY_PATH=/tmp/pb_libs ./test_app
```

### Packaging Apps (BAR Files)
If you are packaging your application into a `.bar` file using the Native Packager, simply place the `.so` files in your app's `lib` directory inside the package, and set the `LD_LIBRARY_PATH` environment variable in your `bar-descriptor.xml`.

---
*Based on the original [bb10-gcc9](https://github.com/the10101/bb10-gcc9) project, optimized and patched specifically for QNX 6.5.0 on the BlackBerry Playbook.*
