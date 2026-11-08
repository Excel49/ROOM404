extends Node
## GameState.gd (Autoload Singleton)
## Mengatur state utama ROOM 404:
## - 1 Karakter Utama dengan Nama Pilihan Pemain (player_name)
## - Simbol Kebutuhan Dinamis (Lapar, Haus, Terluka, Cemas) + Bar Status (HP, Kewarasan, Lapar, Haus)
## - Aksi Pintu 1x Sehari (Looting dengan/tanpa Senjata, Masuk Kamar Tetangga 401/402/403/405)
## - Event Tidur Malam & Dialog Visual Novel Interaktif (gaya Gambar 3)

signal state_updated
signal notification_triggered(msg: String)

var day: int = 1
var player_name: String = "Raka"
var selected_character: String = "raka"

# 4 Bar Status Utama (0 - 100)
var health: int = 100
var sanity: int = 100
var hunger: int = 70
var thirst: int = 70
var barricade: int = 80

# Simbol Status Aktif (Muncul di Pojok Kiri Atas & Hilang Saat Klik Makanan/Minuman/P3K/Radio)
var is_hungry: bool = true
var is_thirsty: bool = true
var is_injured: bool = false
var is_stressed: bool = false

# Pembatas Aksi Harian (Poin 6: Pintu hanya bisa dipakai 1x per hari)
var door_used_today: bool = false
var radio_used_today: bool = false
var use_weapon_on_loot: bool = true

var inventory: Dictionary = {
	"food": 3,
	"water": 3,
	"medkit": 1,
	"weapon": true,
	"radio_parts": 1
}

# Catatan Buku Log (Halaman 1 s/d 4 di Buku Catatan 60 Seconds!)
var notebook_page: int = 0
var morning_diary_text: String = ""
var last_action_note: String = ""
var visited_rooms: Dictionary = {}
var story_data: Dictionary = {}

func _ready() -> void:
	load_story_json()
	start_new_game("Raka")

func load_story_json() -> void:
	var path := "res://data/story_data.json"
	if FileAccess.file_exists(path):
		var file := FileAccess.open(path, FileAccess.READ)
		var parsed = JSON.parse_string(file.get_as_text())
		if typeof(parsed) == TYPE_DICTIONARY:
			story_data = parsed

func start_new_game(custom_name: String = "Raka") -> void:
	var clean_name := custom_name.strip_edges()
	if clean_name.is_empty():
		clean_name = "Raka"
	player_name = clean_name
	selected_character = "raka"

	day = 1
	health = 100
	sanity = 100
	hunger = 65
	thirst = 65
	barricade = 80

	# Setiap awal hari pemain lapar & haus sehingga simbol muncul dan bisa diklik di lemari
	is_hungry = true
	is_thirsty = true
	is_injured = false
	is_stressed = false

	door_used_today = false
	radio_used_today = false
	use_weapon_on_loot = true
	visited_rooms.clear()

	inventory = {
		"food": 3,
		"water": 3,
		"medkit": 1,
		"weapon": true,
		"radio_parts": 1
	}

	morning_diary_text = "Kami terbangun di lantai Kamar 404 oleh suara gemuruh hebat dari luar gedung. Peringatan darurat di HP melarang siapa pun keluar gedung.\n\nPerut mulai terasa lapar dan tenggorokan kering. Aku bisa mengambil Kaleng Sup atau Botol Air langsung di lemari, memeriksa Pintu (maksimal 1x sehari), menyalakan Radio, atau klik Tempat Tidur untuk mengakhiri hari."
	last_action_note = "Pintu Kamar 404 belum digunakan hari ini."
	state_updated.emit()

func reset_for_character(char_id: String) -> void:
	start_new_game(player_name)

# --- INTERAKSI KLIK LANGSUNG DI LEMARI KAMAR (POIN 5 & JAWABAN A3) ---
func eat_food_from_shelf() -> String:
	if inventory["food"] <= 0:
		var m := "Stok Kaleng Sup di lemari sudah habis!"
		notification_triggered.emit(m)
		return m
	if not is_hungry and hunger >= 95:
		var m := "%s sudah kenyang hari ini." % player_name
		notification_triggered.emit(m)
		return m

	inventory["food"] -= 1
	hunger = clampi(hunger + 40, 0, 100)
	is_hungry = false # Simbol Lapar langsung hilang!
	last_action_note = "%s memakan 1 Kaleng Sup. Simbol Lapar hilang!" % player_name
	state_updated.emit()
	notification_triggered.emit("🍲 Makan 1 Kaleng Sup (+40% Lapar, Simbol Lapar Hilang)")
	return last_action_note

