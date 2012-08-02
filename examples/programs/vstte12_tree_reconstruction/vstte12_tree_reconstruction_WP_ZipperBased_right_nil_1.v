(* This file is generated by Why3's Coq driver *)
(* Beware! Only edit allowed sections below    *)
Require Import ZArith.
Require Import Rbase.
Require int.Int.

(* Why3 assumption *)
Definition unit  := unit.

(* Why3 assumption *)
Inductive list (a:Type) :=
  | Nil : list a
  | Cons : a -> (list a) -> list a.
Set Contextual Implicit.
Implicit Arguments Nil.
Unset Contextual Implicit.
Implicit Arguments Cons.

(* Why3 assumption *)
Set Implicit Arguments.
Fixpoint infix_plpl (a:Type)(l1:(list a)) (l2:(list a)) {struct l1}: (list
  a) :=
  match l1 with
  | Nil => l2
  | (Cons x1 r1) => (Cons x1 (infix_plpl r1 l2))
  end.
Unset Implicit Arguments.

Axiom Append_assoc : forall (a:Type), forall (l1:(list a)) (l2:(list a))
  (l3:(list a)), ((infix_plpl l1 (infix_plpl l2
  l3)) = (infix_plpl (infix_plpl l1 l2) l3)).

Axiom Append_l_nil : forall (a:Type), forall (l:(list a)), ((infix_plpl l
  (Nil :(list a))) = l).

(* Why3 assumption *)
Set Implicit Arguments.
Fixpoint length (a:Type)(l:(list a)) {struct l}: Z :=
  match l with
  | Nil => 0%Z
  | (Cons _ r) => (1%Z + (length r))%Z
  end.
Unset Implicit Arguments.

Axiom Length_nonnegative : forall (a:Type), forall (l:(list a)),
  (0%Z <= (length l))%Z.

Axiom Length_nil : forall (a:Type), forall (l:(list a)),
  ((length l) = 0%Z) <-> (l = (Nil :(list a))).

Axiom Append_length : forall (a:Type), forall (l1:(list a)) (l2:(list a)),
  ((length (infix_plpl l1 l2)) = ((length l1) + (length l2))%Z).

(* Why3 assumption *)
Set Implicit Arguments.
Fixpoint mem (a:Type)(x:a) (l:(list a)) {struct l}: Prop :=
  match l with
  | Nil => False
  | (Cons y r) => (x = y) \/ (mem x r)
  end.
Unset Implicit Arguments.

Axiom mem_append : forall (a:Type), forall (x:a) (l1:(list a)) (l2:(list a)),
  (mem x (infix_plpl l1 l2)) <-> ((mem x l1) \/ (mem x l2)).

Axiom mem_decomp : forall (a:Type), forall (x:a) (l:(list a)), (mem x l) ->
  exists l1:(list a), exists l2:(list a), (l = (infix_plpl l1 (Cons x l2))).

(* Why3 assumption *)
Inductive tree  :=
  | Leaf : tree 
  | Node : tree -> tree -> tree .

(* Why3 assumption *)
Set Implicit Arguments.
Fixpoint depths(d:Z) (t:tree) {struct t}: (list Z) :=
  match t with
  | Leaf => (Cons d (Nil :(list Z)))
  | (Node l r) => (infix_plpl (depths (d + 1%Z)%Z l) (depths (d + 1%Z)%Z r))
  end.
Unset Implicit Arguments.

Axiom depths_head : forall (t:tree) (d:Z), match (depths d
  t) with
  | (Cons x _) => (d <= x)%Z
  | Nil => False
  end.

Axiom depths_unique : forall (t1:tree) (t2:tree) (d:Z) (s1:(list Z))
  (s2:(list Z)), ((infix_plpl (depths d t1) s1) = (infix_plpl (depths d t2)
  s2)) -> ((t1 = t2) /\ (s1 = s2)).

Axiom depths_prefix : forall (t:tree) (d1:Z) (d2:Z) (s1:(list Z)) (s2:(list
  Z)), ((infix_plpl (depths d1 t) s1) = (infix_plpl (depths d2 t) s2)) ->
  (d1 = d2).

Axiom depths_prefix_simple : forall (t:tree) (d1:Z) (d2:Z), ((depths d1
  t) = (depths d2 t)) -> (d1 = d2).

Axiom depths_subtree : forall (t1:tree) (t2:tree) (d1:Z) (d2:Z) (s1:(list
  Z)), ((infix_plpl (depths d1 t1) s1) = (depths d2 t2)) -> (d2 <= d1)%Z.

Axiom depths_unique2 : forall (t1:tree) (t2:tree) (d1:Z) (d2:Z), ((depths d1
  t1) = (depths d2 t2)) -> ((d1 = d2) /\ (t1 = t2)).

(* Why3 assumption *)
Definition lt_nat(x:Z) (y:Z): Prop := (0%Z <= y)%Z /\ (x < y)%Z.

(* Why3 assumption *)
Inductive lex : (Z* Z)%type -> (Z* Z)%type -> Prop :=
  | Lex_1 : forall (x1:Z) (x2:Z) (y1:Z) (y2:Z), (lt_nat x1 x2) -> (lex (x1,
      y1) (x2, y2))
  | Lex_2 : forall (x:Z) (y1:Z) (y2:Z), (lt_nat y1 y2) -> (lex (x, y1) (x,
      y2)).

(* Why3 assumption *)
Set Implicit Arguments.
Fixpoint reverse (a:Type)(l:(list a)) {struct l}: (list a) :=
  match l with
  | Nil => (Nil :(list a))
  | (Cons x r) => (infix_plpl (reverse r) (Cons x (Nil :(list a))))
  end.
Unset Implicit Arguments.

Axiom reverse_append : forall (a:Type), forall (l1:(list a)) (l2:(list a))
  (x:a), ((infix_plpl (reverse (Cons x l1)) l2) = (infix_plpl (reverse l1)
  (Cons x l2))).

Axiom reverse_reverse : forall (a:Type), forall (l:(list a)),
  ((reverse (reverse l)) = l).

Axiom Reverse_length : forall (a:Type), forall (l:(list a)),
  ((length (reverse l)) = (length l)).

(* Why3 assumption *)
Set Implicit Arguments.
Fixpoint forest_depths(f:(list (Z* tree)%type)) {struct f}: (list Z) :=
  match f with
  | Nil => (Nil :(list Z))
  | (Cons (d, t) r) => (infix_plpl (depths d t) (forest_depths r))
  end.
Unset Implicit Arguments.

Axiom forest_depths_append : forall (f1:(list (Z* tree)%type)) (f2:(list (Z*
  tree)%type)), ((forest_depths (infix_plpl f1
  f2)) = (infix_plpl (forest_depths f1) (forest_depths f2))).

(* Why3 assumption *)
Set Implicit Arguments.
Fixpoint greedy(d:Z) (d1:Z) (t1:tree) {struct t1}: Prop := (~ (d = d1)) /\
  match t1 with
  | Leaf => True
  | (Node l1 _) => (greedy d (d1 + 1%Z)%Z l1)
  end.
Unset Implicit Arguments.

(* Why3 assumption *)
Inductive g : (list (Z* tree)%type) -> Prop :=
  | Gnil : (g (Nil :(list (Z* tree)%type)))
  | Gone : forall (d:Z) (t:tree), (g (Cons (d, t) (Nil :(list (Z*
      tree)%type))))
  | Gtwo : forall (d1:Z) (d2:Z) (t1:tree) (t2:tree) (l:(list (Z*
      tree)%type)), (greedy d1 d2 t2) -> ((g (Cons (d1, t1) l)) -> (g (Cons (
      d2, t2) (Cons (d1, t1) l)))).

Axiom g_append : forall (l1:(list (Z* tree)%type)) (l2:(list (Z*
  tree)%type)), (g (infix_plpl l1 l2)) -> (g l1).

Require Import Why3. Ltac z := why3 "z3" timelimit 5.
Ltac ae := why3 "alt-ergo".

Lemma depths_length: forall t d, (length (depths d t) >= 1)%Z.
  induction t; simpl.
  intro; omega.
  z.
Qed.

Lemma forest_depths_length: forall l, (length (forest_depths l) >= 0)%Z.
  induction l; simpl.
  omega.
  destruct a. z.
Qed.

Lemma g_tail : forall (l1:(list (Z* tree)%type)) (l2:(list (Z*
  tree)%type)), (g (infix_plpl l1 l2)) -> (g l2).
induction l1; simpl; auto.
ae.
Qed.

Theorem key_lemma : forall t l d d1 t1 s, (d < d1)%Z ->
  (1 <= length l)%Z -> g (reverse (Cons (d1, t1) l)) ->
  ~ (forest_depths (Cons (d1, t1) l) = infix_plpl (depths d t) s).
induction t; simpl.
(* t = Leaf *)
intros.
generalize (depths_head t1 d1).
destruct (depths d1 t1); intuition.
simpl in H3. injection H3.
intros; omega.
(* t = Node _ _ *)
rename t1 into left, IHt1 into IHleft,
       t2 into right, IHt2 into IHright.
destruct l.
(* l = Nil *)
z.
(* l = Cons _ *)
destruct p as (d2, t2).
intros d d1 t1 s hdd1 hlen hg.
assert (hg2: g (infix_plpl (reverse l) (Cons (d2, t2) Nil))) by z.
assert (hg12: g (infix_plpl (Cons (d2, t2) Nil) (Cons (d1, t1) Nil))) by z.
inversion hg12. subst. clear H5.
assert (ineq: (d1 <> d2)) by z.

intros eq.
assert (case: (d2 < d1 \/ d1 < d2)%Z) by omega. destruct case as [case|case].
(* d2 < d1 *)
assert (L0: (forall t2 d1 d2, greedy d1 d2 t2 -> d2 < d1 ->
   match depths d2 t2 with Cons x _ => x < d1 | Nil  => False end)%Z).
  induction t0.
  ae.
  simpl.
  clear IHt0_2.
  intros d0 d3 (diseq, gr) lt.
  assert (d0 <> d3+1)%Z by z.
  assert (d3+1 < d0)%Z by z.
  generalize (IHt0_1 d0 (d3+1)%Z gr H0).
  destruct (depths (d3 + 1) t0_1).
  intuition.
  simpl; auto.
assert (L1: forall t d1 t1 l s d, (d < d1)%Z ->
  infix_plpl (depths d1 t1) l = infix_plpl (depths d t) s -> 
  match l with Cons x _ => (x >= d1)%Z | Nil => True end).
  clear L0 case eq ineq H1 hg12 hg2 hg hlen hdd1.
  clear s t1 d1 d l t2 d2 IHright IHleft right left.
  induction t; simpl.
  intros.
  generalize (depths_head t1 d1).
  destruct (depths d1 t1).
  intuition.
  destruct l; auto.
  ae.
  intros.
  assert (case2: (d+1 = d1 \/ d+1 < d1)%Z) by omega. destruct case2.
  rewrite H1 in *.
  assert (l = infix_plpl (depths d1 t2) s) by z.
  generalize (depths_head t2 d1).
  subst l. destruct (depths d1 t2).
  intuition. simpl. ae.
  clear IHt2.
  apply (IHt1 d1 t0 l (infix_plpl (depths (d+1) t2) s) (d+1))%Z; auto.
  z.

generalize eq.
pose (l0 := (infix_plpl (depths d2 t2) (forest_depths l))).
generalize (depths_head t2 d2).
generalize (L0 t2 d1 d2 H1 case); clear L0.
generalize (L1 (Node left right) d1 t1 l0 s d hdd1 eq).
subst l0.
destruct (depths d2 t2).
intuition.
simpl.
intros; omega.

(* d1 < d2 *)
assert (case2: (d+1 = d1 \/ d+1 < d1)%Z) by omega. destruct case2.
(* d+1 = d1 *)
rewrite H in *.
assert (t1 = left) by z.
subst t1.
assert (forest_depths (Cons (d2, t2) l) = infix_plpl (depths d1 right) s) by z.
clear eq.
destruct l.
(* l = Nil => contradiction *)
simpl in H0.
assert (d1 >= d2)%Z by z.
omega.
(* l = Cons _ _ *)
clear IHleft.
apply (IHright (Cons p l) d1 d2 t2 s); auto.
ae.
(* d+1 < d1 *)
clear IHright.
apply (IHleft (Cons (d2, t2) l) (d+1) d1 t1 (infix_plpl (depths (d+1) right) s))%Z; auto.
z.
Qed.

(* Why3 goal *)
Theorem right_nil : forall (l:(list (Z* tree)%type)),
  (2%Z <= (length l))%Z -> ((g l) -> forall (t:tree) (d:Z),
  ~ ((forest_depths (reverse l)) = (depths d t))).
intros l H hg.
replace l with (reverse (reverse l)) in H, hg by z.
generalize H; clear H. generalize hg; clear hg.
generalize (reverse l). clear l.

destruct l.
(* l = Nil => contradiction *)
intros; ae.
(* l = Cons *)
intros. destruct p as (d1, t1).
intros eq.
assert (d < d1)%Z.
  simpl in eq.
  assert (d <= d1)%Z by z.
  assert (d <> d1)%Z. intro.
  subst.
  assert (depths d1 t = infix_plpl (depths d1 t) Nil) by z.
  assert (t = t1) by z.
  subst.
  assert (forest_depths l = Nil) by z.
  simpl in H.
  destruct l. ae.
  assert (Cons p l = Nil).
  destruct (Cons p l); auto.
  simpl in H2. destruct p0. z.
  discriminate H3.
  omega.
generalize eq; clear eq.
replace (depths d t) with (infix_plpl (depths d t) Nil) by z.
apply key_lemma; auto.
simpl in H.
ae.
Qed.


