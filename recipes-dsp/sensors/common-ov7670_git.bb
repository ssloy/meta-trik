require video-sensor-ov7670-common.inc
SUMMARY		 = "Init script  for ov7670 camera "

SENSOR_RELEASE_DATE = "150813"

do_install() {
	install -d -m 0755 ${D}/etc/trik/
	install -d -m 0755 ${D}/etc/init.d/
	install -m 0755 ${S}/init-ov7670-320x240.sh ${D}/etc/trik/
	install -m 0755 ${S}/media-sensor ${D}/etc/init.d/
}

