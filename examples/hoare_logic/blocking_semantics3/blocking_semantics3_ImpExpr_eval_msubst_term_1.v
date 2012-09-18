(* This file is generated by Why3's Coq driver *)
(* Beware! Only edit allowed sections below    *)
Require Import BuiltIn.
Require BuiltIn.
Require int.Int.
Require int.MinMax.

(* Why3 assumption *)
Inductive list (a:Type) {a_WT:WhyType a} :=
  | Nil : list a
  | Cons : a -> (list a) -> list a.
Axiom list_WhyType : forall (a:Type) {a_WT:WhyType a}, WhyType (list a).
Existing Instance list_WhyType.
Implicit Arguments Nil [[a] [a_WT]].
Implicit Arguments Cons [[a] [a_WT]].

Axiom map : forall (a:Type) {a_WT:WhyType a} (b:Type) {b_WT:WhyType b}, Type.
Parameter map_WhyType : forall (a:Type) {a_WT:WhyType a}
  (b:Type) {b_WT:WhyType b}, WhyType (map a b).
Existing Instance map_WhyType.

Parameter get: forall {a:Type} {a_WT:WhyType a} {b:Type} {b_WT:WhyType b},
  (map a b) -> a -> b.

Parameter set: forall {a:Type} {a_WT:WhyType a} {b:Type} {b_WT:WhyType b},
  (map a b) -> a -> b -> (map a b).

Axiom Select_eq : forall {a:Type} {a_WT:WhyType a} {b:Type} {b_WT:WhyType b},
  forall (m:(map a b)), forall (a1:a) (a2:a), forall (b1:b), (a1 = a2) ->
  ((get (set m a1 b1) a2) = b1).

Axiom Select_neq : forall {a:Type} {a_WT:WhyType a}
  {b:Type} {b_WT:WhyType b}, forall (m:(map a b)), forall (a1:a) (a2:a),
  forall (b1:b), (~ (a1 = a2)) -> ((get (set m a1 b1) a2) = (get m a2)).

Parameter const: forall {a:Type} {a_WT:WhyType a} {b:Type} {b_WT:WhyType b},
  b -> (map a b).

Axiom Const : forall {a:Type} {a_WT:WhyType a} {b:Type} {b_WT:WhyType b},
  forall (b1:b) (a1:a), ((get (const b1:(map a b)) a1) = b1).

(* Why3 assumption *)
Inductive datatype  :=
  | TYunit : datatype 
  | TYint : datatype 
  | TYbool : datatype .
Axiom datatype_WhyType : WhyType datatype.
Existing Instance datatype_WhyType.

(* Why3 assumption *)
Inductive value  :=
  | Vvoid : value 
  | Vint : Z -> value 
  | Vbool : bool -> value .
Axiom value_WhyType : WhyType value.
Existing Instance value_WhyType.

(* Why3 assumption *)
Inductive operator  :=
  | Oplus : operator 
  | Ominus : operator 
  | Omult : operator 
  | Ole : operator .
Axiom operator_WhyType : WhyType operator.
Existing Instance operator_WhyType.

Axiom mident : Type.
Parameter mident_WhyType : WhyType mident.
Existing Instance mident_WhyType.

Axiom mident_decide : forall (m1:mident) (m2:mident), (m1 = m2) \/
  ~ (m1 = m2).

(* Why3 assumption *)
Inductive ident  :=
  | mk_ident : Z -> ident .
Axiom ident_WhyType : WhyType ident.
Existing Instance ident_WhyType.

(* Why3 assumption *)
Definition ident_index(v:ident): Z := match v with
  | (mk_ident x) => x
  end.

(* Why3 assumption *)
Inductive term_node  :=
  | Tvalue : value -> term_node 
  | Tvar : ident -> term_node 
  | Tderef : mident -> term_node 
  | Tbin : term -> operator -> term -> term_node 
  with term  :=
  | mk_term : term_node -> Z -> term .
Axiom term_WhyType : WhyType term.
Existing Instance term_WhyType.

Axiom term_node_WhyType : WhyType term_node.
Existing Instance term_node_WhyType.

Scheme term_induc := Induction for term Sort Prop 
   with term_node_induc := Induction for term_node Sort Prop.

Print term_induc.

(* Why3 assumption *)
Definition term_maxvar(v:term): Z := match v with
  | (mk_term x x1) => x1
  end.

(* Why3 assumption *)
Definition term_node1(v:term): term_node :=
  match v with
  | (mk_term x x1) => x
  end.

(* Why3 assumption *)
Fixpoint var_occurs_in_term(x:ident) (t:term) {struct t}: Prop :=
  match t with
  | (mk_term (Tvalue _) _) => False
  | (mk_term (Tvar i) _) => (x = i)
  | (mk_term (Tderef _) _) => False
  | (mk_term (Tbin t1 _ t2) _) => (var_occurs_in_term x t1) \/
      (var_occurs_in_term x t2)
  end.

(* Why3 assumption *)
Definition term_inv(t:term): Prop := forall (x:ident), (var_occurs_in_term x
  t) -> ((ident_index x) <= (term_maxvar t))%Z.

(* Why3 assumption *)
Definition mk_tvalue(v:value): term := (mk_term (Tvalue v) (-1%Z)%Z).

Axiom mk_tvalue_inv : forall (v:value), (term_inv (mk_tvalue v)).

(* Why3 assumption *)
Definition mk_tvar(i:ident): term := (mk_term (Tvar i) (ident_index i)).

Axiom mk_tvar_inv : forall (i:ident), (term_inv (mk_tvar i)).

(* Why3 assumption *)
Definition mk_tderef(r:mident): term := (mk_term (Tderef r) (-1%Z)%Z).

Axiom mk_tderef_inv : forall (r:mident), (term_inv (mk_tderef r)).

(* Why3 assumption *)
Definition mk_tbin(t1:term) (o:operator) (t2:term): term := (mk_term (Tbin t1
  o t2) (Zmax (term_maxvar t1) (term_maxvar t2))).

Axiom mk_tbin_inv : forall (t1:term) (t2:term) (o:operator),
  ((term_inv t1) /\ (term_inv t2)) -> (term_inv (mk_tbin t1 o t2)).

(* Why3 assumption *)
Inductive fmla  :=
  | Fterm : term -> fmla 
  | Fand : fmla -> fmla -> fmla 
  | Fnot : fmla -> fmla 
  | Fimplies : fmla -> fmla -> fmla 
  | Flet : ident -> term -> fmla -> fmla 
  | Fforall : ident -> datatype -> fmla -> fmla .
Axiom fmla_WhyType : WhyType fmla.
Existing Instance fmla_WhyType.

Print fmla_ind.

(* Why3 assumption *)
Inductive stmt  :=
  | Sskip : stmt 
  | Sassign : mident -> term -> stmt 
  | Sseq : stmt -> stmt -> stmt 
  | Sif : term -> stmt -> stmt -> stmt 
  | Sassert : fmla -> stmt 
  | Swhile : term -> fmla -> stmt -> stmt .
Axiom stmt_WhyType : WhyType stmt.
Existing Instance stmt_WhyType.

Axiom decide_is_skip : forall (s:stmt), (s = Sskip) \/ ~ (s = Sskip).

(* Why3 assumption *)
Definition type_value(v:value): datatype :=
  match v with
  | Vvoid => TYunit
  | (Vint int) => TYint
  | (Vbool bool1) => TYbool
  end.

(* Why3 assumption *)
Inductive type_operator : operator -> datatype -> datatype
  -> datatype -> Prop :=
  | Type_plus : (type_operator Oplus TYint TYint TYint)
  | Type_minus : (type_operator Ominus TYint TYint TYint)
  | Type_mult : (type_operator Omult TYint TYint TYint)
  | Type_le : (type_operator Ole TYint TYint TYbool).

(* Why3 assumption *)
Definition type_stack  := (list (ident* datatype)%type).

Parameter get_vartype: ident -> (list (ident* datatype)%type) -> datatype.

Axiom get_vartype_def : forall (i:ident) (pi:(list (ident* datatype)%type)),
  match pi with
  | Nil => ((get_vartype i pi) = TYunit)
  | (Cons (x, ty) r) => ((x = i) -> ((get_vartype i pi) = ty)) /\
      ((~ (x = i)) -> ((get_vartype i pi) = (get_vartype i r)))
  end.

(* Why3 assumption *)
Definition type_env  := (map mident datatype).

(* Why3 assumption *)
Inductive type_term : (map mident datatype) -> (list (ident* datatype)%type)
  -> term -> datatype -> Prop :=
  | Type_value : forall (sigma:(map mident datatype)) (pi:(list (ident*
      datatype)%type)) (v:value) (m:Z), (type_term sigma pi
      (mk_term (Tvalue v) m) (type_value v))
  | Type_var : forall (sigma:(map mident datatype)) (pi:(list (ident*
      datatype)%type)) (v:ident) (m:Z) (ty:datatype), ((get_vartype v
      pi) = ty) -> (type_term sigma pi (mk_term (Tvar v) m) ty)
  | Type_deref : forall (sigma:(map mident datatype)) (pi:(list (ident*
      datatype)%type)) (v:mident) (m:Z) (ty:datatype), ((get sigma
      v) = ty) -> (type_term sigma pi (mk_term (Tderef v) m) ty)
  | Type_bin : forall (sigma:(map mident datatype)) (pi:(list (ident*
      datatype)%type)) (t1:term) (t2:term) (op:operator) (m:Z) (ty1:datatype)
      (ty2:datatype) (ty:datatype), (type_term sigma pi t1 ty1) ->
      ((type_term sigma pi t2 ty2) -> ((type_operator op ty1 ty2 ty) ->
      (type_term sigma pi (mk_term (Tbin t1 op t2) m) ty))).

(* Why3 assumption *)
Inductive type_fmla : (map mident datatype) -> (list (ident* datatype)%type)
  -> fmla -> Prop :=
  | Type_term : forall (sigma:(map mident datatype)) (pi:(list (ident*
      datatype)%type)) (t:term), (type_term sigma pi t TYbool) ->
      (type_fmla sigma pi (Fterm t))
  | Type_conj : forall (sigma:(map mident datatype)) (pi:(list (ident*
      datatype)%type)) (f1:fmla) (f2:fmla), (type_fmla sigma pi f1) ->
      ((type_fmla sigma pi f2) -> (type_fmla sigma pi (Fand f1 f2)))
  | Type_neg : forall (sigma:(map mident datatype)) (pi:(list (ident*
      datatype)%type)) (f:fmla), (type_fmla sigma pi f) -> (type_fmla sigma
      pi (Fnot f))
  | Type_implies : forall (sigma:(map mident datatype)) (pi:(list (ident*
      datatype)%type)) (f1:fmla) (f2:fmla), (type_fmla sigma pi f1) ->
      ((type_fmla sigma pi f2) -> (type_fmla sigma pi (Fimplies f1 f2)))
  | Type_let : forall (sigma:(map mident datatype)) (pi:(list (ident*
      datatype)%type)) (x:ident) (t:term) (f:fmla) (ty:datatype),
      (type_term sigma pi t ty) -> ((type_fmla sigma (Cons (x, ty) pi) f) ->
      (type_fmla sigma pi (Flet x t f)))
  | Type_forall1 : forall (sigma:(map mident datatype)) (pi:(list (ident*
      datatype)%type)) (x:ident) (f:fmla), (type_fmla sigma (Cons (x, TYint)
      pi) f) -> (type_fmla sigma pi (Fforall x TYint f))
  | Type_forall2 : forall (sigma:(map mident datatype)) (pi:(list (ident*
      datatype)%type)) (x:ident) (f:fmla), (type_fmla sigma (Cons (x, TYbool)
      pi) f) -> (type_fmla sigma pi (Fforall x TYbool f))
  | Type_forall3 : forall (sigma:(map mident datatype)) (pi:(list (ident*
      datatype)%type)) (x:ident) (f:fmla), (type_fmla sigma (Cons (x, TYunit)
      pi) f) -> (type_fmla sigma pi (Fforall x TYunit f)).

(* Why3 assumption *)
Inductive type_stmt : (map mident datatype) -> (list (ident* datatype)%type)
  -> stmt -> Prop :=
  | Type_skip : forall (sigma:(map mident datatype)) (pi:(list (ident*
      datatype)%type)), (type_stmt sigma pi Sskip)
  | Type_seq : forall (sigma:(map mident datatype)) (pi:(list (ident*
      datatype)%type)) (s1:stmt) (s2:stmt), (type_stmt sigma pi s1) ->
      ((type_stmt sigma pi s2) -> (type_stmt sigma pi (Sseq s1 s2)))
  | Type_assigns : forall (sigma:(map mident datatype)) (pi:(list (ident*
      datatype)%type)) (x:mident) (t:term) (ty:datatype), ((get sigma
      x) = ty) -> ((type_term sigma pi t ty) -> (type_stmt sigma pi
      (Sassign x t)))
  | Type_if : forall (sigma:(map mident datatype)) (pi:(list (ident*
      datatype)%type)) (t:term) (s1:stmt) (s2:stmt), (type_term sigma pi t
      TYbool) -> ((type_stmt sigma pi s1) -> ((type_stmt sigma pi s2) ->
      (type_stmt sigma pi (Sif t s1 s2))))
  | Type_assert : forall (sigma:(map mident datatype)) (pi:(list (ident*
      datatype)%type)) (p:fmla), (type_fmla sigma pi p) -> (type_stmt sigma
      pi (Sassert p))
  | Type_while : forall (sigma:(map mident datatype)) (pi:(list (ident*
      datatype)%type)) (guard:term) (body:stmt) (inv:fmla), (type_fmla sigma
      pi inv) -> ((type_term sigma pi guard TYbool) -> ((type_stmt sigma pi
      body) -> (type_stmt sigma pi (Swhile guard inv body)))).

(* Why3 assumption *)
Definition env  := (map mident value).

(* Why3 assumption *)
Definition stack  := (list (ident* value)%type).

Parameter get_stack: ident -> (list (ident* value)%type) -> value.

Axiom get_stack_def : forall (i:ident) (pi:(list (ident* value)%type)),
  match pi with
  | Nil => ((get_stack i pi) = Vvoid)
  | (Cons (x, v) r) => ((x = i) -> ((get_stack i pi) = v)) /\ ((~ (x = i)) ->
      ((get_stack i pi) = (get_stack i r)))
  end.

Axiom get_stack_eq : forall (x:ident) (v:value) (r:(list (ident*
  value)%type)), ((get_stack x (Cons (x, v) r)) = v).

Axiom get_stack_neq : forall (x:ident) (i:ident) (v:value) (r:(list (ident*
  value)%type)), (~ (x = i)) -> ((get_stack i (Cons (x, v) r)) = (get_stack i
  r)).

Parameter eval_bin: value -> operator -> value -> value.

Axiom eval_bin_def : forall (x:value) (op:operator) (y:value), match (x,
  y) with
  | ((Vint x1), (Vint y1)) =>
      match op with
      | Oplus => ((eval_bin x op y) = (Vint (x1 + y1)%Z))
      | Ominus => ((eval_bin x op y) = (Vint (x1 - y1)%Z))
      | Omult => ((eval_bin x op y) = (Vint (x1 * y1)%Z))
      | Ole => ((x1 <= y1)%Z -> ((eval_bin x op y) = (Vbool true))) /\
          ((~ (x1 <= y1)%Z) -> ((eval_bin x op y) = (Vbool false)))
      end
  | (_, _) => ((eval_bin x op y) = Vvoid)
  end.

(* Why3 assumption *)
Fixpoint eval_term(sigma:(map mident value)) (pi:(list (ident* value)%type))
  (t:term) {struct t}: value :=
  match t with
  | (mk_term (Tvalue v) _) => v
  | (mk_term (Tvar id) _) => (get_stack id pi)
  | (mk_term (Tderef id) _) => (get sigma id)
  | (mk_term (Tbin t1 op t2) _) => (eval_bin (eval_term sigma pi t1) op
      (eval_term sigma pi t2))
  end.

Axiom eval_bool_term : forall (sigma:(map mident value)) (pi:(list (ident*
  value)%type)) (sigmat:(map mident datatype)) (pit:(list (ident*
  datatype)%type)) (t:term), (type_term sigmat pit t TYbool) ->
  exists b:bool, ((eval_term sigma pi t) = (Vbool b)).

(* Why3 assumption *)
Fixpoint eval_fmla(sigma:(map mident value)) (pi:(list (ident* value)%type))
  (f:fmla) {struct f}: Prop :=
  match f with
  | (Fterm t) => ((eval_term sigma pi t) = (Vbool true))
  | (Fand f1 f2) => (eval_fmla sigma pi f1) /\ (eval_fmla sigma pi f2)
  | (Fnot f1) => ~ (eval_fmla sigma pi f1)
  | (Fimplies f1 f2) => (eval_fmla sigma pi f1) -> (eval_fmla sigma pi f2)
  | (Flet x t f1) => (eval_fmla sigma (Cons (x, (eval_term sigma pi t)) pi)
      f1)
  | (Fforall x TYint f1) => forall (n:Z), (eval_fmla sigma (Cons (x,
      (Vint n)) pi) f1)
  | (Fforall x TYbool f1) => forall (b:bool), (eval_fmla sigma (Cons (x,
      (Vbool b)) pi) f1)
  | (Fforall x TYunit f1) => (eval_fmla sigma (Cons (x, Vvoid) pi) f1)
  end.

Parameter msubst_term: term -> mident -> ident -> term.

Axiom msubst_term_def : forall (t:term) (r:mident) (v:ident),
  match t with
  | (mk_term ((Tvalue _)|(Tvar _)) _) => ((msubst_term t r v) = t)
  | (mk_term (Tderef x) _) => ((r = x) -> ((msubst_term t r
      v) = (mk_tvar v))) /\ ((~ (r = x)) -> ((msubst_term t r v) = t))
  | (mk_term (Tbin t1 op t2) _) => ((msubst_term t r
      v) = (mk_tbin (msubst_term t1 r v) op (msubst_term t2 r v)))
  end.

Parameter subst_term: term -> ident -> ident -> term.

Axiom subst_term_def : forall (t:term) (r:ident) (v:ident),
  match t with
  | (mk_term ((Tvalue _)|(Tderef _)) _) => ((subst_term t r v) = t)
  | (mk_term (Tvar x) _) => ((r = x) -> ((subst_term t r
      v) = (mk_tvar v))) /\ ((~ (r = x)) -> ((subst_term t r v) = t))
  | (mk_term (Tbin t1 op t2) _) => ((subst_term t r
      v) = (mk_tbin (subst_term t1 r v) op (subst_term t2 r v)))
  end.

(* Why3 assumption *)
Definition fresh_in_term(id:ident) (t:term): Prop :=
  ((term_maxvar t) < (ident_index id))%Z.

Axiom fresh_in_binop : forall (t:term) (t':term) (op:operator) (v:ident),
  (fresh_in_term v (mk_tbin t op t')) -> ((fresh_in_term v t) /\
  (fresh_in_term v t')).

Require Import Why3.

Ltac ae := why3 "alt-ergo" timelimit 3.

(* Why3 goal *)
Theorem eval_msubst_term : forall (e:term) (sigma:(map mident value))
  (pi:(list (ident* value)%type)) (x:mident) (v:ident), (fresh_in_term v
  e) -> ((eval_term sigma pi (msubst_term e x v)) = (eval_term (set sigma x
  (get_stack v pi)) pi e)).
Check term_induc.
intros e.
apply term_induc with (P := fun e => 
  forall (sigma : map mident value) (pi : list (ident * value))
     (x : mident) (v : ident),
     fresh_in_term v e ->
     eval_term sigma pi (msubst_term e x v) =
     eval_term (set sigma x (get_stack v pi)) pi e) 
     (P0 := fun t => 
       forall (i : int) (sigma : map mident value) (pi : list (ident * value))
       (x : mident) (v : ident),
       fresh_in_term v (mk_term t i) ->
       eval_term sigma pi (msubst_term (mk_term t i) x v) =
       eval_term (set sigma x (get_stack v pi)) pi (mk_term t i)).
(* mk_term*)
ae.
(* Value *)
ae.
(* Var *)
intros i i0 sigma pi x v H.
simpl.
rewrite (msubst_term_def (mk_term (Tvar i) i0)).
easy.
(* Ref *)
intros m i sigma pi x v H.
simpl.
destruct (mident_decide m x).
(* m = x*)
ae.
(* m <> x*)
ae.
(* Bin *)
intros t H1.
intros op t' H2.
intros i sigma pi x v H3.
rewrite (msubst_term_def (mk_term (Tbin t op t') i)).
simpl.
rewrite H1.
rewrite H2; auto.
apply fresh_in_binop with (t:=t) (t':=t') (op := op).
apply fresh_in_binop with (t:=t) (t':=t') (op := op);
admit.

Qed.


