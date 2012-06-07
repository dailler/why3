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

open Why3
open Util
open Ident
open Ty
open Term
open Decl
open Theory
open Env
open Ptree
open Mlw_dtree
open Mlw_ty
open Mlw_ty.T
open Mlw_expr
open Mlw_decl
open Mlw_module
open Mlw_dty

(** errors *)

exception DuplicateProgVar of string
exception DuplicateTypeVar of string
(*
exception PredicateExpected
exception TermExpected
exception FSymExpected of lsymbol
exception PSymExpected of lsymbol
exception ClashTheory of string
exception UnboundTheory of qualid
exception UnboundType of string list
*)
exception UnboundTypeVar of string
exception UnboundSymbol of string list

let error = Loc.error
let errorm = Loc.errorm

let rec print_qualid fmt = function
  | Qident s -> Format.fprintf fmt "%s" s.id
  | Qdot (m, s) -> Format.fprintf fmt "%a.%s" print_qualid m s.id

let () = Exn_printer.register (fun fmt e -> match e with
  | DuplicateTypeVar s ->
      Format.fprintf fmt "Type parameter %s is used twice" s
  | DuplicateProgVar s ->
      Format.fprintf fmt "Parameter %s is used twice" s
(*
  | PredicateExpected ->
      Format.fprintf fmt "syntax error: predicate expected"
  | TermExpected ->
      Format.fprintf fmt "syntax error: term expected"
  | FSymExpected ls ->
      Format.fprintf fmt "%a is not a function symbol" Pretty.print_ls ls
  | PSymExpected ls ->
      Format.fprintf fmt "%a is not a predicate symbol" Pretty.print_ls ls
  | ClashTheory s ->
      Format.fprintf fmt "Clash with previous theory %s" s
  | UnboundTheory q ->
      Format.fprintf fmt "unbound theory %a" print_qualid q
  | UnboundType sl ->
      Format.fprintf fmt "Unbound type '%a'"
        (Pp.print_list Pp.dot Pp.pp_print_string) sl
*)
  | UnboundTypeVar s ->
      Format.fprintf fmt "unbound type variable '%s" s
  | UnboundSymbol sl ->
      Format.fprintf fmt "Unbound symbol '%a'"
        (Pp.print_list Pp.dot Format.pp_print_string) sl
  | _ -> raise e)

(* TODO: let type_only = Debug.test_flag Typing.debug_type_only in *)

type denv = {
  uc     : module_uc;
  locals : (tvars * dity) Mstr.t;
  tvars  : tvars;
  denv   : Typing.denv; (* for user type variables only *)
}

let create_denv uc =
  { uc = uc;
    locals = Mstr.empty;
    tvars = empty_tvars;
    denv = Typing.create_denv (); }

(** Typing type expressions *)

let rec dity_of_pty ~user denv = function
  | Ptree.PPTtyvar id ->
      create_user_type_variable id
  | Ptree.PPTtyapp (pl, p) ->
      let dl = List.map (dity_of_pty ~user denv) pl in
      let x = Typing.string_list_of_qualid [] p in
      begin
        try
          let its = ns_find_it (get_namespace denv.uc) x in
          its_app ~user its dl
        with Not_found -> try
          let ts = ns_find_ts (Theory.get_namespace (get_theory denv.uc)) x in
          ts_app ts dl
        with Not_found ->
          let loc = Typing.qloc p in
          errorm ~loc "unbound symbol %a" Typing.print_qualid p
      end
  | Ptree.PPTtuple pl ->
      ts_app (ts_tuple (List.length pl)) (List.map (dity_of_pty ~user denv) pl)

(** Typing program expressions *)

let dity_unit = ts_app (ts_tuple 0) []
let dity_bool = ts_app ts_bool []

let expected_type e dity =
  unify e.dexpr_type dity

let rec extract_labels labs loc e = match e.Ptree.expr_desc with
  | Ptree.Enamed (Ptree.Lstr s, e) -> extract_labels (s :: labs) loc e
  | Ptree.Enamed (Ptree.Lpos p, e) -> extract_labels labs (Some p) e
  | Ptree.Ecast  (e, ty) ->
      let labs, loc, d = extract_labels labs loc e in
      labs, loc, Ptree.Ecast ({ e with Ptree.expr_desc = d }, ty)
  | e -> List.rev labs, loc, e

let rec decompose_app args e = match e.Ptree.expr_desc with
  | Eapply (e1, e2) -> decompose_app (e2 :: args) e1
  | _ -> e, args

(* record parsing *)

