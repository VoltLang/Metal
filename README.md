# Metal

Bare metal framework, with Volt example.


### Dependencies

You will need to have nasm and ld. If you want to test the resulting binary there are targets that uses qemu. All programs needs to be on the path. For Ubuntu you can do:
```
sudo apt-get install nasm binutils qemu
```
If you want to use the volt files you need to install a volt compliler on the path, the make file also supports C files, for that you need clang.


### Usage

To build and run the example in Qemu do the following:
```
$ make
$ make run
```

### Futher reading

http://stackoverflow.com/questions/33488194/creating-a-simple-multiboot-kernel-loaded-with-grub2
http://wiki.osdev.org/Bare_Bones

