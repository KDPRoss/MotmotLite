#!/bin/sh

set -eu

OPAM_SWITCH=5.2.0

apk add bash g++ git gmp-dev make opam rlwrap
opam init --bare --disable-sandboxing --yes --confirm-level=unsafe-yes --disable-shell-hook
yes | opam switch create "$OPAM_SWITCH"
opam switch "$OPAM_SWITCH"
opam install core extlib zarith -y
eval "$( opam env )"
cd /
git clone https://github.com/KDPRoss/MotmotLite.git
cd MotmotLite
make MotmotLite
rm -rf ~/.opam
apk del bash g++ git make opam
cd /MotmotLite
rm /MotmotLite/*.ml
rm /MotmotLite/*.t
rm /MotmotLite/*.md
rm -rf /MotmotLite/docker
rm -rf /MotmotLite/jupyter
echo "#!/bin/sh" > /motmot
echo "rlwrap /MotmotLite/MotmotLite" >> /motmot
chmod u+x /motmot
