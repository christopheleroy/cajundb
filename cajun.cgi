#!/bin/env perl
use cajundb;
use CGI;

my $q = CGI->new();

if($q->request_method() eq 'GET' || $q->request_method() eq 'DELETE') {
  my $path = $q->path_info();

  $db = new cajundb();

  if($q->request_method() eq 'GET') {
    my $obj = $db->getDocFor_id($path);
    if($obj) {
      if(ref($obj)) {
	my $json = encode_json($obj);
	
	print $q->header(-type => 'application/json', -status => '200', -Content_length => length($json));
	print $json;
      }else{
	print $q->header(-type => 'text/plain',  -status => '500 ' . $obj);
      }
    }else{
      print $q->header(-type => 'text/plain', -status => '404 document not found');
    }
  }elsif ($q->request_method eq 'DELETE') {
    my $obj = $db->delete($path);
    my $json = encode_json($obj);
    
    print $q->header(-type => 'application/json', -status => '200 Document Deleted', -Content_length => length($json));
    print $json;
  }else{
    print $q->header(-status => '400 Bad Request');
  }
}elsif($q->request_method() eq 'POST') {
  my $data = $q->param('POSTDATA');
  my $json = decode_json($data);

  if($json) {
    my $obj = $db->store($json);
    if($obj) {
      my $jsonBack = encode_json($obj);
      my $status = $obj->{'success'} ? '200 Document Stored' : '500 Document Storage Issues';
      print $q->header(-type=>'application/json', -status => $status, -Content_length => length($jsonBack));
      print $jsonBack;
    }else{
      print $q->header(-type=>'text/plain', -status => '500 Failed storing document');
    }
  }else{
    print $q->header(-type=> 'text/plain', -status => '500 Invalid content');
  }
}else{
  print $q->header(-status => '400 Bad Request');
}
