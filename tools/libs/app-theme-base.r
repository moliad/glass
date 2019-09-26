REBOL [
	; -- Core Header attributes --
	file: %app-theme-base.r

	; -- slim - Library Manager --
	slim-name: 'app-theme-base
	slim-version: 1.2.7
	slim-prefix: none
	slim-update: http://www.revault.org/downloads/modules/sillica.r
]

slim/register [
	; overide the basic theme values, which are derived by other theme values.
	set 'theme-bg-color  white 
	
		
]