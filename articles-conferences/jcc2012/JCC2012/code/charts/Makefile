PLT_FILES := $(wildcard *.plt)
TARGETS   := $(PLT_FILES:%.plt=%.tex)

all: $(TARGET)
%.tex: %.plt
    gnuplot < $<
