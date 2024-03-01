class_name AudioLoader

static func load_file(path: String, loop: bool = true):
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	var bytes: PackedByteArray = file.get_buffer(file.get_length())
	
	if path.ends_with(".wav"):
		var new_wav_audio_stream: AudioStreamWAV = AudioStreamWAV.new()
		var bits_per_sample: int = 0
		
		for i in range(0, 100):
			var four_bytes: String = str(char(bytes[i]) + char(bytes[i + 1]) + char(bytes[i + 2]) + char(bytes[i + 3]))
			
			if four_bytes == "fmt ":
				var fsc0: int = i + 8
				var format_code: int = bytes[fsc0] + (bytes[fsc0 + 1] << 8)
				
				if format_code not in range(3):
					format_code = AudioStreamWAV.FORMAT_16_BITS
				
				@warning_ignore("int_as_enum_without_cast")
				new_wav_audio_stream.format = format_code
				
				var channel_num: int = bytes[fsc0 + 2] + (bytes[fsc0 + 3] << 8)
				
				if channel_num == 2: new_wav_audio_stream.stereo = true
				
				var sample_rate: int = bytes[fsc0 + 4] + (bytes[fsc0 + 5] << 8) + (bytes[fsc0 + 6] << 16) + (bytes[fsc0 + 7] << 24)
				
				new_wav_audio_stream.mix_rate = sample_rate
				bits_per_sample = bytes[fsc0 + 14] + (bytes[fsc0 + 15] << 8)
				
			if four_bytes == "data":
				assert(bits_per_sample != 0)
				
				var audio_data_size: int = bytes[i + 4] + (bytes[i + 5] << 8) + (bytes[i + 6] << 16) + (bytes[i + 7] << 24)
				var data_entry_point: int = i + 8
				var data: PackedByteArray = bytes.slice(data_entry_point, data_entry_point+audio_data_size - 1)
				
				if bits_per_sample in [24, 32]:
					new_wav_audio_stream.data = convert_to_16bit(data, bits_per_sample)
				else:
					new_wav_audio_stream.data = data
		
		var samplenum: int = int(new_wav_audio_stream.data.size() / 4.0)
		
		new_wav_audio_stream.loop_end = samplenum
		
		if loop:
			new_wav_audio_stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
		else:
			new_wav_audio_stream.loop_mode = AudioStreamWAV.LOOP_DISABLED
		
		return new_wav_audio_stream
	elif path.ends_with(".ogg"):
		var new_audio_stream_ogg_vorbis: AudioStreamOggVorbis = AudioStreamOggVorbis.load_from_file(path)
		
		new_audio_stream_ogg_vorbis.loop = loop
		
		return new_audio_stream_ogg_vorbis
	elif path.ends_with(".mp3"):
		var new_audio_stream_mp3: AudioStreamMP3 = AudioStreamMP3.new()
		
		new_audio_stream_mp3.data = bytes
		new_audio_stream_mp3.loop = loop
		
		return new_audio_stream_mp3
	
	file.close()

static func convert_to_16bit(data: PackedByteArray, from: int) -> PackedByteArray:
	if from == 24:
		var j: int = 0
		
		for i in range(0, data.size(), 3):
			data[j] = data[i + 1]
			data[j + 1] = data[i + 2]
			j += 2
		
		data.resize(int(data.size() * 2 / 3.0))
	
	if from == 32:
		var stream_peer_buffer: StreamPeerBuffer = StreamPeerBuffer.new()
		var single_float: float
		var value: int
		
		for i in range(0, data.size(), 4):
			stream_peer_buffer.data_array = data.slice(i, i + 3)
			single_float = stream_peer_buffer.get_float()
			value = int(single_float * 32768)
			data[int(i / 2.0)] = value
			data[int((i / 2.0) + 1)] = value >> 8
		
		data.resize(int(data.size() / 2.0))
	
	return data
