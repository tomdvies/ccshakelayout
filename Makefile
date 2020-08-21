INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk
export SDKVERSION = 13.5
TWEAK_NAME = ccshakelayout
ccshakelayout_FILES = CCUIModuleHook.xm ManagerHook.xm StatusBarHook.xm
ccshakelayout_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