func drink_water_from_shelf() -> String:
	if inventory["water"] <= 0:
		var m := "Stok Botol Air di lemari sudah habis!"
		notification_triggered.emit(m)
		return m
	if not is_thirsty and thirst >= 95:
		var m := "%s tidak sedang haus." % player_name
		notification_triggered.emit(m)
		return m

	inventory["water"] -= 1
	thirst = clampi(thirst + 45, 0, 100)
	sanity = clampi(sanity + 10, 0, 100)
	is_thirsty = false # Simbol Haus langsung hilang!
	if sanity >= 60:
		is_stressed = false
	last_action_note = "%s meminum 1 Botol Air. Simbol Haus hilang!" % player_name
	state_updated.emit()
	notification_triggered.emit("💧 Minum 1 Botol Air (+45% Haus, Simbol Haus Hilang)")
	return last_action_note

func use_medkit_from_shelf() -> String:
	if inventory["medkit"] <= 0:
		var m := "Stok Kotak P3K di lemari sudah habis!"
		notification_triggered.emit(m)
		return m
	if not is_injured and health >= 95:
		var m := "Kondisi fisik %s masih sehat, simpan P3K untuk saat terluka." % player_name
		notification_triggered.emit(m)
		return m

	inventory["medkit"] -= 1
	health = clampi(health + 50, 0, 100)
	is_injured = false # Simbol Terluka langsung hilang!
	last_action_note = "%s mengobati luka dengan P3K. Simbol Luka hilang!" % player_name
	state_updated.emit()
	notification_triggered.emit("➕ Mengobati luka dengan P3K (+50% HP, Simbol Luka Hilang)")
	return last_action_note

# --- INTERAKSI KLIK RADIO DI MEJA (POIN 6) ---
func use_radio_on_table() -> String:
	if radio_used_today:
		var m := "Radio sudah diperiksa hari ini. Coba lagi besok."
		notification_triggered.emit(m)
		return m

	radio_used_today = true
	sanity = clampi(sanity + 15, 0, 100)
	is_stressed = false
	var msg := ""
	if inventory["radio_parts"] >= 3:
		msg = "📻 SINYAL TERHUBUNG! Tim Evakuasi Helikopter mendengar panggilan %s dari Kamar 404! Bertahanlah malam ini!" % player_name
	else:
		msg = "📻 Frekuensi Darurat Lantai 4: Terdengar siaran musik klasik penenang (+15%% Kewarasan). Komponen Radio saat ini: %d/3." % inventory["radio_parts"]
	last_action_note = msg
	state_updated.emit()
	notification_triggered.emit(msg)
	return msg

# --- INTERAKSI PINTU (MAKSIMAL 1X PER HARI - POIN 5 & 6) ---
func perform_corridor_loot(with_weapon: bool) -> Dictionary:
	door_used_today = true
	var can_use_weapon: bool = with_weapon and bool(inventory["weapon"])
	var roll := randf()
	var result := {
		"title": "LOOTING KORIDOR LANTAI 4",
		"desc": "",
		"open_vn": false,
		"vn_data": {}
	}

	if roll < 0.45:
		inventory["food"] += 1
		inventory["water"] += 1
		result["desc"] = "Kamu menyelinap ke lorong Lantai 4%s dan berhasil mengamankan +1 Kaleng Sup serta +1 Botol Air dari troli kebersihan!" % (" sambil menggenggam Pipa Besi" if can_use_weapon else " dengan tangan kosong")
	elif roll < 0.75:
		if inventory["radio_parts"] < 3:
			inventory["radio_parts"] += 1
			inventory["food"] += 1
			result["desc"] = "Keberuntungan besar! Di dekat kotak sekring koridor, kamu menemukan +1 Komponen Radio Darurat dan +1 Kaleng Sup!"
		else:
			inventory["medkit"] += 1
			result["desc"] = "Kamu menemukan +1 Kotak P3K utuh di loker darurat koridor Lantai 4!"
	else:
		if can_use_weapon:
			inventory["food"] += 1
			result["desc"] = "Seekor penghuni terinfeksi menerjang dari ujung tangga! Berkat Senjata Pipa Besi yang kamu bawa, kamu berhasil menangkisnya tanpa terluka dan membawa pulang +1 Kaleng Sup!"
		else:
			health = clampi(health - 25, 0, 100)
			is_injured = true
			result["desc"] = "BAHAYA! Kamu disergap di koridor gelap tanpa membawa senjata! Kamu berhasil lari kembali ke Kamar 404 namun terluka (-25% HP, Simbol Luka Aktif)."

	last_action_note = result["desc"]
	morning_diary_text += "\n\n[Catatan Pintu]: " + result["desc"]
	state_updated.emit()
	return result

