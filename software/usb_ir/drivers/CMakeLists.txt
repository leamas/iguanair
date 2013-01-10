Set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fvisibility=default")
#Set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -Wl,-undefined,dynamic_lookup")

# build a driver that uses libusb version 1.0 or later
add_library(usb SHARED libusb.c ../list.c)
target_link_libraries(usb -lusb-1.0)

# build a driver that uses libusb pre version 1.0
#add_library(usbpre1 SHARED libusbpre1.c ../list.c)
#target_link_libraries(usbpre1 -lusb)