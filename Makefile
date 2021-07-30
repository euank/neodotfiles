
.PHONY: help
help:
	@echo "Targets: "
	@echo -e "\thelp     This output"
	@echo -e "\tupdate   Update flake lockfile"
	@echo ""

.PHONY:
update:
	nix run '.#nix-flake-update'
