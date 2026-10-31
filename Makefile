# Kernels are cross-built on tron and pushed to /kernels from this machine, which
# holds the attic login. Do this before pushing a recipe: CI stops without them.
TRON ?= tron.netbird
ATTIC = nix shell nixpkgs\#attic-client -c attic

.PHONY: kernels

kernels:
	@set -e; for name in $$(nix eval --raw .#kernels --apply 'k: builtins.concatStringsSep " " (builtins.attrNames k)'); do \
		drv=$$(nix eval --raw .#kernels.$$name.drvPath); \
		out=$$(nix eval --raw .#kernels.$$name.outPath); \
		modules=$$(nix eval --raw .#kernels.$$name.modules.outPath); \
		echo "== $$name: $$out"; \
		nix copy --no-check-sigs --derivation --to ssh-ng://$(TRON) $$drv; \
		ssh -t $(TRON) nix build --no-link -L "$$drv^out,modules"; \
		nix copy --no-check-sigs --from ssh-ng://$(TRON) $$out $$modules; \
		$(ATTIC) push home:kernels --no-closure $$out $$modules; \
	done
