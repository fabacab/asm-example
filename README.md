# `asm` example

Notes to self:

```sh
vagrant up
vagrant ssh
cd /vagrant
nasm -f elf -o hello.o hello.asm
ld -m elf_i386 -o hello hello.o
./hello
```
