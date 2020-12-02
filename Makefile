yubaba: yubaba.ll
	llc yubaba.ll
	gcc yubaba.s -o yubaba

yubaba_O0.s: yubaba.ll
	llc -O0 -o yubaba_O0.s yubaba.ll

yubaba_O1.s: yubaba.ll
	llc -O1 -o yubaba_O1.s yubaba.ll

yubaba_O2.s: yubaba.ll
	llc -O2 -o yubaba_O2.s yubaba.ll

yubaba_O3.s: yubaba.ll
	llc -O3 -o yubaba_O3.s yubaba.ll

optimized_yubaba: yubaba_O0.s yubaba_O1.s yubaba_O2.s yubaba_O3.s

diff_O0_to_O1.txt: yubaba_O0.s yubaba_O1.s
	diff -u yubaba_O0.s yubaba_O1.s | tee diff_O0_to_O1.txt | exit 0

diff_O1_to_O2.txt: yubaba_O1.s yubaba_O2.s
	diff -u yubaba_O1.s yubaba_O2.s | tee diff_O1_to_O2.txt | exit 0

diff_O2_to_O3.txt: yubaba_O2.s yubaba_O3.s
	diff -u yubaba_O2.s yubaba_O3.s | tee diff_O2_to_O3.txt | exit 0

diff: diff_O0_to_O1.txt diff_O1_to_O2.txt diff_O2_to_O3.txt

sample: yubaba_sample.c
	gcc -S -emit-llvm yubaba_sample.c

sample_exe: yubaba_sample.ll
	llc yubaba_sample.ll
	gcc yubaba_sample.s -o yubaba_sample
