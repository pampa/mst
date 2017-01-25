#include "include.h"

VALUE list_midi_devices_on_card(int card);
VALUE list_subdevice_info(snd_ctl_t *ctl, int card, int device);
int is_input(snd_ctl_t *ctl, int card, int device, int sub);
int is_output(snd_ctl_t *ctl, int card, int device, int sub);


VALUE m_alsa_cards(void) {
	int status;
	int card = -1;
	char* longname  = NULL;
	char* shortname = NULL;
	VALUE ary = rb_ary_new();
	VALUE hsh;

	if ((status = snd_card_next(&card)) < 0) {
		RB_RAISE("cannot determine card number", snd_strerror(status));
	}

	if (card < 0) {
		printf("no sound cards found");
	}

	while (card >= 0) {
		if ((status = snd_card_get_name(card,&shortname)) < 0) {
			RB_RAISE("cannot determine card shortname", snd_strerror(status));
			break;
		}
		if ((status = snd_card_get_longname(card,&longname)) < 0) {
			RB_RAISE("cannot determine card longname", snd_strerror(status));
			break;
		}
		hsh = rb_hash_new();
		rb_hash_aset(hsh,ID2SYM(rb_intern("card")),INT2NUM(card));
		rb_hash_aset(hsh,ID2SYM(rb_intern("name")),rb_sprintf("%s",shortname));
		rb_hash_aset(hsh,ID2SYM(rb_intern("longname")),rb_sprintf("%s",longname));
		rb_hash_aset(hsh,ID2SYM(rb_intern("qtrue")),Qtrue);
		rb_hash_aset(hsh,ID2SYM(rb_intern("qfalse")),Qfalse);
		rb_ary_push(ary,hsh);
		if ((status = snd_card_next(&card)) < 0) {
			RB_RAISE("cannot determine card number", snd_strerror(status));
			break;
		}
	}
	return ary;
}

VALUE m_alsa_ports(void) {
	int status;
	int card = -1;
	VALUE  ary = rb_ary_new();
	VALUE _ary;

	if ((status = snd_card_next(&card)) < 0) {
		RB_RAISE("cannot determine card number", snd_strerror(status));
	}
	if (card < 0) {
		RB_RAISE("ALSA Error","no sound cards found");
	}
	
	while (card >= 0) {
		_ary = list_midi_devices_on_card(card);
		if ((status = snd_card_next(&card)) < 0) {
			RB_RAISE("cannot determine card number", snd_strerror(status));
			break;
		}
		rb_ary_concat(ary, _ary);
	} 
	return ary;
}

VALUE list_midi_devices_on_card(int card) {
	snd_ctl_t *ctl;
	char name[32];
	int device = -1;
	int status;
	VALUE  ary = rb_ary_new();
	VALUE _ary;
	char* err;

	sprintf(name, "hw:%d", card);
	if ((status = snd_ctl_open(&ctl, name, 0)) < 0) {
		asprintf(&err, "cannot open control for card %d", card);
		RB_RAISE(err, snd_strerror(status));
	}

	do {
		status = snd_ctl_rawmidi_next_device(ctl, &device);
		if (status < 0) {
			RB_RAISE("cannot determine device number: %s", snd_strerror(status));
			break;
		}
		if (device >= 0) {
			_ary = list_subdevice_info(ctl, card, device);
			rb_ary_concat(ary, _ary);
		}
	} while (device >= 0);
	snd_ctl_close(ctl);
	return ary;
}



