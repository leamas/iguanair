
VERSION                = 0.1.d1a3474
RELEASE                = -1

DSC_FILE               = ./iguanair_$(VERSION)$(RELEASE).dsc
DEBIAN_TAR             = ./iguanair_$(VERSION)$(RELEASE).debian.tar.xz
SOURCE_CHANGES         = ./iguanair_$(VERSION)$(RELEASE)_source.changes
SOURCE_BUILD           = ./iguanair_$(VERSION)$(RELEASE)_source.build
ORIG_TAR               = ./iguanair_$(VERSION).orig.tar.gz

TARBALL                = iguanaIR-$(VERSION)-src.tar.gz

all: tarball 

tarball:  $(DSC_FILE) $(DEBIAN_TAR) $(DSC_FILE) $(SOURCE_CHANGES) $(SOURCE_BUILD) $(ORIG_TAR)
	tar czf $(TARBALL) $^