let parse_record uc fll =
  let pl = match fll with
    | [] -> raise EmptyRecord
    | (pl,_)::_ -> pl in
  let its = match pl.pl_args with
    | [{ vtv_ity = { ity_node = Ityapp (its,_,_) }}] -> its
    | _ -> raise (BadRecordField pl.pl_ls) in
  let cs, pjl = match find_constructors (get_known uc) its with
    | [cs,pjl] -> cs, List.map (exn_option (BadRecordField pl.pl_ls)) pjl
    | _ -> raise (BadRecordField pl.pl_ls) in
  let pjs = List.fold_left (fun s pj -> Sls.add pj.pl_ls s) Sls.empty pjl in
  let flm = List.fold_left (fun m (pj,v) -> let pj = pj.pl_ls in
    if not (Sls.mem pj pjs) then raise (BadRecordField pj) else
      Mls.add_new (DuplicateRecordField (cs.pl_ls,pj)) pj v m)
    Mls.empty fll
  in
  cs,pjl,flm

let find_field ~loc uc (p,e) =
  let x = Typing.string_list_of_qualid [] p in
  try match ns_find_ps (get_namespace uc) x with
    | PL pl -> (pl,e)
    | PV _ | PS _ -> errorm ~loc "bad record field %a" Typing.print_qualid p
  with Not_found -> errorm ~loc "unbound symbol %a" Typing.print_qualid p

let find_pure_field ~loc uc (p,e) =
  let x = Typing.string_list_of_qualid [] p in
  try ns_find_ls (Theory.get_namespace (get_theory uc)) x, e
  with Not_found -> errorm ~loc "unbound symbol %a" Typing.print_qualid p

let pure_record ~loc uc = function
  | [] -> error ~loc Decl.EmptyRecord
  | (p,_)::_ ->
      let x = Typing.string_list_of_qualid [] p in
      begin try ignore (ns_find_ps (get_namespace uc) x); false
      with Not_found -> true end

let hidden_pl ~loc pl =
  { dexpr_desc = DEglobal_pl pl;
    dexpr_type = specialize_plsymbol pl;
    dexpr_loc  = loc; dexpr_lab = [] }

let hidden_ls ~loc ls =
  { dexpr_desc = DEglobal_ls ls;
    dexpr_type = specialize_lsymbol ls;
    dexpr_loc  = loc; dexpr_lab = [] }

(* helper functions for let-expansion *)
let test_var e = match e.dexpr_desc with
  | DElocal _ | DEglobal_pv _ -> true
  | _ -> false

let mk_var e =
  if test_var e then e else
  { dexpr_desc = DElocal "q";
    dexpr_type = e.dexpr_type;
    dexpr_loc  = e.dexpr_loc;
    dexpr_lab  = [] }

let mk_let ~loc ~userloc e (desc,dity) =
  if test_var e then desc, dity else
  let loc = def_option loc userloc in
  let e1 = {
    dexpr_desc = desc; dexpr_type = dity; dexpr_loc = loc; dexpr_lab = [] } in
  DElet ({ id = "q"; id_lab = []; id_loc = loc }, e, e1), dity

(* value restriction *)
let rec is_fun e = match e.dexpr_desc with
  | DEfun _ -> true
  | DEmark (_, e) -> is_fun e
  | _ -> false

let dexpr_app e el =
  let res = create_type_variable () in
  let tyl = List.map (fun a -> a.dexpr_type) el in
  expected_type e (make_arrow_type tyl res);
  DEapply (e, el), res

let rec dexpr ~userloc denv e =
  let loc = e.Ptree.expr_loc in
  let labs, userloc, d = extract_labels [] userloc e in
  let d, ty = dexpr_desc ~userloc denv loc d in
  let loc = def_option loc userloc in
  { dexpr_desc = d; dexpr_loc = loc; dexpr_lab = labs; dexpr_type = ty }

