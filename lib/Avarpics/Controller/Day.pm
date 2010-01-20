package Avarpics::Controller::Day;
use Moose;
use namespace::autoclean;

BEGIN {extends 'Catalyst::Controller'; }

=head1 NAME

Avarpics::Controller::Day - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :CaptureArgs(1) {
    my ( $self, $c, $day ) = @_;

    my $log = $c->model("Log");

    $day = $log->latest_day() unless $day;

    if ( $log->valid_day( $day ) ) {
        my %vars = $log->data_for_day( $day );
        while (my ($k, $v) = each %vars) {
            $c->stash->{$k} = $v;
        }
    } else {
        $c->error( "$day is not a valid day" );
    }

    $c->stash->{no_next} = 1 if $log->is_today($day);
    $c->stash->{title} = sprintf "Pics from %s for %s", $c->config->{channel}, $day;
    $c->stash->{template} = 'day.tt';
}

=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

