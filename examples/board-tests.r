rebol [
	; -- Core Header attributes --
	title: "Board frame unit tests."
	file: %board-tests.r
	version: 0.1.0
	date: 2013-11-5
	author: "Maxim Olivier-Adlhoch"
	purpose: {setup many boards in different layouts to make sure they work properly.}
	web: http://www.revault.org/
	source-encoding: "Windows-1252"

	; -- Licensing details  --
	copyright: "Copyright © 2013 Maxim Olivier-Adlhoch"
	license-type: "Apache License v2.0"
	license: {Copyright © 2013 Maxim Olivier-Adlhoch

	Licensed under the Apache License, Version 2.0 (the "License");
	you may not use this file except in compliance with the License.
	You may obtain a copy of the License at
	
		http://www.apache.org/licenses/LICENSE-2.0
	
	Unless required by applicable law or agreed to in writing, software
	distributed under the License is distributed on an "AS IS" BASIS,
	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
	See the License for the specific language governing permissions and
	limitations under the License.}

	;-  / history
	history: {
		v0.1.0 - 2013-11-05
			-created file
			-testing basic board creation.
			-testing glaze stylesheet integration.
	}
	;-  \ history

	;-  / documentation
	documentation: {
		We simply try out most of the tricks for use with boards
	}
	;-  \ documentation
]


;----
; starts the slim library manager, if it's not setup.. the following loading setup allows slim 
; to be installed either within the steel project or just outside of it, to be shared in multiple
; tools.
; 
unless value? 'slim [
	do any [
		all [ exists? %../slim-path-setup.r do read %../slim-path-setup.r ]
		all [ exists? %../../slim-libs/slim/slim.r  %../../slim-libs/slim/slim.r ] 
		all [ exists? %../slim-libs/slim/slim.r     %../slim-libs/slim/slim.r    ] 
	]
]

slim/vexpose
fb: slim/open 'frame-board none
slim/open/expose 'liquid none [ !plug liquify processor fill content attach link pipe unlink dirty destroy ]

fl: slim/open/expose 'fluid none [flow probe-pool]
gl: slim/open/expose 'glass none [unframe]
win: slim/open 'window none
slim/open/expose 'epoxy none  [ !pair-add ]
cv: slim/open 'style-cv none  [!cv]
btnlib: slim/open 'style-button none  

;cv/von
;win/von
;btnlib/von
;fl/von

gl/layout compose/deep [
	vcavity [
		title "Click and drag buttons, drop on zone."
		row  [
			column (white) (gray) [
				btn-cmd: button "Button" stiff
				fld-cmd: button "Field"  stiff
				grp-cmd: button "Group"  stiff
			]
			frm: pane  400x400 [
				drop-zone: column tight activate [
					brd: board 500x500 [
					]
				]
			]
		]
	]
]

current-cv: none

btn-cmd/actions: context [
	layout-spec: [ 
		marble: button "Click" 100x23 
		mcv: cv
	]
	
	post-layout-code: [
	]

	;------
	SELECT: funcl [
		event 
		/extern current-cv current-marble
	][
		frm-off: content frm/material/position
		gl/layout/within/only compose/deep/only layout-spec brd
		
		do bind/copy post-layout-code 'event
		
		current-cv: mcv
		current-marble: marble
		
		pool: flow [
			/sharing <cv> mcv/aspects
			/sharing  marble/aspects
			tot: !pair-add [ cv.offset cv.drag-delta ]
			offset < tot
		]
		fill pool/cv.offset event/offset - frm-off + content event/marble/material/position
	]
	
	;------
	DROP?: funcl [event][
		fill current-cv/aspects/drag-delta  ( event/drag-delta )
	]
	
	;------
	DROP: funcl [event][
		if drop-zone = event/dropped-on [
			brd-off: content brd/material/position
			fill current-cv/aspects/offset (content current-cv/aspects/offset) + content current-cv/aspects/drag-delta
			fill current-cv/aspects/drag-delta 0x0
		]
	]
	
	;------
	DROP-BG: funcl [event][
		unframe current-cv
		unframe current-marble
	]
]



fld-cmd/actions: make btn-cmd/actions [
	layout-spec: [ 
		marble: field (copy "") 200x23 
		mcv: cv
	]
]

grp-cmd/actions: make btn-cmd/actions [
	scr: none
	layout-spec: [
		marble: column tight 10x10 (black) (white) activate [
			title "GROUP"
			field (copy "") 150x23 
			button
			column tight [scroller]
			scr: scroll-frame 100x100 []
		]
		mcv: cv
	]

	post-layout-code: [
		fill marble/material/dimension 150x200
	]
]


drop-zone/actions: context [
	select: funcl [event][
		print "pressed work area"
		probe words-of event
	]
	
	drop?: swipe: funcl [event][
		print event/action
		print "dragging"
	]
]

von
do-events