and dexpr_desc ~userloc denv loc = function
  | Ptree.Eident (Qident {id=x}) when Mstr.mem x denv.locals ->
      (* local variable *)
      let tvs, dity = Mstr.find x denv.locals in
      let dity = specialize_scheme tvs dity in
      DElocal x, dity
  | Ptree.Eident p ->
      let x = Typing.string_list_of_qualid [] p in
      begin try match ns_find_ps (get_namespace denv.uc) x with
        | PV pv -> DEglobal_pv pv, specialize_pvsymbol pv
        | PS ps -> DEglobal_ps ps, specialize_psymbol  ps
        | PL pl -> DEglobal_pl pl, specialize_plsymbol pl
      with Not_found -> try
        let ls = ns_find_ls (Theory.get_namespace (get_theory denv.uc)) x in
        DEglobal_ls ls, specialize_lsymbol ls
      with Not_found ->
        errorm ~loc "unbound symbol %a" Typing.print_qualid p
      end
  | Ptree.Eapply (e1, e2) ->
      let e, el = decompose_app [e2] e1 in
      let el = List.map (dexpr ~userloc denv) el in
      dexpr_app (dexpr ~userloc denv e) el
  | Ptree.Elet (id, e1, e2) ->
      let e1 = dexpr ~userloc denv e1 in
      let tvars =
        if is_fun e1 then denv.tvars else add_tvars denv.tvars e1.dexpr_type in
      let s = tvars, e1.dexpr_type in
      let denv =
        { denv with locals = Mstr.add id.id s denv.locals; tvars = tvars } in
      let e2 = dexpr ~userloc denv e2 in
      DElet (id, e1, e2), e2.dexpr_type
  | Ptree.Efun (bl, tr) ->
      let dbinder denv (id, pty) =
        let dity = match pty with
          | Some pty -> dity_of_pty ~user:false denv pty
          | None -> create_type_variable ()
        in
        let tvars = add_tvars denv.tvars dity in
        let denv = { denv with
          locals = Mstr.add id.id (tvars, dity) denv.locals;
          tvars  = tvars }
        in
        denv, (id, false, dity)
      in
      let denv, bl = Util.map_fold_left dbinder denv bl in
      let _,e,_ as tr = dtriple ~userloc denv tr in
      let dity =
        make_arrow_type (List.map (fun (_,_,d) -> d) bl) e.dexpr_type in
      DEfun (bl, tr), dity
  | Ptree.Ecast (e1, pty) ->
      let e1 = dexpr ~userloc denv e1 in
      expected_type e1 (dity_of_pty ~user:false denv pty);
      e1.dexpr_desc, e1.dexpr_type
  | Ptree.Enamed _ ->
      assert false
  | Ptree.Esequence (e1, e2) ->
      let e1 = dexpr ~userloc denv e1 in
      expected_type e1 dity_unit;
      let e2 = dexpr ~userloc denv e2 in
      DElet ({ id = "_"; id_lab = []; id_loc = loc }, e1, e2), e2.dexpr_type
  | Ptree.Eif (e1, e2, e3) ->
      let e1 = dexpr ~userloc denv e1 in
      expected_type e1 dity_bool;
      let e2 = dexpr ~userloc denv e2 in
      let e3 = dexpr ~userloc denv e3 in
      expected_type e3 e2.dexpr_type;
      DEif (e1, e2, e3), e2.dexpr_type
  | Ptree.Etuple el ->
      let ls = fs_tuple (List.length el) in
      let el = List.map (dexpr ~userloc denv) el in
      dexpr_app (hidden_ls ~loc ls) el
  | Ptree.Erecord fl when pure_record ~loc denv.uc fl ->
      let kn = Theory.get_known (get_theory denv.uc) in
      let fl = List.map (find_pure_field ~loc denv.uc) fl in
      let cs,pjl,flm = Loc.try2 loc Decl.parse_record kn fl in
      let get_val pj = match Mls.find_opt pj flm with
        | Some e -> dexpr ~userloc denv e
        | None -> error ~loc (Decl.RecordFieldMissing (cs,pj)) in
      dexpr_app (hidden_ls ~loc cs) (List.map get_val pjl)
  | Ptree.Erecord fl ->
      let fl = List.map (find_field ~loc denv.uc) fl in
      let cs,pjl,flm = Loc.try2 loc parse_record denv.uc fl in
      let get_val pj = match Mls.find_opt pj.pl_ls flm with
        | Some e -> dexpr ~userloc denv e
        | None -> error ~loc (Decl.RecordFieldMissing (cs.pl_ls,pj.pl_ls)) in
      dexpr_app (hidden_pl ~loc cs) (List.map get_val pjl)
  | Ptree.Eupdate (e1, fl) when pure_record ~loc denv.uc fl ->
      let e1 = dexpr ~userloc denv e1 in
      let e0 = mk_var e1 in
      let kn = Theory.get_known (get_theory denv.uc) in
      let fl = List.map (find_pure_field ~loc denv.uc) fl in
      let cs,pjl,flm = Loc.try2 loc Decl.parse_record kn fl in
      let get_val pj = match Mls.find_opt pj flm with
        | Some e -> dexpr ~userloc denv e
        | None ->
            let d,dt = dexpr_app (hidden_ls ~loc pj) [e0] in
            { dexpr_desc = d; dexpr_type = dt; dexpr_loc = loc; dexpr_lab = [] }
      in
      let res = dexpr_app (hidden_ls ~loc cs) (List.map get_val pjl) in
      mk_let ~loc ~userloc e1 res
  | Ptree.Eupdate (e1, fl) ->
      let e1 = dexpr ~userloc denv e1 in
      let e0 = mk_var e1 in
      let fl = List.map (find_field ~loc denv.uc) fl in
      let cs,pjl,flm = Loc.try2 loc parse_record denv.uc fl in
      let get_val pj = match Mls.find_opt pj.pl_ls flm with
        | Some e -> dexpr ~userloc denv e
        | None ->
            let d,dt = dexpr_app (hidden_pl ~loc pj) [e0] in
            { dexpr_desc = d; dexpr_type = dt; dexpr_loc = loc; dexpr_lab = [] }
      in
      let res = dexpr_app (hidden_pl ~loc cs) (List.map get_val pjl) in
      mk_let ~loc ~userloc e1 res
  | Ptree.Econstant _c ->
      assert false (*TODO*)
  | Ptree.Eletrec (_rdl, _e1) ->
      assert false (*TODO*)
  | Ptree.Eassign (_e1, _q, _e2) ->
      assert false (*TODO*)
  | Ptree.Eloop (_ann, _e1) ->
      assert false (*TODO*)
  | Ptree.Elazy (_lazy_op, _e1, _e2) ->
      assert false (*TODO*)
  | Ptree.Enot (_e1) ->
      assert false (*TODO*)
  | Ptree.Ematch (_e1, _bl) ->
      assert false (*TODO*)
  | Ptree.Eabsurd ->
      assert false (*TODO*)
  | Ptree.Eraise (_q, _e1) ->
      assert false (*TODO*)
  | Ptree.Etry (_e1, _cl) ->
      assert false (*TODO*)
  | Ptree.Efor (_id, _e1, _dir, _e2, _lexpr_opt, _e3) ->
      assert false (*TODO*)
  | Ptree.Eassert (_ass, _lexpr) ->
      assert false (*TODO*)
  | Ptree.Emark (_id, _e1) ->
      assert false (*TODO*)
  | Ptree.Eany (_type_c) ->
      assert false (*TODO*)
  | Ptree.Eabstract (_e1, _post) ->
      assert false (*TODO*)

