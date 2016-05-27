#HAMLEDT_DIR = /net/projects/tectomt_shared/data/archive/hamledt/3.0_2015-08-18
# HamleDT 2.0 languages:
# Exclude ar because HamleDT data is non-trivially tokenized and vocalized.
# Exclude bn,te because HamleDT data do not contain surface forms (only chunk heads).
# Exclude grc because it is not covered by W2C.
# Exclude ja,ta because HamleDT data is romanized (the text in the original script is not available).
# Exclude nl because there are joined multi-word tokens and their POS tag is always unknown.
# Exclude ru because it does not contain pronouns (they are merged with nouns and adjectives).
# We may also want to exclude tr because it contains too many empty nodes (related to derivational morphology); but it was included in c7 (LREC paper).
HAMLEDT_DIR = /net/projects/tectomt_shared/data/archive/hamledt/2.0_2014-05-24_treex-r12700
HAMLEDT_LANGUAGES = bg ca cs da de el en es et eu fa fi hi hu it la pt ro sk sl sv tr

# Exclude cu,got,grc,grc_proiel because it is not covered by W2C.
# Exclude en_esl,ja because there are only patches for these treebanks, without words.
# Exclude zh because word segmentation of raw text is not trivial.
UD_DIR = /net/data/universal-dependencies-1.3
UD_LANGUAGES = ar bg ca cs cs_cac cs_cltt da de el en en_lines es es_ancora et eu fa fi fi_ftb fr ga gl he hi hr hu id it kk la la_ittb la_proiel lv nl nl_lassysmall no pl pt pt_br ro ru ru_syntagrus sl sl_sst sv sv_lines ta tr

W2C_DIR = /net/data/W2C/W2C_WEB/2011-08
# Only the languages represented in either HamleDT or UD:
#W2C_LANGUAGES = ara bul cat ces dan deu ell eng est eus fas fin fra gle glg heb hin hrv hun ind ita lat lav nld nor pol por ron rus slk slv spa swe tam tur
# All 107 languages included in Deltacorpus:
# (note that 'als/gsw' requires special treatment because it is marked 'als' in W2C but the correct code is 'gsw')
W2C_LANGUAGES_EXCEPT_GSW = bel bos bul ces hbs hrv hsb mkd pol rus slk slv srp ukr lav lit afr dan deu eng fao fry isl lim ltz nds nld nno nor sco swe yid arg ast cat fra glg hat ita lat lmo nap pms por ron spa vec wln bre cym gla gle ell hye sqi diq fas glk kur tgk ben bpy guj hif hin mar nep urd amh ara arz heb est fin hun eus kat chv aze tur uzb kaz tat sah kor mon tel kan mal tam new vie ind jav mlg mri msa pam sun tgl war swa epo ido ina vol
W2C_LANGUAGES = gsw $(W2C_LANGUAGES_EXCEPT_GSW)

w2c_to_conll:
	@mkdir -p data/w2c
	@zcat $(W2C_DIR)/als.txt.gz | ./text_to_conll.pl | ./filter.pl gsw | head -1000000 > data/w2c/gsw.conll
	@echo -n "als=>gsw "
	@for l in $(W2C_LANGUAGES_EXCEPT_GSW); do \
		zcat $(W2C_DIR)/$$l.txt.gz | ./text_to_conll.pl | ./filter.pl $$l | head -1000000 > data/w2c/$$l.conll; \
		echo -n "$$l "; \
	done
	@echo

conllu_to_conll:
	@mkdir -p data/ud/train
	@mkdir -p data/ud/dtest
	@for l in $(UD_LANGUAGES); do \
		cat $(UD_DIR)/*/$$l-ud-train*.conllu | ./clean_conllu.pl > data/ud/train/$$l.conll; \
		cat $(UD_DIR)/*/$$l-ud-dev*.conllu | ./clean_conllu.pl > data/ud/dtest/$$l.conll; \
		echo -n "$$l "; \
	done
	@echo

