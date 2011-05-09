
open Why
open Util
open Ident
open Ty
open Theory
open Term
open Decl

(* program type symbols *)

type mtsymbol = private {
  mt_impure   : tysymbol;
  mt_effect   : tysymbol;
  mt_pure     : tysymbol;
  mt_regions  : int;
  mt_singleton: bool;
}

val create_mtsymbol :
  impure:tysymbol -> effect:tysymbol -> pure:tysymbol -> singleton:bool ->
  mtsymbol

val mt_equal : mtsymbol -> mtsymbol -> bool

val get_mtsymbol : tysymbol -> mtsymbol

val print_mt_symbol : Format.formatter -> mtsymbol -> unit

val is_mutable_ts : tysymbol -> bool
val is_mutable_ty : ty       -> bool

val is_singleton_ts : tysymbol -> bool
val is_singleton_ty : ty       -> bool

(* builtin logic symbols for programs *)

val ts_arrow : tysymbol
val make_arrow_type : ty list -> ty -> ty

val ts_exn : tysymbol
val ty_exn : ty

(* val ts_label : tysymbol *)

(* program types *)

module rec T : sig

  type pre = Term.fmla

  type post_fmla = Term.vsymbol (* result *) * Term.fmla
  type exn_post_fmla = Term.vsymbol (* result *) option * Term.fmla

  type esymbol = lsymbol

  type post = post_fmla * (esymbol * exn_post_fmla) list

  type type_v = private
  | Tpure    of ty
  | Tarrow   of pvsymbol list * type_c

  and type_c = {
    c_result_type : type_v;
    c_effect      : E.t;
    c_pre         : pre;
    c_post        : post;
  }

  and pvsymbol = private {
    pv_name   : ident;
    pv_tv     : type_v;
    pv_effect : vsymbol; 
    pv_pure   : vsymbol;
    pv_regions: Sreg.t;
  }

  val tpure  : ty -> type_v
  val tarrow : pvsymbol list -> type_c -> type_v

  val create_pvsymbol : 
    preid -> type_v -> 
    effect:vsymbol -> pure:vsymbol -> regions:Sreg.t -> pvsymbol

  (* program symbols *)

  type psymbol_fun = private {
    p_name : ident;
    p_tv   : type_v;
    p_ty   : ty;      (* as a logic type, for typing purposes only *)
    p_ls   : lsymbol; (* for use in the logic *)
  }

  type psymbol =
    | PSvar of pvsymbol
    | PSfun of psymbol_fun

  val create_psymbol_fun : preid -> type_v -> psymbol_fun

  val ps_name : psymbol -> ident
  val ps_equal : psymbol -> psymbol -> bool

  (* program types -> logic types *)

  val purify : ty -> ty
  val effectify : ty -> ty

  val purify_type_v : ?logic:bool -> type_v -> ty
    (** when [logic] is [true], mutable types are turned into their models *)

  (* operations on program types *)

  val apply_type_v_var : type_v -> pvsymbol -> type_c
(*   val apply_type_v_sym : type_v -> psymbol  -> type_c *)
(*   val apply_type_v_ref : type_v -> R.t      -> type_c *)

  val occur_type_v : R.t -> type_v -> bool

  val v_result : ty -> vsymbol
  val exn_v_result : Why.Term.lsymbol -> Why.Term.vsymbol option

  val post_map : (fmla -> fmla) -> post -> post

  val subst1 : vsymbol -> term -> term Mvs.t

  val eq_type_v : type_v -> type_v -> bool

  (* pretty-printers *)

  val print_type_v : Format.formatter -> type_v -> unit
  val print_type_c : Format.formatter -> type_c -> unit
  val print_pre    : Format.formatter -> pre    -> unit
  val print_post   : Format.formatter -> post   -> unit
  val print_pvsymbol : Format.formatter -> pvsymbol -> unit

end

and Spv :  sig include Set.S with type elt = T.pvsymbol end
and Mpv :  sig include Map.S with type key = T.pvsymbol end

(* regions *)
and R : sig

  type t = private {
    r_tv : tvsymbol;
    r_ty : Ty.ty;
  }

  val create : tvsymbol -> Ty.ty -> t

  val print : Format.formatter -> t -> unit

end
and Sreg : sig include Set.S with type elt = R.t end
and Mreg : sig include Map.S with type key = R.t end
and Sexn : sig include Set.S with type elt = T.esymbol end

(* effects *)
and E : sig

  type t = private {
    reads  : Sreg.t;
    writes : Sreg.t;
    raises : Sexn.t;
    globals: Spv.t;
  }

  val empty : t

  val add_read  : R.t -> t -> t
  val add_glob  : T.pvsymbol -> t -> t
  val add_write : R.t -> t -> t
  val add_raise : T.esymbol -> t -> t

  val remove_reference : R.t -> t -> t
  val filter : (R.t -> bool) -> t -> t

  val remove_raise : T.esymbol -> t -> t

  val union : t -> t -> t

  val equal : t -> t -> bool

  val no_side_effect : t -> bool

  val subst : Ty.ty Mtv.t -> t -> t

  val occur : R.t -> t -> bool

  val print : Format.formatter -> t -> unit

end

(* ghost code *)
(****
val mt_ghost   : mtsymbol
val ps_ghost   : T.psymbol
val ps_unghost : T.psymbol
****)
