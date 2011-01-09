<html>
<head>
	<title>Testing</title>
</head>
<body>
<img src="gel-powered-by.png">

<%

use [ingredients tmp t1 t2 name atcobj] [
	t2: now/precise
	if not value? 'load-json [
		do http://www.ross-gill.com/r/altjson.r
	]
	atcobj: make object! [
		atc:
		rxcui:
		usan: none
	]
	ingredients: copy []
	druglist: copy []
	interactionlist: copy []
	; probe request/content
	either none? content: select request/content 'rxcuilist [
		print "No list submitted"
	] [
		; trim/head/tail content
		tmp: parse/all content "^/"
		rxlist: copy []
		if tmp [
			foreach el tmp [
				trim el
				if not empty? el [
					append rxlist el
				]
			]
		]
		print {<h2>List of RxCUIs submitted</h2>}
		print <ol>
		foreach rxcui rxlist [
			print [<li> rxcui]
		]
		print </ol>
		; we got the drug list, now get the ATC codes
		atcs: copy []
		foreach el rxlist [
			; print [ "<br/>checking " el " for cache " ]
			sql: do-sql 'iam [{select english, code from ATC where rxcui = (?)} el]
			if all [ sql not empty? sql ][
				foreach record sql [
					if not found? find atcs record/1 [
						append atcs make atcobj [
							atc: record/2
							usan: record/1
							rxcui: el
						]
						; print [ "found " record/1 <br/> ]
					]
				]
			]
		]
		print {<h2>ATC data for submitted RxCUIs</h2>}
		print <pre>
		foreach atc atcs [
			probe atc
		]
		print </pre>
	]
	t1: now/precise
	print reform [ <p/> "Time: " difference t1 t2]
]
%>
</body>
</html>