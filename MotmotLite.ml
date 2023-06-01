(* MotmotLite: A Motmotastic Linguistic Toy

   Copyright 2023, K.D.P.Ross <KDPRoss@gmail.com>

MotmotLite is released under the MotmotLite Licence with the
following terms:
- MotmotLite may be used for amusement and study.
- MotmotLite may be extended for similar purposes, provided
  that the changes involved in doing so are publicly
  released and licensed under the same terms.
- MotmotLite may only be used if you have joy and kindness
  in your thoughts.

   'When we agree about our hallucinations,
    we call that reality.' -- A.Seth

   'Be kind to yourself, and
    the world is your playground.'-KDP
 *)

(* Generated by           *
 *             CamlTrax   *
 *                     NG *
 *                        *
 * Copyright 2007-2023    *
 *             K.D.P.Ross *)

open Util

open Env.Convenience

let typCnsKndEnv    = ( smashEnvs  [ Typing.baseKindEnv   SurfaceParser.knd ; Primitives.primKindEnv   SurfaceParser.knd ] ; )

let expCnsTypEnv    = ( Typing.baseTermConsEnv    (
                        SurfaceParser.typ @>
                        SurfaceSyntax.coreOfSurfaceTyp    id
                      ) )

let stType  = ( ref Prelude.minPreludeType   )

let stTerm  = ( ref Prelude.minPreludeTerm   )

