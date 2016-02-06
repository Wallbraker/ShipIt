########################################
# Find which compilers are installed.
#

VOLT ?= $(shell which volt)


########################################
# Basic settings.
#

VFLAGS ?= --internal-perf
LDFLAGS ?=
HTTP_VFLAGS ?= $(VFLAGS)
HTTP_LDFLAGS ?= $(LDFLAGS) -l curl
HTTP_TARGET ?= http


########################################
# Setting up the source.
#

LICENSE_SRC = src/ship/license.volt
HTTP_SRC = $(shell find src/ship/http -name "*.volt") $(LICENSE_SRC) examples/http.volt


########################################
# Targets.
#

all: $(HTTP_TARGET)

$(HTTP_TARGET): $(HTTP_SRC) GNUmakefile
	@echo "  VOLT   $(HTTP_TARGET)"
	@$(VOLT) -I src $(HTTP_VFLAGS) $(HTTP_LDFLAGS) -o $(HTTP_TARGET) $(HTTP_SRC)

clean:
	@rm -rf $(HTTP_TARGET) perf.cvs

.PHONY: all clean
