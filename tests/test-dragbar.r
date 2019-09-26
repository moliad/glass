rebol [title: "test dragbar"]




;-                                                                                                       .
;-----------------------------------------------------------------------------------------------------------
;
;- LIBS
;
;-----------------------------------------------------------------------------------------------------------
glass-root-path: clean-path %../

;----
; start the slim library manager, if it's not setup in your user.r file
;
; the following loading setup allows us to get slim and various packages in a variety of places easily 
; and with no discreet setup.
;
; they can be:
;   - Installed within the glass project 
;   - Installed at the same level as glass itself
;   - Installed anywhere else, in this case just create a file called slim-path-setup.r within 
;     the root of the glass project and fill it with a single Rebol formatted path which points to 
;     the location of your slim.r script.
;
; if you have GIT installed, you can use a script called get-git-slim-libs.r script to retrieve the latest versions
; of the various slim library packages.  Find the steel project (rebol dev tools) on github to get this script.
;
; if you go to github.com, you can get slim and all libs without GIT using a manual download link 
; for each slim package which gives you a .zip of all the files its repository contains. 
;----
unless value? 'slim [
	do any [
		all [ exists? glass-root-path/slim-path-setup.r         do read glass-root-path/slim-path-setup.r ]
		all [ exists? glass-root-path/../slim-libs/slim/slim.r          glass-root-path/../slim-libs/slim/slim.r ] 
		all [ exists? glass-root-path/slim-libs/slim/slim.r             glass-root-path/slim-libs/slim/slim.r    ] 
	]
]

slim/vexpose







;-                                                                                                       .
;-----------------------------------------------------------------------------------------------------------
;
;- LIBS
;
;-----------------------------------------------------------------------------------------------------------
gl:			slim/open/expose 	'glass			none [ screen-size   request-string   request-inform   discard ]
liquid-lib: slim/open/expose	'liquid			none [ fill   liquify   content  dirty  !plug   link   unlink   processor   detach   attach   insubordinate]
			slim/open/expose	'bulk			none [ make-bulk   clear-bulk  ]

barlib:     slim/open			'style-dragbar	none
barlib/von
von
;-                                                                                                       .
;-----------------------------------------------------------------------------------------------------------
;
;- GUI
;
;-----------------------------------------------------------------------------------------------------------

gl/layout compose/deep [
	row [
		column stiff tight adjust 300x0 [
			lst: scrolled-list [] (make-bulk 3) stiff-x 120x200
		]
		dragbar
		column [
			fld: field  "enter value"
			row tight [
				label "Color" 40 
				fld-clr: field  "255.0.0"
				button stiff 20x20 (200.0.255) (200.0.255) "" [fill fld-clr/aspects/label "200.0.255"]
				button stiff 20x20 (blue) (blue) "" [fill fld-clr/aspects/label "0.0.255"]
				button stiff 20x20 (0.180.200) (0.180.200) "" [fill fld-clr/aspects/label "0.180.200"]
				button stiff 20x20 (green) (green) "" [fill fld-clr/aspects/label "0.255.0"]
				button stiff 20x20 (yellow) (yellow) "" [fill fld-clr/aspects/label "255.255.0"]
				button stiff 20x20 (orange) (orange) "" [fill fld-clr/aspects/label "255.150.10"]
				button stiff 20x20 (red) (red) "" [fill fld-clr/aspects/label "255.0.0"]
			]
			
			button "add" [  
				append content lst/aspects/items reduce [
					data: copy content fld/aspects/label  
					reduce [
						any [attempt [to-tuple content fld-clr/aspects/label]  black ]
					]
					data
				] 
				dirty lst/aspects/items  
				
				probe head content lst/aspects/items
			]
			button "remove" [
				lst/list-marble/valve/delete-chosen lst/list-marble
			]
		]
	]
]

do-events