use Scalar::Util qw(weaken);
my $r = {};
Internals::SvREFCNT(%$r, 9);
my $r1 = $r;
weaken($r1);
print "ok";
