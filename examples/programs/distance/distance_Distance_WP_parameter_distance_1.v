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
Implicit Arguments mk_ref.

(* Why3 assumption *)
Definition contents (a:Type)(v:(ref a)): a :=
  match v with
  | (mk_ref x) => x
  end.
Implicit Arguments contents.

Parameter map : forall (a:Type) (b:Type), Type.

Parameter get: forall (a:Type) (b:Type), (map a b) -> a -> b.
Implicit Arguments get.

Parameter set: forall (a:Type) (b:Type), (map a b) -> a -> b -> (map a b).
Implicit Arguments set.

Axiom Select_eq : forall (a:Type) (b:Type), forall (m:(map a b)),
  forall (a1:a) (a2:a), forall (b1:b), (a1 = a2) -> ((get (set m a1 b1)
  a2) = b1).

Axiom Select_neq : forall (a:Type) (b:Type), forall (m:(map a b)),
  forall (a1:a) (a2:a), forall (b1:b), (~ (a1 = a2)) -> ((get (set m a1 b1)
  a2) = (get m a2)).

Parameter const: forall (a:Type) (b:Type), b -> (map a b).
Set Contextual Implicit.
Implicit Arguments const.
Unset Contextual Implicit.

Axiom Const : forall (a:Type) (b:Type), forall (b1:b) (a1:a),
  ((get (const b1:(map a b)) a1) = b1).

(* Why3 assumption *)
Inductive array (a:Type) :=
  | mk_array : Z -> (map Z a) -> array a.
Implicit Arguments mk_array.

(* Why3 assumption *)
Definition elts (a:Type)(v:(array a)): (map Z a) :=
  match v with
  | (mk_array x x1) => x1
  end.
Implicit Arguments elts.

(* Why3 assumption *)
Definition length (a:Type)(v:(array a)): Z :=
  match v with
  | (mk_array x x1) => x
  end.
Implicit Arguments length.

(* Why3 assumption *)
Definition get1 (a:Type)(a1:(array a)) (i:Z): a := (get (elts a1) i).
Implicit Arguments get1.

(* Why3 assumption *)
Definition set1 (a:Type)(a1:(array a)) (i:Z) (v:a): (array a) :=
  (mk_array (length a1) (set (elts a1) i v)).
Implicit Arguments set1.

Parameter n: Z.

Axiom n_nonneg : (0%Z < n)%Z.

Parameter f: Z -> Z.

Axiom f_prop : forall (k:Z), ((0%Z < k)%Z /\ (k < n)%Z) ->
  ((0%Z <= (f k))%Z /\ ((f k) < k)%Z).

(* Why3 assumption *)
Inductive path : Z -> Z -> Prop :=
  | path0 : (path 0%Z 0%Z)
  | paths : forall (i:Z), ((0%Z <= i)%Z /\ (i < n)%Z) -> forall (d:Z) (j:Z),
      (path d j) -> ((((f i) <= j)%Z /\ (j < i)%Z) -> (path (d + 1%Z)%Z i)).

(* Why3 assumption *)
Definition distance(d:Z) (i:Z): Prop := (path d i) /\ forall (d':Z), (path d'
  i) -> (d <= d')%Z.

Require Import Why3.
Ltac ae := why3 "alt-ergo" timelimit 3.

(* Why3 goal *)
Theorem WP_parameter_distance : (0%Z <= n)%Z -> ((((0%Z < 0%Z)%Z \/
  (0%Z = 0%Z)) /\ (0%Z < n)%Z) -> forall (g:(map Z Z)),
  (g = (set (const 0%Z:(map Z Z)) 0%Z (-1%Z)%Z)) -> ((0%Z <= n)%Z ->
  (((1%Z < (n - 1%Z)%Z)%Z \/ (1%Z = (n - 1%Z)%Z)) -> forall (count:Z) (d:(map
  Z Z)) (g1:(map Z Z)), (((get d 0%Z) = 0%Z) /\ (((get g1 0%Z) = (-1%Z)%Z) /\
  ((((count + (get d
  (((n - 1%Z)%Z + 1%Z)%Z - 1%Z)%Z))%Z < (((n - 1%Z)%Z + 1%Z)%Z - 1%Z)%Z)%Z \/
  ((count + (get d
  (((n - 1%Z)%Z + 1%Z)%Z - 1%Z)%Z))%Z = (((n - 1%Z)%Z + 1%Z)%Z - 1%Z)%Z)) /\
  ((forall (k:Z), ((0%Z < k)%Z /\ (k < ((n - 1%Z)%Z + 1%Z)%Z)%Z) ->
  (((((get g1 (get g1 k)) < (f k))%Z /\ (((f k) < (get g1 k))%Z \/
  ((f k) = (get g1 k)))) /\ ((get g1 k) < k)%Z) /\ ((((0%Z < (get d k))%Z \/
  (0%Z = (get d k))) /\ ((get d k) = ((get d (get g1 k)) + 1%Z)%Z)) /\
  forall (k':Z), (((get g1 k) < k')%Z /\ (k' < k)%Z) -> ((get d (get g1
  k)) < (get d k'))%Z))) /\ forall (k:Z), (((0%Z < k)%Z \/ (0%Z = k)) /\
  (k < ((n - 1%Z)%Z + 1%Z)%Z)%Z) -> (path (get d k) k))))) ->
  ((count < n)%Z -> forall (k:Z), (((0%Z < k)%Z \/ (0%Z = k)) /\
  (k < n)%Z) -> forall (d':Z), (path d' k) -> ((get d k) <= d')%Z)))).
intros h1 (h2,h3) g h4 h5 h6 count d g1 (h7,(h8,(h9,(h10,h11)))) h12 k
(h13,h14) d' h15.
clear h1 h2.
clear h5 h6.
replace (n-1+1)%Z with n in * by omega.
clear count h9 h12.
generalize h13 h14 d' h15.
pattern k.
apply Z_lt_induction; [clear k h13 h14 d' h15 | omega].
intros k IH hk1 hk2 d' hd'.
assert (case: (get d k <= d' \/ d' < get d k)%Z) by omega.
destruct case; auto.
destruct hk1.
(* 0 < k *)
inversion hd'.
omega.
subst i.
assert (h: (0 < k < n)%Z) by omega.
generalize (h10 k h). intros h10k.
assert (case: (j < get g1 k \/ j = get g1 k \/ j > get g1 k)%Z) by omega.
destruct case.
(* j < g[k] *)
why3 "z3" timelimit 5.
destruct H5.
(* j = g[k] *)
ae.
(* j > g[k] *)
why3 "z3" timelimit 3.
(* k = 0 *)
ae.
Qed.