func visit_neighbor_room(room_number: String, with_weapon: bool) -> Dictionary:
	door_used_today = true
	visited_rooms[room_number] = true
	var can_use_weapon: bool = with_weapon and bool(inventory["weapon"])

	# Kamar 401, 402, 403, 405 memiliki variasi isi: Tetangga (VN), Loot, Kosong, atau Bahaya/Damage
	if room_number == "402":
		# Kamar 402: Ada Tetangga (Siska) -> Buka Obrolan Visual Novel (Gambar 3)
		return {
			"open_vn": true,
			"vn_data": {
				"npc_id": "neighbor",
				"speaker": "Siska (Tetangga Kamar 402)",
				"greeting": "Syukurlah kamu manusia normal, %s! Aku kehabisan air minum di Kamar 402, tapi aku masih menyimpan stok obat dan makanan kaleng. Mau bertukar atau bicara sebentar?" % player_name,
				"choice_1": "Tukar 1 Air dengan 2 Kaleng Sup miliknya",
				"choice_2": "Minta perawatan medis darurat (+30% HP)",
				"choice_3": "Pamit kembali ke Kamar 404 (+10% Kewarasan)",
				"context": "room_402"
			}
		}
	elif room_number == "405":
		# Kamar 405: Bertemu Petugas Hazmat yang sedang menyemprot disinfektan (Gambar 3)
		return {
			"open_vn": true,
			"vn_data": {
				"npc_id": "hazmat",
				"speaker": "Hazmat Guy",
				"greeting": "Ada coretan aneh di seluruh dinding Kamar 405 ini... Hei kamu penghuni 404! Aku punya sisa logistik darurat dari Yotte Mart di kantong ini.",
				"choice_1": "Terima bungkusan logistik (+1 Sup & +1 Air)",
				"choice_2": "Tanyakan komponen frekuensi radio (+1 Komponen Radio)",
				"choice_3": "Mundur perlahan dan kembali ke Kamar 404",
				"context": "room_405"
			}
		}
	elif room_number == "401":
		# Kamar 401: Random antara Loot Bagus atau Kosong
		if randf() < 0.65:
			inventory["food"] += 1
			inventory["water"] += 1
			var msg := "Kamu memeriksa Kamar 401. Penghuninya sudah lama mengungsi, menyisakan +1 Kaleng Sup dan +1 Botol Air di meja dapur."
			last_action_note = msg
			morning_diary_text += "\n\n[Kamar 401]: " + msg
			state_updated.emit()
			return { "open_vn": false, "title": "KAMAR 401 — DITEMUKAN LOGISTIK", "desc": msg }
		else:
			sanity = clampi(sanity - 8, 0, 100)
			var msg := "Kamar 401 kosong melompong dan berantakan. Tidak ada satu pun makanan tersisa, hanya suara angin dari jendela pecah (-8% Kewarasan)."
			last_action_note = msg
			morning_diary_text += "\n\n[Kamar 401]: " + msg
			state_updated.emit()
			return { "open_vn": false, "title": "KAMAR 401 — RUANGAN KOSONG", "desc": msg }
	else:
		# Kamar 403: Berbahaya (Ada Bandit / Jebakan)
		if can_use_weapon:
			inventory["medkit"] += 1
			var msg := "Di Kamar 403 ada penjarah liar yang bersembunyi! Melihat Pipa Besi di tanganmu, ia langsung kabur meninggalkan +1 Kotak P3K!"
			last_action_note = msg
			morning_diary_text += "\n\n[Kamar 403]: " + msg
			state_updated.emit()
			return { "open_vn": false, "title": "KAMAR 403 — PENJARAH KABUR!", "desc": msg }
		else:
			health = clampi(health - 22, 0, 100)
			is_injured = true
			var msg := "Saat membuka Kamar 403 tanpa senjata, jebakan kawat pintu melukai lenganmu! Kamu terpaksa kembali ke Kamar 404 (-22% HP, Simbol Luka Aktif)."
			last_action_note = msg
			morning_diary_text += "\n\n[Kamar 403]: " + msg
			state_updated.emit()
			return { "open_vn": false, "title": "KAMAR 403 — TERKENA JEBAKAN!", "desc": msg }

