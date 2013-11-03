module Regex where
{-| A library for working with regular expressions. It uses [the
same kind of regular expressions accepted by JavaScript](https://developer.mozilla.org/en/docs/Web/JavaScript/Guide/Regular_Expressions).

# Create
@docs pattern, caseInsensitive, escape

# Match
@docs Match

### Find and Replace
@docs contains, find, findN, replace, replaceN

### Split
@docs split, splitN

-}

import Maybe (Maybe)
import Native.Regex

data Regex = Regex

{-| Escape all special characters. So `pattern (escape "$$$")`
will match exactly `"$$$"` even though `$` is a special character.
-}
escape : String -> String
escape = Native.Regex.escape

{-| Create a Regex that matches patterns [as specified in JavaScript](https://developer.mozilla.org/en/docs/Web/JavaScript/Guide/Regular_Expressions#Writing_a_Regular_Expression_Pattern).
Be careful to escape backslashes properly!
-}
pattern : String -> Regex
pattern = Native.Regex.pattern


{-| Make a pattern case insensitive -}
caseInsensitive : Regex -> Regex
caseInsensitive = Native.Regex.caseInsensitive

{-| Check to see if a Regex is contained in a string.

    contains (pattern "123") "12345" == True
    contains (pattern "b+") "aabbcc" == True

    contains (pattern "789") "12345" == False
    contains (pattern "z+") "aabbcc" == False
-}
contains : Regex -> String -> Bool
contains = Native.Regex.contains

{-| A `Match` represents all of the details about a particular match in a string.
Here are details on each field:

  * `match` &mdash; the full string of the match.
  * `submatches` &mdash; a pattern might have [subpatterns, surrounded by
    parentheses](https://developer.mozilla.org/en/docs/Web/JavaScript/Guide/Regular_Expressions#Using_Parenthesized_Substring_Matches).
    If there are N subpatterns, there will be N elements in the `submatches` list.
    Each submatch in this list is a `Maybe` because not all subpatterns may trigger.
    For example, `(pattern "(a+)|(b+)")` will either match many `a`&rsquo;s or
    many `b`&rsquo;s, but never both.
  * `index` &mdash; the index of the match in the original string.
  * `number` &mdash; if you find many matches, you can think of each one
    as being labeled with a `number` starting at one. So the first time you
    find a match, that is match `number` one. Second time is match `number` two.
    This is useful when paired with `replace` if replacement is dependent on how
    many times a pattern has appeared before.
-}
type Match = { match : String, submatches : [Maybe String], index : Int, number : Int }

{-| Find all of the matches in a string:

    words = find (pattern "\\w+") "hello world"

        map .match words == ["hello","world"]
        map .index words == [0,6]

    places = find (pattern "[oi]n a (\\w+)") "I am on a boat in a lake."

        map .match places      == ["on a boat", "in a lake"]
        map .submatches places == [ [Just "boat"], [Just "lake"] ]
-}
find : Regex -> String -> [Match]
find = Native.Regex.find

{-| Same as `find`, but `findN` will quit searching after the Nth match.
That means the resulting list has maximum length N, but *it can be shorter*
if there are not that many matches in the given string.
-}
findN : Int -> Regex -> String -> [Match]
findN = Native.Regex.findN

{-| Replace all matches. The function from `Match` to `String` lets
you use the details of a specific match when making replacements.

    vowels = caseInsensitive (pattern "[aeiou]")
    devowel = replace vowels (\_ -> "")

        devowel "The quick brown fox" == "Th qck brwn fx"

    word = pattern "\\w+"
    reverseWords = replace word (\{match} -> String.reverse match)

        reverseWords "deliver mined parts" == "reviled denim strap"
-}
replace : Regex -> (Match -> String) -> String -> String
replace = Native.Regex.replace

{-| Same as `replace`, but `replaceN` will quit after the Nth match.-}
replaceN : Int -> Regex -> (Match -> String) -> String -> String
replaceN = Native.Regex.replaceN

{-| Split a string, using the regex as the separator.

    split (pattern ", ?") "a,b, c, d" == ["a","b","c","d"]
-}
split : Regex -> String -> [String]
split = Native.Regex.split

{-| Same as `split` but stops after the Nth match.

    splitN 1 (pattern ", ?") "a,b,c,d" == ["a","b,c,d"]
-}
splitN : Int -> Regex -> String -> [String]
splitN = Native.Regex.splitN
