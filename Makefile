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

ring: main.pony Makefile
	$(ponyc) .

test: ring
	while true; do echo "Date: `date +%y%m%d-%H%M%S.%N`"; time ./ring $(other) --size $(size) --count $(count) --pass $(pass); done 2>&1 | tee pony-ring$(comment_other)-size$(size)-count$(count)-pass$(pass)-`date +%y%m%d-%H%M%S.%N`.txt

clean:
	rm ./ring
