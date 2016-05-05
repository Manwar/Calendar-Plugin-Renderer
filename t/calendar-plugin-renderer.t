#!/usr/bin/perl

package T;

use Calendar::Plugin::Renderer;
use Moo;
use namespace::clean;

sub BUILD {
    my ($self) = @_;
    Role::Tiny->apply_roles_to_object($self, 'Calendar::Plugin::Renderer');
}

sub calendar_bahai {
    my ($self) = @_;

    # Month: 1, Year: 172
    return $self->svg_calendar({
        adjust_height => 21,
        start_index   => 7,
        month_name    => 'Baha',
        days          => 19,
        year          => 172 });
}

sub calendar_saka {
    my ($self) = @_;

    # Month: 1, Year: 1937
    return $self->svg_calendar({
        start_index => 1,
        month_name  => 'Chaitra',
        days        => 30,
        year        => 1937 });
}

sub calendar_hijri {
    my ($self) = @_;

    # Month: 7, Year: 1437
    return $self->svg_calendar({
        start_index => 7,
        month_name  => 'Rajab',
        days        => 30,
        year        => 1437 });
}

sub calendar_persian {
    my ($self) = @_;

    # Month: 2, Year: 1395
    return $self->svg_calendar({
        start_index => 3,
        month_name  => 'Ordibehesht',
        days        => 31,
        year        => 1395 });
}

sub calendar_gregorian {
    my ($self) = @_;

    # Month: 5, Year: 2016
    return $self->svg_calendar({
        start_index => 1,
        days        => 31,
        month_name  => 'May',
        year        => 2016 });
}

package main;

use 5.006;
use strict; use warnings;
use Test::More;
use File::Temp qw(tempfile tempdir);
use XML::SemanticDiff;

eval "use Role::Tiny";
plan skip_all => "Role::Tiny required for testing Calendar::Plugin::Renderer" if $@;

my $T = T->new;
my $got_calendar_bahai     = $T->calendar_bahai;
my $got_calendar_gregorian = $T->calendar_gregorian;
my $got_calendar_hijri     = $T->calendar_hijri;
my $got_calendar_persian   = $T->calendar_persian;
my $got_calendar_saka      = $T->calendar_saka;

is(is_same_svg($got_calendar_bahai,     't/bahai.xml'    ), 1, 'Bahai Calendar'    );
is(is_same_svg($got_calendar_gregorian, 't/gregorian.xml'), 1, 'Gregorian Calendar');
is(is_same_svg($got_calendar_hijri,     't/hijri.xml'    ), 1, 'Hijri Calendar'    );
is(is_same_svg($got_calendar_persian,   't/persian.xml'  ), 1, 'Persian Calendar'  );
is(is_same_svg($got_calendar_saka,      't/saka.xml'     ), 1, 'Saka Calendar'     );

is(is_same_svg($got_calendar_bahai,     't/fake-bahai.xml'    ), 0);
is(is_same_svg($got_calendar_gregorian, 't/fake-gregorian.xml'), 0);
is(is_same_svg($got_calendar_hijri,     't/fake-hijri.xml'    ), 0);
is(is_same_svg($got_calendar_persian,   't/fake-persian.xml'  ), 0);
is(is_same_svg($got_calendar_saka,      't/fake-saka.xml'     ), 0);

done_testing();

# PRIVATE METHOD

sub is_same_svg {
    my ($got, $expected) = @_;

    my $dir = tempdir(CLEANUP => 1);
    my ($fh, $filename) = tempfile(DIR => $dir);
    print $fh $got;
    close $fh;

    my $xml = XML::SemanticDiff->new;
    my @changes = $xml->compare($filename, $expected);
    return (scalar(@changes))?(0):(1);
}
