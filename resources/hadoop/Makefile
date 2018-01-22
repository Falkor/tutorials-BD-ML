##################################################################################
# Makefile - Configuration file for GNU make (http://www.gnu.org/software/make/)
# Creation : 07 Nov 2013
# Time-stamp: <Mon 2018-01-22 13:00 svarrette>
#
# Copyright (c) 2013 Sebastien Varrette <Sebastien.Varrette@uni.lu>
#               http://varrette.gforge.uni.lu
#
############################## Variables Declarations ############################
SHELL = /bin/bash

# Bootstrapping script
SCRIPT = ../java/bootstrap.sh

HADOOP_EB = $(wildcard Hadoop-*.eb)

TARGETS =

############################
.PHONY: all

#fetch clean build java7 java8

all:
	@echo "Bu default, this Makefile does nothing..."

print:
	@echo "SCRIPT = $(SCRIPT)"
	@echo "HADOOP_EB = $(HADOOP_EB)"

# Building the modules with Easybuild
build:
	$(SCRIPT) --hadoop --eb
