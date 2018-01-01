#include <ruby.h>
#include <alsa/asoundlib.h>
#include <errno.h>

#define THROW(format, ...) __error_raise(__FILE__,__LINE__,format,##__VA_ARGS__); 

void __error_raise(char* file, int line, char *format, ...) 
{
    char* err;
    va_list ap;
    va_start(ap, format);
    if(vasprintf(&err, format, ap));
    va_end(ap);
    rb_raise(rb_eRuntimeError,"%s:%d: %s",file,line, err);
}

typedef struct {
    char* port;
    snd_rawmidi_t* in;
    int npfds;
    int offset;
    int got_bytes;
    int expect_bytes;
    unsigned char buf[3];
} c_input_t;

VALUE m_Alsa;
VALUE m_alsa_ports(void);
VALUE list_card_devices(int);
VALUE list_device(snd_ctl_t *ctl, int card, int device);

VALUE c_Input;
VALUE c_input_init(VALUE self);
VALUE c_input_open(VALUE self, VALUE port);
VALUE c_input_listen(VALUE self);

VALUE c_Output;
VALUE c_output_open(VALUE class, VALUE port);
VALUE c_output_send(VALUE self, VALUE data);


void Init_alsa() 
{ 
    m_Alsa  = rb_define_module("ALSA");
    rb_define_singleton_method(m_Alsa,"ports",m_alsa_ports,0);
    
    c_Input = rb_define_class_under(m_Alsa, "Input", rb_cObject);
    rb_define_method(c_Input,"initialize",c_input_init,0);
    rb_define_method(c_Input,"open",c_input_open,1);
    rb_define_method(c_Input,"listen",c_input_listen,0);

    c_Output = rb_define_class_under(m_Alsa, "Output", rb_cObject);
    rb_define_singleton_method(c_Output,"open",c_output_open,1);
    rb_define_method(c_Output,"send",c_output_send,1);
    rb_define_method(c_Output,"<<",c_output_send,1);
}

