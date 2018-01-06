ponyc=~/prgs/pony/ponyc/build/debug-scheduler_scaling_pthreads/ponyc

other=--ponynoblock
size=1000
count=1000
pass=10

ring: main.pony Makefile
	$(ponyc) .

test:
	while true; do echo "Date: `date +%y%m%d-%H%M%S.%N`"; time ./ring $(other) --size $(size) --count $(count) --pass $(pass); done 2>&1 | tee pony-ring-$(other)-size$(size)-count$(count)-pass$(pass)-`date +%y%m%d-%H%M%S.%N`.txt
