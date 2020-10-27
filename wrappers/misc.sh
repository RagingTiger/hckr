# cpu temp
cpu_temp() {
  echo "$(cat /sys/class/thermal/thermal_zone*/temp) mC"
}
