nasm -f elf64 -g -F dwarf radix.asm -o radix.o
gcc -no-pie radix.o -o radix
./radix