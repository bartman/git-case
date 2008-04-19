# For 'make test', you will need:
# 	prove (should ship with Perl)
# 	Test::More (should ship with Perl)
# 	File::Temp (should ship with Perl)
# 	Test::Cmd ( from CPAN )
# 	Test::Class ( from CPAN )
# 	File::Which  ( from CPAN )
test:
	prove -It t/*.t
