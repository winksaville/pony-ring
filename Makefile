PONYC=~/prgs/pony/ponyc/build/debug-scheduler_scaling_pthreads/ponyc
ring: main.pony Makefile
	$(PONYC) .
