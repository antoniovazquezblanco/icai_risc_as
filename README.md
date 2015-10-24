# ICAI-RiSC-16 Assembler
Assembler for the ICAI-RiSC-16 microprocessor.

## Building in Linux

You will need GNU make, gcc, flex and bison in order to compile this program.

In order to compile the assembler just type `make`.  
To install the software on your system type `make install` with elevated privileges.  
You can clean the generated files `make clean`.  
It is also provided a `make test` target that compiles an assembler example and a `make debug` that launches gdb.  
Another target `make graph` is provided in order to graph the call structure of the compiler.  

It is possible to generate Windows binaries by using the `make wininstaller` if you have MinGW installed in Linux. Nsis will also be needed in order for the installer to be generated.  


## Building in Windows

In order to compile this program [MinGW](http://sourceforge.net/projects/mingw/files/Installer/mingw-get-setup.exe/download) must be downloaded and MSYS should be installed from withing MinGW in order to be able to use GNU Make. It is also important to have flex and bison libraries installed from withing MinGW. It is possible that you may need to manually add MinGW binary directory to yout system path. Again, Nsis will be needed if you wish to generate the installer.  

You will now be able to use make in bash provided by MSYS.  


## To be done

* Symbol table can store the last item and iterate backwards. That should reduce the code size.
* Optimize symbol resolution (hash tables?).
* Add an equ pseudoinstruction.
* Add an include pseudoinstruction
* Group normal instructions encoding for code reuse.
