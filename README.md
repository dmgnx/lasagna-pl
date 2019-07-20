# lasagna
Lazy naxsi rules generator

**NOT MAINTAINED ANYMORE**

This project has been superseded by [dmgnx/lasagna](https://github.com/dmgnx/lasagna) 

## Installation
Lasagna needs Perl (>=5.24) and the URI perl module to run. Just install the p5-URI package from 
your favorite package manager and run the ``make install`` target. You might need to use gmake when 
running OpenBSD.

```bash
# RHEL/CentOS
yum install perl-URI

# Debian
apt-get install liburi-perl

# OpenBSD
pkg_add p5-URI


# Install lasagna into /usr/local
make install

# Install lasagna into ~/.local
PREFIX=~/.local make install
```

## Usage
To generate a ruleset, lasagna will read a stream from a nginx log file. You can let lasagna to open the
stream providing the path to the file in your command-line or just pipe your logs to lasagna's STDIN.
By default, lasagna writes rules to STDOUT. But you can redirect the output stream to a file using the 
``-o`` option.

```bash
# Print ruleset generated from error.log
lasagna error.log

# Write rules generated from multiple files to mywebsite.rules 
cat /var/log/nginx/*.error.log | lasagna -o mywebsite.rules
```
