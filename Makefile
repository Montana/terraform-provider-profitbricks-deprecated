
default: build

version := "v1.2.4"

mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
name := $(notdir $(patsubst %/,%,$(dir $(mkfile_path))))

ifeq ($(OS),Windows_NT)
	bin_suffix := ".exe"
else
	bin_suffix := ""
endif

clean:
	rm -f $(name)*

compile:
	GOGC=off CGOENABLED=0 godep go build -i -o $(name)$(bin_suffix)

print-success:
	@echo
	@echo "Plugin built."
	@echo
	@echo "To use it, either run 'make install' or set your PATH environment variable correctly."

build: compile print-success

release:
	GOOS=linux GOARCH=amd64 GOGC=off CGOENABLED=0 godep go build
	tar  -cvzf ./$(name)-$(version)-linux-amd64.tar.gz -C . $(name)

	GOOS=darwin GOARCH=amd64 GOGC=off CGOENABLED=0 godep go build
	tar -cvzf $(name)-$(version)-darwin-amd64.tar.gz -C . $(name)

	GOOS=windows GOARCH=amd64 GOGC=off CGOENABLED=0 godep go build
	zip  $(name)-$(version)-windows-amd64.zip $(name).exe


install: compile
ifeq ($(OS),Windows_NT)
	cp $(name) $(GOPATH)/bin
else
	cp $(name)$(bin_suffix) $(GOPATH)/bin
endif


.PHONY : build release install
