INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = ccshakelayout
ccshakelayout_FILES = Tweak.x
ccshakelayout_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
