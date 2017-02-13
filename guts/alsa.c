#include <ruby.h>
#include <alsa/asoundlib.h>


// VALUE c_Input;
// VALUE c_Output;
// VALUE m_midi_input_initialize(VALUE self, VALUE port);
// VALUE m_midi_output_open(VALUE self, VALUE port);
// //VALUE m_midi_output_alloc(VALUE klass);
// VALUE m_midi_input_on(VALUE self);
// VALUE m_midi_output_send(VALUE self, VALUE data);

#define RB_RAISE(format, ...) __error_raise(__FILE__,__LINE__,format,##__VA_ARGS__); 

void __error_raise(char* file, int line, char *format, ...) {
    char* err;
    va_list ap;
    va_start(ap, format);
    if(vasprintf(&err, format, ap));
    va_end(ap);
    rb_raise(rb_eRuntimeError,"%s:%d: %s",file,line, err);
}

VALUE m_Alsa;
VALUE m_alsa_ports(void);
VALUE list_card_devices(int);
VALUE list_device(snd_ctl_t *ctl, int card, int device);


void Init_alsa() 
{ 
    m_Alsa = rb_define_module("ALSA");
    rb_define_singleton_method(m_Alsa,"ports",m_alsa_ports,0);
}

VALUE m_alsa_ports(void) 
{
    int card, err;
    VALUE _ary;
    VALUE ary = rb_ary_new();

    card = -1;
    if ((err = snd_card_next(&card)) < 0) {
        RB_RAISE("cannot determine card number: %s", snd_strerror(err));
    }
    if (card < 0) {
        RB_RAISE("no sound card found");
    }
    do {
        _ary = list_card_devices(card);
        if ((err = snd_card_next(&card)) < 0) {
            RB_RAISE("cannot determine card number: %s", snd_strerror(err));
            break;
        }
        rb_ary_concat(ary, _ary);
    } while (card >= 0);

    return ary;
}

VALUE list_card_devices(int card) 
{
    snd_ctl_t *ctl;
    char name[32];
    int device;
    int err;
    VALUE ary = rb_ary_new();
    VALUE _ary;

    sprintf(name, "hw:%d", card);
    if ((err = snd_ctl_open(&ctl, name, 0)) < 0) {
        RB_RAISE("cannot open control for card %d: %s", card, snd_strerror(err));
    }
    device = -1;
    for (;;) {
        if ((err = snd_ctl_rawmidi_next_device(ctl, &device)) < 0) {
            RB_RAISE("cannot determine device number: %s", snd_strerror(err));
        }
        if (device < 0) {
            break;
        }
        _ary = list_device(ctl, card, device);
        rb_ary_concat(ary,_ary);
    }
    snd_ctl_close(ctl);
    return ary;
}

VALUE list_device(snd_ctl_t *ctl, int card, int device)
{
	snd_rawmidi_info_t *info;
	const char *name;
	const char *sub_name;
	int subs, subs_in, subs_out;
	int sub;
	int err;
        VALUE ary = rb_ary_new();
        VALUE hsh;

	snd_rawmidi_info_alloca(&info);
	snd_rawmidi_info_set_device(info, device);

	snd_rawmidi_info_set_stream(info, SND_RAWMIDI_STREAM_INPUT);
	err = snd_ctl_rawmidi_info(ctl, info);
	if (err >= 0)
		subs_in = snd_rawmidi_info_get_subdevices_count(info);
	else
		subs_in = 0;

	snd_rawmidi_info_set_stream(info, SND_RAWMIDI_STREAM_OUTPUT);
	err = snd_ctl_rawmidi_info(ctl, info);
	if (err >= 0)
		subs_out = snd_rawmidi_info_get_subdevices_count(info);
	else
		subs_out = 0;

	subs = subs_in > subs_out ? subs_in : subs_out;
	if (!subs)
		return Qnil;

	for (sub = 0; sub < subs; ++sub) {
		snd_rawmidi_info_set_stream(info, sub < subs_in ?
					    SND_RAWMIDI_STREAM_INPUT :
					    SND_RAWMIDI_STREAM_OUTPUT);
		snd_rawmidi_info_set_subdevice(info, sub);
		err = snd_ctl_rawmidi_info(ctl, info);
		if (err < 0) {
			RB_RAISE("cannot get rawmidi information %d:%d:%d: %s\n",
			      card, device, sub, snd_strerror(err));
		}
		name = snd_rawmidi_info_get_name(info);
		sub_name = snd_rawmidi_info_get_subdevice_name(info);
                hsh = rb_hash_new();
 		rb_hash_aset(hsh,ID2SYM(rb_intern("port")),rb_sprintf("hw:%d,%d,%d",card, device, sub));
 		rb_hash_aset(hsh,ID2SYM(rb_intern("name")),rb_sprintf("%s",name));
 		rb_hash_aset(hsh,ID2SYM(rb_intern("sub_name")),rb_sprintf("%s",sub_name));
 		rb_hash_aset(hsh,ID2SYM(rb_intern("in")),  sub < subs_in  ? Qtrue : Qfalse);
 		rb_hash_aset(hsh,ID2SYM(rb_intern("out")), sub < subs_out ? Qtrue : Qfalse);
 		rb_ary_push(ary,hsh);
	}
        return ary;
}

