#!/usr/bin/perl

use 5.006;
use strict;
use warnings FATAL => 'all';
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME               => 'Calendar::Plugin::Renderer',
    AUTHOR             => q{Mohammad S Anwar <mohammad.anwar@yahoo.com>},
    VERSION_FROM       => 'lib/Calendar/Plugin/Renderer.pm',
    ABSTRACT_FROM      => 'lib/Calendar/Plugin/Renderer.pm',
    LICENSE            => 'artistic_2',
    PL_FILES           => {},
    MIN_PERL_VERSION   => 5.006,
    CONFIGURE_REQUIRES => {
        'ExtUtils::MakeMaker' => 0,
    },
    BUILD_REQUIRES   => {
        'Test::More' => 0,
    },
    PREREQ_PM => {
        'SVG'              => '2.64',
        'Moo'              => '2.000000',
        'Moo::Role'        => '2.000000',
        'namespace::clean' => '0.24',
    },
    dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean => { FILES => 'Calendar-Plugin-Renderer-*' },
    (eval { ExtUtils::MakeMaker->VERSION(6.46) } ? (META_MERGE => {
        'meta-spec' => { version => 2 },
        resources => {
            repository => {
                type => 'git',
                url  => 'https://github.com/Manwar/Calendar-Plugin-Renderer.git',
                web  => 'https://github.com/Manwar/Calendar-Plugin-Renderer',
            },
        }})
     : ()
    ),
);
