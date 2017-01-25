#include "include.h"


VALUE c_Input;
VALUE c_Output;
VALUE m_midi_input_initialize(VALUE self, VALUE port);
VALUE m_midi_output_open(VALUE self, VALUE port);
//VALUE m_midi_output_alloc(VALUE klass);
VALUE m_midi_input_on(VALUE self);
VALUE m_midi_output_send(VALUE self, VALUE data);

void Init_midi_io_class(VALUE m) {
	c_Input = rb_define_class_under(m,"Input",rb_cObject);
	rb_define_method(c_Input,"initialize",m_midi_input_initialize,1);
	rb_define_method(c_Input,"on",m_midi_input_on,0);
	rb_define_attr(c_Input, "port",1,0);
	
	c_Output = rb_define_class_under(m,"Output",rb_cObject);
	rb_define_singleton_method(c_Output,"open",m_midi_output_open,1);
//	rb_define_alloc_func(c_Output,m_midi_output_alloc);
	rb_define_method(c_Output,"send",m_midi_output_send,1);
	rb_define_method(c_Output,"<<",m_midi_output_send,1);
	rb_define_attr(c_Output, "port",1,0);
}

VALUE m_midi_input_initialize(VALUE self, VALUE port) {
	rb_iv_set(self,"@port",port);
	return self;
}

VALUE m_midi_input_on(VALUE self) {
	VALUE _port = rb_iv_get(self,"@port");
	char* port = StringValueCStr(_port);

	int status;
	int mode = SND_RAWMIDI_SYNC;
	snd_rawmidi_t* midiin = NULL;
	unsigned char buf[1];        // Storage for input buffer received
	unsigned char m_buf[3];
	int got    = 0;
	int expect = 0;
	char* err;

	if(rb_block_given_p() == 0) {
		RB_RAISE("Error","ALSA::Midi::Input.on requires block");
	}

	if ((status = snd_rawmidi_open(&midiin, NULL, port, mode)) < 0) {
		RB_RAISE("Problem opening MIDI input", snd_strerror(status));
	}

	for (;;) {
		if ((status = snd_rawmidi_read(midiin, buf, 1)) < 0) {
			RB_RAISE("Problem reading MIDI input", snd_strerror(status));
		}

		if(buf[0] == 0xfa ||
		   buf[0] == 0xfc ||
		   buf[0] == 0xf8) {
			rb_yield(rb_sprintf("%c", buf[0]));
		} else if (buf[0] >= 0xf0) {
			asprintf(&err,"0x%x",buf[0]);
			RB_RAISE("Unsupported system message",err); 
		} else {
			if (buf[0] > 0x7f) {
				if(expect != 0) { RB_RAISE("Protocol Error", "got command when expecting data"); }
				expect = 2;
				m_buf[got] = buf[0];
				got++;
			} else {
				if(expect == 0) { RB_RAISE("Protocol Error", "got data when expecting command"); }
				if (got < expect) {
					m_buf[got] = buf[0];
					got++;
				} else {
					m_buf[got] = buf[0];
					got    = 0;
					expect = 0;
					rb_yield(rb_sprintf("%c%c%c", m_buf[0], m_buf[1],m_buf[2]));
				}
			}
		}
	}

	snd_rawmidi_drain(midiin);
	snd_rawmidi_close(midiin);
	midiin  = NULL; 
	return Qnil;
}

/*
VALUE m_midi_output_alloc(VALUE klass) {

	return Data_Wrap_Struct(c_Output,NULL,NULL,&midiout);
} */

VALUE m_midi_output_open(VALUE class, VALUE port) {
	int status;
	snd_rawmidi_t* midiout;
	int mode = SND_RAWMIDI_SYNC;

	char* _port = StringValuePtr(port);

	if ((status = snd_rawmidi_open(NULL, &midiout, _port, mode)) < 0) {
		RB_RAISE("Problem opening MIDI output", snd_strerror(status));
	}
	VALUE data = Data_Wrap_Struct(class,NULL,NULL,midiout);
	rb_iv_set(data,"@port",port);
	return data;
}


VALUE m_midi_output_send(VALUE self, VALUE data) {
	int status;
	snd_rawmidi_t* midiout;
	Data_Get_Struct(self,snd_rawmidi_t,midiout);
  
	char* _data = StringValuePtr(data);
	int _len    = RSTRING_LEN(data);

	if ((status = snd_rawmidi_write(midiout, _data , _len)) < 0) {
		RB_RAISE("Problem writing to MIDI output", snd_strerror(status));
	} 

	return Qnil;
}
