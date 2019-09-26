rebol [
	title: "glass icon renderer"
	purpose: "using an svg source image, use Inkscript to render it out in various sizes."
]



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


slim/open/expose 'configurator none [configure]

glass-font-overide: make face/font [ name: "Segoe UI" size: 14 style: none bold?: false ]

sl:			slim/open/expose 	'sillica		none [ base-font ]
gl:			slim/open/expose 	'glass			none [ screen-size   request-string   request-inform   discard ]
			slim/open/expose	'icons 			none [ load-icons ]
liquid-lib: slim/open/expose	'liquid			none [ fill   liquify   content  dirty  !plug   link   unlink   processor   detach   attach   insubordinate]
bulk-lib:   slim/open/expose	'bulk			none [ make-bulk   clear-bulk  ]
			slim/open/expose	'utils-files	none [ directory-of  filename-of  extension-of   ]


;-                                                                                                       .
;-----------------------------------------------------------------------------------------------------------
;
;- SETUP GLASS
;
;-----------------------------------------------------------------------------------------------------------
;---------------------------
;-     -collector Pane libs
;---
; setup glass icons before loading panes
load-icons/size 32
load-icons/size/as 20 'toolbar



;-                                                                                                       .
;-----------------------------------------------------------------------------------------------------------
;
;- config
;
;-----------------------------------------------------------------------------------------------------------
cfg: configure [
	;--------------------------
	;-         inkscape-install-path:
	;
	;
	;--------------------------
	inkscape-install-path: %"/C/Program Files (x86)/Inkscape/inkscape.exe"
	
	;--------------------------
	;-         source-svg-file:
	;
	;
	;--------------------------
	source-svg-file: #[none] "what icon to render"
	
	;--------------------------
	;-         output-render-dir:
	;
	;
	;--------------------------
	output-render-dir: %images/ "app creates folder if it doesn't exist"
	
	;--------------------------
	;-         sizes:
	;
	;
	;--------------------------
	sizes: [16X16 20X20 24X24 36X36 48X48 256X256 500X500]  "what icon sizes do you want to generate"
	
	;--------------------------
	;-         icon-name:
	;
	;
	;--------------------------
	icon-name: "icon"  "Overide the name of the icon in rendered images."
]
cfg/store-path: %icon-renderer.cfg

either cfg/needs-update? [
	cfg/from-disk
	cfg/to-disk
][
	cfg/from-disk
]




;-                                                                                                       .
;-----------------------------------------------------------------------------------------------------------
;
;- FUNCTIONS
;
;-----------------------------------------------------------------------------------------------------------
;--------------------------
;-     save-config()
;--------------------------
; purpose:  takes gui values and updates the cfg, then puts it on disk.
;--------------------------
save-config: funcl [][
	vin "save-config()"
	
	sizes: extract/index next content lst-sizes/aspects/items 3 3
	
	;v?? sizes
	cfg/set 'sizes sizes
	
	;cfg/probe
	
	cfg/to-disk
	
	vout
]


