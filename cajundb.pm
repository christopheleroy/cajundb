
package cajundb;

use JSON;

sub new {
	my $self = shift;
	my $class = ref($self) || $self;

	my $r = bless {
		'docs' => 'docs',
		'index' => 'index',
		'keyLength' => 16
              }, $class;

	return $r;

}

my @alphabet = ('a'..'z', '0'..'9', 'A'..'Z');
sub randomKey {
	my $r = shift;
	my $S = scalar(@alphabet);
	my $n = $r->{'keyLength'};

	my @k = map $alphabet[ rand($S) ], 1..$n;

	return join('', @k);
}

sub locationFor_id {
	my $r = shift;
	my $_id = shift;


	return $r->{'docs'} . "/" . $_id . ".json";
}


sub getDocFor_id { 
	my $r = shift;
	my $_id = shift;
	my $plain = shift;

	my $f = $r->locationFor_id($_id);
	if( -f $f ) {
	    open(F, $f) or return "could not open $f: $!";
	    my $jsonTXT = join('', <F>);
	    close(F);
	    
	    return decode_json($jsonTXT);
	}else{
	    return undef;
	}
}

sub certify_id { 
	my $r = shift;
	my $_id = shift;

	return $_id=~ m/^[a-zA-z0-9]{5,}$/;
}
	

sub store {
	my $r = shift;

	my $jsonDoc = shift;

	if($jsonDoc->{'_id'}) {
		if($r->certify_id($jsonDoc->{'_id'})) {
			
			my $loc = $r->locationFor_id($jsonDoc->{'_id'});
			my $currDoc = getDocFor_id($_id);
			my $nrev = 1;
			if($currDoc) {
				my $rev = $currDoc->{'_rev'};
				if($rev =~ /^(\d+)-/) {
					$rev = $1;
					$nrev = $rev +1;
				}
			}
			$jsonDoc->{'_rev'} = $nrev . "-" . $r->randomKey();

			open(G, ">$loc");
			print G encode_json($jsonDoc);
			close(G);
			return { 'op' => 'store', 'success' => 1, 'doc' => $jsonDoc, '_id' => $jsonDoc->{'_id'}, '_rev' => $jsonDoc->{'_rev'} };
			
		}else{
			return {'op' => 'store', 'success' => '0', 'doc' => $jsonDoc, 'reason' => 'the _id is not compliant' };
		}
	}else{
		my $_id;
		do {
			$_id = $r->randomKey();
		} while(-e $r->locationFor_id($_id));

		my $rev = '1-' . $r->randomKey();
		$jsonDoc->{'_id' } = $_id;
		$jsonDoc->{'_rev'} = $rev;

		open(G, ">" . $r->locationFor_id($_id)) or (return {'op' => 'store', 'success' => 0, 'doc' => $jsonDoc, 'reason' => 'could not write file: $!'});
		print G encode_json($jsonDoc);
		return {'op'=> 'store', 'success' => 1, 'doc' => $jsonDoc, '_id' => $_id, '_rev' => $rev };
	}
}

sub delete {
    my $r = shift;

    my $id = shift;

    if(-f $r->{'docs'} . "/$id.json") {
	my $rc = unlink $r->{'docs'} . "/$id.json";
	return {'op' => 'delete', 'rc' => $rc, 'success' => !$rc };
    }
    return {'op' => 'delete', 'success' => 0, 'reason' => 'file not found' };
}


			
sub search {
	my $r = shift;
	my $search = shift;
	my $case = shift;

	my $docs = $r->{'docs'};
	my $s1 = eval "sub { return \$_[0] =~ /$search/; }";
	my $s2 = eval "sub { return \$_[0] =! /$search/i; }";

	my $ss = $case eq 'i' ? $s2 : $s1;

	if(!$ss) {
	    return {'error' => 'search string could not be handled, keep it simple'};
	}

	opendir(DIR, $docs) or return {'error' => 'could not open directory '. $docs };
	
	@jsons = grep /.json$/, readdir(DIR);
	closedir(DIR);
	my @hits = ();
	
	foreach my $jsonFile (@jsons) {
	    if(-f "$docs/$jsonFile") {
		open(FS, "$docs/$jsonFile");
		while(<FS>) {
		    if($ss->($_)) {
			my $id = $jsonFile;
			$id =~ s/\.json$//;
			push(@hits, $id);
			last;
		    }
		}
		close(FS);
	    }
	}
	return \@hits	
}
		


	


