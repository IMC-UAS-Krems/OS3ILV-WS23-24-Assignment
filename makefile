# This makefile is based on http://www.throwtheswitch.org/build/make
SHELL := /bin/bash

# Helper to prompt for client name on demand
CLIENT_NAME ?= $(shell bash -c 'read -p "Name of client instance to spawn: " username; echo $$username')

# Environmental variables
MKFILE_DIR := $(shell dirname "$(abspath $(lastword $(MAKEFILE_LIST)))")
WORKING_DIR := $(shell pwd)

# TODO Ensure that the makefile is NOT invoked from the public folder

# OS-Specific Commands
UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Linux)
	INSTALLER = sudo apt-get update && sudo apt-get install -y
	ADDITIONAL_FLAGS=
endif
ifeq ($(UNAME_S),Darwin)
	INSTALLER = brew install
	ADDITIONAL_FLAGS=-D_DARWIN_C_SOURCE
endif

# Generic Commands
CLEANUP = rm -rf
MKDIR = mkdir -p
GCC = gcc

TARGET_EXTENSION=out
BIN_TARGET=main

# Project Structure
PATHU = unity/src/
PATHS = src/
# Personal tests go here
PATHT = test/
# Public tests go here
PATHPT = public/test/
PATHB = build/
PATHD = build/depends/
PATHO = build/objs/
PATHR = build/results/
PATHC = build/coverage/

BUILD_PATHS = $(PATHB) $(PATHD) $(PATHO) $(PATHR)

# Test source
SRCT = $(wildcard $(PATHT)*.c)
# Public Test source
SRCPT = $(wildcard $(PATHPT)*.c)
# Source files
SRC_FILES = $(wildcard $(PATHS)*.c $(PATHS)**/*.c $(PATHS)**/**/*.c $(PATHS)**/**/**/*.c)
# Source files without Main: Necessary to avoid double definition of main in test executables
SRC_FILES_WITHOUT_MAIN = $(filter-out $(PATHS)Main.c, $(SRC_FILES))


COMPILE = $(GCC) -c
COMPILE_WITH_COVERAGE = $(GCC) -fPIC -fprofile-arcs -ftest-coverage -c
LINK = $(GCC) -fPIC -fprofile-arcs -ftest-coverage 
DEPEND = $(GCC) -MM -MG -MF

CFLAGS = -I. -I$(PATHU) -I$(PATHS) $(ADDITIONAL_FLAGS) -pedantic -Wall -Wuninitialized -Wshadow -Wwrite-strings -Wconversion -Wunreachable-code -D_POSIX_SOURCE -DTEST

#
# This assume that tests follow the Naming Convention Test<MODULE_NAME>.
# For example, TestBlah.c, where Blah matches the file Blah.c
# Public tests instead follow the Naming Conventio PublicTest<MODULE_NAME>
#
RESULTS = $(patsubst $(PATHT)Test%.c,$(PATHR)Test%.txt,$(SRCT))
PRESULTS = $(patsubst $(PATHPT)PublicTest%.c,$(PATHR)PublicTest%.txt,$(SRCPT))
# Compiled sources
SRC_FILES_OUT = $(patsubst $(PATHS)%.c,$(PATHO)%.o,$(SRC_FILES))
# Compiled sources without Main: we need those to ensure gcno and gcda in the build/objs folder
SRC_FILES_OUT_WITHOUT_MAIN = $(filter-out $(PATHO)Main.o, $(SRC_FILES_OUT))

PASSED = `grep -s PASS $(PATHR)*.txt`
FAIL = `grep -s FAIL $(PATHR)*.txt`
IGNORE = `grep -s IGNORE $(PATHR)*.txt`

LCOV := $(shell command -v lcov 2> /dev/null)
CLANG_FORMAT := $(shell command -v clang-format 2> /dev/null)
UNITY := $(shell [[ -d $(PATHU) ]] && echo "Unity")


# Set the link to the Coverage Report

COVERAGE := $(shell type -p greadlink > /dev/null && echo greadlink -f "$(PATHC)index.html")
ifeq ($(COVERAGE),)
COVERAGE := $(shell type -p readlink > /dev/null && echo readlink -f "$(PATHC)index.html")
endif

ifeq ($(COVERAGE),)
COVERAGE := $(shell type -p realpath > /dev/null && echo realpath --relative-to "$(WORKING_DIR)" "$(PATHC)index.html")
endif

ifeq ($(COVERAGE),)
	COVERAGE := echo "Cannot find a coverage link. Please install readlink, greadlink, or realpath"
endif

###### Declare Phonies

.PHONY: help
.PHONY: test
.PHONY: deps
.PHONY: clean
.PHONY: build
.PHONY: run-client
.PHONY: run-server

###### Targets start here 

help: ## Makefile help
	@echo "Shell in use " $(SHELL)
	@echo "Makefile Location: $(MKFILE_DIR)"
	@echo "Working Directory: $(WORKING_DIR)"
	@echo "Available Commands:"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

build: $(PATHB)$(BIN_TARGET).$(TARGET_EXTENSION) $(PATHO) ## Build the project

