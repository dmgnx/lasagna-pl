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
use URI;
use URI::QueryParam;
use Getopt::Long;

my %replacements = ("\"" => "\\\"", "&" => "\", \"", "=" => "\": \"");
my %rules = ();

my @rgxlist = @{[]};


GetOptions(
	"help"     => \(my $help),
	"output=s" => \(my $output),
	"regex=s"  => \(my $regex)
) or exit(-1);

my ($filnam) = @ARGV;


if($help) {
	print("lasagna - lazy naxsi rules generator\n".
              "usage: $0 [<options>] [file]\n\n".
              "options:\n".
              "  -h, --help  show this message and exit\n".
              "  -o FILE, --output FILE\n".
              "              write rules to FILE\n".
              "  -r FILE, --regex FILE\n".
              "              use regular expressions from FILE to generate rules\n");
	exit;
}

if(defined $regex) {
	if ($regex eq "-") {
		*FILE = *STDIN
	} else {
		open(FILE, "<$regex")
	}
	
	while (<FILE>) {
		substr($_, -1) = '';
		push(@rgxlist, $_);
	}

	close(FILE);
}


if(defined $filnam) {open(FILE, "<$filnam")} else {*FILE = *STDIN}

while(<FILE>) {
	if(!($_ =~ /NAXSI_FMT/)){ next; }
	$_ =~ s/^.*NAXSI_FMT/NAXSI_FMT/;

	my $url = URI->new("/?".@{[split(/, |: /, $_)]}[1]);
	my $exceptions = $url->query_form_hash;

	if($exceptions->{"learning"} ne "1") { next; }

	for my $id (grep /^id[0-9]+$/, keys %$exceptions) {
		my $n = substr($id, 2);
		my $mz = "mz:";
		

		for my $rgx (@rgxlist) {
			if ($exceptions->{"uri"} =~ /$rgx/) {
				$mz .= "\$URL_X:".$rgx."|";
				last;
			}
		}

		if (!($mz =~ /\$URL/)) {
			$mz .= "\$URL:".$exceptions->{"uri"}."|";
		}

		if(my $varnam = $exceptions->{"var_name$n"}) {
			my $zone = $exceptions->{"zone$n"};
			
			if($zone eq "HEADERS" and $varnam eq "cookie") {
				$mz =~ s/\$URL(_X)?:.*\|//;
			} 

			if ($mz ~= /\$URL_X/) {
				$zone =~ s/(ARGS|BODY|HEADERS)(.*)/\$$1_VAR_X:^$varnam$2\$/;
			} else {
				$zone =~ s/(ARGS|BODY|HEADERS)(.*)/\$$1_VAR:$varnam$2/;
			}

			$mz .= $zone;
		} else {
			$mz .= $exceptions->{"zone$n"};
		}
	
		$mz =~ s/"/\\"/g;
		push(@{$rules{$mz}}, $exceptions->{"id$n"});
	}
}

if(defined $filnam) {close(FILE)}


if(defined $output) {open(OUTPUT, ">>$output")} else {*OUTPUT = *STDOUT}

for(keys %rules; my ($mz, $ids) = each(%rules);) {
	my %ids = map {$_ => 1} @{$ids};
	my @ids = keys(%ids);
	print(OUTPUT "BasicRule wl:".join(",", sort(@ids))." \"$mz\";\n");
}

if(defined $output) {close(OUTPUT)}


exit(0);