;--------------------------
;-     choose-svg-file()
;--------------------------
; purpose:  opens a file selector and picks the svg file to render.
;--------------------------
choose-svg-file: funcl [
][
	vin "choose-svg-file()"
	default-path: any [
		all [ file? path: cfg/get 'source-svg-file path ]
		%./
	]
	if ( file? path: request-file/only/file/filter default-path ["*.svg"] ) [
		;probe "chose a file"
		cfg/set 'source-svg-file path
		fill fld-svg/aspects/label to-string path
		
		; we will ALSO set the icon name automatically, to its 
		unless content icn-lock/aspects/engaged? [
			name: filename-of path
			
			if ext: find/last name "." [
				name: copy/part name ext
			]
			
			name: to-string name
			
			fill fld-name/aspects/label name
			cfg/set 'icon-name name
		]
		
		save-config
	]
	vout
]



;--------------------------
;-     choose-render-dir()
;--------------------------
; purpose:  opens a file selector and picks the svg file to render.
;--------------------------
choose-render-dir: funcl [
][
	vin "choose-render-dir()"
	default-path: any [
		all [ file? path: cfg/get 'output-render-dir path ]
		%./
	]
	default-path: join default-path "[chose folder]"
	
	
	if ( block? path: request-file/save/file/path default-path ) [
		v?? path
		path: first path
		cfg/set 'output-render-dir path
		fill fld-dir/aspects/label to-string path
		save-config
	]
	vout
]



;--------------------------
;-     render-icons()
;--------------------------
; purpose:  render all icons, or if sizes are selected, render selected ones.
;--------------------------
render-icons: funcl [
][
	vin "render-icons()"
	either empty? content lst-sizes/list-marble/aspects/chosen [
		;----
		; we render all sizes
		foreach [a b size] next content lst-sizes/aspects/items [
			render-icon size
		]
	][
		foreach [a b size] next content lst-sizes/list-marble/material/chosen-items [
			render-icon size
		]
	]
	vout
]

;--------------------------
;-     render-icon()
;--------------------------
; purpose:  launch the render of a single icon size.
;--------------------------
render-icon: funcl [
	size [pair!]
][
	vin "render-icon()"
	if outpath: attempt [
		either size/x <> size/y [
			rejoin [
				cfg/get 'output-render-dir
				cfg/get 'icon-name
				"-" size/x "x" size/y
				".png"
			]
		][
			rejoin [
				cfg/get 'output-render-dir
				cfg/get 'icon-name
				"-" size/x
				".png"
			]
		]
	][
	
		if all [
			outpath: attempt [ to-local-file outpath ]
			v?? outpath
			
			ispath: attempt [to-local-file cfg/get  'inkscape-install-path ]
			
			cmd: attempt [
				rejoin [
					ispath
					" --export-width "  size/x
					" --export-height " size/y
					" --export-png "   outpath
					" --file " to-local-file cfg/get 'source-svg-file
				]
			]
			
			v?? cmd
		][
			fill lbl-render-msg/aspects/label rejoin ["Rendering " filename-of outpath ]
			call/wait cmd
		]
	]
	
	vout
]



;-                                                                                                       .
;-----------------------------------------------------------------------------------------------------------
;
;- MAIN GUI
;
;-----------------------------------------------------------------------------------------------------------
gl/layout/options/size [
	row [
		label right 120 stiff "svg file to render"
		fld-svg: field [ 
			if ( file? path: load join "%" content event/marble/aspects/label ) [
				cfg/set 'source-svg-file path
				fill fld-dir/aspects/label mold path
			]
		
		]
		tool-icon #folder stiff no-label [choose-svg-file ]
	]
	
	row [
		label right 120 stiff "path to output"
		fld-dir: field
		tool-icon #folder stiff no-label [choose-render-dir]
	]
	
	row [
		label right 120 stiff "icon name" 
		fld-name: field 25x25 [ 
			; probe words-of event 
			cfg/set 'icon-name content event/marble/aspects/label
			save-config
		] 
		pad 30
		auto-label "lock name?" stiff 
		icn-lock: tool-icon #check-mark-off #check-mark-on no-label stiff 
	]
	pad 20x20

	label-frame "image sizes" [
		lst-sizes: scrolled-list 100x200  no-label
	] 
	icons [
		tool-icon #add no-label  [ 
			data: attempt [load/all request-string "Enter one or more sizes to add"   ]
			blk: copy []
			irule: [
				some [
					set val pair!    (append blk val)
					| set val integer! (append blk val * 1x1)
					| into irule ; parse several values the same as a single one
					| skip
				]
			]
			
			parse data irule
			
			v?? data
			v?? blk
			list: content lst-sizes/aspects/items 
			foreach item blk [
				append list reduce [mold item [] item]
			]
			dirty lst-sizes/aspects/items
			save-config
		]
		tool-icon #delete no-label  [
			lst-sizes/list-marble/valve/delete-chosen lst-sizes/list-marble
			save-config
		]
		tool-icon #close no-label  [
			lst-sizes/list-marble/valve/choose-item lst-sizes/list-marble none
			;save-config
		]
	]
	
	pad 20
	
	row [
		hstretch
		button "Render!" 100x30  [ render-icons]
		hstretch
	]
	
	lbl-render-msg: title "" red
	
] [ 30x30] 500x500



;von

;-                                                                                                         .
;-----------------------------------------------------------------------------------------------------------
;
;- LOADING CONFIG IN UI
;
;-----------------------------------------------------------------------------------------------------------
if file? data: cfg/get 'source-svg-file [
	fill fld-svg/aspects/label to-string data
]
if file? data: cfg/get 'output-render-dir [
	fill fld-dir/aspects/label to-string data
]
if string? data: cfg/get 'icon-name [
	fill fld-name/aspects/label data
]
if block? data: cfg/get 'sizes [
	blk: make-bulk 3
	foreach item data [
		v?? item
		if pair? item [
			append blk reduce [ mold item [] item]
		]
	]
	v?? blk
	fill lst-sizes/aspects/items blk
]
;
;	
;	inkscape-install-path: %"/C/Program Files (x86)/Inkscape/inkscape.exe"
;	source-svg-file: #[none] "what icon to render"
;	output-render-dir: %images/ "app creates folder if it doesn't exist"
;	sizes: [16X16 20X20 24X24 36X36 48X48 256X256 500X500]  "what icon sizes do you want to generate"
;	icon-name: "icon"  "Overide the name of the icon in rendered images."
;]



do-events