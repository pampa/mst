#include "include.h"

VALUE m_Alsa;
VALUE m_Midi;

void Init_alsa() {

	m_Alsa = rb_define_module("ALSA");
	rb_define_singleton_method(m_Alsa,"cards",m_alsa_cards,0);
	
	m_Midi = rb_define_module_under(m_Alsa, "Midi");
	rb_define_singleton_method(m_Midi,"ports",m_alsa_ports,0);

	Init_midi_io_class(m_Midi);
}