VALUE list_subdevice_info(snd_ctl_t *ctl, int card, int device) {
	snd_rawmidi_info_t *info;
	const char *name;
	const char *sub_name;
	int subs, subs_in, subs_out;
	int sub, in, out;
	int status;
	char* err;
	VALUE ary = rb_ary_new();
	VALUE hsh; 

	snd_rawmidi_info_alloca(&info);
	snd_rawmidi_info_set_device(info, device);

	snd_rawmidi_info_set_stream(info, SND_RAWMIDI_STREAM_INPUT);
	snd_ctl_rawmidi_info(ctl, info);
	subs_in = snd_rawmidi_info_get_subdevices_count(info);
	snd_rawmidi_info_set_stream(info, SND_RAWMIDI_STREAM_OUTPUT);
	snd_ctl_rawmidi_info(ctl, info);
	subs_out = snd_rawmidi_info_get_subdevices_count(info);
	subs = subs_in > subs_out ? subs_in : subs_out;


	sub = 0;
	in = out = 0;
	if ((status = is_output(ctl, card, device, sub)) < 0) {
		asprintf(&err,"cannot get rawmidi information %d:%d",card, device);
		RB_RAISE(err,snd_strerror(status));
	} else if (status) {
		out = 1;
	}

	if (status == 0) {
		if ((status = is_input(ctl, card, device, sub)) < 0) {
			asprintf(&err,"cannot get rawmidi information %d:%d",card, device);
			RB_RAISE(err,snd_strerror(status));
		}
	} else if (status) {
		in = 1;
	}	

	if (status == 0) { 
		RB_RAISE("shit","happened");
	}

	name = snd_rawmidi_info_get_name(info);
	sub_name = snd_rawmidi_info_get_subdevice_name(info);

	for (;;) {
		hsh = rb_hash_new();
		rb_hash_aset(hsh,ID2SYM(rb_intern("port")),rb_sprintf("hw:%d,%d,%d",card, device, sub));
		rb_hash_aset(hsh,ID2SYM(rb_intern("name")),rb_sprintf("%s",name));
		rb_hash_aset(hsh,ID2SYM(rb_intern("sub_name")),rb_sprintf("%s",sub_name));
		rb_hash_aset(hsh,ID2SYM(rb_intern("in")),  in  ? Qtrue : Qfalse);
		rb_hash_aset(hsh,ID2SYM(rb_intern("out")), out ? Qtrue : Qfalse);
		rb_ary_push(ary,hsh);

		if (++sub >= subs) { 
			break;
		}

		in = is_input(ctl, card, device, sub);
		out = is_output(ctl, card, device, sub);
		snd_rawmidi_info_set_subdevice(info, sub);
		
		if (out) {
			snd_rawmidi_info_set_stream(info, SND_RAWMIDI_STREAM_OUTPUT);
			if ((status = snd_ctl_rawmidi_info(ctl, info)) < 0) {
				asprintf(&err,"cannot get rawmidi information %d:%d:%d", card, device, sub);
				RB_RAISE(err,snd_strerror(status));
				break;
			} 
		} else {
			snd_rawmidi_info_set_stream(info, SND_RAWMIDI_STREAM_INPUT);
			if ((status = snd_ctl_rawmidi_info(ctl, info)) < 0) {
				asprintf(&err,"cannot get rawmidi information %d:%d:%d", card, device, sub);
				RB_RAISE(err,snd_strerror(status));
				break;
			}
		}
		sub_name = snd_rawmidi_info_get_subdevice_name(info);
	} 
	return ary;
}



int is_input(snd_ctl_t *ctl, int card, int device, int sub) {
	snd_rawmidi_info_t *info;
	int status;

	snd_rawmidi_info_alloca(&info);
	snd_rawmidi_info_set_device(info, device);
	snd_rawmidi_info_set_subdevice(info, sub);
	snd_rawmidi_info_set_stream(info, SND_RAWMIDI_STREAM_INPUT);

	if ((status = snd_ctl_rawmidi_info(ctl, info)) < 0 && status != -ENXIO) {
		return status;
	} else if (status == 0) {
		return 1;
	}

	return 0;
}

int is_output(snd_ctl_t *ctl, int card, int device, int sub) {
	snd_rawmidi_info_t *info;
	int status;

	snd_rawmidi_info_alloca(&info);
	snd_rawmidi_info_set_device(info, device);
	snd_rawmidi_info_set_subdevice(info, sub);
	snd_rawmidi_info_set_stream(info, SND_RAWMIDI_STREAM_OUTPUT);

	if ((status = snd_ctl_rawmidi_info(ctl, info)) < 0 && status != -ENXIO) {
		return status;
	} else if (status == 0) {
		return 1;
	}

	return 0;
}
