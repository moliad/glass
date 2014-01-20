rebol [
	; -- Core Header attributes --
	title: {Demo which shows how to add custom events which can be triggered at any time or in any way.}
	file: %delayed-events.r
	version: 1.0.0
	date: 2014-1-20
	author: "Maxim Olivier-Adlhoch"
	purpose: "Simple example/tutorial to help learn glass."
	web: http://www.revault.org/
	source-encoding: "Windows-1252"

	; -- Licensing details  --
	copyright: "Copyright © 2014 Maxim Olivier-Adlhoch"
	license-type: "Apache License v2.0"
	license: {Copyright © 2014 Maxim Olivier-Adlhoch

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
		v1 - 2014-01-20
			-created script.
	}
	;-  \ history

	;-  / documentation
	documentation: ""
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



gl: slim/open/expose  'glass none [ unframe ]
evt: slim/open/expose 'event none [ queue-delayed-trigger  ]

slim/vexpose

;print ""

t-handler:  funcl [event][
	print ".-((( BOOM! )))-."
	print ""
	none
]


gl/layout [
	column [
		auto-title "Delayed event tests"
		spacer 30 stiff
		vcavity [
			button "countdown Fire!" [
				; we use /data to put user data within event/trigger-data
				queue-delayed-trigger/repeat-delay/data
				0.5 [
					either event/trigger-data = 0 [
						print "Fire!" 
						print ""
						wait 0.4
						print "...-(o)-..."
						print ""
					][
						print event/trigger-data
					]
					all [
						event/trigger-data <> 0
						event/trigger-data: event/trigger-data - 1
						event
					]
				] 3
				
			]
			button "Delayed explosion!" [
				queue-delayed-trigger 2 :t-handler
				
			]
		]
	]
]



do-events
