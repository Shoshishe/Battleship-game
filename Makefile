all:
	aarch64-linux-gnu-gcc -Wa,-mcpu=cortex-a57 -ggdb3 -o test -static test.s
debug: 
	