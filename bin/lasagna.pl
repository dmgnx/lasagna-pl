#!/usr/bin/perl

# MIT License
# 
# Copyright (c) 2018 Dimitri Gence
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

use strict;
use warnings;
use JSON;
use Getopt::Long;


my %replacements = ("&" => "\", \"", "=" => "\": \"");
my %rules = ();


GetOptions(
	"help"     => \(my $help),
	"output=s" => \(my $output)
) or exit(-1);

my ($filnam) = @ARGV;


if($help) {
	print("lasagna - lazy naxsi rules generator\n".
		  "usage: $0 [<options>] [file]\n\n".
		  "options:\n".
		  "  -h, --help  show this message and exit\n".
	      "  -o FILE, --output FILE\n".
		  "              write rules to FILE\n");
	exit;
}


if(defined $filnam) {open(FILE, "<$filnam")} else {*FILE = *STDIN}

while(<FILE>) {
	if(!($_ =~ /NAXSI_FMT/)){ next; }
	$_ =~ s/^.*NAXSI_FMT/NAXSI_FMT/;
	
	my $jsdoc ="{\"".@{[split(/, |: /, $_)]}[1]."\"}";
	$jsdoc =~ s/(@{[join("|", keys(%replacements))]})/$replacements{$1}/g;  
	$jsdoc = from_json($jsdoc, {utf8 => 1});

	if($jsdoc->{"learning"} ne "1") { next; }

	for(my $i = 0; my $id = $jsdoc->{"id$i"}; ++$i){
		my $mz = "mz:\$URL:".$jsdoc->{"uri"}."|";
		if(my $varnam = $jsdoc->{"var_name$i"}) {
			my $zone = $jsdoc->{"zone$i"};
			if($zone eq "HEADERS" and $varnam eq "cookie") {
				$mz =~ s/\$URL:.*\|//;
			}
			$zone =~ s/(ARGS|BODY|HEADERS)(.*)/\$$1_VAR:$varnam$2/;
			$mz .= $zone;
		} else {
			$mz .= $jsdoc->{"zone$i"};
		}
		
		push(@{$rules{$mz}}, $id);
	}	
}

if(defined $filnam) {close(FILE)}


if(defined $output) {open(OUTPUT, ">>$output")} else {*OUTPUT = *STDOUT}

for(keys %rules; my ($mz, $ids) = each(%rules);) {
	my %ids = map {$_ => 1} @{$ids};
	my @ids = keys(%ids);
	print(OUTPUT "BasicRule wl:".join(",", @ids)." \"$mz\";\n");
}

if(defined $output) {close(OUTPUT)}


exit(0);
