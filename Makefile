# -- ===== Variables ==== --

BUILD_DIR=_build
EXEC=MotmotLite



# -- ===== Top-Level Targets ===== --

.PHONY: default
default: clean build test

.PHONY: build
build: $(EXEC)

.PHONY: run
run: build
	rlwrap ./$(EXEC)

.PHONY: test
test: $(EXEC)
	cram -v *.t



# -- ===== Build Targets ===== --

$(EXEC): *.ml
	rm -f $(EXEC) \#*
	dune build ./$(EXEC).exe --release && \
	ln -s _build/default/$(EXEC).exe $(EXEC)



# ===== Utility Targets ===== --

.PHONY: clean
clean:
	rm -rf *.cache *cmi *cmo *.cmi *.cmx *.o *~ \#* *.tex *.log *.dvi *.bbl *.aux *.ps *.blg *.pdf *.bak *.cache $(EXEC) $(BUILD_DIR)
