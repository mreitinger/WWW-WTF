package WWW::WTF::HTTPResource;

use common::sense;

use v5.12;

use Moose;

has 'headers' => (
    is       => 'ro',
    isa      => 'HTTP::Headers',
    required => 1,
);

has 'content' => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
);

has 'successful' => (
    is       => 'ro',
    isa      => 'Bool',
    required => 1,
);

#FIXME the requested uri. this may not match the final uri after redirects
has 'request_uri' => (
    is       => 'ro',
    isa      => 'URI',
    required => 1,
);

#FIXME this is rather ugly. we need a good solution to get
#information from a Moose::Role so they can self-register here
has 'content_types' => (
    is       => 'ro',
    isa      => 'HashRef',
    required => 1,
    default  => sub {
        {
            'text/html'         => 'HTML',
            'text/plain'        => 'Plaintext',
            'text/xml'          => 'XML',
            'application/xml'   => 'XML',
        }
    },
);

sub BUILD {
    my $self = shift;

    my $content_type = lc($self->headers->content_type);

    die("Unsupported content type $content_type")
        unless exists $self->content_types->{$content_type};

    Moose::Util::apply_all_roles($self, 'WWW::WTF::HTTPResource::' . $self->content_types->{$content_type});
}

sub get_links { ... }

sub get_image_uris { ... }

sub get_headings { ... }

__PACKAGE__->meta->make_immutable;

1;
