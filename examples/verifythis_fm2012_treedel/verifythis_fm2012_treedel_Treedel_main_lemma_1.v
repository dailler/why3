(* This file is generated by Why3's Coq 8.4 driver *)
(* Beware! Only edit allowed sections below    *)
Require Import BuiltIn.
Require BuiltIn.
Require map.Map.
Require int.Int.
Require list.List.
Require list.Length.
Require list.Mem.
Require list.Append.

(* Why3 assumption *)
Definition unit := unit.

(* Why3 assumption *)
Inductive ref (a:Type) {a_WT:WhyType a} :=
  | mk_ref : a -> ref a.
Axiom ref_WhyType : forall (a:Type) {a_WT:WhyType a}, WhyType (ref a).
Existing Instance ref_WhyType.
Implicit Arguments mk_ref [[a] [a_WT]].

(* Why3 assumption *)
Definition contents {a:Type} {a_WT:WhyType a} (v:(@ref a a_WT)): a :=
  match v with
  | (mk_ref x) => x
  end.

Axiom loc : Type.
Parameter loc_WhyType : WhyType loc.
Existing Instance loc_WhyType.

Parameter null: loc.

(* Why3 assumption *)
Inductive node :=
  | mk_node : loc -> loc -> Z -> node.
Axiom node_WhyType : WhyType node.
Existing Instance node_WhyType.

(* Why3 assumption *)
Definition data (v:node): Z := match v with
  | (mk_node x x1 x2) => x2
  end.

(* Why3 assumption *)
Definition right1 (v:node): loc := match v with
  | (mk_node x x1 x2) => x1
  end.

(* Why3 assumption *)
Definition left1 (v:node): loc := match v with
  | (mk_node x x1 x2) => x
  end.

(* Why3 assumption *)
Definition memory := (@map.Map.map loc loc_WhyType node node_WhyType).

(* Why3 assumption *)
Inductive tree
  (a:Type) {a_WT:WhyType a} :=
  | Empty : tree a
  | Node : (@tree a a_WT) -> a -> (@tree a a_WT) -> tree a.
Axiom tree_WhyType : forall (a:Type) {a_WT:WhyType a}, WhyType (tree a).
Existing Instance tree_WhyType.
Implicit Arguments Empty [[a] [a_WT]].
Implicit Arguments Node [[a] [a_WT]].

(* Why3 assumption *)
Fixpoint inorder {a:Type} {a_WT:WhyType a} (t:(@tree
  a a_WT)) {struct t}: (list a) :=
  match t with
  | Empty => nil
  | (Node l x r) => (List.app (inorder l) (cons x (inorder r)))
  end.

(* Why3 assumption *)
Inductive distinct {a:Type} {a_WT:WhyType a} : (list a) -> Prop :=
  | distinct_zero : ((@distinct _ _) nil)
  | distinct_one : forall (x:a), ((@distinct _ _) (cons x nil))
  | distinct_many : forall (x:a) (l:(list a)), (~ (list.Mem.mem x l)) ->
      (((@distinct _ _) l) -> ((@distinct _ _) (cons x l))).

Axiom distinct_append : forall {a:Type} {a_WT:WhyType a},
  forall (l1:(list a)) (l2:(list a)), (distinct l1) -> ((distinct l2) ->
  ((forall (x:a), (list.Mem.mem x l1) -> ~ (list.Mem.mem x l2)) -> (distinct
  (List.app l1 l2)))).

(* Why3 assumption *)
Inductive istree : (@map.Map.map loc loc_WhyType node node_WhyType) -> loc ->
  (@tree loc loc_WhyType) -> Prop :=
  | leaf : forall (m:(@map.Map.map loc loc_WhyType node node_WhyType)),
      (istree m null (Empty :(@tree loc loc_WhyType)))
  | node1 : forall (m:(@map.Map.map loc loc_WhyType node node_WhyType))
      (p:loc) (l:(@tree loc loc_WhyType)) (r:(@tree loc loc_WhyType)),
      (~ (p = null)) -> ((istree m (left1 (map.Map.get m p)) l) -> ((istree m
      (right1 (map.Map.get m p)) r) -> (istree m p (Node l p r)))).

(* Why3 assumption *)
Inductive zipper
  (a:Type) {a_WT:WhyType a} :=
  | Top : zipper a
  | Left : (@zipper a a_WT) -> a -> (@tree a a_WT) -> zipper a.
Axiom zipper_WhyType : forall (a:Type) {a_WT:WhyType a}, WhyType (zipper a).
Existing Instance zipper_WhyType.
Implicit Arguments Top [[a] [a_WT]].
Implicit Arguments Left [[a] [a_WT]].

(* Why3 assumption *)
Fixpoint zip {a:Type} {a_WT:WhyType a} (t:(@tree a a_WT)) (z:(@zipper
  a a_WT)) {struct z}: (@tree a a_WT) :=
  match z with
  | Top => t
  | (Left z1 x r) => (zip (Node t x r) z1)
  end.

Axiom inorder_zip : forall {a:Type} {a_WT:WhyType a}, forall (z:(@zipper
  a a_WT)) (x:a) (l:(@tree a a_WT)) (r:(@tree a a_WT)),
  ((inorder (zip (Node l x r)
  z)) = (List.app (inorder l) (cons x (inorder (zip r z))))).

(** The proof starts here *)

Require Import Why3.
Ltac ae := why3 "Alt-Ergo,0.95.1," timelimit 30.

Lemma distinct1:
  forall (p pp: loc) (pr ppr: tree loc),
    distinct (cons p (app (inorder pr) (cons pp (inorder ppr)))) ->
    p <> pp.
  Proof.
    induction pr; simpl; ae.
  Qed.

Lemma distinct2:
  forall m p p' n t, 
    let m' := Map.set m p' n in
    istree m p t -> ~ (Mem.mem p' (inorder t)) -> istree m' p t.
  Proof.
    induction 1; simpl.
    ae.
    intro.
    assert (~ (Mem.mem p' (inorder l))) by ae.
    assert (~ (Mem.mem p' (inorder r))) by ae.
    intuition.
    apply node1; subst m'.
    red; intro; elim H; trivial.
    ae.
    ae.
  Qed.

Lemma distinct3:
  forall (pp: loc) (l1 l2: list loc),
  distinct (app l1 (cons pp l2)) -> ~ (Mem.mem pp l1).
Proof.
induction l1; simpl; ae.
Qed.

Lemma distinct4:
  forall (pp: loc) (l1 l2: list loc),
  distinct (app l1 (cons pp l2)) -> ~ (Mem.mem pp l2).
Proof.
induction l1; simpl; ae.
Qed.

Lemma distinct_append1:
  forall (l1 l2: list loc), distinct (app l1 l2) -> distinct l1.
Proof.
  induction l1; simpl; ae.
Qed.

Lemma distinct5:
  forall z (p: loc) (l r: tree loc),
  distinct (inorder (zip (Node l p r) z)) -> distinct (inorder (Node l p r)).
Proof.
induction z.
ae.
intros.
simpl in H.
generalize (IHz a (Node l p r) t); clear IHz.
ae.
Qed.

Lemma istree_zip:
  forall m t z l r pp,
  istree m t (zip (Node l pp r) z) -> istree m pp (Node l pp r).
Proof.
induction z; simpl.
ae.
inversion 1.
ae.
generalize (IHz (Node l pp r) t0 a).
ae.
Qed.

Lemma istree_zip_2:
  forall m n a z t pp l r tr',
  istree m t (zip (Node l pp r) z) ->
  distinct (inorder (zip (Node l pp r) z)) ->
  Mem.mem a (inorder (Node l pp r)) -> let m' := Map.set m a n in
  istree m' pp tr' ->
  istree m' t (zip tr' z).
Proof.
induction z; simpl.
ae.
intros t0 pp l r tr'.
generalize (IHz t0 a0 (Node l pp r) t (Node tr' a0 t)); clear IHz; intros IHz.
intuition.
apply H4.
ae.
assert (a <> a0) by ae.
apply node1.
why3 "cvc3".
assert (left1 (Map.get (Map.set m a n) a0) = pp).
rewrite Map.Select_neq.
  generalize (istree_zip _ _ _ _ _ _ H).
  inversion 1.
  inversion H11; auto.
assumption.
ae.
assert (right1 (Map.get (Map.set m a n) a0) = right1 (Map.get m a0)).
rewrite Map.Select_neq.
  generalize (istree_zip _ _ _ _ _ _ H).
  inversion 1.
  inversion H11; auto.
assumption.
rewrite H5; clear H5.
apply distinct2.
generalize (istree_zip _ _ _ _ _ _ H).
inversion 1.
ae.
clear H4 H2 H H3.
assert (Mem.mem a (inorder (Node l pp r))) by ae.
clear H1.
generalize (Node l pp r) H0 H. clear H0 H.
intros.
generalize (distinct5 _ _ _ _ H0); clear H0.
simpl.
intro.
assert (~ (Mem.mem a (cons a0 (inorder t)))).
  generalize (inorder t1) H H0. clear H H0.
  generalize (cons a0 (inorder t)).
  ae.
ae.
Qed.

(* Why3 goal *)
Theorem main_lemma : forall (m:(@map.Map.map loc loc_WhyType
  node node_WhyType)) (t:loc) (pp:loc) (p:loc) (ppr:(@tree loc loc_WhyType))
  (pr:(@tree loc loc_WhyType)) (z:(@zipper loc loc_WhyType)), let it :=
  (zip (Node (Node (Empty :(@tree loc loc_WhyType)) p pr) pp ppr) z) in
  ((istree m t it) -> ((distinct (inorder it)) -> (istree (map.Map.set m pp
  (let usq_ := (map.Map.get m pp) in (mk_node (right1 (map.Map.get m p))
  (right1 usq_) (data usq_)))) t (zip (Node pr pp ppr) z)))).
(* Why3 intros m t pp p ppr pr z it h1 h2. *)
intros m t pp p ppr pr z it h1 h2.
pose (m' := (Map.set m pp
     (mk_node (right1 (Map.get m p)) (right1 (Map.get m pp))
        (data (Map.get m pp))))).
assert (istree m' pp (Node pr pp ppr)).
assert (istree m pp (Node (Node (Empty:tree loc) p pr) pp ppr)) by ae.
assert (istree m' pp (Node pr pp ppr)).
inversion H; simpl.
apply node1.
assumption.
unfold m'.
rewrite Map.Select_eq. 2: trivial.
unfold left1; simpl.
inversion H5.
rewrite -> H8 in *; clear H8.
rewrite <- H11 in *.
subst p1.
assert (p <> pp) by why3 "cvc3" timelimit 3.
apply distinct2.
ae.
why3 "cvc3" timelimit 3.
apply distinct2.
ae.
why3 "cvc3" timelimit 3.
assumption.
apply istree_zip_2 with (l := (Node (Empty:tree loc) p pr)) (r := ppr)
  (pp := pp); try
assumption.
ae.
Qed.

