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
#UD_DIR = /net/data/universal-dependencies-1.3
#UD_LANGUAGES = ar bg ca cs cs_cac cs_cltt da de el en en_lines es es_ancora et eu fa fi fi_ftb fr ga gl he hi hr hu id it kk la la_ittb la_proiel lv nl nl_lassysmall no pl pt pt_br ro ru ru_syntagrus sl sl_sst sv sv_lines ta tr
# Universal Dependencies 1.2 (November 2015)
UD_DIR = /net/data/universal-dependencies-1.2
UD_LANGUAGES = ar bg cs da de el en es et eu fa fi fi_ftb fr ga he hi hr hu id it la la_itt la_proiel nl no pl pt ro sl sv ta

W2C_DIR = /net/data/W2C/W2C_WEB/2011-08
# Only the languages represented in either HamleDT or UD:
#W2C_LANGUAGES = ara bul cat ces dan deu ell eng est eus fas fin fra gle glg heb hin hrv hun ind ita lat lav nld nor pol por ron rus slk slv spa swe tam tur
# All 107 languages included in Deltacorpus:
# (note that 'als/gsw' requires special treatment because it is marked 'als' in W2C but the correct code is 'gsw')
W2C_BALTOSLAVIC_LANGUAGES = bel bos bul ces hbs hrv hsb mkd pol rus slk slv srp ukr lav lit
W2C_GERMANIC_LANGUAGES_EXCEPT_GSW = afr dan deu eng fao fry isl lim ltz nds nld nno nor sco swe yid
W2C_GERMANIC_LANGUAGES = gsw $(W2C_GERMANIC_LANGUAGES_EXCEPT_GSW)
W2C_ROMANCE_LANGUAGES = arg ast cat fra glg hat ita lat lmo nap pms por ron spa vec wln
# We do not have any specific model for Semitic languages and we will process them together with Indo-European.
W2C_INDO_EUROPEAN_LANGUAGES = bre cym gla gle ell hye sqi diq fas glk kur tgk ben bpy guj hif hin mar nep urd amh ara arz heb epo ido ina vol
W2C_AGGLUTINATING_LANGUAGES = est fin hun eus kat chv aze tur uzb kaz tat sah kor mon tel kan mal tam
W2C_OTHER_LANGUAGES = new vie ind jav mlg mri msa pam sun tgl war swa
W2C_LANGUAGES_EXCEPT_GSW = $(W2C_BALTOSLAVIC_LANGUAGES) $(W2C_GERMANIC_LANGUAGES_EXCEPT_GSW) $(W2C_ROMANCE_LANGUAGES) $(W2C_INDO_EUROPEAN_LANGUAGES) $(W2C_AGGLUTINATING_LANGUAGES) new vie ind jav mlg mri msa pam sun tgl war swa epo ido ina vol
W2C_LANGUAGES = gsw $(W2C_LANGUAGES_EXCEPT_GSW)

ANYWHERE = -q 'all.q@*,ms-all.q@*,troja-all.q@*'

w2c_to_conll:
	@mkdir -p data/w2c
	@zcat $(W2C_DIR)/als.txt.gz | ./text_to_conll.pl | ./filter.pl gsw | head -1000000 > data/w2c/gsw.conll
	@echo -n "als=>gsw "
	@for l in $(W2C_LANGUAGES_EXCEPT_GSW); do \
		zcat $(W2C_DIR)/$$l.txt.gz | ./text_to_conll.pl | ./filter.pl $$l | head -1000000 > data/w2c/$$l.conll; \
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

