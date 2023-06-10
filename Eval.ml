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

open Syntax

open Env.Convenience

module Out = OutputManager

exception EvalFailure

type 'a evalResult = EFail of string
                   | ESucc of 'a
                   | EUnkn

let return : 'a -> 'a evalResult =
  ( fun x -> ESucc x )

let ( >>= ) ( m : 'a evalResult ) ( f : ( 'a -> 'b evalResult ) ) : 'b evalResult =
  ( match ( m ) with
  | ESucc v -> ( f v )
  | EFail _ | EUnkn as exn -> ( exn ) )

type ( 'a, 'b ) cond = {
  succ : 'a -> 'b evalResult ;
  fail : string -> 'b evalResult ;
  unkn : unit -> 'b evalResult ;
}

let ( >>+ ) ( m : 'a evalResult ) ( b : ( 'a, 'b ) cond ) : 'b evalResult =
  ( match ( m ) with
  | ESucc v -> ( b.succ v )
  | EFail s -> ( b.fail s )
  | EUnkn -> ( b.unkn () ) )

let fail : string -> 'a evalResult =
  ( fun s -> EFail s )

let mapM  : ( 'a -> 'b evalResult ) -> 'a list -> 'b list evalResult =
  ( fun f ->
    ( let rec loop ( res : 'b list ) : 'a list -> 'b list evalResult =
          ( function
          | x :: xs -> ( f x >>= fun x' ->
                       ( loop ( x' :: res ) xs ) )
          | [] -> ( return ( List.rev res ) ) ) in
    loop [] ) )

let rec flattenFcmp  = ( function
                       | EDely ( fs, _ ) -> ( fs )
                       | EFcmp fs -> ( flattenExps  fs )
                       | e -> ( [ ( e, [] ) ] ) )

and flattenExps  = ( List.concat_map ~f:flattenFcmp  )

let rec flattenPairs  = ( let one = ( function
                                   | ( EDely ( fvs, _ ) , vs ) -> ( pushArgs  fvs vs )
                                   | fv -> ( [ fv ] ) ) in
                         List.concat_map ~f:one )

and delayPairs  fvs st = ( EDely ( flattenPairs  fvs, st ) )

and delay fs vs = ( delayPairs  ( List.map ~f: ( flip pair vs ) fs ) )

and pushArgs  fvs vs = ( fvs &>
                           flattenPairs  @>
                           List.map ~f: (
                             fun ( f, vs' ) ->
                               ( f, vs' @ vs )
                           ) )

let rec bindPats  ( ps : pat list ) ( vs : exp list ) ( g : exp Env.t ) : exp Env.t evalResult =
  ( let binds = ( ref StringSet.empty ) in
  let rec bindPats  ( ps : pat list ) ( vs : exp list ) ( g : exp Env.t ) : exp Env.t evalResult =
        ( let eval g e = ( try ( eval g e ) with
                       | Primitives.UserFailure _
                       | PreludeUtil.NativeFailure _
                       | EvalFailure -> ( fail "Eval failed." )
                       | exn -> ( raise exn ) ) in
        let rec doOne  ( g : exp Env.t ) : pat * exp -> exp Env.t evalResult =
              ( function
              | ( PAny _, _ ) -> ( return g )
              | ( PVar ( x, _ ) , v ) -> ( let _ = ( binds := StringSet.add !binds x ) in
                                                                                               return ( g <+> x @-> v ) )
              | ( p, ( ELazy _ as e ) ) -> ( eval g e >>= fun v ->
                                                                                               ( doOne  g ( p, v ) ) )
              | ( PCVal ( "Cons" , _, [ p ; ps ] ) , EList ( e :: es ) ) -> ( doOne  g ( p, e ) >>= fun g' ->
                                                                                               ( doOne  g' ( ps, EList es ) ) )
              | ( PCVal ( "Nil" , _, [] ) , EList [] ) -> ( return g )
              | ( PCVal ( c, _, ps ) , ECVal ( c', vs ) ) when c = c' -> ( bindPats  ps vs g )
              | ( PTup ps, ETup vs ) -> ( bindPats  ps vs g )
              | ( PConj ( p, p' ) , v ) -> ( doOne  g ( p, v ) >>= fun g' ->
                                                                                               ( doOne  g' ( p', v ) ) )
              | ( PWhen ( e, _ ) , _ ) -> ( eval g e >>= fun v ->
                                                                                               ( if ( ECVal ( "True" , [] ) === v )
                                                                                                  then ( return g )
                                                                                                  else ( fail "Condition failed." ) ) )
              | ( PPred f, v ) -> ( eval g ( EApp ( f, v ) ) >>= fun v' ->
                                                                                               ( if ( ECVal ( "True" , [] ) === v' )
                                                                                                  then ( return g )
                                                                                                  else ( fail "Predicate failed." ) ) )
              | ( p, _ ) -> ( fail ( "`bindPats` fallthrough with `" -- CoreLineariser.showPat  p -- "`." ) ) ) in
        let rec loop g =
              ( function
              | ( [] , [] ) -> ( return g )
              | ( p :: ps, v :: vs ) -> ( doOne  g ( p, v ) >>= fun g' ->
                                      ( loop g' ( ps, vs ) ) )
              | _ -> ( raise EvalFailure ) ) in
        if ( List.length ps <> List.length vs )
           then ( fail ( "Mismatched argument lengths " -- string_of_int ( List.length ps ) -- " vs " -- string_of_int ( List.length vs ) -- "." ) )
           else ( loop g ( ps, vs ) >>= fun res ->
                ( return res ) ) ) in
  bindPats  ps vs g >>= fun res ->
  ( return res ) )

and eval ( g : exp Env.t ) ( e : exp ) : exp evalResult =
  ( match ( e ) with
  | EVar x -> ( x &>
                                                     Env.find g @>
                                                     eval g )
  | ETAbs ( _, _, e )
  | ETApp ( e, _ )
  | EAbs ( [] , e ) -> ( eval g e )
  | EAbs ( ps, e ) -> ( return ( ECls ( ps, e, g ) ) )
  | EApp ( e1, e2 ) -> ( eval g e1 >>= fun f ->
                                                   ( let fs = ( flattenFcmp  f ) in
                                                   eval g e2 >>= fun v ->
                                                   ( [ v ] &>
                                                     pushArgs  fs @>
                                                     flip delayPairs  [] @>
                                                     eval g ) ) )
  | EHcmp ( e, e' ) -> ( eval g e >>= fun v ->
                                                   ( eval g e' >>= fun v' ->
                                                   ( return ( EHcmp ( v, v' ) ) ) ) )
  | ETup [] -> ( let _ = ( Out.error "0-element tuples not allowed." ) in
                                                   raise EvalFailure )
  | ETup [ e ] -> ( let _ = ( Out.error ( "1-element tuples not allowed (exp = `" -- CoreLineariser.showExp  e -- "`)." ) ) in
                                                   raise EvalFailure )
  | ETup es -> ( mapM  ( eval g ) es >>= fun vs ->
                                                   ( return ( ETup vs ) ) )
  | EFcmp fs -> ( mapM  ( eval g ) fs >>= fun vs ->
                                                   ( return ( delay vs [] [] ) ) )
  | ECVal ( c, es ) -> ( match ( ( c, es ) ) with
                                                   | ( "Cons" , [ e ; es ] ) -> ( eval g e >>= fun v ->
                                                                                                        ( eval g es >>=
                                                                                                        function
                                                                                                        | EList vs -> ( return ( EList ( v :: vs ) ) )
                                                                                                        | v -> ( failwith ( "Invalid list: `" -- CoreLineariser.showExp  v -- "`." ) ) ) )
                                                   | ( "Nil" , [] ) -> ( return ( EList [] ) )
                                                   | _ -> ( mapM  ( eval g ) es >>= fun vs ->
                                                                                                        ( return ( ECVal ( c, vs ) ) ) ) )
  | ELet ( bs, e ) -> ( let bs' = ( let doOne  = ( function
                                                                                       | ( PVar ( x, _ ) , e ) -> ( let e' = ( ELazy ( ref ( e, Some Env.empty ) ) ) in
                                                                                                             ( x, e' ) )
                                                                                       | ( p, _ ) -> ( let _ = ( Out.error ( "Invalid destructuring pattern `" -- CoreLineariser.showPat  p -- "` in `let` / `while`; this ought to have been reduced to irrefutable binds!" ) ) in
                                                                                                             raise EvalFailure ) ) in
                                                                          List.map ~f:doOne  bs )
                                                       in let g' = ( let doOne  g ( x, e ) = ( g <+> x @-> e ) in
                                                                          List.fold ~init:g ~f:doOne  bs' )
                                                       in let patchOne  ( _, e ) = ( match ( e ) with
                                                                          | ELazy r -> ( let ( e, _ ) = ( !r ) in
                                                                                       r := ( e, Some g' ) )
                                                                          | _ -> ( () ) )
                                                       in let _ = ( List.iter ~f:patchOne  bs' ) in
                                                   eval g' e )
  | ECls ( [] , e, g' ) -> ( eval g' e )
  | EDely ( fvs, st ) -> ( match ( fvs ) with
                                                   | [] -> ( let _ = ( match ( st ) with
                                                                                | [] -> ( Out.warn "Failed: No context available for `resolve` failure; this is probably an implementation bug!" )
                                                                                | _ -> ( let patsString  = ( function
                                                                                                            | ECls ( ps, _, _ ) -> ( concatMap  CoreLineariser.showPat  ", " ps )
                                                                                                            | _ -> ( "<patterns-unavailable>" ) )
                                                                                            in let one ( f, vs ) = ( let f _ = ( let expString  = ( concatMap  CoreLineariser.showExp  ", " vs ) in
                                                                                                                      "Failed: `resolve(" -- patsString  f -- " <- " -- expString  -- ")`" ) in
                                                                                                            Out.warnClosure  f )
                                                                                            in let ( allSame,  vs ) = ( match ( List.map ~f:snd st ) with
                                                                                                             | [ vs ] -> ( ( false, vs ) )
                                                                                                             | vs :: vss -> ( ( List.for_all ~f: ( fun vs' -> vs = vs' ) vss, vs ) )
                                                                                                             | [] -> ( ( false, [] ) ) )
                                                                                            in let _ = ( if ( allSame  )
                                                                                                                then ( let _ = ( let f _ = ( let expString  = ( concatMap  CoreLineariser.showExp  ", " vs ) in
                                                                                                                                                "Failed: `resolve(_ <- " -- expString  -- ")`" ) in
                                                                                                                                      Out.warnClosure  f )
                                                                                                                         in let onePats  f = ( Out.warnClosure  ( fun _ -> "    " -- patsString  f ) ) in
                                                                                                                     st &>
                                                                                                                       List.iter ~f: (
                                                                                                                         fst @>
                                                                                                                         onePats
                                                                                                                       ) )
                                                                                                                else ( List.iter ~f:one st ) ) in
                                                                                        Out.warn "----------------------------------------" ) ) in
                                                                        fail "Empty list in `evalOrDelay`!" )
                                                   | ( f, vs ) :: fvs' -> ( let resolve ( f, vs ) =
                                                                              ( match ( f ) with
                                                                              | EHcmp ( f, f' ) -> ( eval g ( delay [ f ] vs st ) >>= fun v ->
                                                                                                   ( return ( Some ( delay [ f' ] [ v ] [] ) ) ) )
                                                                              | ELazy _ as f -> ( eval g f >>= fun f' ->
                                                                                                   ( return ( Some ( delayPairs  ( ( f', vs ) :: fvs' ) st ) ) ) )
                                                                              | ECls ( ps, e, g ) -> ( let j = ( List.length ps ) in
                                                                                                   if ( List.length vs >= j )
                                                                                                      then ( let ( vsNow,  vsLater  ) = ( List.split_n vs j )
                                                                                                               in let cont = ( fun _ -> return ( Some ( delayPairs  fvs' ( st @ [ ( f, vs ) ] ) ) ) )
                                                                                                               in let succ g' = ( eval g' e >>= fun v ->
                                                                                                                                    ( match ( vsLater  ) with
                                                                                                                                    | [] -> ( return ( Some v ) )
                                                                                                                                    | _ -> ( return ( Some ( delay [ v ] vsLater  st ) ) ) ) ) in
                                                                                                           bindPats  ps vsNow  g >>+
                                                                                                           { succ = succ ;
                                                                                                             fail = cont ;
                                                                                                             unkn = cont ;
                                                                                                           } )
                                                                                                      else ( return None ) )
                                                                              | ECVal ( c, vs' ) -> ( return ( Some ( ECVal ( c, vs' @ vs ) ) ) )
                                                                              | ENatF ( n, core ) -> ( let j = ( natNumArgs   core )
                                                                                                       in let evalExn  g e = ( match ( eval g e ) with
                                                                                                                      | ESucc v -> ( v )
                                                                                                                      | res -> ( raise EvalFailure ) ) in
                                                                                                   if ( List.length vs >= j )
                                                                                                      then ( let ( vsNow,  vsLater  ) = ( List.split_n vs j )
                                                                                                               in let force e = ( eval g e >>=
                                                                                                                                      beNotLazy   @>
                                                                                                                                      return ) in
                                                                                                           mapM  force vsNow  >>= fun vsNow  ->
                                                                                                           ( let e = ( try ( match ( ( core, vsNow  ) ) with
                                                                                                                                          | ( Natv1 core, [ x1 ] ) -> ( return ( core evalExn  g x1 ) )
                                                                                                                                          | ( Natv2 core, [ x1 ; x2 ] ) -> ( return ( core evalExn  g x1 x2 ) )
                                                                                                                                          | ( Natv3 core, [ x1 ; x2 ; x3 ] ) -> ( return ( core evalExn  g x1 x2 x3 ) )
                                                                                                                                          | _ -> ( failwith "impossible" ) ) with
                                                                                                                                      | PreludeUtil.FailCoreFailure
                                                                                                                                      | Primitives.UserFailure _ as exn -> ( raise exn )
                                                                                                                                      | _ -> ( fail ( "Native-code failure for `" -- n -- "`." ) ) ) in
                                                                                                           match ( vsLater  ) with
                                                                                                           | [] -> ( e >>= fun v ->
                                                                                                                   ( return ( Some v ) ) )
                                                                                                           | vs -> ( e >>= fun e' ->
                                                                                                                   ( let e'' = ( delay [ e' ] vs st ) in
                                                                                                                   return ( Some e'' ) ) ) ) )
                                                                                                      else ( return None ) )
                                                                              | _ -> ( fail ( "Unexpected function in `evalOrDelay`: `" -- CoreLineariser.showExp  f -- "`." ) ) )
                                                                            in let res = ( try ( resolve ( f, vs ) ) with
                                                                                  | PreludeUtil.FailCoreFailure -> ( if ( fvs' = [] )
                                                                                                                      then ( raise EvalFailure )
                                                                                                                      else ( let st' = ( st @ [ ( f, vs ) ] ) in
                                                                                                                           return ( Some ( delayPairs  fvs' st' ) ) ) )
                                                                                  | exn -> ( raise exn ) ) in
                                                                        res >>=
                                                                        function
                                                                        | Some e -> ( eval g e )
                                                                        | None -> ( return ( delayPairs  fvs st ) ) ) )
  | ELazy r -> ( match ( !r ) with
                                                   | ( v, None ) -> ( return v )
                                                   | ( e, Some g ) -> ( eval g e >>= fun v ->
                                                                    ( let _ = ( r := ( v, None ) ) in
                                                                    return v ) ) )
  | ENatF _ as f -> ( return ( delay [ f ] [] [] ) )
  | EList es -> ( mapM  ( eval g ) es >>= fun vs ->
                                                   ( return ( EList vs ) ) )
  | ECls _
  | EPrim _
  | EMap _ as v -> ( return v ) )

and beNotLazy   = ( let eval g e = ( match ( eval g e ) with
                                 | EFail s -> ( let _ = ( Out.error s ) in
                                              raise EvalFailure )
                                 | ESucc v -> ( v )
                                 | EUnkn -> ( let _ = ( Out.error "Leaked `EUnkn`; this is an implementation bug!" ) in
                                              raise EvalFailure ) ) in
                  function
                  | ETup vs -> ( ETup ( List.map ~f:beNotLazy   vs ) )
                  | ELazy r -> ( match ( !r ) with
                                     | ( v, None ) -> ( v )
                                     | ( e, Some g ) -> ( let v = ( eval g e )
                                                          in let _ = ( r := ( v, None ) ) in
                                                      beNotLazy   v ) )
                  | ECVal ( c, vs ) -> ( ECVal ( c, List.map ~f:beNotLazy   vs ) )
                  | EList vs -> ( EList ( List.map ~f:beNotLazy   vs ) )
                  | EMap m -> ( let m' = ( m &>
                                                PolyMap.to_alist @>
                                                List.map ~f: ( fun ( k, v ) -> ( beNotLazy   k, beNotLazy   v ) ) @>
                                                PolyMap.of_alist_exn ) in
                                     EMap m' )
                  | v -> ( v ) )

let eval g e =
  ( let ( eval, beNotLazy   ) = ( ( eval, beNotLazy   ) )
      in let eval g e = ( match ( eval g e ) with
                            | EFail s -> ( let _ = ( Out.error s ) in
                                         raise EvalFailure )
                            | ESucc v -> ( v )
                            | EUnkn -> ( let _ = ( Out.error "Leaked `EUnkn`; this is an implementation bug!" ) in
                                         raise EvalFailure ) ) in
  e &>
    eval g @>
    beNotLazy   )

