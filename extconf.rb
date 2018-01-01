require 'mkmf'

$CFLAGS     += ' -Wall -Werror -g -std=gnu11 -Wno-error=unused-result -Wno-error=unused-but-set-variable'
$LOCAL_LIBS += `pkg-config --libs alsa`

create_makefile("alsa")
