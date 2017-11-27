#!/usr/bin/perl
use strict;
use warnings;
use Test::More;
use File::Spec;
use Cwd;

eval {
    require Test::PerlTidy;
    Test::PerlTidy->import(qw(run_tests));
};

if ($@) {
    plan skip_all => "Test::PerlTidy required";
}
my $cwd = Cwd->getcwd();

run_tests( path => File::Spec->catfile( $cwd, 'lib' ) );

done_testing();
