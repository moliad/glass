REBOL [
	; -- Core Header attributes --
	file: %app-theme-custom.r

	; -- slim - Library Manager --
	slim-name: 'app-theme-custom
	slim-version: 1.2.7
	slim-prefix: none
	slim-update: http://www.revault.org/downloads/modules/sillica.r
]

slim/register [
	; overide the basic theme values, which are derived by other theme values.
	set 'theme-requestor-bg-color  white 

	set 'theme-frame-color         230.235.240
	set 'theme-frame-label-color   230.235.240 * .3


]