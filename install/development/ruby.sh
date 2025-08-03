#!/bin/bash

# Install Ruby using standard gcc on Ubuntu
mise settings set ruby.ruby_build_opts "CC=gcc CXX=g++"

# Trust .ruby-version
mise settings add idiomatic_version_file_enable_tools ruby
