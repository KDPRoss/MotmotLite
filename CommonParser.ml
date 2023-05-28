(* Generated by           *
 *             CamlTrax   *
 *                     NG *
 *                        *
 * Copyright 2007-2023    *
 *             K.D.P.Ross *)


open Util


open ParserCombinators


let surfaceKeywords  =
  ( let core = [
        ":" ;
        "<+" ;
        "=" ;
        "\\" ;
        "axiom" ;
        "case" ;
        "cases" ;
        "else" ;
        "fun" ;
        "if" ;
        "in" ;
        "lazy" ;
        "lazy-parse" ;
        "let" ;
        "matches" ;
        "mixfix" ;
        "module" ;
        "of" ;
        "private" ;
        "recover" ;
        "strict" ;
        "then" ;
        "thunk" ;
        "try" ;
        "typedef" ;
        "using" ;
        "where" ;
        "~" ;
      ] in
  StringSet.of_list core )


let checkEnd  keywords s =
  ( if ( StringSet.mem keywords s )
     then ( fail "keyword is not valid" )
     else ( just s ) )


let repsep1NoSpace    ( p : 'a parse ) ( s : 'b parse ) : 'a list parse =
  ( let rec mult = ( lazy ( p <*= s <*> cache nonEmpty  >>> fun ( x, xs ) -> x :: xs ) )
      and single = ( lazy ( p >>> fun x -> [ x ] ) )
      and nonEmpty  = ( lazy ( cache mult ||| cache single ) ) in
  cache nonEmpty  )


let repsepK  ( p : 'a parse ) ( s : 'b parse ) : 'a list parse =
  ( let rec mult = ( lazy ( p <== s <=> cache nonEmpty  >>> fun ( x, xs ) -> x :: xs ) )
      and single = ( lazy ( p >>> fun x -> [ x ] ) )
      and empty = ( lazy ( just [] ) )
      and nonEmpty  = ( lazy ( cache mult ||| cache single ) ) in
  cache nonEmpty  ||| cache empty )


let repsepKNoSpace    ( p : 'a parse ) ( s : 'b parse ) : 'a list parse =
  ( let rec mult = ( lazy ( p <*= s <*> cache nonEmpty  >>> fun ( x, xs ) -> x :: xs ) )
      and single = ( lazy ( p >>> fun x -> [ x ] ) )
      and empty = ( lazy ( just [] ) )
      and nonEmpty  = ( lazy ( cache mult ||| cache single ) ) in
  cache nonEmpty  ||| cache empty )


let many1Spaces   ( p : 'a parse ) : 'a list parse =
  ( let rec mult = ( lazy ( p <!> cache nonEmpty  >>> fun ( x, xs ) -> x :: xs ) )
      and single = ( lazy ( p >>> fun x -> [ x ] ) )
      and nonEmpty  = ( lazy ( cache mult ||| cache single ) ) in
  cache nonEmpty  )


let commaSepList1    ( p : 'a parse ) : 'a list parse = ( repsep1  ( p <== just () ) ( txt "," <== just () ) )


let commaSepList   ( p : 'a parse ) : 'a list parse = ( repsepK  ( p <== just () ) ( txt "," <== just () ) )


let nonEmpty  s =
  ( if ( String.length s = 0 )
     then ( fail "Must be nonempty." )
     else ( just s ) )


let mashStringStringOpt    c =
  ( function
  | Some s -> ( c -- s )
  | None -> ( c ) )


let varPExt   : string parse =
  ( let mashCharString   ( c, s ) = ( stringOfChar   c -- s )
      in let mashCharStringOpt    = ( first stringOfChar   @>
                                        uncurry mashStringStringOpt    )
      in let ( |@| ) p q = ( fun x -> p x || q x )
      in let follow : string parse = ( stringOf  ( oneOfC   "!%&*+-/;<>?\\^~_:#=@|_\'" |@| upperC  |@| lowerC  |@| digitC  ) )
      in let startWithLetterOrUnderscore     = ( let init = ( oneOf  lowerC  ||| chr '_' ) in
                                        init <*> maybe follow >>> mashCharStringOpt    )
      in let startWithNormalOpC     = ( let init = ( ":!%&*+-/;<>?\\^~_#@" &>
                                                     oneOfC   @>
                                                     oneOf  ) in
                                        init <*> maybe follow >>> mashCharStringOpt    )
      in let startWithSpecialOpC     = ( let init = ( "=|" &>
                                                        oneOfC   @>
                                                        oneOf  )
                                            in let follow' = ( follow >>= nonEmpty  ) in
                                        init <*> follow' >>> mashCharString   ) in
  startWithLetterOrUnderscore     ||| startWithNormalOpC     ||| startWithSpecialOpC     )


let atomP  =
  ( let norm = ( ( stringOf  upperC  >>= nonEmpty  ) <*> maybe varPExt   >>> uncurry mashStringStringOpt    )
      in let esc = ( let body = ( "[]\n\r" &>
                          oneOfNotC    @>
                          stringOf  ) in
             txt "[[" =*> body <*= txt "]]" >>> fun t -> "[[" -- t -- "]]" ) in
  esc ||| norm )


let qName  : string list parse = ( repsep1NoSpace    atomP  ( txt "." ) )

