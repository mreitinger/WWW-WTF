package WWW::WTF::HTTPResource::HTML;

use common::sense;

use Moose::Role;

use HTML::TokeParser;

has 'parser' => (
    is      => 'ro',
    isa     => 'HTML::TokeParser',
    lazy    => 1,
    default => sub {
        my ($self) = @_;
        my $parser = HTML::TokeParser->new(\$self->content) or die "Can't parse: $!";
        return $parser;
    },
);

sub get_links {
    my ($self, $o) = @_;

    my @links;

    while (my $token = $self->parser->get_tag(qw/a/)) {
        if (exists $o->{filter}->{title}) {
            next unless(($token->[1]->{title} // '') =~ m/$o->{filter}->{title}/);
        }

        push @links, URI->new($token->[1]->{href});
    }

    return @links;
}

1;
