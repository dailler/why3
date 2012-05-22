(**************************************************************************)
(*                                                                        *)
(*  Copyright (C) 2010-2012                                               *)
(*    François Bobot                                                      *)
(*    Jean-Christophe Filliâtre                                           *)
(*    Claude Marché                                                       *)
(*    Guillaume Melquiond                                                 *)
(*    Andrei Paskevich                                                    *)
(*                                                                        *)
(*  This software is free software; you can redistribute it and/or        *)
(*  modify it under the terms of the GNU Library General Public           *)
(*  License version 2.1, with the special exception on linking            *)
(*  described in file LICENSE.                                            *)
(*                                                                        *)
(*  This software is distributed in the hope that it will be useful,      *)
(*  but WITHOUT ANY WARRANTY; without even the implied warranty of        *)
(*  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.                  *)
(*                                                                        *)
(**************************************************************************)

(* destructive types for program type inference *)

open Why3
open Ident
open Ty
open Term
open Mlw_ty
open Mlw_ty.T
open Mlw_expr
open Mlw_module

type dreg
type dity

val create_user_type_variable: Ptree.ident -> dity
val create_type_variable: unit -> dity
val its_app: user:bool -> itysymbol -> dity list -> dity
val ts_app: tysymbol -> dity list -> dity

val unify: dity -> dity -> unit
  (** destructive unification *)

val ity_of_dity: dity -> ity
  (** use with care, only once unification is done *)

type darrow = dity list * dity

(***

val specialize_darrow: darrow -> darrow
val specialize_lsymbol: lsymbol  -> darrow
val specialize_prgsymbol: prgsymbol -> darrow

val match_darrow: psymbol -> darrow -> ity_subst
***)