// void Init_midi_io_class(VALUE m) {
// 	c_Input = rb_define_class_under(m,"Input",rb_cObject);
// 	rb_define_method(c_Input,"initialize",m_midi_input_initialize,1);
// 	rb_define_method(c_Input,"on",m_midi_input_on,0);
// 	rb_define_attr(c_Input, "port",1,0);
// 	
// 	c_Output = rb_define_class_under(m,"Output",rb_cObject);
// 	rb_define_singleton_method(c_Output,"open",m_midi_output_open,1);
// //	rb_define_alloc_func(c_Output,m_midi_output_alloc);
// 	rb_define_method(c_Output,"send",m_midi_output_send,1);
// 	rb_define_method(c_Output,"<<",m_midi_output_send,1);
// 	rb_define_attr(c_Output, "port",1,0);
// }
// 
// VALUE m_midi_input_initialize(VALUE self, VALUE port) {
// 	rb_iv_set(self,"@port",port);
// 	return self;
// }
// 
// VALUE m_midi_input_on(VALUE self) {
// 	VALUE _port = rb_iv_get(self,"@port");
// 	char* port = StringValueCStr(_port);
// 
// 	int status;
// 	int mode = SND_RAWMIDI_SYNC;
// 	snd_rawmidi_t* midiin = NULL;
// 	unsigned char buf[1];        // Storage for input buffer received
// 	unsigned char m_buf[3];
// 	int got    = 0;
// 	int expect = 0;
// 	char* err;
// 
// 	if(rb_block_given_p() == 0) {
// 		RB_RAISE("Error","ALSA::Midi::Input.on requires block");
// 	}
// 
// 	if ((status = snd_rawmidi_open(&midiin, NULL, port, mode)) < 0) {
// 		RB_RAISE("Problem opening MIDI input", snd_strerror(status));
// 	}
// 
// 	for (;;) {
// 		if ((status = snd_rawmidi_read(midiin, buf, 1)) < 0) {
// 			RB_RAISE("Problem reading MIDI input", snd_strerror(status));
// 		}
// 
// 		if(buf[0] == 0xfa ||
// 		   buf[0] == 0xfc ||
// 		   buf[0] == 0xf8) {
// 			rb_yield(rb_sprintf("%c", buf[0]));
// 		} else if (buf[0] >= 0xf0) {
// 			asprintf(&err,"0x%x",buf[0]);
// 			RB_RAISE("Unsupported system message",err); 
// 		} else {
// 			if (buf[0] > 0x7f) {
// 				if(expect != 0) { RB_RAISE("Protocol Error", "got command when expecting data"); }
// 				expect = 2;
// 				m_buf[got] = buf[0];
// 				got++;
// 			} else {
// 				if(expect == 0) { RB_RAISE("Protocol Error", "got data when expecting command"); }
// 				if (got < expect) {
// 					m_buf[got] = buf[0];
// 					got++;
// 				} else {
// 					m_buf[got] = buf[0];
// 					got    = 0;
// 					expect = 0;
// 					rb_yield(rb_sprintf("%c%c%c", m_buf[0], m_buf[1],m_buf[2]));
// 				}
// 			}
// 		}
// 	}
// 
// 	snd_rawmidi_drain(midiin);
// 	snd_rawmidi_close(midiin);
// 	midiin  = NULL; 
// 	return Qnil;
// }
// 
// /*
// VALUE m_midi_output_alloc(VALUE klass) {
// 
// 	return Data_Wrap_Struct(c_Output,NULL,NULL,&midiout);
// } */
// 
// VALUE m_midi_output_open(VALUE class, VALUE port) {
// 	int status;
// 	snd_rawmidi_t* midiout;
// 	int mode = SND_RAWMIDI_SYNC;
//         VALUE data;
// 
// 	char* _port = StringValuePtr(port);
// 
// 	if ((status = snd_rawmidi_open(NULL, &midiout, _port, mode)) < 0) {
// 		RB_RAISE("Problem opening MIDI output", snd_strerror(status));
// 	}
// 	data = Data_Wrap_Struct(class,NULL,NULL,midiout);
// 	rb_iv_set(data,"@port",port);
// 	return data;
// }
// 
// 
// VALUE m_midi_output_send(VALUE self, VALUE data) {
// 	int status;
// 	snd_rawmidi_t* midiout;
// 	char* _data;
//         int _len;
// 
//         Data_Get_Struct(self,snd_rawmidi_t,midiout);
//   
// 	_data = StringValuePtr(data);
// 	_len    = RSTRING_LEN(data);
// 
// 	if ((status = snd_rawmidi_write(midiout, _data , _len)) < 0) {
// 		RB_RAISE("Problem writing to MIDI output", snd_strerror(status));
// 	} 
// 
// 	return Qnil;
// }
