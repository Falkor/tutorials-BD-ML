##################################################################################
# Makefile - Configuration file for GNU make (http://www.gnu.org/software/make/)
# Creation : 07 Nov 2013
# Time-stamp: <Sat 2018-01-20 23:17 svarrette>
#
# Copyright (c) 2013 Sebastien Varrette <Sebastien.Varrette@uni.lu>
#               http://varrette.gforge.uni.lu
#
############################## Variables Declarations ############################
SHELL = /bin/bash

# Bootstrapping script
SCRIPT = ./bootstrap.sh

ARCHIVE_JAVA7 = jdk-7u80-linux-x64.tar.gz
ARCHIVE_JAVA8 = jdk-8u152-linux-x64.tar.gz
MAVEN_EB      = $(wildcard Maven-*.eb)

TARGETS = $(ARCHIVE_JAVA7) $(ARCHIVE_JAVA8)

############################
.PHONY: all

#fetch clean build java7 java8

all:  $(TARGETS)


print:
	@echo "SCRIPT = $(SCRIPT)"
	@echo "ARCHIVE_JAVA7 = $(ARCHIVE_JAVA7)"
	@echo "ARCHIVE_JAVA8 = $(ARCHIVE_JAVA8)"
	@echo "MAVEN_EB      = $(MAVEN_EB)"
	@echo "--------------------"
	@echo "TARGETS = $(TARGETS)"

# Fetching the sources jdk
fetch: $(ARCHIVE_JAVA7) $(ARCHIVE_JAVA8)
$(ARCHIVE_JAVA7):
	$(SCRIPT) --java7

$(ARCHIVE_JAVA8):
	$(SCRIPT) --java8

java7: $(ARCHIVE_JAVA7)
java8: $(ARCHIVE_JAVA8)

# Building the modules with Easybuild
build: java maven

build.java7: java7
	$(SCRIPT) --java7 --eb
build.java8: java8
	$(SCRIPT) --java8 --eb

build.maven maven: $(MAVEN_EB)
	$(SCRIPT) --maven --eb

java: build.java7 build.java8


clean:
	rm -f $(TARGETS)
