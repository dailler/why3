(********************************************************************)
(*                                                                  *)
(*  The Why3 Verification Platform   /   The Why3 Development Team  *)
(*  Copyright 2010-2019   --   Inria - CNRS - Paris-Sud University  *)
(*                                                                  *)
(*  This software is distributed under the terms of the GNU Lesser  *)
(*  General Public License version 2.1, with the special exception  *)
(*  on linking described in file LICENSE.                           *)
(*                                                                  *)
(********************************************************************)

(** Parse trees *)


(** {1 Parse trees} *)

(** {2 Identifiers and attributes} *)

type attr =
  | ATstr of Ident.attribute
  | ATpos of Loc.position

type ident = {
  id_str : string;
  id_ats : attr list;
  id_loc : Loc.position;
}

type qualid =
  | Qident of ident
  | Qdot of qualid * ident

(** {2 Types} *)

type pty =
  | PTtyvar of ident
  | PTtyapp of qualid * pty list
  | PTtuple of pty list
  | PTref   of pty list
  | PTarrow of pty * pty
  | PTscope of qualid * pty
  | PTparen of pty
  | PTpure  of pty

(** {2 Patterns} *)

type ghost = bool

type pattern = {
  pat_desc : pat_desc;
  pat_loc  : Loc.position;
}

and pat_desc =
  | Pwild
  | Pvar of ident
  | Papp of qualid * pattern list
  | Prec of (qualid * pattern) list
  | Ptuple of pattern list
  | Pas of pattern * ident * ghost
  | Por of pattern * pattern
  | Pcast of pattern * pty
  | Pscope of qualid * pattern
  | Pparen of pattern
  | Pghost of pattern

(** {2 Logical terms and formulas} *)

type binder = Loc.position * ident option * ghost * pty option
type param  = Loc.position * ident option * ghost * pty

type term = {
  term_desc : term_desc;
  term_loc  : Loc.position;
}

and term_desc =
  | Ttrue
  | Tfalse
  | Tconst of Constant.constant
  | Tident of qualid
  | Tasref of qualid
  | Tidapp of qualid * term list
  | Tapply of term * term
  | Tinfix of term * ident * term
  | Tinnfix of term * ident * term
  | Tbinop of term * Dterm.dbinop * term
  | Tbinnop of term * Dterm.dbinop * term
  | Tnot of term
  | Tif of term * term * term
  | Tquant of Dterm.dquant * binder list * term list list * term
  | Tattr of attr * term
  | Tlet of ident * term * term
  | Tcase of term * (pattern * term) list
  | Tcast of term * pty
  | Ttuple of term list
  | Trecord of (qualid * term) list
  | Tupdate of term * (qualid * term) list
  | Teps of (ident * pty) * term
  | Tscope of qualid * term
  | Tat of term * ident

(** {2 Program expressions} *)

type invariant = term list
type variant = (term * qualid option) list

type pre = term
type post = Loc.position * (pattern * term) list
type xpost = Loc.position * (qualid * (pattern * term) option) list

type spec = {
  sp_pre     : pre list;
  sp_post    : post list;
  sp_xpost   : xpost list;
  sp_reads   : qualid list;
  sp_writes  : term list;
  sp_alias   : (term * term) list;
  sp_variant : variant;
  sp_checkrw : bool;
  sp_diverge : bool;
  sp_partial : bool;
}

type expr = {
    expr_desc : expr_desc;
    expr_loc  : Loc.position;
  }