VALUE m_alsa_ports(void) 
{
    int card, err;
    VALUE _ary;
    VALUE ary = rb_ary_new();

    card = -1;
    if ((err = snd_card_next(&card)) < 0) {
        THROW("cannot determine card number: %s", snd_strerror(err));
    }
    if (card < 0) {
        THROW("no sound card found");
    }
    do {
        _ary = list_card_devices(card);
        if ((err = snd_card_next(&card)) < 0) {
            THROW("cannot determine card number: %s", snd_strerror(err));
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
        THROW("cannot open control for card %d: %s", card, snd_strerror(err));
    }
    device = -1;
    for (;;) {
        if ((err = snd_ctl_rawmidi_next_device(ctl, &device)) < 0) {
            THROW("cannot determine device number: %s", snd_strerror(err));
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
    if (err >= 0) {
        subs_in = snd_rawmidi_info_get_subdevices_count(info);
    }
    else {
        subs_in = 0;
    }

    snd_rawmidi_info_set_stream(info, SND_RAWMIDI_STREAM_OUTPUT);
    err = snd_ctl_rawmidi_info(ctl, info);
    if (err >= 0) {
        subs_out = snd_rawmidi_info_get_subdevices_count(info);
    }
    else {
        subs_out = 0;
    }

    subs = subs_in > subs_out ? subs_in : subs_out;
    if (!subs) {
        return Qnil;
    }

    for (sub = 0; sub < subs; ++sub) {
        snd_rawmidi_info_set_stream(info, sub < subs_in ?
                                    SND_RAWMIDI_STREAM_INPUT :
                                    SND_RAWMIDI_STREAM_OUTPUT);
        snd_rawmidi_info_set_subdevice(info, sub);
        err = snd_ctl_rawmidi_info(ctl, info);
        if (err < 0) {
            THROW("cannot get rawmidi information %d:%d:%d: %s\n",
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

VALUE c_input_init(VALUE self) 
{
    rb_iv_set(self,"@ports",rb_ary_new());
    return self;
}

VALUE c_input_open(VALUE self, VALUE port) 
{
    VALUE ary;

    ary = rb_iv_get(self,"@ports");

    if (rb_ary_includes(ary,port) == Qfalse) {
        rb_ary_push(ary,port);
    }
    return Qnil;
}

VALUE c_input_listen(VALUE self) 
{
    c_input_t *inp;
    int count, i, err;
    int npfds = 0;
    VALUE ports, _port;
    struct pollfd *pfds;
   
    if(rb_block_given_p() == 0) {
        THROW("ALSA::Input.listen requires a block");
    }

    ports = rb_iv_get(self, "@ports");
    count = RARRAY_LEN(ports);

    inp = alloca(count * sizeof(c_input_t));

    for (i = 0; i < count; i++) {
        _port = rb_ary_entry(rb_iv_get(self,"@ports"),i);
        inp[i].port = StringValueCStr(_port);
        if ((err = snd_rawmidi_open(&inp[i].in, NULL, inp[i].port, SND_RAWMIDI_NONBLOCK)) < 0) {
            THROW("Problem opening MIDI input", snd_strerror(err));
        }
        inp[i].offset = npfds;
        inp[i].got_bytes = 0;
        inp[i].expect_bytes = 0;
        inp[i].npfds = snd_rawmidi_poll_descriptors_count(inp[i].in);
        npfds += inp[i].npfds;
    }

    pfds = alloca(npfds * sizeof(struct pollfd));
    
    for (i = 0; i < count; i++) {
        snd_rawmidi_poll_descriptors(inp[i].in, &pfds[inp[i].offset], inp[i].npfds);
    }

    for (;;) {
        unsigned char buf[1];
        unsigned short revents;

        err = poll(pfds, npfds, -1);
        if (err < 0 && errno == EINTR) {
            break;
        }
        
        if (err < 0) {
            THROW("poll failed: %s", strerror(errno));
            break;
        }

        for (i = 0; i < count; i++) {
            err = snd_rawmidi_poll_descriptors_revents(inp[i].in, &pfds[inp[i].offset], inp[i].npfds, &revents);
            if (err < 0) {
                THROW("cannot get poll events: %s", snd_strerror(errno));
                break;
            }
        
            err = snd_rawmidi_read(inp[i].in, buf, sizeof(buf));
            if (err == -EAGAIN) {
                continue;
            }

            if (err < 0) {
                THROW("cannot read from port \"%s\": %s", inp[i].port, snd_strerror(err));
                break;
            }

	    if(buf[0] == 0xfa ||
               buf[0] == 0xfc ||
               buf[0] == 0xf8) {
                rb_yield_values(2, rb_sprintf("%s",inp[i].port), rb_sprintf("%c",buf[0]));
            } else if (buf[0] >= 0xf0) {
                THROW("SysEx not supported 0x%x",buf[0]); 
            } else {
                if (buf[0] > 0x7f) {
                if(inp[i].expect_bytes != 0) { THROW("got status byte when expecting data"); }
                    inp[i].expect_bytes = 2;
                    inp[i].buf[inp[i].got_bytes] = buf[0];
                    inp[i].got_bytes++;
                } else {
                    if(inp[i].expect_bytes == 0) { THROW("got data when expecting status byte"); }
                    if (inp[i].got_bytes < inp[i].expect_bytes) {
                        inp[i].buf[inp[i].got_bytes] = buf[0];
                        inp[i].got_bytes++;
                    } else {
                        inp[i].buf[inp[i].got_bytes] = buf[0];
                        inp[i].got_bytes = 0;
                        inp[i].expect_bytes = 0;
                        rb_yield_values(2,rb_sprintf("%s",inp[i].port),rb_sprintf("%c%c%c", inp[i].buf[0], inp[i].buf[1],inp[i].buf[2]));
                    }
                }
            }
        }
    }
    return Qnil;
}

VALUE c_output_open(VALUE class, VALUE port)
{
    int status;
    snd_rawmidi_t* midiout;
    char* _port = StringValueCStr(port);

    if ((status = snd_rawmidi_open(NULL, &midiout, _port, SND_RAWMIDI_SYNC)) < 0) {
        THROW("Problem opening MIDI output", snd_strerror(status));
    }

    return Data_Wrap_Struct(class, NULL, NULL, midiout);
}

VALUE c_output_send(VALUE self, VALUE data) {
    int status;
    snd_rawmidi_t* midiout;
    char* _data;
    int _len;

    Data_Get_Struct(self,snd_rawmidi_t,midiout);

    _data = StringValuePtr(data);
    _len    = RSTRING_LEN(data);

    if ((status = snd_rawmidi_write(midiout, _data , _len)) < 0) {
        THROW("Problem writing to MIDI output", snd_strerror(status));
    } 

    return Qnil;
}
