-include $(TARGET_PLATFORMDIR)/.config
include $(PRJ_PATH)/configs/config.mk

HTTPFS_SRCDIR = $(shell pwd)
HTTPFS_ARCHIVE = $(wildcard httpfs*.tar.gz)
HTTPFS_VER    = $(patsubst httpfs%.tar.gz,%,$(HTTPFS_ARCHIVE))
HTTPFS_OUT = $(patsubst $(PRJ_PATH)/%,$(OUT_DIR)/%,$(HTTPFS_SRCDIR))
HTTPFS_BLD = $(HTTPFS_OUT)/$(HTTPFS_ARCHIVE:%.tar.gz=%)
HTTPFS_PATCHES=$(sort $(wildcard $(HTTPFS_SRCDIR)/patch/*.patch))
FAKEROOT = $(HTTPFS_OUT)/fake_root


SRC_FILE = httpfs2.c

CFLAGS = -L$(BUILD_SYSROOT)/usr/lib -I$(BUILD_SYSROOT)/usr/include/fuse -I$(TC_LOCAL)/usr/include -I$(BUILD_SYSROOT)/usr/include \
          -D_FILE_OFFSET_BITS=64 -D_GNU_SOURCE -D__USE_XOPEN -DUSE_THREAD -DUSE_SSL -DUSE_AUTH

LDFLAGS += -lfuse -lrt -lm -lpthread -lssl -lcrypto -lpcre -lsafec#-lssl -lcrypto

all:
	$(Q)echo "==================== build httpfs ====================";
	$(Q)echo $(HTTPFS_BLD) ;
	$(Q)mkdir -p $(HTTPFS_OUT);
	$(Q)if [ ! -d $(HTTPFS_BLD) ]; then \
		tar xf $(HTTPFS_ARCHIVE) -C $(HTTPFS_OUT); \
		cd $(HTTPFS_BLD); \
		for i in $(HTTPFS_PATCHES); do \
			patch -p1 < $$i; \
		done; \
	fi
	$(Q)if [ -e $(HTTPFS_BLD) ]; then \
		cd $(HTTPFS_BLD); \
		echo $(CC) $(CFLAGS) $(LDFLAGS) $(SRC_FILE) "-o httpfs2"; \
		$(CC) $(CFLAGS) $(LDFLAGS) $(SRC_FILE) -o httpfs2; \
	fi

install:
	$(Q)echo "================ install httpfs ================";
	$(Q)mkdir -p $(FAKEROOT)/usr/bin
	$(Q)cp $(HTTPFS_BLD)/httpfs2 $(FAKEROOT)/usr/bin
	$(Q)cp $(HTTPFS_BLD)/httpfs2 $(FAKEROOT)
	$(Q)cp -avu $(FAKEROOT)/* $(BUILD_SYSROOT)/usr/bin/
	$(Q)echo "================ install httpfs done ================"

CLEAN_FILES = $(HTTPFS_BLD) $(FAKEROOT)
include $(PRJ_PATH)/PKConfig/Lx_Script/clean.mk

include $(PRJ_PATH)/PKConfig/Lx_Script/Extract.mk
