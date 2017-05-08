
LINUX_SRC ?= ../../kernel/linux-3.0
CROSS_COMPILE= /opt/buildroot-2012.08-Lei/arm920t/usr/bin/arm-linux-


obj-m := led.o

modules:
	@make -C $(LINUX_SRC) M=`pwd` modules
	@make clean

clean:
	rm -f *.ko.* *.o.mod.c *.order *.symvers *.mod.c *.mod.o 