func reinforce_door_today() -> String:
	door_used_today = true
	barricade = clampi(barricade + 25, 0, 100)
	var msg := "Kamu memalu papan tambahan di Pintu 404 (+25% Barikade). Pintu sudah dikunci rapat dan tidak bisa dibuka lagi hari ini."
	last_action_note = msg
	morning_diary_text += "\n\n[Barikade Pintu]: " + msg
	state_updated.emit()
	notification_triggered.emit("🔨 Pintu Kamar 404 diperkuat (+25% Barikade)")
	return msg

# --- PROSES TIDUR MALAM & GENERATOR EVENT KETUKAN PINTU (POIN 7 & 8) ---
func prepare_sleep_night_event() -> Dictionary:
	# Kurangi lapar & haus selama tidur malam
	if is_hungry:
		hunger = clampi(hunger - 22, 0, 100)
		if hunger <= 20:
			health = clampi(health - 15, 0, 100)
			is_injured = true
	else:
		hunger = clampi(hunger - 12, 0, 100)

	if is_thirsty:
		thirst = clampi(thirst - 25, 0, 100)
		sanity = clampi(sanity - 12, 0, 100)
		if thirst <= 20:
			health = clampi(health - 15, 0, 100)
			is_injured = true
	else:
		thirst = clampi(thirst - 14, 0, 100)

	if sanity <= 45:
		is_stressed = true

	# Tentukan Event Malam saat tidur (Ketukan Pintu / Pesan / Bandit / Hazmat / Malam Tenang)
	var pool := [
		{
			"type": "knock_vn",
			"title": "TOK... TOK... TOK! KETUKAN TENGAH MALAM",
			"knock_desc": "Pukul 02:15 dini hari. Kamu terbangun di tempat tidur karena ketukan berat di pintu Kamar 404. Dari balik celah pintu terlihat siluet baju pelindung kuning (Hazmat).",
			"peephole_hint": "Intipan Lubang Pintu: Seorang petugas berjas Hazmat kuning membawa kantong plastik '404 MART'. Tidak tampak membawa senjata tajam.",
			"closed_outcome": "Kamu memilih tetap menutup pintu rapat-rapat. Petugas Hazmat itu menghela napas dan pergi menyusuri lorong.",
			"vn_data": {
				"npc_id": "hazmat",
				"speaker": "Hazmat Guy",
				"greeting": "Ada goresan aneh di sepanjang dinding lantai 4 ini... Baguslah masih ada yang hidup di Kamar 404. Ambil sebagian jatah darurat ini sebelum gudang bawah dikunci.",
				"choice_1": "Terima bungkusan logistik (+1 Kaleng Sup & +1 Air)",
				"choice_2": "Tukar 1 Kaleng Sup dengan 1 Kotak P3K Medis",
				"choice_3": "Tanyakan kabar evakuasi (+15% Kewarasan)",
				"context": "night_hazmat"
			}
		},
		{
			"type": "knock_vn",
			"title": "SUARA KETUKAN PANIK & BISIKAN DI PINTU",
			"knock_desc": "Seseorang mengetuk pintu Kamar 404 dengan tergesa-gesa sambil berbisik meminta tolong dari lorong yang gelap.",
			"peephole_hint": "Intipan Lubang Pintu: Siska, tetangga dari Kamar 402! Ia tampak kedinginan dan membawa suku cadang elektronik kecil.",
			"closed_outcome": "Kamu mengabaikan ketukannya dan tetap mengunci pintu. Suara langkah kakinya menjauh dengan kecewa (-10% Kewarasan).",
			"vn_data": {
				"npc_id": "neighbor",
				"speaker": "Siska (Tetangga 402)",
				"greeting": "%s, syukurlah kamu membuka pintu! Listrik di kamarku mati total. Kalau kamu punya 1 Kaleng Sup hangat, aku bisa memberikan komponen pemancar radio ini padamu!" % player_name,
				"choice_1": "Berikan 1 Sup untuk ditukar +1 Komponen Radio",
				"choice_2": "Ajak mengobrol sebentar untuk saling menenangkan (+20% Kewarasan)",
				"choice_3": "Maaf, stok makananku juga menipis (Tutup pintu kembali)",
				"context": "night_neighbor"
			}
		},
		{
			"type": "knock_vn",
			"title": "GEDORAN KERAS & ANCAMAN BANDIT!",
			"knock_desc": "BRUAK! BRUAK! Seseorang menggedor pintu Kamar 404 sambil berteriak: 'Buka pintunya! Kami tahu ada makanan di dalam!'",
			"peephole_hint": "Intipan Lubang Pintu: BAHAYA! Seorang Bandit Koridor bertopeng membawa linggis besi di depan pintu!",
			"closed_outcome": "Kamu menahan pintu sekuat tenaga dari dalam! Bandit itu gagal mendobrak barikade pintumu dan akhirnya pergi (-15% Barikade, kamu selamat!).",
			"vn_data": {
				"npc_id": "bandit",
				"speaker": "Bandit Koridor",
				"greeting": "Hahaha! Akhirnya kamu buka juga pintunya! Serahkan makananmu sekarang atau rasakan linggis besi ini!",
				"choice_1": "Lawan dengan Senjata Pipa Besi! (Butuh Senjata)",
				"choice_2": "Serahkan 1 Kaleng Sup agar dia pergi tanpa melukaimu",
				"choice_3": "Tendang pintu & kunci paksa! (-20% HP Risiko Terluka)",
				"context": "night_bandit"
			}
		},
		{
			"type": "under_door_note",
			"title": "PESAN KERTAS DI BAWAH CELAH PINTU",
			"knock_desc": "Terdengar suara ketukan pelan 2 kali, lalu selembar amplop kertas diselipkan dari bawah pintu Kamar 404 tanpa ada orang yang menunggu di luar.",
			"peephole_hint": "Intipan Lubang Pintu: Koridor tampak kosong, hanya ada amplop surat dan 1 kaleng makanan di lantai depan pintu.",
			"closed_outcome": "Kamu mengambil surat dari bawah celah pintu tanpa membuka kunci utama. Isinya peta frekuensi radio darurat (+10% Kewarasan)!"
		}
	]

	var chosen: Dictionary = pool[(day - 1) % pool.size()]
	return chosen

