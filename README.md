# GCC 9.3.0 toolchain for BlackBerry PlayBook (QNX 6.5.0)

This repository contains the build scripts and pre-compiled binaries for a fully cross-compiled GCC 9.3.0 toolchain tailored specifically for the BlackBerry PlayBook.

This toolchain brings modern C++11/C++14/C++17 features to the PlayBook.

## Downloads
You can download the pre-compiled toolchain and runtime libraries from the **[Releases](../../releases)** page.
- **Toolchain:** `playbook-gcc-9.3.0-toolchain.tar.gz` (For 64-bit Linux hosts)
- **Runtime libraries:** `playbook-gcc-9.3.0-target-libs.tar.gz` (For the PlayBook device)

---

## 1. Installation (Linux Host)

Extract the toolchain to a directory of your choice. For example, to `/opt/playbook-gcc9`:
```bash
sudo mkdir -p /opt/playbook-gcc9
sudo tar -xzf playbook-gcc-9.3.0-toolchain.tar.gz -C /opt/playbook-gcc9
```

## 2. Environment setup

To use the cross-compiler, you need to add its `bin` directory to your path and set up the QNX environment variables. An `env.sh` script is automatically included in the root of the toolchain folder to do this for you.

Simply source the script to activate the toolchain in your current terminal session:
```bash
cd /opt/playbook-gcc9
source env.sh
```

You can now use `$CXX` or `arm-blackberry-qnx8eabi-g++` from any directory.

## 3. Compiling modern C++

You can now compile modern C++ code targeting the PlayBook. The compiler automatically links against the correct QNX 6.5.0 sysroot and targets the PlayBook's Cortex-A9 architecture.

```cpp
// test.cpp
#include <iostream>
#include <thread>
#include <vector>

int main() {
    std::cout << "Hello from GCC 9.3!" << std::endl;
    return 0;
}
```

Compile it using C++14 or C++17:
```bash
arm-blackberry-qnx8eabi-g++ -std=c++17 -pthread test.cpp -o test_app
```
(You can also use `$CXX` to shorten the `arm-blackberry-qnx8eabi-g++` command)

### Porting complex software (ICU, WebKit, etc.)
When building larger libraries that use QNX math templates, add `-D_HAS_GENERIC_TEMPLATES=0` to your `CXXFLAGS`. This prevents an ambiguous overload error between QNX's Dinkumware C++ math templates and GNU libstdc++'s own `<cmath>` overloads (e.g., `fmod(double, int)`):

```bash
arm-blackberry-qnx8eabi-g++ -std=c++17 -D_HAS_GENERIC_TEMPLATES=0 mylib.cpp -o mylib
```

## 4. Deploying to the PlayBook

Because you compiled the binary using a modern GCC, it requires modern C++ standard libraries (`libstdc++.so.6` and `libgcc_s.so.1`) at runtime. The PlayBook's native OS does not have these.

**Step A: Transfer the runtime libraries**
Extract `playbook-gcc-9.3.0-target-libs.tar.gz` and transfer the `.so` files to your PlayBook. I recommend keeping them in an isolated folder like `/accounts/devuser/lib` or bundled inside your app's directory.
(Assuming you have either blackberry-connect or an SSH session already running)
```bash
scp -o StrictHostKeyChecking=no -o HostKeyAlgorithms=+ssh-rsa -o PubkeyAcceptedKeyTypes=+ssh-rsa -o MACs=+hmac-sha1 -i rsa libstdc++.so.6 libgcc_s.so.1 devuser@<playbook-ip>:/accounts/devuser/lib/
```

**Step B: Transfer and run your binary**
Transfer your compiled executable (`test_app`) to the Playbook.

```bash
scp -o StrictHostKeyChecking=no -o HostKeyAlgorithms=+ssh-rsa -o PubkeyAcceptedKeyTypes=+ssh-rsa -o MACs=+hmac-sha1 -i rsa test_app devuser@<playbook-ip>:/accounts/devuser/
```

SSH into your PlayBook and use `LD_LIBRARY_PATH` to instruct the dynamic linker to load the modern libraries before checking the system directories:

```bash
cd /accounts/devuser/
chmod +x test_app
LD_LIBRARY_PATH=/accounts/devuser/lib/ ./test_app
```

### Packaging apps (BAR Files)
If you are packaging your application into a `.bar`, simply place the `.so` files in your app's `lib` directory inside the package, and set the `LD_LIBRARY_PATH` environment variable in your `bar-descriptor.xml`.

---

## 5. Building from source

If you prefer to compile the toolchain yourself instead of using the pre-compiled binaries:

1. **Extract the BlackBerry NDK**: Ensure you have the BlackBerry NDK 2.1.0 extracted on your Linux host.
2. **Set BBNDK_ROOT**: Set the environment variable to point to your NDK installation.
   ```bash
   export BBNDK_ROOT=/path/to/bbndk-2.1.0
   ```
3. **Clone the repository**:
   ```bash
   git clone https://github.com/Psyden57/BB-PlayBook-gcc-9.3.0.git
   cd BB-PlayBook-gcc-9.3.0
   ```
4. **Build and install**:
   The `build.sh` script will automatically download the GNU GCC and Binutils sources, apply the QNX patches, and build the toolchain.
   ```bash
   ./build.sh all build
   ./build.sh all install
   ```
5. **Output**:
   The fully compiled toolchain will be located in `out/playbook-gcc9/`.

### Extracting runtime libraries manually
If you build from source and need to grab the `.so` files yourself (for the target device), the `build.sh` script automatically copies them to a convenient folder for you:
- `out/target-libs/libstdc++.so.6`
- `out/target-libs/libgcc_s.so.1`

---
*Based on the original [bb10-gcc9](https://github.com/extrowerk/bb10-gcc9) project, optimized and patched specifically for QNX 6.5.0 on the BlackBerry PlayBook.*
