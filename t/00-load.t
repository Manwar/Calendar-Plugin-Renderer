#!perl

use 5.006;
use strict;
use warnings FATAL => 'all';
use Test::More tests => 6;

BEGIN {
    use_ok('Calendar::Plugin::Renderer')             || print "Bail out!";
    use_ok('Calendar::Plugin::Renderer::SVG')        || print "Bail out!";
    use_ok('Calendar::Plugin::Renderer::SVG::Page')  || print "Bail out!";
    use_ok('Calendar::Plugin::Renderer::SVG::Text')  || print "Bail out!";
    use_ok('Calendar::Plugin::Renderer::SVG::Box')   || print "Bail out!";
    use_ok('Calendar::Plugin::Renderer::SVG::Label') || print "Bail out!";
}

diag( "Testing Calendar::Plugin::Renderer $Calendar::Plugin::Renderer::VERSION, Perl $], $^X" );
