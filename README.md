# icai_risc_as
Assembler for the ICAI-RiSC-16 microprocessor.

## Building

In order to compile the assembler just type `make`.
To install the software on your system type `make install` with elevated privileges.
You can clean the generated files `make clean`.
It is also provided a `make test` target that compiles an assembler example and a `make debug` that launches gdb.

# To be done

* Symbol table can store the last item and iterate backwards. That should reduce the code size.
* Optimize symbol resolution (hash tables?).
* Add an equ pseudoinstruction.
* Add an include pseudoinstruction
* Group normal instructions encoding for code reuse.
