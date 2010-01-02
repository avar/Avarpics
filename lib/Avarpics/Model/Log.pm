package Avarpics::Model::Log;
use Moose;
use namespace::autoclean;

extends 'Catalyst::Model::Adaptor';

=head1 NAME

Avarpics::Model::Log - Catalyst Model

=head1 DESCRIPTION

Catalyst Model.

=cut

 __PACKAGE__->config( class => 'Avarpics::Log' );

