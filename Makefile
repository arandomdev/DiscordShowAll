DEBUG = 0
FINALPACKAGE = 1

ARCHS = arm64

TARGET := iphone:clang:latest:13.0
INSTALL_TARGET_PROCESSES = Discord


include $(THEOS)/makefiles/common.mk

TWEAK_NAME = DiscordShowAll

DiscordShowAll_FILES = $(shell find ./ -type f -name '*.m') Tweak.xm
DiscordShowAll_CFLAGS = -fobjc-arc -D__USE_CFLOG -Wno-deprecated-declarations -Ipods -Ipods/PINRemoteImage/Classes/include -Ipods/PINRemoteImage/Classes/Categories -Ipods/PINRemoteImage/Classes

include $(THEOS_MAKE_PATH)/tweak.mk
