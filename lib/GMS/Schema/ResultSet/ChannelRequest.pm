package GMS::Schema::ResultSet::ChannelRequest;

use strict;
use warnings;
use base 'DBIx::Class::ResultSet';

=head1 NAME

GMS::Schema::ResultSet::ChannelRequest

=head1 DESCRIPTION

ResultSet class for ChannelRequest.

=head1 METHODS

=head2 search_pending

Returns a ResultSet of channel requests that have not been approved
or rejected by staff.

=cut

sub search_pending {
    my ($self) = @_;

    return $self->_search_channel_request_status ('pending_staff');
}

=head2 search_unapplied

Returns a ResultSet of channel requests that have been approved by staff,
but not applied in Atheme.

=cut

sub search_unapplied {
    my ($self) = @_;

    return $self->_search_channel_request_status ('approved');
}

=head2 search_failed

Returns a ResultSet of cloak changes that failed to be applied in
Atheme.

=cut

sub search_failed {
    my ($self) = @_;

    return $self->_search_channel_request_status ('error');
}

=head2 last_change

Returns the newest change for the channel request

=cut

sub last_change {
    my $self = shift;

    return $self->search({
        'me.id' => {
            '=' => $self->search ({
                  'channel_request.id' => {  -ident => 'me.channel_request_id' }
                },
                { alias => 'inner' }
            )->get_column('id')->max_rs->as_query
        },
    });
}

=head1 INTERNAL METHODS

=head2 _search_channel_request_statuss

Returns a ResultSet of channel requests with the given current status.

=cut

sub _search_channel_request_status {
    my ($self, $status) = @_;

    return $self->search(
        { 'active_change.status' => $status },
        { join => 'active_change' }
    );
}

1