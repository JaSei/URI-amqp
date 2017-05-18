use strict;
use warnings;

use Test::More tests => 3;
use URI;

subtest 'amqp' => sub {
    my $uri = URI->new('amqp://user:pass@host.avast.com:1234/vhost?heartbeat=10&connection_timeout=60');

    is($uri->scheme, 'amqp', 'scheme');
    is($uri->host, 'host.avast.com', 'host');
    is($uri->port, '1234', 'port');

    is($uri->path, '/vhost', 'path');
    is($uri->vhost, 'vhost', 'vhost');

    is($uri->user, 'user', 'user');
    is($uri->password, 'pass', 'password');

    is($uri->query_param('heartbeat'), 10, 'query heartbeat');
    is($uri->query_param('connection_timeout'), 60, 'query heartbeat');

    ok(!$uri->secure, 'no SSL/TLS');
};

subtest 'amqps' => sub {
    my $uri = URI->new('amqps://user:pass@host.avast.com:1234/vhost');
    is($uri->scheme, 'amqps', 'scheme');
    is($uri->host, 'host.avast.com', 'host');
    is($uri->port, '1234', 'port');

    ok($uri->secure, 'SSL/TLS');
};

subtest 'Appendix A: Examples' => sub {
    subtest 'amqp://user:pass@host:10000/vhost' => sub {
        plan tests => 5;

        my $uri = URI->new('amqp://user:pass@host:10000/vhost');
        is($uri->user, 'user', 'user');
        is($uri->password, 'pass', 'password');
        is($uri->host, 'host', 'host');
        is($uri->port, 10000, 'port');
        is($uri->vhost, 'vhost', 'vhost');
    };
    
    subtest 'amqp://user%61:%61pass@ho%61st:10000/v%2fhost' => sub {
        my $uri = URI->new('amqp://user%61:%61pass@ho%61st:10000/v%2fhost');
        is($uri->user, 'usera', 'user');
        is($uri->password, 'apass', 'password');
        is($uri->host, 'hoast', 'host');
        is($uri->port, 10000, 'port');
        is($uri->vhost, 'v/host', 'vhost');
    };

    subtest 'amqp://' => sub {
        my $uri = URI->new('amqp://');
        is($uri->user, undef, 'user');
        is($uri->password, undef, 'password');
        is($uri->host, '', 'host');
        is($uri->port, 5672, 'port');
        is($uri->vhost, '', 'vhost');
    };
};

subtest 'Net::AMQP::RabbitMQ' => sub {
    #connect($host, $options)
    
    my $uri = URI->new('amqps://user:pass@host.avast.com:1234/vhost?heartbeat=10&connection_timeout=60&channel_max=11,frame_max=8192,verify=0,cacertfile=/etc/cert/ca');
    is_deeply(
        $uri->as_net_amqp_rabbitmq_options,
        {
            user            => 'user',
            password        => 'pass',
            port            => 1234,
            vhost           => 'vhost',
            channel_max     => 11,
            frame_max       => 8192,
            heartbeat       => 10,
            timeout         => 60,
            ssl             => 1,
            ssl_verify_host => 0,
            ssl_cacert      => '/etc/cert/ca',
        },
        'options hash'
    );
};