and expr_desc =
  | Eref
  (** TODO: document *)
  | Etrue
  (** literal `true` *)
  | Efalse
  (** literal `false` *)
  | Econst of Constant.constant
  (** constant literals *)
  | Eident of qualid
  (** variable identifier *)
  | Easref of qualid
  (** TODO: document *)
  | Eidapp of qualid * expr list
  (** uncurried application of a function identifier to a list of arguments *)
  | Eapply of expr * expr
  (** curried application *)
  | Einfix of expr * ident * expr
  (** infix operation *)
  | Einnfix of expr * ident * expr
  (** infix operation (TODO: document the difference with the former) *)
  | Elet of ident * ghost * Expr.rs_kind * expr * expr
  (** `let ... in ...` expression *)
  | Erec of fundef list * expr
  (** local definition of function, possibly mutually recursive *)
  | Efun of binder list * pty option * pattern * Ity.mask * spec * expr
  (** anonymous function *)
  | Eany of param list * Expr.rs_kind * pty option * pattern * Ity.mask * spec
  (** `any`: abstract expression with a specification,
       generating of VC for existence *)
  | Etuple of expr list
  (** tuple of expressions *)
  | Erecord of (qualid * expr) list
  (** record expressions *)
  | Eupdate of expr * (qualid * expr) list
  (** TODO: record update ? *)
  | Eassign of (expr * qualid option * expr) list
  (** assignment ? TODO: document *)
  | Esequence of expr * expr
  (** sequence of two expressions *)
  | Eif of expr * expr * expr
  (** `if .. then .. else ..` expression *)
  | Ewhile of expr * invariant * variant * expr
  (** `while` loop *)
  | Eand of expr * expr
  (** lazy conjunction *)
  | Eor of expr * expr
  (** lazy disjunction *)
  | Enot of expr
  (** negation *)
  | Ematch of expr * reg_branch list * exn_branch list
  (** match expression, including both regular patterns and exception
     patterns (those lists cannot be both empty) *)
  | Eabsurd
  (** `absurd` statement to mark unreachable branches *)
  | Epure of term
  (** turns a logical term into a pure expression *)
  | Eidpur of qualid
  (** TODO: document *)
  | Eraise of qualid * expr option
  (** raise an exception *)
  | Eexn of ident * pty * Ity.mask * expr
  (** local declaration of an exception *)
  | Eoptexn of ident * Ity.mask * expr
  (** TODO: document *)
  | Efor of ident * expr * Expr.for_direction * expr * invariant * expr
  (** `for` loop *)
  | Eassert of Expr.assertion_kind * term
  (** `assert` expression *)
  | Escope of qualid * expr
  (** TODO: document *)
  | Elabel of ident * expr
  (** introduction of a label *)
  | Ecast of expr * pty
  (** cast an expression to a given type *)
  | Eghost of expr
  (** forces an expression to be ghost *)
  | Eattr of attr * expr
  (** attach an attribute to an expression *)

and reg_branch = pattern * expr

and exn_branch = qualid * pattern option * expr

and fundef = ident * ghost * Expr.rs_kind *
               binder list * pty option * pattern * Ity.mask * spec * expr

(** {2 Declarations} *)

type field = {
  f_loc     : Loc.position;
  f_ident   : ident;
  f_pty     : pty;
  f_mutable : bool;
  f_ghost   : bool
}

type type_def =
  | TDalias     of pty
  | TDalgebraic of (Loc.position * ident * param list) list
  | TDrecord    of field list
  | TDrange     of BigInt.t * BigInt.t
  | TDfloat     of int * int

type visibility = Public | Private | Abstract (** = Private + ghost fields *)

type type_decl = {
  td_loc    : Loc.position;
  td_ident  : ident;
  td_params : ident list;
  td_vis    : visibility; (** records only *)
  td_mut    : bool;       (** records or abstract types *)
  td_inv    : invariant;  (** records only *)
  td_wit    : (qualid * expr) list;
  td_def    : type_def;
}

type logic_decl = {
  ld_loc    : Loc.position;
  ld_ident  : ident;
  ld_params : param list;
  ld_type   : pty option;
  ld_def    : term option;
}

type ind_decl = {
  in_loc    : Loc.position;
  in_ident  : ident;
  in_params : param list;
  in_def    : (Loc.position * ident * term) list;
}

(** Arguments of `meta` declarations *)
type metarg =
  | Mty  of pty
  | Mfs  of qualid
  | Mps  of qualid
  | Max  of qualid
  | Mlm  of qualid
  | Mgl  of qualid
  | Mval of qualid
  | Mstr of string
  | Mint of int

(** The possible `clone` substitution elements *)
type clone_subst =
  | CStsym  of qualid * ident list * pty
  | CSfsym  of qualid * qualid
  | CSpsym  of qualid * qualid
  | CSvsym  of qualid * qualid
  | CSxsym  of qualid * qualid
  | CSprop  of Decl.prop_kind
  | CSaxiom of qualid
  | CSlemma of qualid
  | CSgoal  of qualid

(** top-level declarations *)
type decl =
  | Dtype of type_decl list
  (** Type declaration *)
  | Dlogic of logic_decl list
  (** `function` and `predicate`, mutually recursively declared *)
  | Dind of Decl.ind_sign * ind_decl list
  (** inductive or co-inductive predicate *)
  | Dprop of Decl.prop_kind * ident * term
  (** propositions: `lemma` or `goal` or `axiom` *)
  | Dlet of ident * ghost * Expr.rs_kind * expr
  (** global program variable *)
  | Drec of fundef list
  (** program functions, mutually recursively defined *)
  | Dexn of ident * pty * Ity.mask
  (** declaration of global exceptions *)
  | Dmeta of ident * metarg list
  (** `meta` *)
  | Dcloneexport of qualid * clone_subst list
  (** `clone` *)
  | Duseexport of qualid
  (** `use` *)
  | Dcloneimport of Loc.position * bool * qualid * ident option * clone_subst list
  (** `clone import ... as ...` *)
  | Duseimport of Loc.position * bool * (qualid * ident option) list
  (** `use import ... as ...` *)
  | Dimport of qualid
  (** `import` *)
  | Dscope of Loc.position * bool * ident * decl list
  (** `scope` *)

type mlw_file =
  | Modules of (ident * decl list) list
  | Decls of decl list
