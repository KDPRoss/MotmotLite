KERNEL=motmot-lite-kernel.py

.PHONY: install uninstall
install: kernel.json
	sudo jupyter kernelspec install $(shell pwd)

kernel.json: $(KERNEL)
	echo "{ 'argv': [ 'python', '$(shell pwd)/$(KERNEL)', '-f', '{connection_file}' ], 'display_name': 'MotmotLite' }" | sed "s/'/\"/g" | jq . > $@

uninstall:
	yes | sudo jupyter kernelspec uninstall motmotlite-kernel
