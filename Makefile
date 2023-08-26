# -- ===== Variables ==== --

BUILD_DIR=_build
EXEC=MotmotLite
DOCKER_ARCHIVE=motmot-lite-docker.tgz



# -- ===== Top-Level Targets ===== --

.PHONY: default
default: clean build run run-docker test

.PHONY: build
build: $(EXEC)

.PHONY: run
run: build
	rlwrap ./$(EXEC)

.PHONY: run-docker
run-docker: $(DOCKER_ARCHIVE)
	docker import $(DOCKER_ARCHIVE) && \
	docker run -it motmotlite /motmot

.PHONY: test
test: $(EXEC)
	cram -v *.t



# -- ===== Build Targets ===== --

$(EXEC): *.ml
	rm -f $(EXEC) \#*
	dune build ./$(EXEC).exe --release && \
	ln -s _build/default/$(EXEC).exe $(EXEC)

$(DOCKER_ARCHIVE):
	./build-docker-container.sh



# ===== Utility Targets ===== --

.PHONY: clean
clean:
	rm -rf *.cache *cmi *cmo *.cmi *.cmx *.o *~ \#* *.tex *.log *.dvi *.bbl *.aux *.ps *.blg *.pdf *.bak *.cache $(EXEC) $(BUILD_DIR)
