rebol [
	file: %get-all-rxcui.r
	date: 30-Nov-2010
	author: "Graham Chiu"
	purpose: {update the ATC database with rxcuis}
]

comment {
make object! [
    idGroup: make object! [
        name: "lipitor"
        rxnormId: [
            "153165"
        ]
    ]
]
}

if not value? 'load-json [
	*do %altjson.r
]

dbase: open odbc://freediams
p: first dbase

insert p {select count(id) as cnt from ATC where rxcui is null}
print [ "Records to do are: " copy p ]
insert p {select count(id) as cnt from ATC where rxcui is not null}
print [ "Records done are: " copy p ]

wait 2

insert p {select first 5000 english from ATC where rxcui is null}
foreach drug copy p [
	wait .3
	drugname: copy drug/1
	replace/all drugname " " "%20"
	attempt [
	info: read/custom join http://rxnav.nlm.nih.gov/REST/rxcui?name= drugname [ header [ accept: "application/json" ]]
	if not empty? info [
		json: load-json info
		prin drug/1
		if error? try [
			rxcui: json/idGroup/rxnormid/1
			print [ " is " rxcui ]
			insert p [{update ATC set RXCUI = (?) where english = (?)} to-integer rxcui drug/1 ]
		][ print " was not found" ]
	]
	]
]

close dbase
