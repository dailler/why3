(* This file is generated by Why3's Coq driver *)
(* Beware! Only edit allowed sections below    *)
Require Import ZArith.
Require Import Rbase.
Require int.Int.

(* Why3 assumption *)
Definition unit  := unit.

(* Why3 assumption *)
Inductive ref (a:Type) :=
  | mk_ref : a -> ref a.
Implicit Arguments mk_ref [[a]].

(* Why3 assumption *)
Definition contents {a:Type}(v:(ref a)): a :=
  match v with
  | (mk_ref x) => x
  end.

Parameter map : forall (a:Type) (b:Type), Type.

Parameter get: forall {a:Type} {b:Type}, (map a b) -> a -> b.

Parameter set: forall {a:Type} {b:Type}, (map a b) -> a -> b -> (map a b).

Axiom Select_eq : forall {a:Type} {b:Type}, forall (m:(map a b)),
  forall (a1:a) (a2:a), forall (b1:b), (a1 = a2) -> ((get (set m a1 b1)
  a2) = b1).

Axiom Select_neq : forall {a:Type} {b:Type}, forall (m:(map a b)),
  forall (a1:a) (a2:a), forall (b1:b), (~ (a1 = a2)) -> ((get (set m a1 b1)
  a2) = (get m a2)).

Parameter const: forall {a:Type} {b:Type}, b -> (map a b).

Axiom Const : forall {a:Type} {b:Type}, forall (b1:b) (a1:a),
  ((get (const b1:(map a b)) a1) = b1).

(* Why3 assumption *)
Inductive array (a:Type) :=
  | mk_array : Z -> (map Z a) -> array a.
Implicit Arguments mk_array [[a]].

(* Why3 assumption *)
Definition elts {a:Type}(v:(array a)): (map Z a) :=
  match v with
  | (mk_array x x1) => x1
  end.

(* Why3 assumption *)
Definition length {a:Type}(v:(array a)): Z :=
  match v with
  | (mk_array x x1) => x
  end.

(* Why3 assumption *)
Definition get1 {a:Type}(a1:(array a)) (i:Z): a := (get (elts a1) i).

(* Why3 assumption *)
Definition set1 {a:Type}(a1:(array a)) (i:Z) (v:a): (array a) :=
  (mk_array (length a1) (set (elts a1) i v)).

(* Why3 assumption *)
Definition map_eq_sub {a:Type}(a1:(map Z a)) (a2:(map Z a)) (l:Z)
  (u:Z): Prop := forall (i:Z), ((l <= i)%Z /\ (i < u)%Z) -> ((get a1
  i) = (get a2 i)).

(* Why3 assumption *)
Definition exchange {a:Type}(a1:(map Z a)) (a2:(map Z a)) (i:Z)
  (j:Z): Prop := ((get a1 i) = (get a2 j)) /\ (((get a2 i) = (get a1 j)) /\
  forall (k:Z), ((~ (k = i)) /\ ~ (k = j)) -> ((get a1 k) = (get a2 k))).

Axiom exchange_set : forall {a:Type}, forall (a1:(map Z a)), forall (i:Z)
  (j:Z), (exchange a1 (set (set a1 i (get a1 j)) j (get a1 i)) i j).

(* Why3 assumption *)
Inductive permut_sub{a:Type}  : (map Z a) -> (map Z a) -> Z -> Z -> Prop :=
  | permut_refl : forall (a1:(map Z a)) (a2:(map Z a)), forall (l:Z) (u:Z),
      (map_eq_sub a1 a2 l u) -> (permut_sub a1 a2 l u)
  | permut_sym : forall (a1:(map Z a)) (a2:(map Z a)), forall (l:Z) (u:Z),
      (permut_sub a1 a2 l u) -> (permut_sub a2 a1 l u)
  | permut_trans : forall (a1:(map Z a)) (a2:(map Z a)) (a3:(map Z a)),
      forall (l:Z) (u:Z), (permut_sub a1 a2 l u) -> ((permut_sub a2 a3 l
      u) -> (permut_sub a1 a3 l u))
  | permut_exchange : forall (a1:(map Z a)) (a2:(map Z a)), forall (l:Z)
      (u:Z) (i:Z) (j:Z), ((l <= i)%Z /\ (i < u)%Z) -> (((l <= j)%Z /\
      (j < u)%Z) -> ((exchange a1 a2 i j) -> (permut_sub a1 a2 l u))).

Axiom permut_weakening : forall {a:Type}, forall (a1:(map Z a)) (a2:(map Z
  a)), forall (l1:Z) (r1:Z) (l2:Z) (r2:Z), (((l1 <= l2)%Z /\ (l2 <= r2)%Z) /\
  (r2 <= r1)%Z) -> ((permut_sub a1 a2 l2 r2) -> (permut_sub a1 a2 l1 r1)).

Axiom permut_eq : forall {a:Type}, forall (a1:(map Z a)) (a2:(map Z a)),
  forall (l:Z) (u:Z), (permut_sub a1 a2 l u) -> forall (i:Z), ((i < l)%Z \/
  (u <= i)%Z) -> ((get a2 i) = (get a1 i)).

Axiom permut_exists : forall {a:Type}, forall (a1:(map Z a)) (a2:(map Z a)),
  forall (l:Z) (u:Z), (permut_sub a1 a2 l u) -> forall (i:Z), ((l <= i)%Z /\
  (i < u)%Z) -> exists j:Z, ((l <= j)%Z /\ (j < u)%Z) /\ ((get a2
  i) = (get a1 j)).

(* Why3 assumption *)
Definition exchange1 {a:Type}(a1:(array a)) (a2:(array a)) (i:Z)
  (j:Z): Prop := (exchange (elts a1) (elts a2) i j).

(* Why3 assumption *)
Definition permut_sub1 {a:Type}(a1:(array a)) (a2:(array a)) (l:Z)
  (u:Z): Prop := (permut_sub (elts a1) (elts a2) l u).

(* Why3 assumption *)
Definition permut {a:Type}(a1:(array a)) (a2:(array a)): Prop :=
  ((length a1) = (length a2)) /\ (permut_sub (elts a1) (elts a2) 0%Z
  (length a1)).

Axiom exchange_permut : forall {a:Type}, forall (a1:(array a)) (a2:(array a))
  (i:Z) (j:Z), (exchange1 a1 a2 i j) -> (((length a1) = (length a2)) ->
  (((0%Z <= i)%Z /\ (i < (length a1))%Z) -> (((0%Z <= j)%Z /\
  (j < (length a1))%Z) -> (permut a1 a2)))).

Axiom permut_sym1 : forall {a:Type}, forall (a1:(array a)) (a2:(array a)),
  (permut a1 a2) -> (permut a2 a1).

Axiom permut_trans1 : forall {a:Type}, forall (a1:(array a)) (a2:(array a))
  (a3:(array a)), (permut a1 a2) -> ((permut a2 a3) -> (permut a1 a3)).

(* Why3 assumption *)
Definition array_eq_sub {a:Type}(a1:(array a)) (a2:(array a)) (l:Z)
  (u:Z): Prop := (map_eq_sub (elts a1) (elts a2) l u).

(* Why3 assumption *)
Definition array_eq {a:Type}(a1:(array a)) (a2:(array a)): Prop :=
  ((length a1) = (length a2)) /\ (array_eq_sub a1 a2 0%Z (length a1)).

Axiom array_eq_sub_permut : forall {a:Type}, forall (a1:(array a)) (a2:(array
  a)) (l:Z) (u:Z), (array_eq_sub a1 a2 l u) -> (permut_sub1 a1 a2 l u).

Axiom array_eq_permut : forall {a:Type}, forall (a1:(array a)) (a2:(array
  a)), (array_eq a1 a2) -> (permut a1 a2).

Parameter usN: Z.

Parameter f: Z.

Axiom f_N_range : (1%Z <= f)%Z /\ (f <= usN)%Z.

(* Why3 assumption *)
Definition found(a:(array Z)): Prop := forall (p:Z) (q:Z), ((((1%Z <= p)%Z /\
  (p <= f)%Z) /\ (f <= q)%Z) /\ (q <= usN)%Z) -> (((get1 a p) <= (get1 a
  f))%Z /\ ((get1 a f) <= (get1 a q))%Z).

(* Why3 assumption *)
Definition m_invariant(m:Z) (a:(array Z)): Prop := (m <= f)%Z /\ forall (p:Z)
  (q:Z), ((((1%Z <= p)%Z /\ (p < m)%Z) /\ (m <= q)%Z) /\ (q <= usN)%Z) ->
  ((get1 a p) <= (get1 a q))%Z.

(* Why3 assumption *)
Definition n_invariant(n:Z) (a:(array Z)): Prop := (f <= n)%Z /\ forall (p:Z)
  (q:Z), ((((1%Z <= p)%Z /\ (p <= n)%Z) /\ (n < q)%Z) /\ (q <= usN)%Z) ->
  ((get1 a p) <= (get1 a q))%Z.

(* Why3 assumption *)
Definition i_invariant(m:Z) (n:Z) (i:Z) (r:Z) (a:(array Z)): Prop :=
  (m <= i)%Z /\ ((forall (p:Z), ((1%Z <= p)%Z /\ (p < i)%Z) -> ((get1 a
  p) <= r)%Z) /\ ((i <= n)%Z -> exists p:Z, ((i <= p)%Z /\ (p <= n)%Z) /\
  (r <= (get1 a p))%Z)).

(* Why3 assumption *)
Definition j_invariant(m:Z) (n:Z) (j:Z) (r:Z) (a:(array Z)): Prop :=
  (j <= n)%Z /\ ((forall (q:Z), ((j < q)%Z /\ (q <= usN)%Z) -> (r <= (get1 a
  q))%Z) /\ ((m <= j)%Z -> exists q:Z, ((m <= q)%Z /\ (q <= j)%Z) /\ ((get1 a
  q) <= r)%Z)).

(* Why3 assumption *)
Definition termination(i:Z) (j:Z) (i0:Z) (j0:Z) (r:Z) (a:(array Z)): Prop :=
  ((i0 < i)%Z /\ (j < j0)%Z) \/ (((i <= f)%Z /\ (f <= j)%Z) /\ ((get1 a
  f) = r)).



(* Why3 goal *)
Theorem WP_parameter_find : forall (a:Z), forall (a1:(map Z Z)), let a2 :=
  (mk_array a a1) in ((a = (usN + 1%Z)%Z) -> forall (n:Z) (m:Z) (a3:(map Z
  Z)), let a4 := (mk_array a a3) in (((m_invariant m a4) /\ ((n_invariant n
  a4) /\ ((permut a4 a2) /\ ((1%Z <= m)%Z /\ (n <= usN)%Z)))) ->
  ((m < n)%Z -> (((0%Z <= f)%Z /\ (f < a)%Z) -> let r := (get a3 f) in
  forall (j:Z) (i:Z) (a5:(map Z Z)), let a6 := (mk_array a a5) in
  (((i_invariant m n i r a6) /\ ((j_invariant m n j r a6) /\ ((m_invariant m
  a6) /\ ((n_invariant n a6) /\ ((0%Z <= j)%Z /\ ((i <= (usN + 1%Z)%Z)%Z /\
  ((termination i j m n r a6) /\ (permut a6 a2)))))))) -> ((i <= j)%Z ->
  forall (i1:Z), ((i_invariant m n i1 r a6) /\ (((i <= i1)%Z /\
  (i1 <= n)%Z) /\ (termination i1 j m n r a6))) -> (((0%Z <= i1)%Z /\
  (i1 < a)%Z) -> ((~ ((get a5 i1) < r)%Z) -> forall (j1:Z), ((j_invariant m n
  j1 r a6) /\ ((j1 <= j)%Z /\ ((m <= j1)%Z /\ (termination i1 j1 m n r
  a6)))) -> (((0%Z <= j1)%Z /\ (j1 < a)%Z) -> ((~ (r < (get a5 j1))%Z) ->
  ((((get a5 j1) <= r)%Z /\ (r <= (get a5 i1))%Z) -> ((i1 <= j1)%Z ->
  (((0%Z <= i1)%Z /\ (i1 < a)%Z) -> (((0%Z <= j1)%Z /\ (j1 < a)%Z) ->
  (((0%Z <= i1)%Z /\ (i1 < a)%Z) -> forall (a7:(map Z Z)), (a7 = (set a5 i1
  (get a5 j1))) -> (((0%Z <= j1)%Z /\ (j1 < a)%Z) -> forall (a8:(map Z Z)),
  let a9 := (mk_array a a8) in ((a8 = (set a7 j1 (get a5 i1))) ->
  ((exchange a8 a5 i1 j1) -> (((get a8 i1) <= r)%Z -> ((r <= (get a8
  j1))%Z -> forall (i2:Z), (i2 = (i1 + 1%Z)%Z) -> forall (j2:Z),
  (j2 = (j1 - 1%Z)%Z) -> ((i_invariant m n i2 r a9) /\ ((j_invariant m n j2 r
  a9) /\ ((m_invariant m a9) /\ ((n_invariant n a9) /\ ((0%Z <= j2)%Z /\
  ((i2 <= (usN + 1%Z)%Z)%Z /\ ((termination i2 j2 m n r a9) /\ (permut a9
  a2)))))))))))))))))))))))))))).
(* YOU MAY EDIT THE PROOF BELOW *)
intuition.
intuition.
(* i_invariant *)
red; intuition.
red in H20. intuition.
unfold get1; simpl.
assert (h: (p < i1 \/ p = i1)%Z) by omega.
destruct h.
subst a8.
rewrite Select_neq; try omega.
subst a7.
rewrite Select_neq; try omega.
red in H20.
unfold get1 in H20; simpl in H20. intuition.
subst p a8.
assert (h: (i1 = j1 \/ i1 <> j1)%Z) by omega.
destruct h.
subst i1.
rewrite Select_eq; try omega.
rewrite Select_neq; try omega.
subst a7.
rewrite Select_eq; try omega.
unfold get1; simpl.
red in H20; unfold get1 in H20; simpl in H20; intuition.
assert (h: (i1 < j1 \/ i1 = j1)%Z) by omega. destruct h.
exists j1.
split. red in H32; omega.
subst a8; rewrite Select_eq; try omega.
assert (h: (j1 < n)%Z) by omega.
exists (j1+1)%Z.
split. omega.
red in H32; unfold get1 in H32. simpl in H32; intuition.
subst a8; rewrite Select_neq; try omega.
subst a7; rewrite Select_neq; try omega.
apply H32; omega.
(* j_invariant *)
red; intuition.
red in H32; intuition.
unfold get1; simpl.
assert (h: (j1 < q \/ q = j1)%Z) by omega.
destruct h.
subst a8.
rewrite Select_neq; try omega.
subst a7.
rewrite Select_neq; try omega.
red in H32.
unfold get1 in H32; simpl in H32. intuition.
subst q a8.
assert (h: (i1 = j1 \/ i1 <> j1)%Z) by omega.
destruct h.
subst i1.
rewrite Select_eq; try omega.
rewrite Select_eq; try omega.
assert (h: (i1 < j1 \/ i1 = j1)%Z) by omega. destruct h.
exists i1.
split. red in H20; omega.
unfold get1; simpl.
subst a8; rewrite Select_neq; try omega.
subst a7; rewrite Select_eq; try omega.
assert (h: (m < i1)%Z) by omega.
exists (i1-1)%Z.
split. omega.
red in H20; unfold get1 in H20. simpl in H20; intuition.
unfold get1; simpl.
subst a8; rewrite Select_neq; try omega.
subst a7; rewrite Select_neq; try omega.
apply H20; omega.
(* m_invariant *)
clear H15 H23 H40.
red; intuition.
red in H11; omega.
unfold get1; simpl.
red in H11; intuition.
unfold get1 in H51; simpl in H51.
subst a8.
rewrite Select_neq at 1; try omega.
subst a7.
rewrite Select_neq at 1; red in H20; try omega.
assert (h: (q = i1 \/ q <> i1)%Z) by omega. destruct h.
subst q.
assert (h: (i1 = j1 \/ i1 <> j1)%Z) by omega. destruct h.
subst i1.
rewrite Select_eq; try omega.
apply H51; omega.
rewrite Select_neq; try omega.
rewrite Select_eq; try omega.
apply H51; omega.
assert (h: (q = j1 \/ q <> j1)%Z) by omega. destruct h.
subst q.
rewrite Select_eq; try omega.
apply H51; omega.
rewrite Select_neq; try omega.
rewrite Select_neq; try omega.
apply H51; omega.
(* n_invariant *)
clear H15 H23 H40.
red; intuition.
red in H12; omega.
unfold get1; simpl.
red in H12; intuition.
unfold get1 in H51; simpl in H51.
subst a8.
rewrite (Select_neq _ _ q); red in H32; try omega.
subst a7.
rewrite (Select_neq _ _ q); try omega.
assert (h: (p = i1 \/ p <> i1)%Z) by omega. destruct h.
subst p.
assert (h: (i1 = j1 \/ i1 <> j1)%Z) by omega. destruct h.
subst i1.
rewrite Select_eq; try omega.
apply H51; omega.
rewrite Select_neq; try omega.
rewrite Select_eq; try omega.
apply H51; omega.
assert (h: (p = j1 \/ p <> j1)%Z) by omega. destruct h.
subst p.
rewrite Select_eq; try omega.
apply H51; red in H20; omega.
rewrite Select_neq; try omega.
rewrite Select_neq; try omega.
apply H51; omega.
(* termination *)
red; intros.
unfold get1; simpl.
red in H20.
red in H32.
left.
intuition.
(* permut *)
red; simpl.
split. trivial.
apply permut_trans with a5.
apply permut_exchange with i1 j1; try omega.
assumption.
red in H17; simpl in H17.
intuition.
Qed.

