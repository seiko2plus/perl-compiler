sub w ($$) {my ($l, my $r) = @_; my $v = \@_; undef @_; @_ = 0..2; $l <=> $r}; print join q{ }, sort w 3, 1, 2, 0