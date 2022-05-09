# Ataque cambio de comportamiento en un programa al detectar una secuencia de código en icicle en EDU-FPGA

Más detalles en:

https://seguridad-agile.blogspot.com/2021/09/h4ck3d-2021-configuracion-basica.html

https://seguridad-agile.blogspot.com/2021/09/h4ck3d-2021-leyendo-los-botones-de-la.html

https://seguridad-agile.blogspot.com/2021/09/h4ck3d-2021-un-desvio-necesario.html

https://seguridad-agile.blogspot.com/2021/09/h4ck3d-2021-un-desvio-innecesario.html

https://seguridad-agile.blogspot.com/2021/10/h4ck3d-2021-sigue-el-desvio-para-bien.html

https://seguridad-agile.blogspot.com/2021/10/h4ck3d-2021-cambios-al-makefile.html

https://seguridad-agile.blogspot.com/2021/10/h4ck3d-2021-mejor-resolucion-de.html

https://seguridad-agile.blogspot.com/2021/11/h4ck3d-2021-el-escenario-y-el-programa.html

https://seguridad-agile.blogspot.com/2021/11/h4ck3d-2021-el-ataque-concreto.html


## Falta revisión

Instrucciones específicas para [EDU-FPGA](http://www.proyecto-ciaa.com.ar/devwiki/doku.php?id=desarrollo%3Aedu-fpga):

## Instalación nativa de las herramientas

Estos pasos fueron probados con `Linux Mint 21 Mate` en un sistema de 64-bits `x86_64`.

### Prerrequisitos

- Crear un directorio de trabajo y posicionarse en él.
```
mkdir -p ~/workspace/
cd ~/workspace/
```

- Instalar dependencias disponibles en el repositorio.

```
sudo apt update
sudo apt install gperf build-essential cmake python3-dev texinfo vim libboost-all-dev tcl-dev libreadline-dev libffi-dev libeigen3-dev

```

### Toolchain RISC-V

Clonar y construir el toolchain para `RV32I`. La instalación necesita privilegios de root.

**NOTA**: Este repositorio es grande (~7GB). Clonarlo y luego construirlo lleva tiempo, ¡paciencia!

```
cd ~/workspace/
git clone --recursive https://github.com/riscv/riscv-gnu-toolchain
cd riscv-gnu-toolchain

./configure --enable-multilib
sudo make # compila e instala
```

### Icarus Verilog

La instalación necesita privilegios de root.

```
cd ~/workspace/
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
cd ~/workspace/
git clone https://github.com/YosysHQ/icestorm.git icestorm
cd icestorm
make -j$(nproc)
sudo make install
```

### NextPNR

La instalación necesita privilegios de root.

```
cd ~/workspace/
git clone https://github.com/YosysHQ/nextpnr nextpnr --recursive
cd nextpnr
cmake -DARCH=ice40 -DCMAKE_INSTALL_PREFIX=/usr/local .
make -j$(nproc)
sudo make install
```

### Yosys

La instalación necesita privilegios de root.

```
cd ~/workspace/
git clone https://github.com/YosysHQ/yosys.git yosys
cd yosys
make config-gcc
make -j$(nproc)
sudo make install
```

## Permisos

Para que `iceprog` pueda acceder a la placa, puede hacer falta:
 
```
echo 'ACTION=="add", ATTR{idVendor}=="0403", ATTR{idProduct}=="6010", MODE:="666"' |\
sudo tee -a /etc/udev/rules.d/70-lattice.rules 1>/dev/null
sudo service udev restart
```
## Conexión en Virtual Box

No te olvides de conectar a la virtual:

Devices -> USB -> FTDI Dual RS232-HS[0700]

## Generación del bitstream


- Clonar repositorio, construir y grabar memoria de la EDU-FPGA:
```
cd ~/workspace/
git clone https://github.com/cpantel/evilCodeSequence.git
cd evilCodeSequence
# esto construirá el programa demofull
make software hardware system
# antes de ejecutar el siguiente comando, conectar la EDU-FPGA a la PC
make flash
```

Así se ve la salida típica de estos comandos:

![](./img/software.png)
![](./img/hardware.png)
![](./img/system.png)
![](./img/flash.png)


¡Listo! Si conectaras unos switches al PMOD1, unos leds al PMOD0, un servo y unos leds al conector Arduino, verías...

Para compilar y desplegar otros programas:

```
make PROGRAM=rtc2uart
```
## TODO

  - Terminar de hacer funcionar K.I.T.T. 
  - Diseñar e implementar **sequencer**
  - Agregar lo que verías al paso anterior
  - Agregar diagrama e imagen con el conexionado para **fulldemo**
  - Orquestar mejor los readme legacy
  - Explicar como funciona
  - Explicar la evolución 
