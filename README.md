***Para comenzar con la instalacion, debemos conocer los preambulos a considerar, se trabajara en ubuntu 20.04 LTS y se instalara la versión 4.3.0.0 de los drivers para la USRP conocidos como UHD (USRP Hardware Drivers), estos drivers deben ser instalados tanto en la PC de desarrollo como en la USRP, ademas se instalara GNU-Radio en su version 3.8-maint.***

# Instalacion en la USRP

En funcion de la simplesa, la parte de la instalacion de UHD en la memoria SD de la USRP se hara en Windows 10, el resto de los pasos deben ser hecho en Ubuntu 20.04 LTS

Comenzamos sacando la memoria SD que posee la USRP y la conectamos a nuestro PC de desarrollo.

Luego descargamos todo el software necesario:

+ Descargamos la imagen de UHD con el link a continuacion:
https://files.ettus.com/binaries/cache/e3xx/meta-ettus-v4.3.0.0/e3xx_e310_sg3_sdimg_default-v4.3.0.0.zip

+ Descargamos el programa gratuito win32diskimager, el cual nos permite montar la imagen en la memoria USB:
https://win32diskimager.org/#download

Instalamos y abrimos el programa win32diskimager, debemos elegir el archivo "e3xx_e310_sg3_sdimg_default-v4.3.0.0.zip", la memoria USB y le damos al boton de WRITE, este proceso no deberia demorar más de 5 minutos.

Una vez finalizado el proceso de montura de imagen, quitamos la memoria USB de nuestra PC de desarrollo y la insertamos en la USRP.

Hasta aqui llegamos respecto a Windows 10, de ahora en adelante todo el proceso sera hecho en Ubuntu 20.04 LTS

Con la memoria USB ya en la USRP, conectamos el sistema embebido a la PC de desarrollo tanto por la conexcion USB-C como por la conexion RED y encendemos la USRP.

En la PC de desarrollo abrimos una consola de comando he iniciaremos una conexion con la USRP, para lograrlo, haremos lo siguiente.

Ejecutamos lo siguiente:

```
sudo screen /dev/ttyUSB0 115200
```

Escribimos nuestras credenciales y accedemos a una nueva pantalla de login, como es una nueva instalacion, el ususarios es root y no hay contraseña, una vez dentro, haremos lo siguiente:

```
uhd_find_devices
```

Para asegurarnos que el PC de desarrollo detecta la USRP y que instalamos la vesion correcta de UHD (v4.3.0.0), ya seguros continuamos con la configuracion de la USRP:

```
ifconfig
```

Notaremos que la USRP no tiene una direcion IP y debemos configurarla de manera estica, para ello haremos lo siguiente:

```
cd /etc/network
vim interfaces 
```

Se nos abrira un editor de texto, debemos presionar la tecla "esc" y luego la tecla "i" para entrar en modo insert, en este modo añadiremos el siguiente texto:

```
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet static
address 192.168.10.42
netmask 255.255.255.0
```

Presionamos la tecla "esc", escribimos :wq y enter para guardar un archivo llamado "interfaces" en la carpeta "/etc/network", a continuacion configurarmemos la USRP para que la ip que se acaba de asignar quede de manera estatica y por lo tanto, no debamos configurarla nosotros mismo cada vez que encendamos la usrp, para ello ejecutamos los siguientes comandos:

```
cd /data/network
nano eth0.network
```

Con esto se nos abrira otro archivo en un editor de texto, esta vez, el archivo ya tiene contenido, el contenido que tenga, debemos cambiarlo por lo que aparece a continuacion:

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

Una vez reiniciada la USRP, debemos asegurarnos que la asignacion de la ip de manera estatica se realizo de manera satisfactoria, recordar que la IP estatica para la conexion lan es 192.168.10.42, para confirmar esta ip ejecutamos lo siguiente:

```
ifconfig
```

***Con esto ya podemos constatar que la USRP esta con una IP estatica lista para ser usada.***

Ya con la USRP configurada y con su ip bien asignada, podemos continuar con la instalacion del software necesario para realizar procesamiento de señales, cabe destacar que para concretar la conexion con la USRP, se debe configurar una conexion de red cableada de manera manual, ya que hasta la fecha, la USRP no ha demostrado utilizar el protocolo DHCP, para asegurarnos de que la conexion se configuro con exito, desde la PC debemos realizar un ping hacia el dispositivo.

# Instalacion en PC Host

Ya seguros de que la comunicacion entre PC y la USRP, procedemos a instalar todo el software necesario para usar GNU-Radio junto a la USRP e312,
esta instalacion tomo como base, el sistema operativo Ubuntu 20.04 LTS, pero puede ser llevado a demas distribuciones teniendo cuidado de instalar las
dependencias correctas.

