# Icicle en EDU-FPGA

Instrucciones específicas para [EDU-FPGA](http://www.proyecto-ciaa.com.ar/devwiki/doku.php?id=desarrollo%3Aedu-fpga):

## Instalación nativa de las herramientas

Estos pasos fueron probados con `Linux Mint 20 Cinnamon` en un sistema de 64-bits `x86_64`.

### Prerrequisitos

- Crear un directorio de trabajo y posicionarse en él.
```
mkdir -p ~/edufpga-icicle/
cd ~/edufpga-icicle/
```

- Instalar dependencias disponibles en el repositorio (`make`, `vim`, entre otras necesarias para construir las herramientas).

```
sudo apt update
sudo apt install git make arachne-pnr fpga-icestorm vim autoconf automake autotools-dev curl python3 libmpc-dev libmpfr-dev libgmp-dev gawk build-essential bison flex texinfo gperf libtool patchutils bc zlib1g-dev libexpat-dev gtkterm clang libreadline-dev tcl-dev libffi-dev graphviz xdot pkg-config libboost-system-dev libboost-python-dev libboost-filesystem-dev mercurial libftdi-dev qt5-default python3-dev libboost-all-dev cmake libeigen3-dev
```

### Toolchain RISC-V

Clonar y construir el toolchain para `RV32I`. La instalación necesita privilegios de root.

**NOTA**: Este repositorio es grande (~7GB). Clonarlo y luego construirlo lleva tiempo, ¡paciencia!

```
cd ~/edufpga-icicle/
git clone --recursive https://github.com/riscv/riscv-gnu-toolchain
cd riscv-gnu-toolchain

./configure --prefix=/opt/riscv
sudo make # compila e instala
```

### Icarus Verilog

La instalación necesita privilegios de root.

```
cd ~/edufpga-icicle/
git clone git://github.com/steveicarus/iverilog.git
cd iverilog
sh autoconf.sh
./configure
make
sudo make install
```

### IceStorm

La instalación necesita privilegios de root.

```
cd ~/edufpga-icicle/
git clone https://github.com/YosysHQ/icestorm.git icestorm
cd icestorm
make -j$(nproc)
sudo make install
```

### NextPNR

La instalación necesita privilegios de root.

```
cd ~/edufpga-icicle/
git clone https://github.com/YosysHQ/nextpnr nextpnr --recursive
cd nextpnr
cmake -DARCH=ice40 -DCMAKE_INSTALL_PREFIX=/usr/local .
make -j$(nproc)
sudo make install
```

### Yosys

La instalación necesita privilegios de root.

```
cd ~/edufpga-icicle/
git clone https://github.com/YosysHQ/yosys.git yosys
cd yosys
make config-gcc
make -j$(nproc)
sudo make install
```

## Generación del bitstream

- Asegurar que el compilador esté disponible en `PATH`:
```
export PATH=/opt/riscv/bin/:$PATH
```
Así el comando `riscv64-unknown-elf-gcc` debería ser accesible.

- Clonar repositorio, construir y grabar memoria SPI de la EDU-FPGA:
```
cd ~/edufpga-icicle/
git clone https://github.com/ciaa/icicle.git
cd icicle
make BOARD=edufpga
# antes de ejecutar el siguiente comando, conectar la EDU-FPGA a la PC
make BOARD=edufpga flash
```

Así se ve la salida típica de estos comandos:

```
$ make BOARD=edufpga
riscv64-unknown-elf-gcc -march=rv32i -mabi=ilp32 -Wall -Wextra -pedantic -DFREQ=36000000 -Os -ffreestanding -nostartfiles -g -Iprograms/hello   -c -o programs/hello/main.o programs/hello/main.c
riscv64-unknown-elf-gcc -march=rv32i -mabi=ilp32 -Wall -Wextra -pedantic -DFREQ=36000000 -Os -ffreestanding -nostartfiles -g -Iprograms/hello -Wl,-Tprogmem.lds -o progmem programs/hello/main.o start.o
riscv64-unknown-elf-objcopy -O binary progmem progmem.bin
xxd -p -c 4 < progmem.bin > progmem.hex
yosys -q ice40.ys
arachne-pnr -q -d 8k -P tq144:4k -o top_syn.asc -p boards/edufpga.pcf top.blif
icebram progmem_syn.hex progmem.hex < top_syn.asc > top.asc
icepack top.asc top.bin
```
```
$ make BOARD=edufpga flash
icetime -t -m -d hx8k -P tq144:4k -p boards/edufpga.pcf -c 36 -r top.rpt top_syn.asc
// Reading input .pcf file..
// Reading input .asc file..
// Reading 8k chipdb file..
// Creating timing netlist..
// Timing estimate: 27.43 ns (36.45 MHz)
// Checking 27.78 ns (36.00 MHz) clock constraint: PASSED.
iceprog top.bin
init..
cdone: high
reset..
cdone: low
flash ID: 0xEF 0x30 0x13 0x00
file size: 135100
erase 64kB sector at 0x000000..
erase 64kB sector at 0x010000..
erase 64kB sector at 0x020000..
programming..
reading..
VERIFY OK
cdone: high
Bye.
```

¡Listo! Deberías ver destellar los LEDs de la EDU-FPGA y por la UART (`/dev/ttyUSB1`) deberías observar el mensaje `Hello, world!`.