let processExp  ( e : SurfaceSyntax.exp ) : unit =
  ( let e' = ( SurfaceSyntax.coreOfSurfaceExp    id e )
      in let _ = ( print_endline ( "Parsed: `" -- CoreLineariser.showExp  e' -- "`." ) )
      in let t = ( Typing.typOf  CoreLineariser.showTyp  typCnsKndEnv    Env.empty expCnsTypEnv    !stType  e' )
      in let _ = ( print_endline ( "Has type: `" -- CoreLineariser.showTyp  t -- "`." ) )
      in let e'' = ( Bindings.restructureBindingsExp   e' )
      in let _ = ( if ( e'' <> e' )
               then ( print_endline ( "Restructured: `" -- CoreLineariser.showExp  e'' -- "`." ) ) )
      in let v = ( Eval.eval !stTerm  e'' )
      in let _ = ( print_endline ( "Value: `" -- CoreLineariser.showExp  v -- "`." ) ) in
  () )

let processBind  ( x, t, e ) : unit =
  ( let _ = ( match ( !stType  ==> x ) with
            | Some _ -> ( let _ = ( print_endline ( "Binding `" -- x -- "` already defined!" ) ) in
                        raise Typing.TypeError )
            | None -> ( () ) )
      in let t' = ( SurfaceSyntax.coreOfSurfaceTyp    id t )
      in let e' = ( SurfaceSyntax.coreOfSurfaceExp    id e )
      in let e'' = ( Bindings.restructureBindingsExp   e' )
      in let _ = ( print_endline ( "Parsed: `" -- x -- " : " -- CoreLineariser.showTyp  t' -- " = " -- CoreLineariser.showExp  e' ) )
      in let t'' = ( let g = ( !stType  <+> x @-> t' ) in
            Typing.typOf  CoreLineariser.showTyp  typCnsKndEnv    Env.empty expCnsTypEnv    g e' )
      in let _ = ( if ( not ( Typing.typEquiv  CoreLineariser.showTyp  typCnsKndEnv    Env.empty t'' t' ) )
               then ( let _ = ( print_endline "Annotated type does not match expression's type." ) in
                    raise Typing.TypeError ) )
      in let _ = ( print_endline ( "Has type: `" -- CoreLineariser.showTyp  t'' -- "`." ) )
      in let _ = ( stType  := !stType  <+> x @-> t' )
      in let v = ( Eval.eval !stTerm  Syntax. ( ELet ( [ ( PVar ( x, t' ) , e'' ) ] , EVar x ) ) )
      in let _ = ( print_endline ( "Value; `" -- CoreLineariser.showExp  v -- "`." ) )
      in let _ = ( stTerm  := !stTerm  <+> x @-> v )
      in let _ = ( print_endline ( "Binding `" -- x -- "` has been created." ) ) in
  () )

let processInput  ( s : string ) : unit =
  ( match ( SurfaceParser.tlExp  s ) with
  | TopLevelSyntax.TLExp e -> ( processExp  e )
  | TopLevelSyntax.TLBind xte -> ( processBind  xte ) )

let processCodeFile   ( f : string ) : unit =
  ( let stTypeOld   = ( !stType  )
      in let stTermOld   = ( !stTerm  )
      in let ss = ( readFile  f )
      in let _ = ( ss &>
                      List.length @>
                      string_of_int @>
                      around "Read " ( " lines from `" -- f -- "`." ) @>
                      print_endline )
      in let gs = ( let nontrivialInputQ  = ( function
                                            | [] -> ( false )
                                            | "" :: _ -> ( false )
                                            | _ -> ( true ) ) in
                    ss &>
                      List.map ~f: (
                        Str.global_replace ( Str.regexp " -- .*" ) "" @>
                        Str.global_replace ( Str.regexp "^-- .*" ) "" @>
                        trimString
                      ) @> List.group ~break: ( fun x y -> ( x = "" ) <> ( y = "" ) ) @>
                      List.filter ~f:nontrivialInputQ  )
      in let ss' = ( gs &>
                      List.map ~f: (
                        String.concat ~sep: " " @>
                        Str.global_replace ( Str.regexp "[ \t]+" ) " "
                      ) )
      in let one s = ( let _ = ( print_endline ( "Processing `" -- s -- "`." ) )
                        in let _ = ( processInput  s ) in
                    print_newline () ) in
  try ( let _ = ( List.iter ~f:one ss' )
          in let xs = ( StringSet.diff ( Env.domain !stType  ) ( Env.domain stTypeOld   ) &>
                 StringSet.to_list )
          in let s = ( xs &>
                 List.sort ~compare:Stdlib.compare @>
                 concatMap  ( around "`" "`" ) ", " )
          in let _ = ( if ( List.length xs > 0 )
                  then ( print_endline ( "Successfully loaded `" -- f -- "`; created bindings " -- s -- "." ) )
                  else ( print_endline ( "Successfully loaded `" -- f -- "`, but created no bindings." ) ) ) in
      () ) with
  | e -> ( let _ = ( stType  := stTypeOld   )
             in let _ = ( stTerm  := stTermOld   )
             in let _ = ( print_endline "(Restored state.)" ) in
         raise e ) )

let resetState  () =
  ( let _ = ( stType  := Prelude.minPreludeType   )
      in let _ = ( stTerm  := Prelude.minPreludeTerm   )
      in let _ = ( print_endline "Interpreter-state has been reset." )
      in let _ = ( !stType  &>
            Env.domain @>
            StringSet.to_list @>
            List.sort ~compare:Stdlib.compare @>
            concatMap  ( around "`" "`" ) ", " @>
            ( -- ) "The following bindings are defined: " @>
            print_endline ) in
  () )

let _ =
  ( let _ = ( match ( Sys.getenv_opt "TERM" ) with
                    | Some _ -> ( "clear" &>
                                  Sys.command @>
                                  ignore )
                    | None -> ( () ) )
      in let banner = [
                      "Welcome to MotmotLite" ;
                      "Copyright 2023, K.D.P.Ross <KDPRoss@gmail.com>" ;
                      "" ;
                      "'It's about 20% as good as Motmot" ;
                      " with a code-base only 9% the size;" ;
                      " calibrate expectations accordingly.'" ;
                      "" ;
                      "Enter:" ;
                      "- a binding / expression, e.g.:" ;
                      "  - `x : Num = 5`" ;
                      "  - `2 + 3`" ;
                      "- `:file {filepath}` (to load a file)" ;
                      "- `:reset`           (to reset the interpreter)" ;
                      "- `:quit`            (to exit)" ;
                    ]
      in let _ = ( List.iter ~f:print_endline banner )
      in let _ = ( resetState  () )
      in let _ = ( print_endline "(Protip: Type the name of one of these bindings to see its type!)" ) in
  let rec loop () = ( try ( let _ = ( print_string "\n#> " )
                            in let _ = ( flush stdout )
                            in let s = ( read_line () ) in
                        match ( String.split ~on:' ' s ) with
                        | [ ":q" ]
                        | [ ":quit" ] -> ( let _ = ( print_endline "Goodbye!" ) in
                                             exit 0 )
                        | [ ":f" ; f ]
                        | [ ":file" ; f ] -> ( let _ = ( print_endline ( "Ought to load `" -- f -- "`." ) )
                                                 in let _ = ( processCodeFile   f ) in
                                             loop () )
                        | [ ":r" ]
                        | [ ":reset" ] -> ( let _ = ( resetState  () ) in
                                             loop () )
                        | _ -> ( let _ = ( processInput  s ) in
                                             loop () ) ) with
                    | _ -> ( let _ = ( print_endline "You've made a blunder." ) in
                           loop () ) ) in
  loop () )

