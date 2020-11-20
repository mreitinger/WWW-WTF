use common::sense;
use WWW::WTF::Testcase;

my $test = WWW::WTF::Testcase->new();

$test->run_test(sub {
    my ($self) = @_;

    use WWW::WTF::Helpers::Filesystem qw/ remove_directory /;
    use WWW::WTF::Helpers::QRCode qw/ get_uri_from_qr_code_image_path /;

    my $http_resource = $self->ua_lwp->get(URI->new('https://www.oewt.at/servicecenter/lohnverrechnung/faq_lohnverrechnung/'));

    #while (my $http_resource = $iterator->next) {
        my $uri = $http_resource->request_uri;

        $self->run_subtest($uri, sub {

            my @pdf_uris = $http_resource->get_links({
                filter => {
                    href_regex => qr/.pdf$/,
                }
            });

            foreach my $pdf_uri (@pdf_uris) {

                my $absolute_uri = URI->new($uri->scheme . '://' . $uri->host . $pdf_uri);

                my $pdf_resource = $self->ua_lwp->get($absolute_uri);

                my @images = $pdf_resource->get_images;

                foreach my $image_path (@images) {
                    my $qr_code_uri = get_uri_from_qr_code_image_path($image_path);

                    next unless $qr_code_uri;

                    my $response = $self->ua_lwp->get($qr_code_uri);

                    $response->successful
                        ? $self->report->pass("URI from QR code is reachable: $qr_code_uri")
                        : $self->report->fail("URI from QR code is unreachable: $qr_code_uri")
                    ;
                }

                remove_directory($images[0]) if @images;
            }
        });
    #}
});
