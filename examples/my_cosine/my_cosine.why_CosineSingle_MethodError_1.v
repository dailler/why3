(* This file is generated by Why3's Coq driver *)
(* Beware! Only edit allowed sections below    *)
Require Import ZArith.
Require Import Rbase.
Require Import Rbasic_fun.
Require Import R_sqrt.
Require Import Rtrigo.
Require Import AltSeries. (* for def of pi *)
Axiom Abs_le : forall (x:R) (y:R), ((Rabs x) <= y)%R <-> (((-y)%R <= x)%R /\
  (x <= y)%R).

Axiom Sqrt_positive : forall (x:R), ((0)%R <= x)%R -> ((0)%R <= (sqrt x))%R.

Axiom Sqrt_square : forall (x:R), ((0)%R <= x)%R -> ((Rsqr (sqrt x)) = x).

Axiom Square_sqrt : forall (x:R), ((0)%R <= x)%R -> ((sqrt (x * x)%R) = x).

Axiom Pythagorean_identity : forall (x:R),
  (((Rsqr (Rtrigo_def.cos x)) + (Rsqr (Rtrigo_def.sin x)))%R = (1)%R).

Axiom Cos_le_one : forall (x:R), ((Rabs (Rtrigo_def.cos x)) <= (1)%R)%R.

Axiom Sin_le_one : forall (x:R), ((Rabs (Rtrigo_def.sin x)) <= (1)%R)%R.

Axiom Cos_0 : ((Rtrigo_def.cos (0)%R) = (1)%R).

Axiom Sin_0 : ((Rtrigo_def.sin (0)%R) = (0)%R).

Axiom Pi_interval : ((314159265358979323846264338327950288419716939937510582097494459230781640628620899862803482534211706798214808651328230664709384460955058223172535940812848111745028410270193852110555964462294895493038196 / 100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000)%R <  PI)%R /\
  (PI <  (314159265358979323846264338327950288419716939937510582097494459230781640628620899862803482534211706798214808651328230664709384460955058223172535940812848111745028410270193852110555964462294895493038197 / 100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000)%R)%R.

Axiom Cos_pi : ((Rtrigo_def.cos PI) = (-(1)%R)%R).

Axiom Sin_pi : ((Rtrigo_def.sin PI) = (0)%R).

Axiom Cos_pi2 : ((Rtrigo_def.cos ((05 / 10)%R * PI)%R) = (0)%R).

Axiom Sin_pi2 : ((Rtrigo_def.sin ((05 / 10)%R * PI)%R) = (1)%R).

Axiom Cos_plus_pi : forall (x:R),
  ((Rtrigo_def.cos (x + PI)%R) = (-(Rtrigo_def.cos x))%R).

Axiom Sin_plus_pi : forall (x:R),
  ((Rtrigo_def.sin (x + PI)%R) = (-(Rtrigo_def.sin x))%R).

Axiom Cos_plus_pi2 : forall (x:R),
  ((Rtrigo_def.cos (x + ((05 / 10)%R * PI)%R)%R) = (-(Rtrigo_def.sin x))%R).

Axiom Sin_plus_pi2 : forall (x:R),
  ((Rtrigo_def.sin (x + ((05 / 10)%R * PI)%R)%R) = (Rtrigo_def.cos x)).

Axiom Cos_neg : forall (x:R), ((Rtrigo_def.cos (-x)%R) = (Rtrigo_def.cos x)).

Axiom Sin_neg : forall (x:R),
  ((Rtrigo_def.sin (-x)%R) = (-(Rtrigo_def.sin x))%R).

Axiom Cos_sum : forall (x:R) (y:R),
  ((Rtrigo_def.cos (x + y)%R) = (((Rtrigo_def.cos x) * (Rtrigo_def.cos y))%R - ((Rtrigo_def.sin x) * (Rtrigo_def.sin y))%R)%R).

Axiom Sin_sum : forall (x:R) (y:R),
  ((Rtrigo_def.sin (x + y)%R) = (((Rtrigo_def.sin x) * (Rtrigo_def.cos y))%R + ((Rtrigo_def.cos x) * (Rtrigo_def.sin y))%R)%R).

Parameter atan: R  -> R.


Axiom Tan_atan : forall (x:R), ((Rtrigo.tan (atan x)) = x).

Inductive mode  :=
  | NearestTiesToEven : mode 
  | ToZero : mode 
  | Up : mode 
  | Down : mode 
  | NearTiesToAway : mode .

Parameter single : Type.

Axiom Zero : ((IZR 0%Z) = (0)%R).

Axiom One : ((IZR 1%Z) = (1)%R).

Axiom Add : forall (x:Z) (y:Z), ((IZR (x + y)%Z) = ((IZR x) + (IZR y))%R).

Axiom Sub : forall (x:Z) (y:Z), ((IZR (x - y)%Z) = ((IZR x) - (IZR y))%R).

Axiom Mul : forall (x:Z) (y:Z), ((IZR (x * y)%Z) = ((IZR x) * (IZR y))%R).

Axiom Neg : forall (x:Z), ((IZR (-x)%Z) = (-(IZR x))%R).

Parameter round: mode -> R  -> R.


Parameter round_logic: mode -> R  -> single.


Parameter value: single  -> R.


Parameter exact: single  -> R.


Parameter model: single  -> R.


Definition round_error(x:single): R := (Rabs ((value x) - (exact x))%R).

Definition total_error(x:single): R := (Rabs ((value x) - (model x))%R).

Definition no_overflow(m:mode) (x:R): Prop := ((Rabs (round m
  x)) <= (33554430 * 10141204801825835211973625643008)%R)%R.

Axiom Bounded_real_no_overflow : forall (m:mode) (x:R),
  ((Rabs x) <= (33554430 * 10141204801825835211973625643008)%R)%R ->
  (no_overflow m x).

Axiom Round_monotonic : forall (m:mode) (x:R) (y:R), (x <= y)%R -> ((round m
  x) <= (round m y))%R.

Axiom Exact_rounding_for_integers : forall (m:mode) (i:Z),
  (((-16777216%Z)%Z <= i)%Z /\ (i <= 16777216%Z)%Z) -> ((round m
  (IZR i)) = (IZR i)).

Axiom Round_down_le : forall (x:R), ((round (Down ) x) <= x)%R.

Axiom Round_up_ge : forall (x:R), (x <= (round (Up ) x))%R.

Axiom Round_down_neg : forall (x:R), ((round (Down ) (-x)%R) = (-(round (Up )
  x))%R).

Axiom Round_up_neg : forall (x:R), ((round (Up ) (-x)%R) = (-(round (Down )
  x))%R).

Theorem MethodError : forall (x:R), ((Rabs x) <= (1 / 32)%R)%R ->
  ((Rabs (((1)%R - ((05 / 10)%R * (x * x)%R)%R)%R - (Rtrigo_def.cos x))%R) <= (1 / 16777216)%R)%R.
(* YOU MAY EDIT THE PROOF BELOW *)
intros x H.
Require Import Interval_tactic.
interval with (i_bisect_diff x).
Qed.
(* DO NOT EDIT BELOW *)


