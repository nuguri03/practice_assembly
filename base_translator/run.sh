nasm -f elf64 -g -F dwarf base_translator.asm -o base_translator.o
gcc -no-pie base_translator.o -o base_translator
./base_translator