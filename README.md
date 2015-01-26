# cajundb

Cajundb is a poor man's NoSQL JSON document database with no bells and only one whistle.
Cajun is casual and meant to run in a CGI context. 
Drop it in the CGI-BIN of your favorite Apache webserver and you are nearly good to do.

You will need to create a ./docs directory in this CGI-BIN (writeable by the http server system user), or hack the first few lines of cajundb.pm to put 'docs' elsewhere. More documentation can help, I'll write it.

You will also need to ensure that your http server runs Perl CGI scripts with a Perl environment with the JSON perl module.

To create a new document, just POST it to the cajun.cgi.  
If your document has a '_id' property, it will be used as its record ID in the database, otherwise, cajun will create one for you. The _id property must start with an alphanumeric character and must be at least 6 characters long (a-z, A-Z, 0-9, dash, underscore and dot are allowable). Because the document is saved on disk as a _id.json document, be sure to be reasonable with your _ids, or better yet, let cajun.cgi create it for you.

Example:

curl -d '{"hello":"Hello World!","friendly":true}' http://yourserver.domain.net/cgi-bin/cajun.cgi


To get the document back, just request it by _id:
curl http://yourserver.domain.net/cgi-bin/cajun.cgi?tlt725K0yxqOGmvs

To delete the document, use the DELETE http method:
curl -X DELETE http://yourserver.domain.net/cgi-bin/cajun.cgi?tlt725K0yxqOGmvs

To search for document by a simple (perl regexp) search string:

curl http://yourserver.domain.net/cgi-bin/cajun.cgi?search=casual
returns a JSON array of document ids where the search 'casual' was found.

curl http://youserver.domain.net/cgi-bin/cajun.cgi?search=casual&include_docs=yes
returns a JSON array with all the documents themselves.

Pro-Tip: returns the entier database with:
curl http://yourserver.domain.net/cgi-bin/cajun.cgi?search=_id&include_docs=yes


Cajun is meant for very small projects of a few hundred documents. This version has no security, although, it is pretty easy to protect the execution of your CGI scripts with your Apache configuration.

