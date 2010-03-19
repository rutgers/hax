RM = rm -rf

srcdir = .
VPATH  = $(srcdir)

PROG = mikish
ARCH = vex_pic

CSOURCE = hax_main.c hax_serial.c
HEADERS = stdint.h hax.h

ALL_CFLAGS  = $(ARCH_CFLAGS) $(CFLAGS)
ALL_LDFLAGS = $(ARCH_LDFLAGS) $(LDFLAGS)
ALL_AFLAGS = $(ARCH_AFLAGS) $(AFLAGS)

.SUFFIXES:
.SUFFIXES: .c .asm .o
.SECONDARY :

include $(PROG)/Makefile
include $(ARCH)/Makefile

