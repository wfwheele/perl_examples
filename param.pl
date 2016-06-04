#!/usr/bin/perl
use strict;
use warnings;
use lib './';
use MyMod qw/dump_params self_test/;

dump_params('p1');
self_test('p2');