hamledt2_to_conll:
	@mkdir -p data/hamledt2/train
	@mkdir -p data/hamledt2/dtest
	@for l in $(HAMLEDT_LANGUAGES); do \
		zcat $(HAMLEDT_DIR)/$$l/stanford/train/*.conll.gz > data/hamledt2/train/$$l.conll; \
		zcat $(HAMLEDT_DIR)/$$l/stanford/test/*.conll.gz > data/hamledt2/dtest/$$l.conll; \
		echo -n "$$l "; \
	done
	@echo

generate_hfeatures:
	@mkdir -p data/features/htrain
	@mkdir -p data/features/hdtest
	@mkdir -p log
	@for l in $(HAMLEDT_LANGUAGES); do \
		./fill_langcode.pl "python get_featurefromw2c.py data/hamledt2/train/XX.conll data/w2c/XXX.conll \
			20000000 data/features/htrain/XX.feat" $$l > log/hfeatures_$$l.sh; \
		./fill_langcode.pl "python get_featurefromw2c.py data/hamledt2/dtest/XX.conll data/w2c/XXX.conll \
			20000000 data/features/hdtest/XX.feat" $$l >> log/hfeatures_$$l.sh; \
		qsub -hard -l mf=10g -l act_mem_free=10g -o log -e log -cwd log/hfeatures_$$l.sh; \
	done

generate_features:
	@mkdir -p data/features/train
	@mkdir -p data/features/dtest
	@mkdir -p log
	@for l in $(UD_LANGUAGES); do \
		./fill_langcode.pl "python get_featurefromw2c.py data/ud/train/XX.conll data/w2c/XXX.conll \
			20000000 data/features/train/XX.feat" $$l > log/features_$$l.sh; \
		./fill_langcode.pl "python get_featurefromw2c.py data/ud/dtest/XX.conll data/w2c/XXX.conll \
			20000000 data/features/dtest/XX.feat" $$l >> log/features_$$l.sh; \
		qsub -hard -l mf=10g -l act_mem_free=10g -o log -e log -cwd log/features_$$l.sh; \
	done

generate_wfeatures:
	@mkdir -p data/features/w2c
	@mkdir -p log
	@for l in $(W2C_LANGUAGES); do \
		python get_featurefromw2c.py data/w2c/$$l.conll data/w2c/$$l.conll 20000000 data/features/w2c/$$l.feat > log/wfeatures_$$l.sh; \
		qsub -q 'all.q@*,ms-all.q@*,troja-all.q@*' -hard -l mf=10g -l act_mem_free=10g -j yes -o log -cwd log/wfeatures_$$l.sh; \
	done

# Prepares training data for the classifier. For each target language the training data of this language is left out.
# Training data of all other languages are concatenated (the first 30,000 tokens per language only).
leave_one_out:
	./leave1out.pl hamledt $(HAMLEDT_LANGUAGES)
	./leave1out.pl $(UD_LANGUAGES)

# Prepares custom mixes of training data, such as the c7 described in our LREC 2016 paper.
# c7 ... bg ca de el hi hu tr (from HamleDT 2.0)
hctrain:
	@rm -rf data/features/hctrain
	@mkdir -p data/features/hctrain
	@echo -n "c7: "
	@for l in bg ca de el hi hu tr ; do \
		cat data/features/htrain/$$l.feat | head -50000 >> data/features/hctrain/c7.feat; \
		echo -n "$$l "; \
	done
	@echo
	@echo -n "csla: "
	@for l in bg cs sl ; do \
		cat data/features/htrain/$$l.feat | head -50000 >> data/features/hctrain/csla.feat; \
		echo -n "$$l "; \
	done
	@echo
	@echo -n "cger: "
	@for l in de en sv ; do \
		cat data/features/htrain/$$l.feat | head -50000 >> data/features/hctrain/cger.feat; \
		echo -n "$$l "; \
	done
	@echo
	@echo -n "crom: "
	@for l in ca it pt ; do \
		cat data/features/htrain/$$l.feat | head -50000 >> data/features/hctrain/crom.feat; \
		echo -n "$$l "; \
	done
	@echo
	@echo -n "cine: "
	@for l in bg ca cs de el hi pt ; do \
		cat data/features/htrain/$$l.feat | head -50000 >> data/features/hctrain/cine.feat; \
		echo -n "$$l "; \
	done
	@echo
	@echo -n "cagl: "
	@for l in hu fi et tr eu cs sv ; do \
		cat data/features/htrain/$$l.feat | head -50000 >> data/features/hctrain/cagl.feat; \
		echo -n "$$l "; \
	done
	@echo

# Similar mixed models but trained on Universal Dependencies data.
ctrain:
	@rm -rf data/features/ctrain
	@mkdir -p data/features/ctrain
	@echo -n "c7: "
	@for l in bg ca de el hi hu tr ; do \
		cat data/features/train/$$l.feat | head -50000 >> data/features/ctrain/c7.feat; \
		echo -n "$$l "; \
	done
	@echo
	@echo -n "csla: "
	@for l in bg cs hr pl ru sl ; do \
		cat data/features/train/$$l.feat | head -50000 >> data/features/ctrain/csla.feat; \
		echo -n "$$l "; \
	done
	@echo
	@echo -n "cger: "
	@for l in de en no sv ; do \
		cat data/features/train/$$l.feat | head -50000 >> data/features/ctrain/cger.feat; \
		echo -n "$$l "; \
	done
	@echo
	@echo -n "crom: "
	@for l in ca es fr it pt ; do \
		cat data/features/train/$$l.feat | head -50000 >> data/features/ctrain/crom.feat; \
		echo -n "$$l "; \
	done
	@echo
	@echo -n "cine: "
	@for l in bg ca cs de el hi pt ; do \
		cat data/features/train/$$l.feat | head -50000 >> data/features/ctrain/cine.feat; \
		echo -n "$$l "; \
	done
	@echo
	@echo -n "cagl: "
	@for l in hu fi et tr eu cs sv ; do \
		cat data/features/train/$$l.feat | head -50000 >> data/features/ctrain/cagl.feat; \
		echo -n "$$l "; \
	done
	@echo

svm_tag:
	@mkdir -p data/predicted
	@mkdir -p data/hpredicted
	@for l in $(HAMLEDT_LANGUAGES); do \
		echo "./svm.py data/features/htrain_leave1out/$$l.feat data/features/hdtest/$$l.feat data/hpredicted/$$l.pred" \
			> log/htag_$$l.sh; \
		qsub -hard -l mf=30g -l act_mem_free=30g -o log/htag_$$l.o -e log/htag_$$l.e -cwd log/htag_$$l.sh; \
	done
	@for l in $(UD_LANGUAGES); do \
		echo "./svm.py data/features/train_leave1out/$$l.feat data/features/dtest/$$l.feat data/predicted/$$l.pred" \
			> log/tag_$$l.sh; \
		qsub -hard -l mf=30g -l act_mem_free=30g -o log/tag_$$l.o -e log/tag_$$l.e -cwd log/tag_$$l.sh; \
	done

# Train a model that will be reused to tag multiple languages.
# Save the model as a Python pickle file. Do not do the tagging.
svm_hctrain:
	@mkdir -p data/models
	@for c in c7 csla cger crom cine cagl; do \
		echo "./svm-train.py data/features/hctrain/$$c.feat data/models/svm-$$c-h.p" > log/svm-$$c-htrain.sh; \
		qsub -q 'all.q@*,ms-all.q@*,troja-all.q@*' -hard -l mf=30g -l act_mem_free=30g -j yes -o log/svm-$${c}-htrain.o -cwd log/svm-$$c-htrain.sh; \
	done

# Train a model for multiple languages on Universal Dependencies.
svm_ctrain:
	@mkdir -p data/models
	@for c in c7 csla cger crom cine cagl; do \
		echo "./svm-train.py data/features/ctrain/$$c.feat data/models/svm-$$c.p" > log/svm-$$c-train.sh; \
		qsub -q 'all.q@*,ms-all.q@*,troja-all.q@*' -hard -l mf=30g -l act_mem_free=30g -j yes -o log/svm-$$c-train.o -cwd log/svm-$$c-train.sh; \
	done

svm_hctag:
	@mkdir -p data/hcpredicted
	@for l in $(HAMLEDT_LANGUAGES); do \
		for c in c7 csla cger crom cine cagl; do \
			echo "./svm-tag.py data/models/svm-$$c-h.p data/features/hdtest/$$l.feat data/hcpredicted/$$c-$$l.pred" > log/$$c-$$l-h.sh; \
			qsub -q 'all.q@*,ms-all.q@*,troja-all.q@*' -hard -l mf=30g -l act_mem_free=30g -j yes -o log/$$c-$$l-h.o -cwd log/$$c-$$l-h.sh; \
		done; \
	done

svm_ctag:
	@mkdir -p data/cpredicted
	@for l in $(UD_LANGUAGES); do \
		for c in c7 csla cger crom cine cagl; do \
			echo "./svm-tag.py data/models/svm-$$c.p data/features/dtest/$$l.feat data/cpredicted/$$c-$$l.pred" > log/$$c-$$l.sh; \
			echo "./merge_output.pl data/ud/dtest/$$l.conll data/cpredicted/$$c-$$l.pred > data/cpredicted/$$c-$$l.conll" >> log/$$c-$$l.sh; \
			qsub -q 'all.q@*,ms-all.q@*,troja-all.q@*' -hard -l mf=30g -l act_mem_free=30g -j yes -o log/$$c-$$l.o -cwd log/$$c-$$l.sh; \
		done; \
	done

output:
	@for l in $(UD_LANGUAGES); do \
		echo -n "$$l "; \
		./merge_output.pl data/ud/dtest/$$l.conll data/predicted/$$l.pred > data/predicted/$$l.conll; \
	done