and dtriple ~userloc denv (p, e, q) =
  let e = dexpr ~userloc denv e in
  let q = dpost denv q in
  p, e, q

and dpost _denv (q, _ql) =
  q, [] (* TODO *)

let id_user x = id_user x.id x.id_loc

let rec expr locals de = match de.dexpr_desc with
  | DElocal x ->
      assert (Mstr.mem x locals);
      begin match Mstr.find x locals with
      | LetV pv -> e_value pv
      | LetA ps -> e_cast ps (vty_of_dity de.dexpr_type)
      end
  | DElet (x, { dexpr_desc = DEfun (bl, tr) }, de2) ->
      let def1 = expr_fun locals x bl tr in
      let locals = Mstr.add x.id (LetA def1.rec_ps) locals in
      let e2 = expr locals de2 in
      e_rec [def1] e2
  | DEfun (bl, tr) ->
      let x = { id = "fn"; id_loc = de.dexpr_loc; id_lab = [] } in
      let def = expr_fun locals x bl tr in
      let e2 = e_cast def.rec_ps (VTarrow def.rec_ps.ps_vta) in
      e_rec [def] e2
  | DElet (x, de1, de2) ->
      let e1 = expr locals de1 in
      let def1 = create_let_defn (id_user x) e1 in
      let locals = Mstr.add x.id def1.let_var locals in
      let e2 = expr locals de2 in
      e_let def1 e2
  | DEapply (de1, del) ->
      let el = List.map (expr locals) del in
      begin match de1.dexpr_desc with
        | DEglobal_pl pls -> e_plapp pls el (ity_of_dity de.dexpr_type)
        | DEglobal_ls ls  -> e_lapp  ls  el (ity_of_dity de.dexpr_type)
        | _               -> e_app (expr locals de1) el
      end
  | DEglobal_pv pv ->
      e_value pv
  | DEglobal_ps ps ->
      e_cast ps (vty_of_dity de.dexpr_type)
  | DEglobal_pl pl ->
      assert (pl.pl_ls.ls_args = []);
      e_plapp pl [] (ity_of_dity de.dexpr_type)
  | DEglobal_ls ls ->
      assert (ls.ls_args = []);
      e_lapp ls [] (ity_of_dity de.dexpr_type)
  | DEif (de1, de2, de3) ->
      e_if (expr locals de1) (expr locals de2) (expr locals de3)
  | _ ->
      assert false (*TODO*)

and expr_fun locals x bl (_, e1, _) =
  let binder (id, ghost, dity) =
    let vtv = vty_value ~ghost (ity_of_dity dity) in
    create_pvsymbol (id_user id) vtv in
  let pvl = List.map binder bl in
  let add_binder pv = Mstr.add pv.pv_vs.vs_name.id_string (LetV pv) in
  let locals' = List.fold_right add_binder pvl locals in
  let e1 = expr locals' e1 in
  let ty1 = match e1.e_vty with
    | VTarrow _ -> ty_tuple []
    | VTvalue vtv -> ty_of_ity vtv.vtv_ity in
  let res1 = create_vsymbol (id_fresh "result") ty1 in
  let lam = {
    l_args = pvl;
    l_variant = [];
    l_pre = t_true;                   (* TODO *)
    l_expr = e1;
    l_post = create_post res1 t_true; (* TODO *)
    l_xpost = Mexn.empty;             (* TODO *)
  } in
  create_fun_defn (id_user x) lam

(** Type declaration *)

type tys = ProgTS of itysymbol | PureTS of tysymbol

let find_tysymbol q uc =
  let loc = Typing.qloc q in
  let sl = Typing.string_list_of_qualid [] q in
  try ProgTS (ns_find_it (get_namespace uc) sl)
  with Not_found ->
  try PureTS (ns_find_ts (Theory.get_namespace (get_theory uc)) sl)
  with Not_found -> error ~loc (UnboundSymbol sl)

