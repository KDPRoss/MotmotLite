#!/bin/sh

apk add bash g++ git gmp-dev make opam rlwrap && \
yes | opam init --bare --disable-sandboxing && \
yes | opam switch create 4.14.1 && \
opam switch 4.14.1 && \
opam install core extlib zarith -y && \
eval $(opam env) && \
cd / && \
git clone https://github.com/KDPRoss/MotmotLite.git && \
cd MotmotLite && \
make MotmotLite && \
rm -rf ~/.opam && \
apk del bash g++ git make opam && \
cd /MotmotLite && \
rm /MotmotLite/*.ml && \
rm /MotmotLite/*.t && \
rm /MotmotLite/*.md && \
rm -rf /MotmotLite/docker && \
rm -rf /MotmotLite/jupyter && \
echo "#!/bin/sh" > /motmot && \
echo "rlwrap /MotmotLite/MotmotLite" >> /motmot && \
chmod u+x /motmot
