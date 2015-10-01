#!/usr/bin/perl
package ProcessObject;
use Data::Dumper;

sub new
{
    my $class = shift;
    my $self = {
      	_process_id     => shift,
	_parent_id      => shift,
	_stat           => shift,
	_tty            => shift,
	_time           => shift,
	_command        => shift,
        _child_objects  => shift,
    };

    bless $self, $class;
    return $self;
}

sub getProcessID {
    my ($self) = @_;
    return $self->{_process_id};
}

sub getParentID {
    my ($self) = @_;
    return $self->{_parent_id};
}

sub getStat {
    my ($self) = @_;
    return $self->{_stat};
}
sub getTTY {
    my ($self) = @_;
    return $self->{_tty};
}
sub getTime {
    my ($self) = @_;
    return $self->{_time};
}

sub getCommand {
    my ($self) = @_;
    return $self->{_command};
}

sub getChildObjects {
    my ($self) = @_;
    return $self->{_child_objects};
}

sub setChildObjects {
    my ($self, $childObjects) = @_;
    $self->{_child_objects} = $childObjects if defined($childObjects);
    return $self->{_child_objects};
}

1;