let look_for_loc tdl s =
  let look_id loc id = if id.id = s then Some id.id_loc else loc in
  let look_pj loc (id,_) = option_fold look_id loc id in
  let look_cs loc (csloc,id,pjl) =
    let loc = if id.id = s then Some csloc else loc in
    List.fold_left look_pj loc pjl in
  let look_fl loc f = look_id loc f.f_ident in
  let look loc d =
    let loc = look_id loc d.td_ident in
    match d.td_def with
      | TDabstract | TDalias _ -> loc
      | TDalgebraic csl -> List.fold_left look_cs loc csl
      | TDrecord fl -> List.fold_left look_fl loc fl
  in
  List.fold_left look None tdl

let add_types uc tdl =
  let add m d =
    let id = d.td_ident.id in
    Mstr.add_new (Loc.Located (d.td_loc, ClashSymbol id)) id d m in
  let def = List.fold_left add Mstr.empty tdl in

  (* detect cycles *)

  let rec cyc_visit x d seen = match Mstr.find_opt x seen with
    | Some true -> seen
    | Some false -> errorm ~loc:d.td_loc "Cyclic type definition"
    | None ->
        let ts_seen seen = function
          | Qident { id = x } ->
              begin try cyc_visit x (Mstr.find x def) seen
              with Not_found -> seen end
          | _ -> seen in
        let rec check seen = function
          | PPTtyvar _ -> seen
          | PPTtyapp (tyl,q) -> List.fold_left check (ts_seen seen q) tyl
          | PPTtuple tyl -> List.fold_left check seen tyl in
        let seen = match d.td_def with
          | TDabstract | TDalgebraic _ | TDrecord _ -> seen
          | TDalias ty -> check (Mstr.add x false seen) ty in
        Mstr.add x true seen in
  ignore (Mstr.fold cyc_visit def Mstr.empty);

  (* detect mutable types *)

  let mutables = Hashtbl.create 5 in
  let rec mut_visit x =
    try Hashtbl.find mutables x
    with Not_found ->
      let ts_mut = function
        | Qident { id = x } when Mstr.mem x def -> mut_visit x
        | q ->
            begin match find_tysymbol q uc with
              | ProgTS s -> s.its_regs <> []
              | PureTS _ -> false end in
      let rec check = function
        | PPTtyvar _ -> false
        | PPTtyapp (tyl,q) -> ts_mut q || List.exists check tyl
        | PPTtuple tyl -> List.exists check tyl in
      Hashtbl.replace mutables x false;
      let mut = match (Mstr.find x def).td_def with
        | TDabstract -> false
        | TDalias ty -> check ty
        | TDalgebraic csl ->
            let proj (_,pty) = check pty in
            List.exists (fun (_,_,l) -> List.exists proj l) csl
        | TDrecord fl ->
            let field f = f.f_mutable || check f.f_pty in
            List.exists field fl in
      Hashtbl.replace mutables x mut;
      mut
  in
  Mstr.iter (fun x _ -> ignore (mut_visit x)) def;

  (* create type symbols and predefinitions for mutable types *)

  let tysymbols = Hashtbl.create 5 in
  let predefs = Hashtbl.create 5 in
  let rec its_visit x =
    try match Hashtbl.find tysymbols x with
      | Some ts -> ts
      | None ->
          let loc = (Mstr.find x def).td_loc in
          errorm ~loc "Mutable type in a recursive type definition"
    with Not_found ->
      let d = Mstr.find x def in
      let add_tv acc id =
        let e = Loc.Located (id.id_loc, DuplicateTypeVar id.id) in
        let tv = create_tvsymbol (Denv.create_user_id id) in
        Mstr.add_new e id.id tv acc in
      let vars = List.fold_left add_tv Mstr.empty d.td_params in
      let vl = List.map (fun id -> Mstr.find id.id vars) d.td_params in
      let id = Denv.create_user_id d.td_ident in
      let abst = d.td_vis = Abstract in
      let priv = d.td_vis = Private in
      Hashtbl.add tysymbols x None;
      let get_ts = function
        | Qident { id = x } when Mstr.mem x def -> ProgTS (its_visit x)
        | q -> find_tysymbol q uc
      in
      let rec parse = function
        | PPTtyvar { id = v ; id_loc = loc } ->
            let e = Loc.Located (loc, UnboundTypeVar v) in
            ity_var (Mstr.find_exn e v vars)
        | PPTtyapp (tyl,q) ->
            let tyl = List.map parse tyl in
            begin match get_ts q with
              | PureTS ts -> Loc.try2 (Typing.qloc q) ity_pur ts tyl
              | ProgTS ts -> Loc.try2 (Typing.qloc q) ity_app_fresh ts tyl
            end
        | PPTtuple tyl ->
            let ts = ts_tuple (List.length tyl) in
            ity_pur ts (List.map parse tyl)
      in
      let ts = match d.td_def with
        | TDalias ty ->
            let def = parse ty in
            let rl = Sreg.elements def.ity_vars.vars_reg in
            create_itysymbol id ~abst ~priv vl rl (Some def)
        | TDalgebraic csl when Hashtbl.find mutables x ->
            let projs = Hashtbl.create 5 in
            (* to check projections' types we must fix the tyvars *)
            let add s v = let t = ity_var v in ity_match s t t in
            let sbs = List.fold_left add ity_subst_empty vl in
            let mk_proj s (id,pty) =
              let ity = parse pty in
              let vtv = vty_value ity in
              match id with
                | None ->
                    let pv = create_pvsymbol (id_fresh "pj") vtv in
                    Sreg.union s ity.ity_vars.vars_reg, (pv, false)
                | Some id ->
                    try
                      let pv = Hashtbl.find projs id.id in
                      let ty = pv.pv_vtv.vtv_ity in
                      (* once we have ghost/mutable fields in algebraics,
                         don't forget to check here that they coincide, too *)
                      ignore (Loc.try3 id.id_loc ity_match sbs ty ity);
                      s, (pv, true)
                    with Not_found ->
                      let pv = create_pvsymbol (Denv.create_user_id id) vtv in
                      Hashtbl.replace projs id.id pv;
                      Sreg.union s ity.ity_vars.vars_reg, (pv, true)
            in
            let mk_constr s (_loc,cid,pjl) =
              let s,pjl = Util.map_fold_left mk_proj s pjl in
              s, (Denv.create_user_id cid, pjl)
            in
            let s,def = Util.map_fold_left mk_constr Sreg.empty csl in
            Hashtbl.replace predefs x def;
            create_itysymbol id ~abst ~priv vl (Sreg.elements s) None
        | TDrecord fl when Hashtbl.find mutables x ->
            let mk_field s f =
              let ghost = f.f_ghost in
              let ity = parse f.f_pty in
              let fid = Denv.create_user_id f.f_ident in
              let s,mut = if f.f_mutable then
                let r = create_region fid ity in
                Sreg.add r s, Some r
              else
                Sreg.union s ity.ity_vars.vars_reg, None
              in
              let vtv = vty_value ?mut ~ghost ity in
              s, (create_pvsymbol fid vtv, true)
            in
            let s,pjl = Util.map_fold_left mk_field Sreg.empty fl in
            let cid = { d.td_ident with id = "mk " ^ d.td_ident.id } in
            Hashtbl.replace predefs x [Denv.create_user_id cid, pjl];
            create_itysymbol id ~abst ~priv vl (Sreg.elements s) None
        | TDalgebraic _ | TDrecord _ | TDabstract ->
            create_itysymbol id ~abst ~priv vl [] None
      in
      Hashtbl.add tysymbols x (Some ts);
      ts
  in
  Mstr.iter (fun x _ -> ignore (its_visit x)) def;

  (* create predefinitions for immutable types *)

  let def_visit d (abstr,algeb,alias) =
    let x = d.td_ident.id in
    let ts = Util.of_option (Hashtbl.find tysymbols x) in
    let add_tv s x v = Mstr.add x.id v s in
    let vars = List.fold_left2 add_tv Mstr.empty d.td_params ts.its_args in
    let get_ts = function
      | Qident { id = x } when Mstr.mem x def ->
          ProgTS (Util.of_option (Hashtbl.find tysymbols x))
      | q -> find_tysymbol q uc
    in
    let rec parse = function
      | PPTtyvar { id = v ; id_loc = loc } ->
          let e = Loc.Located (loc, UnboundTypeVar v) in
          ity_var (Mstr.find_exn e v vars)
      | PPTtyapp (tyl,q) ->
          let tyl = List.map parse tyl in
          begin match get_ts q with
            | PureTS ts -> Loc.try2 (Typing.qloc q) ity_pur ts tyl
            | ProgTS ts -> Loc.try3 (Typing.qloc q) ity_app ts tyl []
          end
      | PPTtuple tyl ->
          let ts = ts_tuple (List.length tyl) in
          ity_pur ts (List.map parse tyl)
    in
    match d.td_def with
      | TDabstract ->
          ts :: abstr, algeb, alias
      | TDalias _ ->
          abstr, algeb, ts :: alias
      | (TDalgebraic _ | TDrecord _) when Hashtbl.find mutables x ->
          abstr, (ts, Hashtbl.find predefs x) :: algeb, alias
      | TDalgebraic csl ->
          let projs = Hashtbl.create 5 in
          let mk_proj (id,pty) =
            let ity = parse pty in
            let vtv = vty_value ity in
            match id with
              | None ->
                  create_pvsymbol (id_fresh "pj") vtv, false
              | Some id ->
                  try
                    let pv = Hashtbl.find projs id.id in
                    let ty = pv.pv_vtv.vtv_ity in
                    (* once we have ghost/mutable fields in algebraics,
                       don't forget to check here that they coincide, too *)
                    Loc.try2 id.id_loc ity_equal_check ty ity;
                    pv, true
                  with Not_found ->
                    let pv = create_pvsymbol (Denv.create_user_id id) vtv in
                    Hashtbl.replace projs id.id pv;
                    pv, true
          in
          let mk_constr (_loc,cid,pjl) =
            Denv.create_user_id cid, List.map mk_proj pjl in
          abstr, (ts, List.map mk_constr csl) :: algeb, alias
      | TDrecord fl ->
          let mk_field f =
            let fid = Denv.create_user_id f.f_ident in
            let vtv = vty_value ~ghost:f.f_ghost (parse f.f_pty) in
            create_pvsymbol fid vtv, true in
          let cid = { d.td_ident with id = "mk " ^ d.td_ident.id } in
          let csl = [Denv.create_user_id cid, List.map mk_field fl] in
          abstr, (ts, csl) :: algeb, alias
  in
  let abstr,algeb,alias = List.fold_right def_visit tdl ([],[],[]) in

  (* detect pure type declarations *)

  let kn = get_known uc in
  let check its = Mid.mem its.its_pure.ts_name kn in
  let check ity = ity_s_any check Util.ffalse ity in
  let is_impure_type ts =
    ts.its_abst || ts.its_priv || ts.its_regs <> [] ||
    option_apply false check ts.its_def
  in
  let check (pv,_) =
    let vtv = pv.pv_vtv in
    vtv.vtv_ghost || vtv.vtv_mut <> None || check vtv.vtv_ity in
  let is_impure_data (ts,csl) =
    is_impure_type ts ||
    List.exists (fun (_,l) -> List.exists check l) csl
  in
  let mk_pure_decl (ts,csl) =
    let pjt = Hvs.create 3 in
    let ty = ty_app ts.its_pure (List.map ty_var ts.its_args) in
    let mk_proj (pv,f) =
      let vs = pv.pv_vs in
      if f then try vs.vs_ty, Some (Hvs.find pjt vs) with Not_found ->
        let pj = create_fsymbol (id_clone vs.vs_name) [ty] vs.vs_ty in
        Hvs.replace pjt vs pj;
        vs.vs_ty, Some pj
      else
        vs.vs_ty, None
    in
    let mk_constr (id,pjl) =
      let pjl = List.map mk_proj pjl in
      let cs = create_fsymbol id (List.map fst pjl) ty in
      cs, List.map snd pjl
    in
    ts.its_pure, List.map mk_constr csl
  in
  let add_type_decl uc ts =
    if is_impure_type ts then
      add_pdecl_with_tuples uc (create_ty_decl ts)
    else
      add_decl_with_tuples uc (Decl.create_ty_decl ts.its_pure)
  in
  try
    let uc = List.fold_left add_type_decl uc abstr in
    let uc = if algeb = [] then uc else
      if List.exists is_impure_data algeb then
        add_pdecl_with_tuples uc (create_data_decl algeb)
      else
        let d = List.map mk_pure_decl algeb in
        add_decl_with_tuples uc (Decl.create_data_decl d)
    in
    let uc = List.fold_left add_type_decl uc alias in
    uc
  with
    | ClashSymbol s ->
        error ?loc:(look_for_loc tdl s) (ClashSymbol s)
    | RecordFieldMissing ({ ls_name = { id_string = s }} as cs,ls) ->
        error ?loc:(look_for_loc tdl s) (RecordFieldMissing (cs,ls))
    | DuplicateRecordField ({ ls_name = { id_string = s }} as cs,ls) ->
        error ?loc:(look_for_loc tdl s) (DuplicateRecordField (cs,ls))
    | DuplicateVar { vs_name = { id_string = s }} ->
        errorm ?loc:(look_for_loc tdl s)
          "Field %s is used twice in the same constructor" s

(** Use/Clone of theories and modules *)

type mlw_contents = modul Mstr.t
type mlw_library = mlw_contents library
type mlw_file = mlw_contents * Theory.theory Mstr.t

let find_theory loc lib path s =
  (* search first in .mlw files (using lib) *)
  let thm =
    try Some (Env.read_lib_theory lib path s)
    with LibFileNotFound _ | TheoryNotFound _ -> None
  in
  (* search also in .why files *)
  let th =
    try Some (Env.find_theory (Env.env_of_library lib) path s)
    with LibFileNotFound _ | TheoryNotFound _ -> None
  in
  match thm, th with
    | Some _, Some _ ->
        Loc.errorm ~loc
          "a module/theory %s is defined both in Why and WhyML libraries" s
    | None, None -> Loc.error ~loc (Env.TheoryNotFound (path, s))
    | None, Some t | Some t, None -> t

let find_theory loc lib mt path s = match path with
  | [] -> (* local theory *)
      begin try Mstr.find s mt with Not_found -> find_theory loc lib [] s end
  | _ :: _ -> (* theory in file path *)
      find_theory loc lib path s

type theory_or_module = Theory of Theory.theory | Module of modul

let print_path fmt sl =
  Pp.print_list (Pp.constant_string ".") Format.pp_print_string fmt sl

let find_module loc lib path s =
  (* search first in .mlw files *)
  let m, thm =
    try
      let mm, mt = Env.read_lib_file lib path in
      Mstr.find_opt s mm, Mstr.find_opt s mt
    with
      | LibFileNotFound _ -> None, None
  in
  (* search also in .why files *)
  let th =
    try Some (Env.find_theory (Env.env_of_library lib) path s)
    with LibFileNotFound _ | TheoryNotFound _ -> None
  in
  match m, thm, th with
    | Some _, None, _ -> assert false
    | _, Some _, Some _ ->
        Loc.errorm ~loc
          "a module/theory %s is defined both in Why and WhyML libraries" s
    | None, None, None ->
        Loc.errorm ~loc "Theory/module not found: %a" print_path (path @ [s])
    | Some m, Some _, None -> Module m
    | None, Some t, None | None, None, Some t -> Theory t

let find_module loc lib mm mt path s = match path with
  | [] -> (* local module/theory *)
      begin try Module (Mstr.find s mm)
        with Not_found -> begin try Theory (Mstr.find s mt)
          with Not_found -> find_module loc lib [] s end end
  | _ :: _ -> (* module/theory in file path *)
      find_module loc lib path s

(** Main loop *)

let add_theory lib path mt m =
  let { id = id; id_loc = loc } = m.pth_name in
  if Mstr.mem id mt then Loc.errorm ~loc "clash with previous theory %s" id;
  let uc = create_theory ~path (Denv.create_user_id m.pth_name) in
  let rec add_decl uc = function
    | Dlogic d ->
        Typing.add_decl uc d
    | Duseclone (loc, use, inst) ->
        let path, s = Typing.split_qualid use.use_theory in
        let th = find_theory loc lib mt path s in
        (* open namespace, if any *)
        let uc =
          if use.use_imp_exp <> None then Theory.open_namespace uc else uc in
        (* use or clone *)
        let uc = match inst with
          | None -> Theory.use_export uc th
          | Some inst ->
              let inst = Typing.type_inst uc th inst in
              Theory.clone_export uc th inst
        in
        (* close namespace, if any *)
        begin match use.use_imp_exp with
          | None -> uc
          | Some imp -> Theory.close_namespace uc imp use.use_as
        end
    | Dnamespace (loc, name, import, dl) ->
        let uc = Theory.open_namespace uc in
        let uc = List.fold_left add_decl uc dl in
        Loc.try3 loc Theory.close_namespace uc import name
    | Dlet _ | Dletrec _ | Dparam _ | Dexn _ | Duse _ ->
        assert false
  in
  let uc = List.fold_left add_decl uc m.pth_decl in
  let th = close_theory uc in
  Mstr.add id th mt

let add_module lib path mm mt m =
  let { id = id; id_loc = loc } = m.mod_name in
  if Mstr.mem id mm then Loc.errorm ~loc "clash with previous module %s" id;
  if Mstr.mem id mt then Loc.errorm ~loc "clash with previous theory %s" id;
  let uc = create_module ~path (Denv.create_user_id m.mod_name) in
  let rec add_decl uc = function
    | Dlogic (TypeDecl tdl) ->
        add_types uc tdl
    | Dlogic d ->
        add_to_theory Typing.add_decl uc d
    | Duseclone (loc, use, inst) ->
        let path, s = Typing.split_qualid use.use_theory in
        let mth = find_module loc lib mm mt path s in
        (* open namespace, if any *)
        let uc = if use.use_imp_exp <> None then open_namespace uc else uc in
        (* use or clone *)
        let uc = match mth, inst with
          | Theory th, None -> use_export_theory uc th
          | Theory th, Some inst ->
              let inst = Typing.type_inst (get_theory uc) th inst in
              clone_export_theory uc th inst
          | Module m, None -> use_export uc m
          | Module m, Some inst ->
              let inst = Typing.type_inst (get_theory uc) m.mod_theory inst in
              clone_export uc m inst
        in
        (* close namespace, if any *)
        begin match use.use_imp_exp with
          | None -> uc
          | Some imp -> close_namespace uc imp use.use_as
        end
    | Dnamespace (loc, name, import, dl) ->
        let uc = open_namespace uc in
        let uc = List.fold_left add_decl uc dl in
        Loc.try3 loc close_namespace uc import name
    | Dlet (_id, e) ->
        let e = dexpr ~userloc:None (create_denv uc) e in
        let e = expr Mstr.empty e in
        Format.eprintf "@[%a@]@." Mlw_pretty.print_expr e;
        uc
    | Dletrec _ | Dparam _ | Dexn _ ->
        assert false (* TODO *)
    | Duse _ ->
        assert false (*TO BE REMOVED EVENTUALLY *)
  in
  let uc = List.fold_left add_decl uc m.mod_decl in
  let m = close_module uc in
  Mstr.add id m mm, Mstr.add id m.mod_theory mt

let add_theory_module lib path (mm, mt) = function
  | Ptheory th -> mm, add_theory lib path mt th
  | Pmodule m -> add_module lib path mm mt m

