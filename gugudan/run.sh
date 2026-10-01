nasm -f elf64 -g -F dwarf gugudan.asm -o gugudan.o
gcc -no-pie gugudan.o -o gugudan
./gugudan