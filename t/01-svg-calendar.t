#!perl

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

package main;

use strict; use warnings;
use Test::More;
use File::Temp qw(tempfile tempdir);
use XML::SemanticDiff;

eval "use Role::Tiny";
plan skip_all => "Role::Tiny required for testing Calendar::Plugin::Renderer" if $@;

my $T = T->new;

is(is_same_svg($T->calendar_bahai, 't/bahai.xml'), 1);
is(is_same_svg($T->calendar_saka, 't/saka.xml' ), 1);

is(is_same_svg($T->calendar_bahai, 't/fake-bahai.xml'), 0);
is(is_same_svg($T->calendar_saka, 't/fake-saka.xml' ), 0);

sub is_same_svg {
    my ($svg, $expected) = @_;

    my $dir = tempdir( CLEANUP => 1 );
    my ($fh, $filename) = tempfile( DIR => $dir );
    print $fh $svg;
    close $fh;

    my $xml = XML::SemanticDiff->new;
    my @changes = $xml->compare($filename, $expected);

    return (scalar(@changes))?(0):(1);
}

done_testing();
