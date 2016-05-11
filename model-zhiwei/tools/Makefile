TRAIN_LANGUAGES = bg ca cs de el en hi hu it pt ru sv tr
LANGUAGES = bg bn ca cs da de el es en et eu fa fi hi hu it la nl pt ro ru sk sl sv te tr
#TRAIN_LANGUAGES = bg ca de el hi hu tr
#LANGUAGES = bn cs da es en et eu fa fi it la nl pt ro ru sk sl sv te

NAME2=a
TOKENS=10000000

conll:
	mkdir data/conll-test-1k
	for l in $(LANGUAGES); do \
		zcat /net/data/hamledt/$$l/stanford/test/*.conll.gz | head -1000 > data/conll-test-1k/$$l.conll; \
	done
	mkdir data/conll-train-50k
	for l in $(TRAIN_LANGUAGES); do \
		zcat /net/data/hamledt/$$l/stanford/train/*.conll.gz | head -50000 > data/conll-train-50k/$$l.conll; \
	done
	mkdir data/conll-train
	for l in $(TRAIN_LANGUAGES); do \
		zcat /net/data/hamledt/$$l/stanford/train/*.conll.gz > data/conll-train/$$l.conll; \
	done	

w2c:
	mkdir data/w2c-1Mlines
	for l in $(LANGUAGES); do \
		./unpack_w2c.pl $$l 1000000 data/w2c-1Mlines/$$l.txt; \
	done

pokus:
	cat data/conll-train-50k/cs.conll | head -1000 > d
	./get_statistics.pl d data/w2c-1Mlines/cs.txt 0 1000000 > o

stats_name:
	mkdir -p data/stats$(NAME)-test-1k
	for l in $(LANGUAGES); do \
		echo "./get_statistics.pl data/conll-test-1k/$$l.conll data/w2c-1Mlines/$$l.txt 0 $(TOKENS) $$l > data/stats$(NAME)-test-1k/$$l.data 2> $$l.stats.test.err" > $$l.test.sh; \
		qsub -hard -l mf=30g -l act_mem_free=30g -cwd -o /dev/null -e /dev/null $$l.test.sh; \
	done
	mkdir -p data/stats$(NAME)-train-50k
	for l in $(TRAIN_LANGUAGES); do \
		echo "./get_statistics.pl data/conll-train-50k/$$l.conll data/w2c-1Mlines/$$l.txt 0 $(TOKENS) $$l > data/stats$(NAME)-train-50k/$$l.data 2> $$l.stats.test.err" > $$l.train.sh; \
		qsub -hard -l mf=50g -l act_mem_free=50g -cwd -o /dev/null -e /dev/null $$l.train.sh; \
	done

stats9:
	mkdir data/stats9-test-1k
	for l in $(LANGUAGES); do \
		echo "./get_statistics.pl data/conll-test-1k/$$l.conll data/w2c-1Mlines/$$l.txt 0 > data/stats9-test-1k/$$l.data 2> $$l.stats.test.err" > $$l.test.sh; \
		qsub -hard -l mf=30g -l act_mem_free=30g -cwd -o /dev/null -e /dev/null $$l.test.sh; \
	done
	mkdir data/stats9-train-50k
	for l in $(TRAIN_LANGUAGES); do \
		echo "./get_statistics.pl data/conll-train-50k/$$l.conll data/w2c-1Mlines/$$l.txt 0 > data/stats9-train-50k/$$l.data 2> $$l.stats.test.err" > $$l.train.sh; \
		qsub -hard -l mf=50g -l act_mem_free=50g -cwd -o /dev/null -e /dev/null $$l.train.sh; \
	done
	mkdir data/stats9-train
	for l in $(TRAIN_LANGUAGES); do \
		echo "./get_statistics.pl data/conll-train/$$l.conll data/w2c-1Mlines/$$l.txt 0 > data/stats9-train/$$l.data 2> $$l.stats.test.err" > $$l.train.sh; \
		qsub -hard -l mf=50g -l act_mem_free=50g -cwd -o /dev/null -e /dev/null $$l.train.sh; \
	done

statsX:
	mkdir -p data/statsX-train-50k
	for l in $(TRAIN_LANGUAGES); do \
		echo "./get_statistics.pl data/conll-train-50k/$$l.conll data/w2c-1Mlines/$$l.txt 0 > data/statsX-train-50k/$$l.data 2> $$l.stats.test.err" > $$l.train.sh; \
		qsub -hard -l mf=50g -l act_mem_free=50g -cwd -o /dev/null -e /dev/null $$l.train.sh; \
	done

join_data:
	mkdir -p data/stats11-train-joined
	cd data/stats11-train-50k; cat bg.data ca.data de.data el.data hi.data hu.data tr.data > ../stats11-train-joined/c1.data

join_data_name:
	mkdir -p data/stats$(NAME)-train-joined
	cd data/stats$(NAME)-train-50k; cat bg.data ca.data de.data el.data hi.data hu.data > ../stats$(NAME)-train-joined/c1.data

knn_matrix:
	mkdir -p data/knn9-50k
	@for l1 in $(TRAIN_LANGUAGES); do \
		for l2 in $(LANGUAGES); do \
			echo "./knn_classifier.pl data/stats9-train-50k/$$l1.data data/stats9-test-1k/$$l2.data > data/knn9-50k/$$l1-$$l2.output 2> data/knn9-50k/$$l1-$$l2.results" > $$l1-$$l2.knn.sh; \
			qsub -hard -l mf=5g -l act_mem_free=5g -cwd -o /dev/null -e /dev/null $$l1-$$l2.knn.sh; \
		done; \
	done
	mkdir -p data/knn9
	@for l1 in $(TRAIN_LANGUAGES); do \
		for l2 in $(LANGUAGES); do \
			echo "./knn_classifier.pl data/stats9-train/$$l1.data data/stats9-test-1k/$$l2.data > data/knn9/$$l1-$$l2.output 2> data/knn9/$$l1-$$l2.results" > $$l1-$$l2.knn.sh; \
			qsub -hard -l mf=5g -l act_mem_free=5g -cwd -o /dev/null -e /dev/null $$l1-$$l2.knn.sh; \
		done; \
	done

knn_matrix_name:
	mkdir -p data/knn$(NAME)-50k
	@for l1 in $(TRAIN_LANGUAGES); do \
		for l2 in $(LANGUAGES); do \
			echo "./knn_classifier.pl data/stats9-train-50k/$$l1.data data/stats$(NAME)-test-1k/$$l2.data > data/knn$(NAME)-50k/$$l1-$$l2.output 2> data/knn$(NAME)-50k/$$l1-$$l2.results" > $$l1-$$l2.knn.sh; \
			qsub -hard -l mf=5g -l act_mem_free=5g -cwd -o /dev/null -e /dev/null $$l1-$$l2.knn.sh; \
		done; \
	done

knn_joined:
	mkdir -p data/knn9-joined
	@for l1 in c1; do \
		for l2 in $(LANGUAGES); do \
			echo "./knn_classifier.pl data/stats9-train-joined/$$l1.data data/stats9-test-1k/$$l2.data > data/knn9-joined/$$l1-$$l2.output 2> data/knn9-joined/$$l1-$$l2.results" > $$l1-$$l2.knn.sh; \
			qsub -hard -l mf=5g -l act_mem_free=5g -cwd -o /dev/null -e /dev/null $$l1-$$l2.knn.sh; \
		done; \
	done

knn_joined_name:
	mkdir -p data/knn$(NAME)$(NAME2)-joined
	@for l1 in c1; do \
		for l2 in $(LANGUAGES); do \
			echo "./knn_classifier.pl data/stats$(NAME)-train-joined/$$l1.data data/stats$(NAME)-test-1k/$$l2.data > data/knn$(NAME)$(NAME2)-joined/$$l1-$$l2.output 2> data/knn$(NAME)$(NAME2)-joined/$$l1-$$l2.results" > $$l1-$$l2.knn.sh; \
			qsub -hard -l mf=5g -l act_mem_free=5g -cwd -o /dev/null -e /dev/null $$l1-$$l2.knn.sh; \
		done; \
	done

tag:
	mkdir -p data/tagged$(NAME)$(NAME2)-joined
	@for l1 in c1; do \
		for l2 in $(LANGUAGES); do \
			./tag.pl data/knn$(NAME)$(NAME2)-joined/$$l1-$$l2.output data/conll-test-1k/$$l2.conll > data/tagged$(NAME)$(NAME2)-joined/$$l1-$$l2.conll; \
		done; \
	done

eval:
	@for l1 in c1; do \
		for l2 in $(LANGUAGES); do \
			echo $$l2; \
			./eval.pl data/conll-test-1k/$$l2.conll data/tagged$(NAME)$(NAME2)-joined/$$l1-$$l2.conll; \
		done; \
	done

initialize_results:
	for l in $(LANGUAGES) avg; do \
		echo -n " $$l" >> results.txt; \
	done

NAME = jako_v_clanku_k=100_count-tokens_+tr

experiment:
	mkdir data/experiments/$(NAME)
	for l in $(LANGUAGES); do \
		echo "./knn_classifier.pl --train data/stats11-train-joined/c1.data --test data/stats11-test-1k/$$l.data \
		      --k 100 --weights 1,1,1,1,1,5,5,1,1,0,0 --count-tokens > data/experiments/$(NAME)/$$l.output \
			  2> data/experiments/$(NAME)/$$l.log" > data/experiments/$(NAME)/$$l.knn.sh; \
		echo "./tag.pl data/experiments/$(NAME)/$$l.output data/conll-test-1k/$$l.conll \
		      > data/experiments/$(NAME)/$$l.tagged 2>> data/experiments/$(NAME)/$$l.log" >> data/experiments/$(NAME)/$$l.knn.sh; \
		qsub -hard -l mf=5g -l act_mem_free=5g -cwd -o /dev/null -e /dev/null data/experiments/$(NAME)/$$l.knn.sh; \
	done

experiment_eval:
	./eval_all.pl --gold-dir data/conll-test-1k --gold-suffix .conll --predicted-dir data/experiments/$(NAME) \
		--predicted-suffix .tagged --languages "$(LANGUAGES)" --description $(NAME) >> results.txt 

tnt_lex_model:
	mkdir -p data/tnt-models
	@for l2 in $(LANGUAGES); do \
		echo "./get_knn.pl data/statsLANG-train-joined/c1.data data/statsLANG-test-1k/$$l2.data data/tnt-models/c1-$$l2.log > data/tnt-models/c1-$$l2.lex 2> err" > c1-$$l2.lex.sh; \
		qsub -hard -l mf=5g -l act_mem_free=5g -cwd -o /dev/null -e /dev/null c1-$$l2.lex.sh; \
	done

tnt_123_model:
	cd data/conll-train-50k; cat bg.conll ca.conll de.conll el.conll hi.conll hu.conll tr.conll | cut -f2,4 > ../../corpus.tmp
	/home/marecek/tectomt/share/external_tools/tnt_tagger/tnt/tnt-para -o model corpus.tmp
	@for l2 in $(LANGUAGES); do \
		cp model.123 data/tnt-models/c1-$$l2.123; \
	done

tnt_tag:
	mkdir -p data/tnt-outputs
	rm results
	@for l2 in $(LANGUAGES); do \
		cat data/conll-test-1k/$$l2.conll | ./conll_lowercase.pl | cut -f2 > forms.tmp; \
		/home/marecek/tectomt/share/external_tools/tnt_tagger/tnt/tnt -n1 -m data/tnt-models/c1-$$l2 forms.tmp | ./unknown_words_postprocessing.pl > data/tnt-outputs/c1-$$l2.tnt; \
		echo "$$l2:" >> results; \
		./tnt_eval.pl data/conll-test-1k/$$l2.conll data/tnt-outputs/c1-$$l2.tnt >> results; \
		rm forms.tmp; \
	done

	
	



svm_train:
	mkdir data/svm9-models
	@for l in $(TRAIN_LANGUAGES); do \
		echo "training $$l"; \
		./svm_train.pl data/stats9-train-50k/$$l.data data/svm9-models/$$l.model; \
	done
	./svm_train.pl data/stats9-train-joined/c1.data data/svm9-models/c1.model; \


svm_matrix:
	mkdir -p data/svm9-50k
	@for l1 in $(TRAIN_LANGUAGES); do \
		for l2 in $(LANGUAGES); do \
			./svm_predict.pl data/stats9-test-1k/$$l2.data data/svm9-models/$$l1.model > data/svm9-50k/$$l1-$$l2.output 2> data/svm9-50k/$$l1-$$l2.results; \
		done; \
	done

svm_joined:
	mkdir -p data/svm9-joined
	@for l1 in c1; do \
		for l2 in $(LANGUAGES); do \
			./svm_predict.pl data/stats9-test-1k/$$l2.data data/svm9-models/$$l1.model > data/svm9-joined/$$l1-$$l2.output 2> data/svm9-joined/$$l1-$$l2.results; \
		done; \
	done

sim:
	for l2 in $(LANGUAGES); do \
		echo "$$l2"; \
		cat data/tnt-models/c1-$$l2.log | ./language_similarity.pl; \
	done

results:
	@echo; echo "KNN-1M:" 
	@./show_results.pl data/knn1M-50k $(TRAIN_LANGUAGES) - $(LANGUAGES)
	@echo; echo "KNN-1MW:" 
	@./show_results.pl data/knn10Mnew-50k $(TRAIN_LANGUAGES) - $(LANGUAGES)
	@echo; echo "KNN-10Mnew:" 
	@./show_results.pl data/knn1MW-50k $(TRAIN_LANGUAGES) - $(LANGUAGES)
	@echo; echo "KNN (trained on bg,ca,de,el,hi,hu,tr):"
	@./show_results.pl data/knn9-joined c1 - $(LANGUAGES)
	@echo; echo "KNN-100M (trained on bg,ca,de,el,hi,hu,tr):" 
	@./show_results.pl data/knn100M-joined c1 - $(LANGUAGES)
	@echo; echo "KNN-10M-new (trained on bg,ca,de,el,hi,hu,tr):" 
	@./show_results.pl data/knn10Mnew-joined c1 - $(LANGUAGES)
	@echo; echo "KNN-10M (trained on bg,ca,de,el,hi,hu,tr):" 
	@./show_results.pl data/knn10M-joined c1 - $(LANGUAGES)
	@echo; echo "KNN-1M (trained on bg,ca,de,el,hi,hu,tr):" 
	@./show_results.pl data/knn1M-joined c1 - $(LANGUAGES)
	@echo; echo "KNN-100k (trained on bg,ca,de,el,hi,hu,tr):"
	@./show_results.pl data/knn100k-joined c1 - $(LANGUAGES)
	@echo; echo "KNN-10k (trained on bg,ca,de,el,hi,hu,tr):"
	@./show_results.pl data/knn10k-joined c1 - $(LANGUAGES)

results2:
	@echo "SVM:" 
	@./show_results.pl data/knn9-50k $(TRAIN_LANGUAGES) - $(LANGUAGES)
	@echo; echo "KNN-1MW:" 
	@./show_results.pl data/knn1M-50k $(TRAIN_LANGUAGES) - $(LANGUAGES)
	@echo; echo "KNN (whole training data):"
	@./show_results.pl data/knn9 $(TRAIN_LANGUAGES) - $(LANGUAGES)
	@echo; echo "KNN11 (whole training data):"
	@./show_results.pl data/knn11-joined c1 - $(LANGUAGES)
	@echo; echo "KNN (trained on bg,ca,de,el,hi,hu,tr):"
	@./show_results.pl data/knn9-joined c1 - $(LANGUAGES)
	@echo; echo "KNN-1M (trained on bg,ca,de,el,hi,hu,tr):"
	@./show_results.pl data/knn1MW-joined c1 - $(LANGUAGES)
	@echo; echo "KNN-100k (trained on bg,ca,de,el,hi,hu,tr):"
	@./show_results.pl data/knn100k-joined c1 - $(LANGUAGES)


tex:
	@echo; echo "KNN:"
	@./tex_results.pl data/knn9-50k $(TRAIN_LANGUAGES) - $(LANGUAGES)
	@echo; echo "SVM (trained on bg,ca,de,el,hi,hu,tr):"
	@./show_results.pl data/svm9-joined c1 - $(LANGUAGES)
	@echo; echo "KNN (trained on bg,ca,de,el,hi,hu,tr):"
	@./show_results.pl data/knn9-joined c1 - $(LANGUAGES)




train_stats:
	zcat /net/data/hamledt/en/stanford/train/*.conll.gz > en.train.conll
	zcat $(W2C_DIR)/eng.txt.gz | head -1000000 > en.w2c.txt
	echo "./get_statistics.pl en.train.conll en.w2c.txt > en.nn.data 2> err" > run.sh
	qsub -hard -l mf=50g -l act_mem_free=50g -cwd -o /dev/null -e /dev/null run.sh

test_stats:
	zcat /net/data/hamledt/$(LANG)/stanford/test/*.conll.gz | head -1000 > $(LANG).test.small.conll
	zcat $(W2C_DIR)/$(LANG_LONG).txt.gz | head -1000000 > $(LANG).w2c.txt
	echo "./get_statistics.pl $(LANG).test.small.conll $(LANG).w2c.txt > $(LANG).test.small.nn.data 2> $(LANG).err" > $(LANG)-run.sh
	qsub -hard -l mf=30g -l act_mem_free=30g -cwd -o /dev/null -e /dev/null $(LANG)-run.sh

classify:
	./knn_classifier.pl data/de.train.norm.data data/en.test.small.norm.data > output

svm_train2:
	./svm_train.pl data/train9/bg-ca-de-hi.train.data data/models9/bg-ca-de-hi.model

svm_train_all:
	@for l in $(TRAIN_LANGUAGES); do \
		./svm_train.pl data/$$l.train.data data/$$l.model; \
	done

x:
	@for l in en cs; do \
		./svm_train.pl data/$$l.train.data data/$$l.model; \
	done

svm_predict:
	./svm_predict.pl /ta.test.small.data data/all.model > output

svm_predict_all:
	@for l1 in bg ca de el hi hu it ja pt ru sv ta tr; do \
		for l2 in $(LANGUAGES); do \
			./svm_predict.pl data/test9/$$l2.test.small.data data/models9/$$l1.model > data/svm9/$$l1-$$l2.output 2> data/svm9/$$l1-$$l2.results; \
		done; \
	done

svm_all:
	@for l2 in $(LANGUAGES); do \
		./svm_predict.pl data/$$l2.test.small.data all.train.model > data/all-$$l2.output; \
	done

classify_all:
	@for l1 in bg ca de el hi hu it ja pt ru sv ta tr; do \
		for l2 in $(LANGUAGES); do \
			echo "./knn_classifier.pl data/train9/$$l1.train.data data/test9/$$l2.test.small.data > data/knn9-pokus/$$l1-$$l2.output 2> data/knn9-pokus/$$l1-$$l2.results" > $$l1-$$l2.knn.sh; \
			qsub -hard -l mf=5g -l act_mem_free=5g -cwd -o /dev/null -e /dev/null $$l1-$$l2.knn.sh; \
		done; \
	done
		
classify_c4:
	@for l2 in $(LANGUAGES); do \
		echo "./knn_classifier.pl data/train9/bg-ca-de-hi.train.data data/test9/$$l2.test.small.data > data/knn9-pokus/c4-$$l2.output 2> data/knn9-pokus/c4-$$l2.results" > $$l2.knn.sh; \
		qsub -hard -l mf=5g -l act_mem_free=5g -cwd -o /dev/null -e /dev/null $$l2.knn.sh; \
	done

eval2:
	@for l2 in $(TEST3); do \
		cat data/$$l2.results; \
	done	

wc:
	cat de.w2c.txt | head -100000 | ./w2c_to_conll.pl | gzip > de.additional.gz
	zcat /net/data/hamledt/de/stanford/t*/*.conll.gz de.additional.gz | ./posinduction_wrapper.pl --clusters 50 --tmpdir tmp > de.wc.50

wc_classify:
	./knn_wc_classifier.pl en.nn.data de.test.small.nn.data de.wc.50 > output

