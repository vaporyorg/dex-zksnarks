#!/bin/bash
set -e

cd $PEPPER/pepper

function run {
	./pepper_compile_and_setup_P.sh hash_transform | sed "s/^/[$COUNT Setup Prover] /"
	/usr/bin/time -v ./pepper_compile_and_setup_V.sh hash_transform transform.vkey transform.pkey | sed "s/^/[$COUNT Setup Verifier] /"

	/usr/bin/time -v ./bin/pepper_prover_hash_transform prove transform.pkey transform.inputs transform.outputs transform.proof | sed "s/^/[$COUNT Prove] /"
	/usr/bin/time -v ./bin/pepper_verifier_hash_transform verify transform.vkey transform.inputs transform.outputs transform.proof | sed "s/^/[$COUNT Verify] /"
}

# remove assert and provide input
sed -i 's%assert_zero(result - input->shaHash);%//assert_zero(result - input->shaHash);%g' apps/hash_transform.c
echo 62174266130574243119709474530137211798696360945565673697823515822613061023144 > prover_verifier_shared/transform.inputs

# 50M constraints
COUNT='50M'
echo '50 million constraints'
sed -i 's/#define ORDERS [0-9]*/#define ORDERS 725/g' apps/hash_transform.h
run

# 100M constraints
COUNT='100M'
echo '100 million constraints'
sed -i 's/#define ORDERS [0-9]*/#define ORDERS 1450/g' apps/hash_transform.h
run

# 150M constraints
COUNT='150M'
echo '150 million constraints'
sed -i 's/#define ORDERS [0-9]*/#define ORDERS 2175/g' apps/hash_transform.h
run

# 200M constraints
COUNT='200M'
echo '200 million constraints'
sed -i 's/#define ORDERS [0-9]*/#define ORDERS 2900/g' apps/hash_transform.h
run