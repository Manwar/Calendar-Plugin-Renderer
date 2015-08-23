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
    return $self->as_svg({
        adjust_height => 21,
        start_index   => 7,
        month_name    => 'Baha',
        days          => 19,
        year          => 172 });
}

sub calendar_saka {
    my ($self) = @_;

    # Month: 1, Year: 1937
    return $self->as_svg({
        start_index => 1,
        month_name  => 'Chaitra',
        days        => 30,
        year        => 1937 });
}

package main;

use strict;use warnings;
use Test::More;
use Path::Tiny qw(path);

eval "use Role::Tiny";
plan skip_all => "Role::Tiny required for testing Calendar::Plugin::Renderer" if $@;

my $T = T->new;

is($T->calendar_bahai, get('t/bahai.xml'));
is($T->calendar_saka,  get('t/saka.xml' ));

sub get { return path($_[0])->slurp_utf8; }

done_testing();
