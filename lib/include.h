#include <ruby.h>
#include <alsa/asoundlib.h>

#define RB_RAISE(e,s) rb_raise(rb_eRuntimeError,"%s:%d: %s: %s",__FILE__,__LINE__, e, s);

VALUE m_alsa_cards(void);
VALUE m_alsa_ports(void);
void Init_midi_io_class(VALUE m);