func resolve_vn_choice(context: String, choice_idx: int) -> String:
	var outcome := ""
	if context == "room_402":
		if choice_idx == 1:
			if inventory["water"] > 0:
				inventory["water"] -= 1
				inventory["food"] += 2
				outcome = "Kamu memberikan 1 Botol Air kepada Siska, dan ia menyerahkan +2 Kaleng Sup hangat!"
			else:
				outcome = "Kamu tidak punya Botol Air, tapi Siska tetap memberimu +1 Kaleng Sup karena iba."
				inventory["food"] += 1
		elif choice_idx == 2:
			health = clampi(health + 30, 0, 100)
			is_injured = false
			outcome = "Siska membalut lukamu dengan perban medisnya (+30% HP, Simbol Luka Hilang)!"
		else:
			sanity = clampi(sanity + 12, 0, 100)
			is_stressed = false
			outcome = "Kamu berpamitan baik-baik dengan Siska dan kembali ke Kamar 404 (+12% Kewarasan)."

	elif context == "room_405" or context == "night_hazmat":
		if choice_idx == 1:
			inventory["food"] += 1
			inventory["water"] += 1
			outcome = "Petugas Hazmat menyerahkan bungkusan berisi +1 Kaleng Sup dan +1 Botol Air Bersih!"
		elif choice_idx == 2:
			if context == "room_405":
				inventory["radio_parts"] = clampi(inventory["radio_parts"] + 1, 0, 3)
				outcome = "Petugas Hazmat memberikan +1 Komponen Radio Darurat dari sakunya!"
			else:
				if inventory["food"] > 0:
					inventory["food"] -= 1
					inventory["medkit"] += 1
					outcome = "Kamu menukar 1 Kaleng Sup dengan +1 Kotak P3K Medis milik Petugas Hazmat!"
				else:
					inventory["water"] += 1
					outcome = "Karena supmu habis, Petugas Hazmat memberimu +1 Botol Air secara cuma-cuma."
		else:
			sanity = clampi(sanity + 15, 0, 100)
			is_stressed = false
			outcome = "Petugas Hazmat memberitahu bahwa helikopter evakuasi akan menyisir atap gedung pada Hari Ke-10 (+15% Kewarasan)."

	elif context == "night_neighbor":
		if choice_idx == 1:
			if inventory["food"] > 0:
				inventory["food"] -= 1
				inventory["radio_parts"] = clampi(inventory["radio_parts"] + 1, 0, 3)
				outcome = "Siska sangat berterima kasih atas Kaleng Sup itu dan menyerahkan +1 Komponen Radio Darurat!"
			else:
				sanity = clampi(sanity + 10, 0, 100)
				outcome = "Stok supmu sedang kosong, namun Siska tetap mendoakan keselamatanmu (+10% Kewarasan)."
		elif choice_idx == 2:
			sanity = clampi(sanity + 20, 0, 100)
			is_stressed = false
			outcome = "Obrolan hangat di tengah malam membuat pikiranmu jauh lebih tenang (+20% Kewarasan)."
		else:
			outcome = "Kamu meminta maaf dan menutup kembali pintu Kamar 404."

	elif context == "night_bandit":
		if choice_idx == 1:
			if inventory["weapon"]:
				inventory["food"] += 1
				outcome = "Kamu menghantam linggis Bandit itu dengan Pipa Besi! Ia lari terbirit-birit dan menjatuhkan +1 Kaleng Sup!"
			else:
				health = clampi(health - 25, 0, 100)
				is_injured = true
				outcome = "Kamu tidak punya senjata! Bandit itu melukaimu sebelum kamu berhasil mengunci pintu (-25% HP, Simbol Luka Aktif)!"
		elif choice_idx == 2:
			if inventory["food"] > 0:
				inventory["food"] -= 1
				outcome = "Kamu menyerahkan 1 Kaleng Sup. Bandit itu tertawa puas lalu pergi tanpa melukaimu."
			else:
				health = clampi(health - 20, 0, 100)
				is_injured = true
				outcome = "Karena kamu tidak punya sup, Bandit itu marah dan memukul pintu hingga melukaimu (-20% HP)!"
		else:
			health = clampi(health - 20, 0, 100)
			is_injured = true
			outcome = "Kamu menendang pintu sekuat tenaga! Lenganmu tergores linggis (-20% HP), tapi pintu berhasil terkunci kembali!"

	last_action_note = outcome
	state_updated.emit()
	return outcome

func advance_to_next_morning(night_summary: String) -> void:
	day += 1
	# Saat bangun pagi, perut kembali lapar & haus (simbol muncul lagi sampai pemain klik makanan/minuman)
	is_hungry = true
	is_thirsty = true
	door_used_today = false
	radio_used_today = false

	morning_diary_text = "HARI KE-%d — Catatan %s:\n%s\n\nPagi ini aku terbangun di Kamar 404. Jangan lupa klik Kaleng Sup & Botol Air di lemari untuk menghilangkan rasa lapar/haus, dan gunakan Pintu dengan bijak (maksimal 1x sehari)." % [
		day,
		player_name,
		night_summary
	]
	last_action_note = "Hari baru dimulai. Pintu Kamar 404 bisa digunakan 1x hari ini."
	state_updated.emit()