ud_to_conll:
	@mkdir -p data/ud
	@for l in $(UD_LANGUAGES); do \
		mkdir -p data/ud/$$l/train; \
		mkdir -p data/ud/$$l/dev; \
		mkdir -p data/ud/$$l/test; \
		cat $(UD_DIR)/*/$$l-ud-train*.conllu | ./clean_conllu.pl > data/ud/$$l/train/$$l.conll; \
		cat $(UD_DIR)/*/$$l-ud-dev*.conllu | ./clean_conllu.pl > data/ud/$$l/dev/$$l.conll; \
		cat $(UD_DIR)/*/$$l-ud-test*.conllu | ./clean_conllu.pl > data/ud/$$l/test/$$l.conll; \
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
	@mkdir -p log
	@for l in $(UD_LANGUAGES); do \
		./fill_langcode.pl "python get_featurefromw2c.py data/ud/XX/train/XX.conll data/w2c/XXX.conll 20000000 data/ud/XX/train/XX.feat" $$l >  log/$$l-features.sh; \
		./fill_langcode.pl "python get_featurefromw2c.py data/ud/XX/dev/XX.conll   data/w2c/XXX.conll 20000000 data/ud/XX/dev/XX.feat"   $$l >> log/$$l-features.sh; \
		./fill_langcode.pl "python get_featurefromw2c.py data/ud/XX/test/XX.conll  data/w2c/XXX.conll 20000000 data/ud/XX/test/XX.feat"  $$l >> log/$$l-features.sh; \
		qsub $(ANYWHERE) -hard -l mf=10g -l act_mem_free=10g -j yes -o log -cwd log/$$l-features.sh; \
	done

generate_features_w2c:
	@mkdir -p log
	@for l in $(W2C_LANGUAGES); do \
		echo python get_featurefromw2c.py data/w2c/$$l.conll data/w2c/$$l.conll 20000000 data/w2c/$$l.feat > log/$$l-features-w2c.sh; \
		echo rm data/w2c/$$l.feat.oov >> log/$$l-features-w2c.sh; \
		qsub $(ANYWHERE) -hard -l mf=10g -l act_mem_free=10g -j yes -o log -cwd log/$$l-features-w2c.sh; \
	done

# Prepares training data for the classifier. For each target language the training data of this language is left out.
# Training data of all other languages are concatenated (the first 30,000 tokens per language only).
leave_one_out:
	./leave1out.pl hamledt $(HAMLEDT_LANGUAGES)
	./leave1out.pl $(UD_LANGUAGES)

# Train a model that will be reused to tag multiple languages.
# Save the model as a Python pickle file. Do not do the tagging.
svm_train:
	@for l in $(UD_LANGUAGES); do \
		echo "./svm-train.py data/ud/$$l/train/$$l.feat data/ud/$$l/train/$$l.p" > log/$$l-svmtrain.sh; \
		qsub $(ANYWHERE) -hard -l mf=30g -l act_mem_free=30g -j yes -o log/$$l-svmtrain.o -cwd log/$$l-svmtrain.sh; \
		for c in all c7 csla cger crom cine cagl; do \
			echo "./svm-train.py data/ud/$$l/multitrain/$$c.feat data/ud/$$l/multitrain/$$c.p" > log/$$l-$$c-svmtrain.sh; \
			qsub $(ANYWHERE) -hard -l mf=30g -l act_mem_free=30g -j yes -o log/$$l-$$c-svmtrain.o -cwd log/$$l-$$c-svmtrain.sh; \
		done; \
	done

# The output from Zhiwei's tagger (the .pred file) omits sentence boundaries and has a special section with OOV words at the end.
# The script merge_output.pl will restore it as a CoNLL-X file and at the same time it will compute tagging accuracy.
# However, it will not restore the original CoNLL file with all the dependency annotation, ready for further processing.
# That's why we subsequently call merge2.pl.
svm_tag:
	@for l in $(UD_LANGUAGES); do \
		echo "./svm-tag.py data/ud/$$l/train/$$l.p data/ud/$$l/dev/$$l.feat data/ud/$$l/dev/$$l-$$l.pred" > log/$$l-$$l-svmtag.sh; \
		echo "./merge_output.pl data/ud/$$l/dev/$$l.conll data/ud/$$l/dev/$$l-$$l.pred > data/ud/$$l/dev/$$l-$$l.conll" >> log/$$l-$$l-svmtag.sh; \
		echo "./merge2.pl data/ud/$$l/dev/$$l.conll data/ud/$$l/dev/$$l-$$l.conll > data/ud/$$l/dev/$$l-$$l.2.conll" >> log/$$l-$$l-svmtag.sh; \
		qsub $(ANYWHERE) -hard -l mf=30g -l act_mem_free=30g -j yes -o log/$$l-$$l-svmtag.o -cwd log/$$l-$$l-svmtag.sh; \
		for c in all c7 csla cger crom cine cagl; do \
			echo "./svm-tag.py data/ud/$$l/multitrain/$$c.p data/ud/$$l/dev/$$l.feat data/ud/$$l/dev/$$c-$$l.pred" > log/$$c-$$l-svmtag.sh; \
			echo "./merge_output.pl data/ud/$$l/dev/$$l.conll data/ud/$$l/dev/$$c-$$l.pred > data/ud/$$l/dev/$$c-$$l.conll" >> log/$$c-$$l-svmtag.sh; \
			echo "./merge2.pl data/ud/$$l/dev/$$l.conll data/ud/$$l/dev/$$c-$$l.conll > data/ud/$$l/dev/$$c-$$l.2.conll" >> log/$$c-$$l-svmtag.sh; \
			qsub $(ANYWHERE) -hard -l mf=30g -l act_mem_free=30g -j yes -o log/$$c-$$l-svmtag.o -cwd log/$$c-$$l-svmtag.sh; \
		done; \
	done

# We have to tag the training data as well. We will need them for delexicalized parsing.
# There is no conflict because the delexicalized tagger for the language has never been trained on the same language (we omit the $$l-$$l model in this case).
svm_tag_training_data:
	@for l in $(UD_LANGUAGES); do \
		for c in all c7 csla cger crom cine cagl; do \
			echo "./svm-tag.py data/ud/$$l/multitrain/$$c.p data/ud/$$l/train/$$l.feat data/ud/$$l/train/$$c-$$l.pred" > log/$$c-$$l-svmtagtrdata.sh; \
			echo "./merge_output.pl data/ud/$$l/train/$$l.conll data/ud/$$l/train/$$c-$$l.pred > data/ud/$$l/train/$$c-$$l.conll" >> log/$$c-$$l-svmtagtrdata.sh; \
			echo "./merge2.pl data/ud/$$l/train/$$l.conll data/ud/$$l/train/$$c-$$l.conll > data/ud/$$l/train/$$c-$$l.2.conll" >> log/$$c-$$l-svmtagtrdata.sh; \
			qsub $(ANYWHERE) -hard -l mf=30g -l act_mem_free=30g -j yes -o log/$$c-$$l-svmtagtrdata.o -cwd log/$$c-$$l-svmtagtrdata.sh; \
		done; \
	done

# And this is how we tag the W2C data and create Deltacorpus.
# We don't really need to exclude the target language from the source in this case because the result will not be used for evaluation.
# And we want the output as good as possible.
# We could create a separate set of models where no language was excluded but that would be an extra effort that is not absolutely needed.
# Instead, we will use the models for Latin. The three Latin treebanks will be excluded, which probably does not hurt too much, they are not too consistent anyway.
svm_tag_w2c:
	@for l in $(W2C_LANGUAGES); do \
		for c in all cine csla cger crom cagl; do \
			echo "./svm-tag.py data/ud/la/multitrain/$$c.p data/w2c/$$l.feat data/w2c/$$c-$$l.pred" > log/$$c-$$l-svmtagtrdata.sh; \
			echo "./merge_output.pl data/w2c/$$l.conll data/w2c/$$c-$$l.pred > data/w2c/$$c-$$l.conll" >> log/$$c-$$l-svmtagtrdata.sh; \
			echo "./merge2.pl data/w2c/$$l.conll data/w2c/$$c-$$l.conll > data/w2c/$$c-$$l.2.conll" >> log/$$c-$$l-svmtagtrdata.sh; \
			qsub $(ANYWHERE) -hard -l mf=30g -l act_mem_free=30g -j yes -o log/$$c-$$l-svmtagtrdata.o -cwd log/$$c-$$l-svmtagtrdata.sh; \
		done; \
	done
