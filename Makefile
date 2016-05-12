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

UD_DIR = /net/data/universal-dependencies-1.2
UD_LANGUAGES = bg cs da de el en et eu fa fi fi_ftb fr ga he hi hr hu id it la la_itt la_proiel no pl ro sl sv ta

UD2_DIR = /ha/work/people/zeman/unidep
UD2_LANGUAGES = ca es pt pt_br

W2C_DIR = /net/data/W2C/W2C_WEB/2011-08
W2C_LANGUAGES = bul cat ces dan deu ell eng est eus fas fin fra gle heb hin hrv hun ind ita lat nor pol por ron slk slv spa swe tam tur

w2c_to_conll:
	@mkdir -p data/w2c
	@for l in $(W2C_LANGUAGES); do \
		zcat $(W2C_DIR)/$$l.txt.gz | head -1000000 | ./text_to_conll.pl | ./filter.pl $$l > data/w2c/$$l.conll; \
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
	@for l in $(UD2_LANGUAGES); do \
		cat $(UD2_DIR)/*/$$l-ud-train*.conllu | ./clean_conllu.pl > data/ud/train/$$l.conll; \
		cat $(UD2_DIR)/*/$$l-ud-dev*.conllu | ./clean_conllu.pl > data/ud/dtest/$$l.conll; \
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

generate_features:
	@mkdir -p data/features/train
	@mkdir -p data/features/dtest
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
	@for l in $(UD_LANGUAGES) $(UD2_LANGUAGES); do \
		./fill_langcode.pl "python get_featurefromw2c.py data/ud/train/XX.conll data/w2c/XXX.conll \
			20000000 data/features/train/XX.feat" $$l > log/features_$$l.sh; \
		./fill_langcode.pl "python get_featurefromw2c.py data/ud/dtest/XX.conll data/w2c/XXX.conll \
			20000000 data/features/dtest/XX.feat" $$l >> log/features_$$l.sh; \
		qsub -hard -l mf=10g -l act_mem_free=10g -o log -e log -cwd log/features_$$l.sh; \
	done

# Prepares training data for the classifier. For each target language the training data of this language is left out.
# Training data of all other languages are concatenated (the first 30,000 tokens per language only).
leave_one_out:
	./leave1out.pl hamledt $(HAMLEDT_LANGUAGES)
	./leave1out.pl $(UD_LANGUAGES) $(UD2(LANGUAGES)

# Prepares custom mixes of training data, such as the c7 described in our LREC 2016 paper.
# c7 ... bg ca de el hi hu tr (from HamleDT 2.0)
ctrain:
	@rm -rf data/features/ctrain
	@mkdir -p data/features/ctrain
	@echo -n "c7: "
	@for l in bg ca de el hi hu tr ; do \
		cat data/features/htrain/$$l.feat | head -50000 >> data/features/ctrain/c7.feat; \
		echo -n "$$l "; \
	done
	@echo
	@echo -n "csla: "
	@for l in bg cs sl ; do \
		cat data/features/htrain/$$l.feat | head -50000 >> data/features/ctrain/csla.feat; \
		echo -n "$$l "; \
	done
	@echo
	@echo -n "cger: "
	@for l in de en sv ; do \
		cat data/features/htrain/$$l.feat | head -50000 >> data/features/ctrain/cger.feat; \
		echo -n "$$l "; \
	done
	@echo
	@echo -n "crom: "
	@for l in ca it pt ; do \
		cat data/features/htrain/$$l.feat | head -50000 >> data/features/ctrain/crom.feat; \
		echo -n "$$l "; \
	done
	@echo
	@echo -n "cine: "
	@for l in bg ca cs de el hi pt ; do \
		cat data/features/htrain/$$l.feat | head -50000 >> data/features/ctrain/cine.feat; \
		echo -n "$$l "; \
	done
	@echo
	@echo -n "cagl: "
	@for l in hu fi et tr eu cs sv ; do \
		cat data/features/htrain/$$l.feat | head -50000 >> data/features/ctrain/cagl.feat; \
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
	@for l in $(UD_LANGUAGES) $(UD2(LANGUAGES); do \
		echo "./svm.py data/features/train_leave1out/$$l.feat data/features/dtest/$$l.feat data/predicted/$$l.pred" \
			> log/tag_$$l.sh; \
		qsub -hard -l mf=30g -l act_mem_free=30g -o log/tag_$$l.o -e log/tag_$$l.e -cwd log/tag_$$l.sh; \
	done

# Train a model that will be reused to tag multiple languages.
# Save the model as a Python pickle file. Do not do the tagging.
svm_ctrain:
	@mkdir -p data/models
	@for c in c7 csla cger crom cine cagl; do \
		echo "./svm-train.py data/features/ctrain/$$c.feat data/models/svm-$$c.p" > log/svm-$$c-train.sh; \
		qsub -q 'all.q@*,ms-all.q@*,troja-all.q@*' -hard -l mf=30g -l act_mem_free=30g -j yes -o log/svm-$${c}-train.o -cwd log/svm-$$c-train.sh; \
	done

svm_ctag:
	@mkdir -p data/cpredicted
	@for l in $(HAMLEDT_LANGUAGES); do \
		for c in c7 csla cger crom cine cagl; do \
			echo "./svm-tag.py data/models/svm-$$c.p data/features/hdtest/$$l.feat data/cpredicted/$$c-$$l.pred" > log/$${c}_$$l.sh; \
			qsub -q 'all.q@*,ms-all.q@*,troja-all.q@*' -hard -l mf=30g -l act_mem_free=30g -j yes -o log/$${c}_$$l.o -cwd log/$${c}_$$l.sh; \
		done; \
	done

output:
	@for l in $(UD_LANGUAGES) $(UD2(LANGUAGES); do \
		echo -n "$$l "; \
		./merge_output.pl data/ud/dtest/$$l.conll data/predicted/$$l.pred > data/predicted/$$l.conll; \
	done
