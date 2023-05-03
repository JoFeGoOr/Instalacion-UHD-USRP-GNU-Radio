***Para comenzar con la instalación, debemos conocer los preámbulos a considerar, se trabajara en Ubuntu 20.04 LTS y se instalara la versión 4.3.0.0 de los drivers para la USRP conocidos como UHD (USRP Hardware Drivers), estos drivers deben ser instalados tanto en la PC de desarrollo como en la USRP, además se instalara GNU-Radio en su versión 3.8-maint.***

# Instalación en la USRP

En función de la simpleza, la parte de la instalación de UHD en la memoria SD de la USRP se hará en Windows 10, el resto de los pasos deben ser hechos en Ubuntu 20.04 LTS

Comenzamos sacando la memoria SD que posee la USRP y la conectamos a nuestro PC de desarrollo.

Luego descargamos todo el software necesario:

+ Descargamos la imagen de UHD con el link a continuación:
https://files.ettus.com/binaries/cache/e3xx/meta-ettus-v4.3.0.0/e3xx_e310_sg3_sdimg_default-v4.3.0.0.zip

+ Descargamos el programa gratuito win32diskimager, el cual nos permite montar la imagen en la memoria USB:
https://win32diskimager.org/#download

Instalamos y abrimos el programa win32diskimager, debemos elegir el archivo "e3xx_e310_sg3_sdimg_default-v4.3.0.0.zip", la memoria USB y hacemos clic en el botón WRITE, este proceso no debería demorar más de 5 minutos.

Una vez finalizado el proceso de montura de imagen, quitamos la memoria USB de nuestra PC de desarrollo y la insertamos en la USRP.

Hasta aquí llegamos respecto a Windows 10, de ahora en adelante todo el proceso será hecho en Ubuntu 20.04 LTS

Con la memoria USB ya en la USRP, conectamos el sistema embebido a la PC de desarrollo tanto por la conexión USB-C como por la conexión RED y encendemos la USRP.

En la PC de desarrollo abrimos una consola de comando, iniciaremos una conexión con la USRP, para lograrlo, haremos lo siguiente.

Ejecutamos lo siguiente:

```
sudo screen /dev/ttyUSB0 115200
```

Escribimos nuestras credenciales y accedemos a una nueva pantalla de login, como es una nueva instalación, el usuario es root y no hay contraseña, una vez dentro, haremos lo siguiente:

```
uhd_find_devices
```

Para asegurarnos que el PC de desarrollo detecta la USRP y que instalamos la versión correcta de UHD (v4.3.0.0), ya seguros continuamos con la configuración de la USRP:

```
ifconfig
```

Notaremos que la USRP no tiene una dirección IP y debemos configurarla de manera estática, para ello haremos lo siguiente:

```
cd /etc/network
vim interfaces 
```

Se nos abrirá un editor de texto, debemos presionar la tecla "esc" y luego la tecla "i" para entrar en modo "insert", en este modo añadiremos el siguiente texto:

```
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet static
address 192.168.10.42
netmask 255.255.255.0
```

Presionamos la tecla "esc", escribimos :wq y enter para guardar un archivo llamado "interfaces" en la carpeta "/etc/network", a continuación configuraremos la USRP para que la IP que se acaba de asignar quede de manera estática, por lo tanto, no debemos configurarla nosotros mismo cada vez que encendamos la usrp, para ello ejecutamos los siguientes comandos:

```
cd /data/network
nano eth0.network
```

Con esto se nos abrirá otro archivo en un editor de texto, esta vez, el archivo ya tiene contenido, el contenido que tenga, debemos cambiarlo, por lo que aparece a continuación:

```
[Match]
Name=eth0
KernelCommandLine=!nfsroot

[Network]
Address=192.168.10.42/24
IPForward=ipv4

[DHCP]
UseHostname=true
UseDomains=true
ClientIdentifier=mac
```

Una vez modificado el contenido, debemos guardar los cambios, para ello presionamos ctrl-o y confirmamos para guardar el archivo y luego presionamos ctrl-x para salir del editor, ya devuelta a la terminal de la USRP, debemos reiniciar la USRP, para ello, podemos ejecutar el siguiente comando.


```
shutdown -r now
```

Una vez reiniciada la USRP, debemos asegurarnos que la asignación de la IP de manera estática se realizó de manera satisfactoria, recordar que la IP estática para la conexión LAN es 192.168.10.42, para confirmar esta IP ejecutamos lo siguiente:

```
ifconfig
```

***Con esto ya podemos constatar que la USRP está con una IP estática lista para ser usada.***

Ya con la USRP configurada y con su IP bien asignada, podemos continuar con la instalación del software necesario para realizar procesamiento de señales, cabe destacar que para concretar la conexión con la USRP, se debe configurar una conexión de red cableada de manera manual, ya que hasta la fecha, la USRP no ha demostrado utilizar el protocolo DHCP, para asegurarnos de que la conexión se configuró con éxito, desde la PC debemos realizar un ping hacia el dispositivo.

# Instalación en PC Host

Ya seguros de que la comunicación entre PC y la USRP, procedemos a instalar todo el software necesario para usar GNU-Radio junto a la USRP e312, esta instalación tomo como base, el sistema operativo Ubuntu 20.04 LTS, pero puede ser llevado a demás distribuciones teniendo cuidado de instalar las dependencias correctas.

Actualizamos las bibliotecas y las dependencias ya instaladas.

```
sudo apt update
sudo apt upgrade
sudo dpkg-reconfigure dash
```

Seleccionamos la opción "no"

