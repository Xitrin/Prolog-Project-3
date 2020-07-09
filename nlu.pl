% Database 
block(first). block(second).  block(third). block(fourth). block(fifth). block(sixth).
block(seventh). block(eighth). block(ninth). block(tenth). block(eleventh). block(twelfth).

shape(first, cube). shape(second, cube). shape(third, cube). shape(fourth, cube). shape(fifth, wedge).
shape(sixth, wedge). shape(seventh, wedge). shape(eighth, wedge). shape(ninth, pyramid). shape(tenth, pyramid).
shape(eleventh, pyramid). shape(twelfth, pyramid). shape(thirteenth, cube). shape(fourteenth,cube).

size(first, big). size(second, medium). size(third, big). size(fourth, small). size(fifth, big). 
size(sixth, small). size(seventh, small). size(eighth, medium). size(ninth, big). size(tenth, small). 
size(eleventh, medium). size(twelfth, big). size(thirteenth, medium). size(fourteenth, small).

colour(first, green). colour(second, blue). colour(third, red). colour(fourth, grey). colour(fifth, blue). 
colour(sixth, green). colour(seventh, orange). colour(eighth, pink). colour(ninth, yellow). 
colour(tenth, red). colour(eleventh, black). colour(twelfth, purple). colour(thirteenth, violet). colour(fourteenth,azure).

locatedOn(first, area1). locatedOn(second, fourth). locatedOn(third, area8). locatedOn(fourth, area7).
locatedOn(fifth, area4). locatedOn(sixth, second). locatedOn(seventh, area9). locatedOn(eighth,third).
locatedOn(ninth, first). locatedOn(tenth, area6). locatedOn(eleventh,area3). locatedOn(twelfth,fourteenth).
locatedOn(thirteenth,area2). locatedOn(fourteenth,area5).

justLeftOf(area1,area2). justLeftOf(area2,area3). justLeftOf(area3,area4). justLeftOf(area4,area5).                                                                                          
justLeftOf(area5,area6). justLeftOf(area6,area7). justLeftOf(area7,area8). justLeftOf(area8,area9).               
 
%checking if above and then justLeft and reverse to get justRight
beside(X,Y) :- above(X,A1), above(Y,A2), justLeftOf(A1,A2).
beside(X,Y) :- above(X,A1), above(Y,A2), justLeftOf(A2,A1).

above(X,Y) :- locatedOn(X,Y).
above(X,Y) :- locatedOn(X,Z), above(Z,Y).

%checking for areas and also for above/below 
leftOf(X,Y) :- locatedOn(X,Z), locatedOn(Y,C), justLeftOf(Z,C).
leftOf(X,Y) :- locatedOn(X,T), locatedOn(Y,_), justLeftOf(T,Z), locatedOn(L,Z), leftOf(L,Y).
leftOf(X,Y) :- above(X,Z), leftOf(Z,Y).
leftOf(X,Y) :- above(Y,Z), leftOf(X,Z).

rightOf(X,Y) :- leftOf(Y,X).



%lexicon
%not sure if these actually count as articles, but they fit into sentences
article(a). article(an). article(the). article(any). article(of). article(to). article(and).

common_noun(pyramid,X) :- shape(X,pyramid).
common_noun(cube,X) :- shape(X,cube).
common_noun(wedge,X) :- shape(X,wedge).
common_noun(block,X) :- block(X).
%table = one of the areas has to check for specific ones
common_noun(table,X) :- locatedOn(_,X), X = area1.
common_noun(table,X) :- locatedOn(_,X), X = area2.
common_noun(table,X) :- locatedOn(_,X), X = area3.
common_noun(table,X) :- locatedOn(_,X), X = area4.
common_noun(table,X) :- locatedOn(_,X), X = area5.
common_noun(table,X) :- locatedOn(_,X), X = area6.
common_noun(table,X) :- locatedOn(_,X), X = area7.
common_noun(table,X) :- locatedOn(_,X), X = area8.
common_noun(table,X) :- locatedOn(_,X), X = area9.

%size
adjective(big,X) :- size(X,big).
adjective(large,X) :- size(X,big).
adjective(huge,X) :- size(X, big).
adjective(enormous,X) :- size(X,big).
adjective(medium,X) :- size(X,medium).
adjective(average,X) :- size(X,medium).
adjective(small,X) :- size(X,small).
adjective(little,X) :- size(X,small).
adjective(miniscule,X) :- size(X,small).
%colour
adjective(green,X) :- colour(X,green).
adjective(red,X) :- colour(X,red).
adjective(blue,X) :- colour(X,blue).
adjective(grey,X) :- colour(X,grey).
adjective(white,X) :- colour(X,white).
adjective(purple,X) :- colour(X,purple).
adjective(pink,X) :- colour(X,pink).
adjective(black,X) :- colour(X,black).
adjective(orange,X) :- colour(X,orange).
adjective(yellow,X) :- colour(X,yellow).

preposition(on,X,Y) :- locatedOn(X,Y).
preposition(left,X,Y) :- leftOf(X,Y).
preposition(right,X,Y) :- rightOf(X,Y).
preposition(beside,X,Y) :- beside(X,Y).
preposition(below,X,Y) :- above(Y,X).
preposition(above,X,Y) :- above(X,Y).
preposition(between,X,Y) :- rightOf(X,Z), leftOf(Z,Y).

/******************* parser **********************/

who(Words, Ref) :- np(Words, Ref).
what(Words, Ref) :- np(Words, Ref).

/* Noun phrase can be a proper name or can start with an article */

np([Art|Rest], Who) :- article(Art), np2(Rest, Who).


/* If a noun phrase starts with an article, then it must be followed
   by another noun phrase that starts either with an adjective
   or with a common noun. */

np2([Adj|Rest],Who) :- adjective(Adj,Who), np2(Rest, Who).
np2([Noun|Rest], Who) :- common_noun(Noun, Who), mods(Rest,Who).


/* Modifier(s) provide an additional specific info about nouns.
   Modifier can be a prepositional phrase followed by none, one or more
   additional modifiers.  */

mods([], _).
mods(Words, Who) :-
	appendLists(Start, End, Words),
	prepPhrase(Start, Who),	mods(End, Who).

prepPhrase([Prep|Rest], Who) :-
	preposition(Prep, Who, Ref), np(Rest, Ref).

appendLists([], L, L).
appendLists([H|L1], L2, [H|L3]) :-  appendLists(L1, L2, L3).

