# AnyKernel3 Ramdisk Mod Script
# osm0sis @ xda-developers

## AnyKernel setup
# begin properties
properties() { '
#kernel.string=Styrofoam-Kernel By NadinSylaa
do.devicecheck=1
do.modules=0
do.systemless=1
do.cleanup=1
do.cleanuponabort=0
device.name1=pine
device.name2=olive
device.name3=olivewood
device.name4=olivelite
device.name5=onc
supported.versions=10,11
supported.patchlevels=
'; } # end properties

# shell variables
block=/dev/block/by-name/boot;
is_slot_device=0;
ramdisk_compression=auto;


## AnyKernel methods (DO NOT CHANGE)
# import patching functions/variables - see for reference
. tools/ak3-core.sh;


## AnyKernel file attributes
# set permissions/ownership for included ramdisk files
set_perm_recursive 0 0 755 644 $ramdisk/*;
set_perm_recursive 0 0 750 750 $ramdisk/init* $ramdisk/sbin;

# Prima
ui_print "Setting up Prima..."
if [ -d "/vendor/lib/modules" ]; then
    cp pronto_wlan.ko modules/vendor/lib/modules
fi
if [ -f "/system/lib/modules/pronto_wlan.ko" ]; then
    cp pronto_wlan.ko modules/system/lib/modules
fi

# Patches
# Prevent init from overriding kernel tweaks.
ui_print "Patching init..."
# IMO this is kinda destructive but works
find /system/etc/init/ -type f | while read file; do 
sed -Ei 's;[^#](write /proc/sys/(kernel|vm)/(sched|dirty|perf_cpu|page-cluster|stat|swappiness|vfs));#\1;g' $file
done
# IORap
ui_print "Patching system's build.prop..."
patch_prop /system/build.prop "ro.iorapd.enable" "true"
patch_prop /system/build.prop "iorapd.perfetto.enable" "true"
patch_prop /system/build.prop "iorapd.readahead.enable" "true"
# Replace post_boot with ours.
ui_print "Pushing init.qcom.post_boot.sh..."
replace_file "/vendor/bin/init.qcom.post_boot.sh" "0755" "init.qcom.post_boot.sh"
## AnyKernel install
dump_boot;

# begin ramdisk changes

# end ramdisk changes

write_boot;
## end install