Actualizamos las bibliotecas y las dependencias ya instaladas.

```
sudo apt update
sudo apt upgrade
sudo dpkg-reconfigure dash
```

Seleccionamos la opcion "no"

```
sudo apt install git cmake g++ libboost-all-dev libgmp-dev swig python3-numpy python3-mako python3-sphinx python3-lxml doxygen libfftw3-dev libsdl1.2-dev libgsl-dev libqwt-qt5-dev libqt5opengl5-dev python3-pyqt5 liblog4cpp5-dev libzmq3-dev python3-yaml python3-click python3-click-plugins python3-zmq python3-scipy python3-gi python3-gi-cairo gobject-introspection gir1.2-gtk-3.0 build-essential libusb-1.0-0-dev python3-docutils python3-setuptools python3-ruamel.yaml python-is-python3
```
  
Creamos las carpetas de trabajo, este paso podria realizarse en otra carpeta y tendria los mismo resultados, pero se recomienda iniciar la instalacion con un cierto nivel de orden ya que asi se puede explorar la posibilidad de instalar diferentes versiones de UHD, lo que podria resultar util en las etapas de debug el desarrollo de software para la USRP.
  
```
mkdir -p ~/src
```
  
Instalamos UHD v4.3.0.0, la misma version que los drivers instalados en la USRP, este paso es crucial por lo que recomienda tener especial cuidado.

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

Instalamos GNU-Radio, la version que a demostrado ser la mas estable para la utilizacion de la USRP a sido la v3.8, pero esta version no posee los bloques mas sofisticados para visualizacion de señales, por lo que algunas funciones graficas podrian mas actuales podrian no fucionar con esta version, aun asi, el mismo fabricante recomienda esta version porque ha sido la que mas soporte a recibido y la que mas documentacion posee, en espacial en el manejo de errores presentes dentro del posecamiento de señales.
  
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

Para asegurarse de que se instalaron las versiones corretas de cada software, probamos los siguientes comandos, ellos deben devolver las version instaladas.
  
```
uhd_usrp_probe --version
gnuradio-config-info --version
```

Existe la alta posibilidad de que aún realizando toda esta instalacion, cuando se intente ejecutar gnuradio, nos aparezca un error referente a 
"LD_LIBRARY_PATH", para solucionar este problema se hace lo relatado a continuacion.

Debemo modificar un archivo de ejecucion.

```
cd
nano ~/.profile
```

Se abrira un editor de texto, al final de este archivo debemos agregar la siguiente linea de codigo.

```
export PYTHONPATH=/usr/local/lib/python3/dist-packages:$PYTHONPATH
```

Luego guardamos el archivo con "ctrl+O" y salimos con "ctrl+X", ejecutamos los siguientes comandos

```
source ~/.profile
sudo ldconfig
```

Por ultimo, reiniciamos la PC de desarrollo y se daria por finalizada la instalacion de los harremientas basicas para utilizar la USRP E312 con GNU-Radio

***Para iniciar GNU-Radio, se puede inciar desde la consola, con el comando que se presenta a continuacion.***

```
gnuradio-companion
```
# EJECUCION DE CODIGO EN LA USRP

para finalizar con esta guia de instalalcion, se presentaran los pasos necesarios para ejecutar archivos programados en PYTHON, la idea de gnu-radio es generar un archivo en PYTHON o C++, el cual puede ser cargado en usrp para posteriormente ser ejecutado, para lograr esto se debe hacer lo siguiente.

en la pc de desarrollo, abrimos una terminal y nos posicionamos en la carpeta en donde existe el archivo '.py', a modo de ejemplos, copiaremos un archivo generado por gnu-radio llamado test.py

```
scp -p test.py root@192.168.10.42:/home/root
```

nostamos que debemos hacer un conexion via ssh, por lo que debemos conocer el nombre de usuario y la ip de la usrp, como hicimos la configuracion anteriormente, sabemos que la ip es 192.168.10.42, el usuario es root, ademas el directorio /home/root/ es el directorio por defecto cuando iniciamos sesion en la usrp, una vez copiado el archivo, dentro de la usrp podemos correr el siguiente comando para asegurarnos de que el archivo se ha copiado con exito.

```
cd /home/root
ls
```
si hicimmos todo correctamente, deberia existir el archivo test.py en la carpeta /home/root dentro de la usrp, si es asi, para ejecutar el archivo debemos ejecutar el siguiente comando en la terminal:

```
python3 test.py
```

si todo se hizo con exito, el archivo test.py es ejecutado por la usrp, por lo que el usuario ya esta capacitado para operar la USRP E312 y desarrollar software para esta.

Con esto se da por finalizada la guia de instalacion de la USRP E312, cualquier consulta, puede comunicarse con el autor de esta guia para hacer preguntas correspondiente a esta guia de instalacion.