run-client: build ## Run the client
	./$(PATHB)$(BIN_TARGET).$(TARGET_EXTENSION) --client $(CLIENT_NAME)

run-server: build ## Run server
	./$(PATHB)$(BIN_TARGET).$(TARGET_EXTENSION) --server
	
## Link compiled files
$(PATHB)$(BIN_TARGET).$(TARGET_EXTENSION): $(SRC_FILES_OUT)
	@echo "Linking $@ from $^"
	$(LINK) -o $@ $^
	@echo "Linking complete!"

test: deps $(BUILD_PATHS) $(RESULTS) $(PRESULTS) ## Visualize the test results
	@echo "-----------------------\nIGNORES:\n-----------------------"
	@echo "$(IGNORE)"
	@echo "-----------------------\nFAILURES:\n-----------------------"
	@echo "$(FAIL)"
	@echo "-----------------------\nPASSED:\n-----------------------"
	@echo "$(PASSED)"
	@echo "\n"


deps: ## Install dependencies
ifndef LCOV
	$(INSTALLER) lcov
endif
ifndef CLANG_FORMAT
	$(INSTALLER) clang-format
endif
ifndef UNITY
	git submodule add https://github.com/ThrowTheSwitch/Unity.git unity
endif


dirs: $(PATHB) $(PATHD) $(PATHO) $(PATHR) ## Create build directories
	@echo ""


clean: ## Clean temp files
	$(CLEANUP) $(PATHO)
	$(CLEANUP) $(PATHB)*.$(TARGET_EXTENSION)
	$(CLEANUP) $(PATHR)*.txt
	$(CLEANUP) $(PATHC)
	find . -iname "*.gc*" -exec $(CLEANUP) {} \;


lint: deps ## Reformat (Lint) the source code with clang-format
	clang-format -i --style=LLVM $(PATHS)%.c $(PATHS)%.h


coverage: $(PATHC)index.html
	@echo " "
	@echo "The coverage report is available here:" $(shell $(COVERAGE))

######

$(PATHC)index.html: test ## Compute code coverage and generate the report
	@gcov $(PATHO)/*.gcda
	@mv *.gcov $(PATHB)
	
	@$(CLEANUP) $(PATHC)
	@mkdir $(PATHC)

	@lcov --capture --directory $(PATHB) --output-file $(PATHC)/coverage.info
	@genhtml $(PATHC)/coverage.info --output-directory $(PATHC)

# Run the tests
$(PATHR)%.txt: $(PATHB)%.$(TARGET_EXTENSION)
	-./$< > $@ 2>&1

# This create and executes the test files?
# Build Tests
$(PATHB)Test%.$(TARGET_EXTENSION): $(PATHO)Test%.o $(PATHO)unity.o $(SRC_FILES_OUT_WITHOUT_MAIN)
	@echo " "
	@echo "Linking Tests using $(SRC_FILES_OUT_WITHOUT_MAIN)"
	$(LINK) -o $@ $^

# Build Public Tests
$(PATHB)PublicTest%.$(TARGET_EXTENSION): $(PATHO)PublicTest%.o $(PATHO)unity.o $(SRC_FILES_OUT_WITHOUT_MAIN)
	@echo " "
	@echo "Linking Public Tests using $(SRC_FILES_OUT_WITHOUT_MAIN)"
	$(LINK) -o $@ $^

# Compile Tests
$(PATHO)%.o:: $(PATHT)%.c 
	@echo " "
	@echo "Compile test $<"
	$(COMPILE) $(CFLAGS) $< -o $@

# Compile Public Tests
$(PATHO)%.o:: $(PATHPT)%.c
	@echo " "
	@echo "Compile public test $<" 
	$(COMPILE) $(CFLAGS) $< -o $@

# Build Source - Note that we add coverage instrumentation here
# This creates the gcno file
$(PATHO)%.o:: $(PATHS)%.c
	@echo " "
	@echo "Building $< source with coverage information"
	$(MKDIR) -p $(@D)
	$(COMPILE_WITH_COVERAGE) $(CFLAGS) $< -o $@

# Build Unity
$(PATHO)%.o:: $(PATHU)%.c $(PATHU)%.h
	$(COMPILE) $(CFLAGS) $< -o $@

# Build Depedency
$(PATHD)%.d:: $(PATHT)%.c
	$(DEPEND) $@ $<

# Make sure build directories are there
$(PATHB):
	$(MKDIR) $(PATHB)

$(PATHD):
	$(MKDIR) $(PATHD)

$(PATHO):
	$(MKDIR) $(PATHO)

$(PATHR):
	$(MKDIR) $(PATHR)

$(PATH_BIN):
	$(MKDIR) $(PATH_BIN)

# Avoid those files are automatically deleted by make
.PRECIOUS: $(PATHB)Test%.$(TARGET_EXTENSION)
.PRECIOUS: $(PATHB)PublicTest%.$(TARGET_EXTENSION)
.PRECIOUS: $(PATHD)%.d
.PRECIOUS: $(PATHO)%.o
.PRECIOUS: $(PATHR)%.txt
