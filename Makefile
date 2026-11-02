# Kernels are cross-built on tron and pushed to /kernels from core, which holds the
# attic login. Do this before pushing a recipe: CI stops without them.
TRON ?= tron.netbird
ATTIC = nix shell nixpkgs\#attic-client -c attic
ATTIC_CACHE ?= home:kernels
KERNELS ?= $(shell nix eval --raw path:.\#kernels --apply 'k: builtins.concatStringsSep " " (builtins.attrNames k)')

.PHONY: kernels

kernels:
	@set -e; for name in $(KERNELS); do \
		drv=$$(nix eval --raw path:.#kernels.$$name.drvPath); \
		out=$$(nix eval --raw path:.#kernels.$$name.outPath); \
		modules=$$(nix eval --raw path:.#kernels.$$name.modules.outPath); \
		config=$$(nix eval --raw path:.#kernels.$$name.configfile.outPath 2>/dev/null || true); \
		configdrv=$$(nix eval --raw path:.#kernels.$$name.configfile.drvPath 2>/dev/null || true); \
		echo "== $$name: $$out"; \
		nix copy --no-check-sigs --derivation --to ssh-ng://$(TRON) $$drv $$configdrv; \
		ssh -t $(TRON) nix build --no-link -L "$$drv^out,modules" $${configdrv:+"$$configdrv^out"}; \
		nix copy --no-check-sigs --from ssh-ng://$(TRON) $$out $$modules $$config; \
		$(ATTIC) push $(ATTIC_CACHE) --no-closure $$out $$modules $$config; \
	done
