rebol []

do clean-path %../slim-libs/slim/slim.r

; enable vprint tracing (more details below)
slim/vexpose


gl: slim/open 'glass none
liquid: slim/open/expose 'liquid none [fill link attach content cleanup !plug liquify process: --process]

;-                                                                                                       .
;-----------------------------------------------------------------------------------------------------------
;
;- MODELS
;
;-----------------------------------------------------------------------------------------------------------


	!int: make !plug [
		valve: make valve [
			pipe-server-class: make !plug [
				valve: make valve [
					type: '!int
					
					;--------------------------
					;-        purify()
					;--------------------------
					purify: funcl [
						plug
					][
;						vin "purify()"

						pl: plug/liquid

						unless integer? pl [
							pl: any [
								attempt [to-integer pl]
								attempt [to-integer mold pl]
								1
							]
							plug/liquid: pl
						]
						
						false
					]
				]
			]
		]
	]

;-                                                                                                       .
;-----------------------------------------------------------------------------------------------------------
;
;- PLUGS
;
;-----------------------------------------------------------------------------------------------------------


value: liquify/pipe/fill !int 10








;-                                                                                                       .
;-----------------------------------------------------------------------------------------------------------
;
;- GUI
;
;-----------------------------------------------------------------------------------------------------------
gl/layout compose/deep [
	row  [
		field test 
		button "go" stiff
	]
	row [
		column  [
			scr: scroller 200x20  min 1 max 20 visible 5 init 10
		]
		fld:  field 100x30 stiff
		fld2: field 100x30 stiff
	]
	
	spacer 20x20
	
	button "close" [quit]

]



attach/to fld/aspects/label scr/aspects/value 'value
attach/to fld2/aspects/label fld/aspects/label 'value




do-events
