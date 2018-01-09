# Makefile for pony-ring

# Command line parameters
# Example make ponyc=../ponyc/build/release/ponyc pass=1000 test
ponyc=~/prgs/pony/ponyc/build/debug-scheduler_scaling_pthreads/ponyc
comment=
other=--ponynoblock
size=1000
count=1000
pass=10

# Define a space character:
# https://stackoverflow.com/questions/10571658/gnu-make-convert-spaces-to-colons
empty:=
space:=$(empty) $(empty)

# Use "-" as seperator between words after concatonating comment and other
# Change all "-" to spaces
# Strip which changes multiple spaces to a single space
# Change spaces to "-" as a seperator
comment_other:=$(comment) $(other)
comment_other:=$(subst -,$(space),$(comment_other))
comment_other:=$(strip $(comment_other))
comment_other:=$(subst $(space),-,$(comment_other))
ifneq "$(comment_other)" ""
 # There is a comment_other so prepend "-" as seperator
 comment_other:=-$(comment_other)
endif

# Create command line and log file
date_now:=$(shell date +%y%m%d-%H%M%S.%N)
cmd:=./ring
full_cmd:=time $(cmd) $(other) --size $(size) --count $(count) --pass $(pass)
log_file:=pony-ring$(comment_other)-size$(size)-count$(count)-pass$(pass)-$(date_now).txt
test_cmd_line:=while true; do echo "Date: $(date_now)"; $(full_cmd); done 2>&1 | tee -a $(log_file)

ring: main.pony Makefile
	$(ponyc) .

test: ring
	$(cmd) --ponyversion >> $(log_file)
	echo "ponyc=$(ponyc)" >> $(log_file)
	echo "test_cmd_line=$(test_cmd_line)" >> $(log_file)
	$(test_cmd_line)

clean:
	rm ./ring
