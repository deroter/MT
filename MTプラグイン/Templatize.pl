package MT::Plugin::SKR::Templatize;
########################################################################
#   Templatize - Process the MT template tags written in the entry
#           Copyright (c) SKYARC System Co.,Ltd.
#           @see http://www.skyarc.co.jp/
########################################################################
use strict;
use warnings;

use vars qw( $VENDOR_NAME $NAME $VERSION );
$VENDOR_NAME = 'SKR';
$NAME = 'Templatize';
$VERSION = '1.00';

########################################################################
### Register as MT::Plugin
use base qw( MT::Plugin );
my $plugin = MT::Plugin::SKR::Templatize->new ({
        name => $NAME,
        version => $VERSION,
        key => $NAME,
        id => $NAME,
        author_name => 'SKYARC System Co.,Ltd.',
        author_link => 'http://www.skyarc.co.jp/',
        description => <<PERLHEREDOC,
Process the MT template tags written in the entry
PERLHEREDOC
});
MT->add_plugin ($plugin);

sub instance { $plugin }



use MT::Template::Context;
MT::Template::Context->add_global_filter( 'templatize' => sub {
    my( $raw_data, $arg, $ctx ) = @_;

    ### Retrieve the tag names which permitted the process
    if( $arg =~ /^all$/i ) {
        $arg = qr/.+?/;
    } else {
        $arg =~ s/\s*,\s*/|/;
        $arg = qr/(?:$arg).*?/;
    }

    ### Unescape the escaped bracket for the permitted tags
    $raw_data =~ s!&lt;([\/\$]?mt\:?$arg[\$\/]?)&gt;!<$1>!gi;

    ### Compile & Build me again
    my $builder = $ctx->stash( 'builder' );
    my $tokens = $builder->compile( $ctx, $raw_data )
        or return $ctx->error( $builder->errstr );
    defined( my $out = $builder->build( $ctx, $tokens ))
        or return $ctx->error( $builder->errstr );

    $out;
});

1;