```
sudo apt install git cmake g++ libboost-all-dev libgmp-dev swig python3-numpy python3-mako python3-sphinx python3-lxml doxygen libfftw3-dev libsdl1.2-dev libgsl-dev libqwt-qt5-dev libqt5opengl5-dev python3-pyqt5 liblog4cpp5-dev libzmq3-dev python3-yaml python3-click python3-click-plugins python3-zmq python3-scipy python3-gi python3-gi-cairo gobject-introspection gir1.2-gtk-3.0 build-essential libusb-1.0-0-dev python3-docutils python3-setuptools python3-ruamel.yaml python-is-python3
```
  
Creamos las carpetas de trabajo, este paso podría realizarse en otra carpeta y tendría los mismos resultados, pero se recomienda iniciar la instalación con un cierto nivel de orden, ya que así se puede explorar la posibilidad de instalar diferentes versiones de UHD, lo que podría resultar útil en las etapas de debug el desarrollo de software para la USRP.
  
```
mkdir -p ~/src
```
  
Instalamos UHD v4.3.0.0, la misma versión que los drivers instalados en la USRP, este paso es crucial por lo que recomienda tener especial cuidado.

```
cd ~/src    
git clone --branch UHD-4.3 https://github.com/ettusresearch/uhd.git uhd
mkdir uhd/host/build
cd uhd/host/build
cmake ..
make -j8
sudo make install
sudo ldconfig
```

Descargamos los archivos o "imagen" para los drives del FPGA.

```
sudo uhd_images_downloader
```

Instalamos GNU-Radio, la versión que ha demostrado ser la más estable para la utilización de la USRP ha sido la v3.8, pero esta versión no posee los bloques más sofisticados para visualización de señales, por lo que algunas funciones gráficas más actuales podrían no funcionar con esta versión, aun así, el mismo fabricante recomienda esta versión porque ha sido la que más soporte ha recibido y la que más documentación posee, en espacial en el manejo de errores presentes dentro del procesamiento de señales.
  
```
cd ~/src 
git clone --branch maint-3.8 --recursive https://github.com/gnuradio/gnuradio.git gnuradio
mkdir gnuradio/build 
cd gnuradio/build 
cmake ..
make -j8 
sudo make install
sudo ldconfig
```

Instalamos gr-ettus

```
cd ~/src 
git clone --branch maint-3.8-uhd4.0 https://github.com/ettusresearch/gr-ettus.git gr-ettus
mkdir gr-ettus/build 
cd gr-ettus/build 
cmake --DENABLE_QT=True ..
make -j8 
sudo make install
sudo ldconfig
```

Para asegurarse de que se instalaron las versiones correctas de cada software, probamos los siguientes comandos, ellos deben devolver las versiones instaladas.
  
```
uhd_usrp_probe --version
gnuradio-config-info --version
```

Existe la alta posibilidad de que aún realizando toda esta instalación, cuando se intente ejecutar gnu-radio, nos aparezca un error referente a "LD_LIBRARY_PATH", para solucionar este problema se hace lo relatado a continuación.

Debemos modificar un archivo de ejecución.

```
cd
nano ~/.profile
```

Se abrirá un editor de texto, al final de este archivo debemos agregar la siguiente línea de código.

```
export PYTHONPATH=/usr/local/lib/python3/dist-packages:$PYTHONPATH
```

Luego guardamos el archivo con "ctrl+O" y salimos con "ctrl+X", ejecutamos los siguientes comandos

```
source ~/.profile
sudo ldconfig
```

Por último, reiniciamos la PC de desarrollo y se daría por finalizada la instalación de las herramientas básicas para utilizar la USRP E312 con GNU-Radio

***Para iniciar GNU-Radio, se puede iniciar desde la consola, con el comando que se presenta a continuación.***

```
gnuradio-companion
```
# EJECUCIÓN DE CÓDIGO EN LA USRP

Para finalizar con esta guía de instalación, se presentarán los pasos necesarios para ejecutar archivos programados en PYTHON, la idea de gnu-radio es generar un archivo en PYTHON o C++, el cual puede ser cargado en usrp para posteriormente ser ejecutado, para lograr esto se debe hacer lo siguiente.

En la PC de desarrollo, abrimos una terminal y nos posicionamos en la carpeta en donde existe el archivo '.py', a modo de ejemplos, copiaremos un archivo generado por gnu-radio llamado test.py

```
scp -p test.py root@192.168.10.42:/home/root
```

Notamos que debemos hacer una conexión vía SSH, por lo que debemos conocer el nombre de usuario y la IP de la usrp, como hicimos la configuración anteriormente, sabemos que la IP es 192.168.10.42, el usuario es root, además el directorio /home/root/ es el directorio por defecto cuando iniciamos sesión en la usrp, una vez copiado el archivo, dentro de la usrp podemos correr el siguiente comando para asegurarnos de que el archivo se ha copiado con éxito.

```
cd /home/root
ls
```
Si hicimos todo correctamente, debería existir el archivo test.py en la carpeta /home/root dentro de la usrp, si es así, para ejecutar el archivo debemos ejecutar el siguiente comando en la terminal:

```
python3 test.py
```

Si todo se hizo con éxito, el archivo test.py es ejecutado por la usrp, por lo que el usuario ya está capacitado para operar la USRP E312 y desarrollar software para esta.

Con esto se da por finalizada la guía de instalación de la USRP E312, cualquier consulta, puede comunicarse con el autor de esta guía para hacer preguntas correspondiente a esta guía de instalación.
