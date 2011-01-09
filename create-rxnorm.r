Rebol [
	file: %create-rxnorm.r
	date: 3-Dec-2010
	author: "Graham Chiu"
	purpose: {create the rxnorm table to hold rxcui, usna, and atc.ids }
]

dbase: open odbc://freediams
p: first dbase

insert p {create table RXNORM ( RXCUI integer not null, USAN varchar(127) not null, INN varchar(127))}
insert p {create unique index RXNORM_X on RXNORM(USAN, INN, RXCUI)}

insert p {select rxcui, english from atc where rxcui is not null}
foreach record copy p [
	attempt [ insert p [ {INSERT into RXNORM (RXCUI, USAN, INN) values (?, ?, ?)} record/1 record/2 record/2 ]]
	prin "."
]

close dbase
