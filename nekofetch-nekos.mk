ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS             += nekofetch-nekos
NEKOFETCH-NEKOS_COMMIT  := dbf35c9b6671f61d7dabc51929b8afa0125dfb33
NEKOFETCH-NEKOS_VERSION := 1.0+git20210529.$(shell echo $(NEKOFETCH-NEKOS_COMMIT) | cut -c -7)
DEB_NEKOFETCH-NEKOS_V   ?= $(NEKOFETCH-NEKOS_VERSION)

nekofetch-nekos-setup: setup
	$(call GITHUB_ARCHIVE,BBaoVanC,nekofetch-nekos,$(NEKOFETCH-NEKOS_COMMIT),$(NEKOFETCH-NEKOS_COMMIT))
	$(call EXTRACT_TAR,nekofetch-nekos-$(NEKOFETCH-NEKOS_COMMIT).tar.gz,nekofetch-nekos-$(NEKOFETCH-NEKOS_COMMIT),nekofetch-nekos)

ifneq ($(wildcard $(BUILD_WORK)/nekofetch-nekos/.build_complete),)
nekofetch-nekos:
	@echo "Using previously built nekofetch-nekos."
else
nekofetch-nekos: nekofetch-nekos-setup
	+$(MAKE) -C $(BUILD_WORK)/nekofetch-nekos install \
		PREFIX=$(MEMO_PREFIX)$(MEMO_SUB_PREFIX) \
		DESTDIR=$(BUILD_STAGE)/nekofetch-nekos
	touch $(BUILD_WORK)/nekofetch-nekos/.build_complete
endif

nekofetch-nekos-package: nekofetch-nekos-stage
	# nekofetch-nekos.mk Package Structure
	rm -rf $(BUILD_DIST)/nekofetch-nekos

	# nekofetch-nekos.mk Prep nekofetch
	cp -a $(BUILD_STAGE)/nekofetch-nekos $(BUILD_DIST)

	# nekofetch-nekos.mk Make .debs
	$(call PACK,nekofetch-nekos,DEB_NEKOFETCH-NEKOS_V)

	# nekofetch-nekos.mk Build cleanup
	rm -rf $(BUILD_DIST)/nekofetch-nekos

.PHONY: nekofetch-nekos nekofetch-nekos-package
