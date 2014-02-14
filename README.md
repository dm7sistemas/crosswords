# Crosswords

Crosswords is a collaboration between [Matt Neuburg](http://github.com/mattneub) and [Mark Alldritt](http://github.com/alldritt) to build a Crossword Puzzel app for the iPad that suites our own needs.

## Puzzle Data Format

As a starting place, I (Mark) am using the JSON crossword puzzle format described [here](http://www.xwordinfo.com/JSON/).  This web site provides daily examples of the New Your Times crossword which I'm using as test data for our project.

Matt desires to play Cryptic corsswords ([example](http://www.theguardian.com/crosswords/cryptic/26171)).  We don't yet have a data source for these puzzles.  For the time being, I'm transcribing this puzzle to JSON format by hand.

[Here](http://www.theguardian.com/crossword/print/0,,-29336,00.html?answers=) is another type of crossword puzzle Matt would like to play on the iPad.  Here again, we don't have a puzzle data source so I'm transcribing this puzzle by hand for the time being until we find a source for pzuzzle data.

### Extensions to XWordInfo JSON Format

1. I have extended the JSON format to handle multi-word answers found in some of the Guardian puzzles.  In these situations, the answer string is sown as an ARRAY of word strings which comprise the answer.  For example, `["WORD1","WORD2"]` instead of "WORD1WORD2".  You would only use this array form if you want a seperator drawn between WORD1 and WORD2.
