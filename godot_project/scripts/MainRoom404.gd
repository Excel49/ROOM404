extends Node2D
## MainRoom404.gd
## Mengatur seluruh alur visual & interaksi ROOM 404 berdasarkan 8 Poin Evaluasi:
## 1. Buku Catatan 60 Seconds! Non-Transparan (Gambar 1)
## 2. Simbol Status Dinamis (Lapar/Haus/Luka/Cemas hilang saat klik item) + 4 Bar Warna
## 3. 1 Karakter Utama dengan Input Nama Pemain di Awal Game
## 4. Halaman Menu bergaya Papan Petunjuk Jalan (Gambar 2) dengan Background Eksterior Berbeda
## 5 & 6. Klik Kaleng/Botol di Lemari, Klik Pintu (Maks 1x Sehari: Looting + Opsi Senjata / Kamar Tetangga 401-405), Radio, & Tempat Tidur
## 7 & 8. Event Tidur Malam (Ketukan Pintu/Bandit/Pesan/Hazmat) & Dialog Visual Novel (Gambar 3)

@onready var survivor_sprite: Sprite2D = $SurvivorCharacter/CharSprite
@onready var speech_box: Panel = $SurvivorCharacter/SpeechBubble
@onready var speech_label: Label = $SurvivorCharacter/SpeechBubble/SpeechLabel
@onready var soup_sprite_1: Sprite2D = $ShelfProps/Soup1
@onready var soup_sprite_2: Sprite2D = $ShelfProps/Soup2
@onready var soup_sprite_3: Sprite2D = $ShelfProps/Soup3
@onready var water_sprite_1: Sprite2D = $ShelfProps/Water1
@onready var water_sprite_2: Sprite2D = $ShelfProps/Water2
@onready var medkit_sprite: Sprite2D = $ShelfProps/Medkit1

# --- HOTSPOTS OBJEK DI DALAM KAMAR 404 ---
@onready var room_hotspots: Control = $CanvasLayerUI/RoomInteractiveHotspots
@onready var btn_click_door: Button = $CanvasLayerUI/RoomInteractiveHotspots/BtnClickDoor
@onready var door_tag_label: Label = $CanvasLayerUI/RoomInteractiveHotspots/BtnClickDoor/DoorTag/DoorTagLabel
@onready var btn_click_soup: Button = $CanvasLayerUI/RoomInteractiveHotspots/BtnClickSoup
@onready var btn_click_water: Button = $CanvasLayerUI/RoomInteractiveHotspots/BtnClickWater
@onready var btn_click_medkit: Button = $CanvasLayerUI/RoomInteractiveHotspots/BtnClickMedkit
@onready var btn_click_radio: Button = $CanvasLayerUI/RoomInteractiveHotspots/BtnClickRadio
@onready var btn_click_bed: Button = $CanvasLayerUI/RoomInteractiveHotspots/BtnClickBed

# --- TOP HUD: SIMBOL KEBUTUHAN + 4 BAR WARNA + DAY COUNTER ---
@onready var top_hud: Control = $CanvasLayerUI/TopHUD
@onready var badge_injured: PanelContainer = $CanvasLayerUI/TopHUD/StatusSymbolsBox/BadgeInjured
@onready var badge_hungry: PanelContainer = $CanvasLayerUI/TopHUD/StatusSymbolsBox/BadgeHungry
@onready var badge_thirsty: PanelContainer = $CanvasLayerUI/TopHUD/StatusSymbolsBox/BadgeThirsty
@onready var badge_stressed: PanelContainer = $CanvasLayerUI/TopHUD/StatusSymbolsBox/BadgeStressed
@onready var bar_hp: ProgressBar = $CanvasLayerUI/TopHUD/BarsPanel/BarHP
@onready var bar_sanity: ProgressBar = $CanvasLayerUI/TopHUD/BarsPanel/BarSanity
@onready var bar_hunger: ProgressBar = $CanvasLayerUI/TopHUD/BarsPanel/BarHunger
@onready var bar_thirst: ProgressBar = $CanvasLayerUI/TopHUD/BarsPanel/BarThirst
@onready var day_big_label: Label = $CanvasLayerUI/TopHUD/DayBadge/DayBigLabel
@onready var btn_open_journal: Button = $CanvasLayerUI/BtnOpenJournal
@onready var toast_banner: Panel = $CanvasLayerUI/ToastBanner
@onready var toast_label: Label = $CanvasLayerUI/ToastBanner/ToastLabel

# --- MODAL AKSI PINTU (LOOTING / KAMAR TETANGGA 401-405 / BARIKADE) ---
@onready var door_action_modal: ColorRect = $CanvasLayerUI/DoorActionModal
@onready var btn_toggle_weapon: Button = $CanvasLayerUI/DoorActionModal/DoorCard/BtnToggleWeapon

# --- MODAL BUKU CATATAN 60 SECONDS! NON-TRANSPARAN (GAMBAR 1) ---
@onready var notebook_modal: ColorRect = $CanvasLayerUI/NotebookModal
@onready var book_day_header: Label = $CanvasLayerUI/NotebookModal/BookGraphic/DayHeaderLabel
@onready var book_page_body: RichTextLabel = $CanvasLayerUI/NotebookModal/BookGraphic/PageBodyText
@onready var book_bottom_icons: Label = $CanvasLayerUI/NotebookModal/BookGraphic/BottomIconsLabel

# --- MODAL EVENT TIDUR MALAM (KETUKAN PINTU) ---
@onready var sleep_event_modal: ColorRect = $CanvasLayerUI/SleepEventModal
@onready var sleep_title_label: Label = $CanvasLayerUI/SleepEventModal/SleepBox/SleepTitle
@onready var sleep_desc_label: RichTextLabel = $CanvasLayerUI/SleepEventModal/SleepBox/SleepDesc
@onready var btn_knock_open: Button = $CanvasLayerUI/SleepEventModal/SleepBox/BtnKnockOpen
@onready var btn_knock_peek: Button = $CanvasLayerUI/SleepEventModal/SleepBox/BtnKnockPeek
@onready var btn_knock_keep_closed: Button = $CanvasLayerUI/SleepEventModal/SleepBox/BtnKnockKeepClosed

# --- LAYER DIALOG VISUAL NOVEL (GAMBAR 3) ---
@onready var vn_dialogue_layer: Control = $CanvasLayerUI/VNDialogueLayer
@onready var vn_visitor_sprite: TextureRect = $CanvasLayerUI/VNDialogueLayer/VNVisitorSprite
@onready var vn_speaker_name: Label = $CanvasLayerUI/VNDialogueLayer/VNSpeakerName
@onready var vn_dialogue_text: RichTextLabel = $CanvasLayerUI/VNDialogueLayer/VNDialogueBox/VNDialogueText
@onready var btn_vn_choice_1: Button = $CanvasLayerUI/VNDialogueLayer/VNDialogueBox/VNChoicesBox/BtnVNChoice1
@onready var btn_vn_choice_2: Button = $CanvasLayerUI/VNDialogueLayer/VNDialogueBox/VNChoicesBox/BtnVNChoice2
@onready var btn_vn_choice_3: Button = $CanvasLayerUI/VNDialogueLayer/VNDialogueBox/VNChoicesBox/BtnVNChoice3

# --- MENU AWAL (GAMBAR 2), INPUT NAMA PEMAIN, OPTIONS, & VIDEO OPENING ---
@onready var title_screen_layer: Control = $CanvasLayerUI/TitleScreenLayer
@onready var name_input_modal: ColorRect = $CanvasLayerUI/NameInputModal
@onready var name_line_edit: LineEdit = $CanvasLayerUI/NameInputModal/NameBox/NameLineEdit
@onready var options_modal: Panel = $CanvasLayerUI/OptionsModal
@onready var btn_opt_fullscreen: Button = $CanvasLayerUI/OptionsModal/BtnOptFullscreen
@onready var opening_video_layer: ColorRect = $CanvasLayerUI/OpeningVideoLayer
@onready var video_frame_rect: TextureRect = $CanvasLayerUI/OpeningVideoLayer/VideoFrameRect
@onready var native_ogv_player: VideoStreamPlayer = $CanvasLayerUI/OpeningVideoLayer/NativeOgvPlayer
@onready var opening_audio_player: AudioStreamPlayer = $CanvasLayerUI/OpeningVideoLayer/OpeningAudioPlayer

@onready var room_bg_sprite: Sprite2D = $RoomBackground
@onready var menu_bg_rect: TextureRect = $CanvasLayerUI/TitleScreenLayer/MenuBackground
@onready var book_graphic_rect: TextureRect = $CanvasLayerUI/NotebookModal/BookGraphic
@onready var vn_player_portrait_rect: TextureRect = $CanvasLayerUI/VNDialogueLayer/VNPlayerPortrait

var npc_textures: Dictionary = {}

var is_fullscreen: bool = false
var is_playing_frame_video: bool = false
var current_video_frame: int = 0
var total_video_frames: int = 300
var video_frame_timer: float = 0.0
const VIDEO_FPS: float = 15.0

var current_night_event: Dictionary = {}
var current_vn_context: String = ""
var vn_from_sleep: bool = false
var vn_outcome_pending: bool = false
var toast_tween: Tween = null

func _load_svg_safe(res_path: String) -> Texture2D:
	var abs_path := ProjectSettings.globalize_path(res_path)
	if FileAccess.file_exists(abs_path):
		var svg_str := FileAccess.get_file_as_string(abs_path)
		var img := Image.new()
		if img.load_svg_from_string(svg_str) == OK:
			return ImageTexture.create_from_image(img)
	if ResourceLoader.exists(res_path):
		return load(res_path)
	return null

func _ready() -> void:
	room_bg_sprite.texture = _load_svg_safe("res://assets/backgrounds/bg_room404.svg")
	menu_bg_rect.texture = _load_svg_safe("res://assets/backgrounds/bg_main_menu.svg")
	book_graphic_rect.texture = _load_svg_safe("res://assets/props/notebook_60s.svg")
	vn_player_portrait_rect.texture = _load_svg_safe("res://assets/characters/player_portrait.svg")
	npc_textures = {
		"hazmat": _load_svg_safe("res://assets/characters/npc_hazmat.svg"),
		"neighbor": _load_svg_safe("res://assets/characters/npc_neighbor.svg"),
		"bandit": _load_svg_safe("res://assets/characters/npc_bandit.svg")
	}

	GameState.state_updated.connect(_on_state_updated)
	GameState.notification_triggered.connect(_show_toast)
	_start_character_breathing()
	_on_state_updated()
	_show_title_screen()

func _process(delta: float) -> void:
	if is_playing_frame_video:
		if opening_audio_player.playing:
			var pos := opening_audio_player.get_playback_position()
			var target_frame := int(pos * VIDEO_FPS)
			if target_frame >= total_video_frames:
				_on_opening_video_finished()
				return
			if target_frame != current_video_frame:
				current_video_frame = target_frame
				_display_video_frame(current_video_frame)
		else:
			video_frame_timer += delta
			var frame_step := 1.0 / VIDEO_FPS
			if video_frame_timer >= frame_step:
				video_frame_timer -= frame_step
				current_video_frame += 1
				if current_video_frame >= total_video_frames:
					_on_opening_video_finished()
				else:
					_display_video_frame(current_video_frame)

# =====================================================================
# 1. HALAMAN MENU AWAL (GAMBAR 2) & INPUT NAMA KARAKTER UTAMA (POIN 3 & 4)
# =====================================================================
func _show_title_screen() -> void:
	is_playing_frame_video = false
	if native_ogv_player.is_playing():
		native_ogv_player.stop()
	if opening_audio_player.playing:
		opening_audio_player.stop()

	title_screen_layer.visible = true
	name_input_modal.visible = false
	options_modal.visible = false
	opening_video_layer.visible = false
	room_hotspots.visible = false
	top_hud.visible = false
	btn_open_journal.visible = false
	door_action_modal.visible = false
	notebook_modal.visible = false
	sleep_event_modal.visible = false
	vn_dialogue_layer.visible = false
	toast_banner.visible = false
	speech_box.visible = false

func _start_gameplay_room() -> void:
	title_screen_layer.visible = false
	name_input_modal.visible = false
	options_modal.visible = false
	opening_video_layer.visible = false
	door_action_modal.visible = false
	sleep_event_modal.visible = false
	vn_dialogue_layer.visible = false

	room_hotspots.visible = true
	top_hud.visible = true
	btn_open_journal.visible = true
	speech_box.visible = true
	# Buka Buku Catatan 60 Seconds! saat pagi Hari Ke-1 dimulai
	GameState.notebook_page = 0
	_render_notebook_page()
	notebook_modal.visible = true
	_on_state_updated()

func _on_btn_title_play_pressed() -> void:
	name_line_edit.text = GameState.player_name
	name_input_modal.visible = true
	name_line_edit.grab_focus()

func _on_btn_confirm_start_video_pressed() -> void:
	var chosen_name := name_line_edit.text.strip_edges()
	if chosen_name.is_empty():
		chosen_name = "Raka"
	GameState.start_new_game(chosen_name)
	name_input_modal.visible = false
	title_screen_layer.visible = false
	_start_opening_video()

func _on_btn_confirm_skip_video_pressed() -> void:
	var chosen_name := name_line_edit.text.strip_edges()
	if chosen_name.is_empty():
		chosen_name = "Raka"
	GameState.start_new_game(chosen_name)
	_start_gameplay_room()

func _on_btn_cancel_name_pressed() -> void:
	name_input_modal.visible = false

func _on_btn_title_options_pressed() -> void:
	options_modal.visible = true

func _on_btn_opt_fullscreen_pressed() -> void:
	is_fullscreen = not is_fullscreen
	if is_fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		btn_opt_fullscreen.text = "Layar Penuh (Fullscreen): ON"
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		btn_opt_fullscreen.text = "Layar Penuh (Fullscreen): OFF"

func _on_btn_close_options_pressed() -> void:
	options_modal.visible = false

func _on_btn_title_quit_pressed() -> void:
	get_tree().quit()

func _on_btn_back_to_title_pressed() -> void:
	_show_title_screen()

# =====================================================================
# 2. PEMUTAR VIDEO OPENING (scene_opening.mp4 + scene_opening_audio.wav)
# =====================================================================
func _start_opening_video() -> void:
	opening_video_layer.visible = true
	if ResourceLoader.exists("res://assets/video/opening_404.ogv"):
		video_frame_rect.visible = false
		native_ogv_player.visible = true
		native_ogv_player.stream = load("res://assets/video/opening_404.ogv")
		native_ogv_player.play()
		return

	native_ogv_player.visible = false
	video_frame_rect.visible = true
	current_video_frame = 0
	video_frame_timer = 0.0
	is_playing_frame_video = true
	_display_video_frame(0)
	_play_opening_audio()

func _play_opening_audio() -> void:
	var wav_res := "res://assets/video/scene_opening_audio.wav"
	var wav_abs := ProjectSettings.globalize_path(wav_res)
	if FileAccess.file_exists(wav_abs):
		var stream := AudioStreamWAV.load_from_file(wav_abs)
		if stream != null:
			opening_audio_player.stream = stream
			opening_audio_player.play()
			return
	if ResourceLoader.exists(wav_res):
		opening_audio_player.stream = load(wav_res)
		opening_audio_player.play()

func _display_video_frame(frame_idx: int) -> void:
	var res_path := "res://assets/video/frames/f_%03d.jpg" % frame_idx
	var abs_path := ProjectSettings.globalize_path(res_path)
	if FileAccess.file_exists(abs_path):
		var img := Image.load_from_file(abs_path)
		if img != null:
			video_frame_rect.texture = ImageTexture.create_from_image(img)

func _on_btn_skip_video_pressed() -> void:
	_on_opening_video_finished()

func _on_opening_video_finished() -> void:
	is_playing_frame_video = false
	if native_ogv_player.is_playing():
		native_ogv_player.stop()
	if opening_audio_player.playing:
		opening_audio_player.stop()
	opening_video_layer.visible = false
	_start_gameplay_room()

# =====================================================================
# 3. UPDATE STATUS SIMBOL, BAR WARNA, & OBJEK DI KAMAR (POIN 2, 5, 6)
# =====================================================================
func _start_character_breathing() -> void:
	var tween := create_tween().set_loops()
	tween.tween_property(survivor_sprite, "scale", Vector2(1.0, 1.03), 1.6).set_trans(Tween.TRANS_SINE)
	tween.tween_property(survivor_sprite, "scale", Vector2(1.0, 1.0), 1.6).set_trans(Tween.TRANS_SINE)

func _on_state_updated() -> void:
	# 1. Visibilitas Kaleng Sup, Botol Air, & P3K di Lemari
	var f_count: int = GameState.inventory["food"]
	soup_sprite_1.visible = f_count >= 1
	soup_sprite_2.visible = f_count >= 2
	soup_sprite_3.visible = f_count >= 3
	btn_click_soup.text = "🍲 Makan Sup (%d)" % f_count
	btn_click_soup.disabled = (f_count <= 0)

	var w_count: int = GameState.inventory["water"]
	water_sprite_1.visible = w_count >= 1
	water_sprite_2.visible = w_count >= 2
	btn_click_water.text = "💧 Minum Air (%d)" % w_count
	btn_click_water.disabled = (w_count <= 0)

	var m_count: int = GameState.inventory["medkit"]
	medkit_sprite.visible = m_count >= 1
	btn_click_medkit.text = "➕ Pakai P3K (%d)" % m_count
	btn_click_medkit.disabled = (m_count <= 0)

	# 2. Simbol Status di Pojok Kiri Atas (Hilang saat diklik makan/minum/obat!)
	badge_injured.visible = GameState.is_injured
	badge_hungry.visible = GameState.is_hungry
	badge_thirsty.visible = GameState.is_thirsty
	badge_stressed.visible = GameState.is_stressed

	# 3. Update 4 Bar Warna (HP, Kewarasan, Lapar, Haus)
	bar_hp.value = GameState.health
	bar_sanity.value = GameState.sanity
	bar_hunger.value = GameState.hunger
	bar_thirst.value = GameState.thirst

	# 4. Update Counter Hari di Kanan Atas (DAY X)
	day_big_label.text = "DAY %d" % GameState.day

	# 5. Status Pintu Kamar 404 (Poin 6: Setelah dipakai 1x, tidak bisa dipakai lagi hari itu)
	if GameState.door_used_today:
		door_tag_label.text = "🔒 TERKUNCI HARI INI"
		door_tag_label.modulate = Color(1, 0.45, 0.45, 1)
	else:
		door_tag_label.text = "🚪 PINTU (1x/Hari)"
		door_tag_label.modulate = Color(0.98, 0.85, 0.25, 1)

	btn_click_radio.text = "📻 Radio (%d/3)" % GameState.inventory["radio_parts"]

	# 6. Gelembung Status Karakter Utama
	var p_name := GameState.player_name.to_upper()
	if GameState.is_injured:
		speech_label.text = "%s: AKU TERLUKA!" % p_name
	elif GameState.is_hungry and GameState.is_thirsty:
		speech_label.text = "%s: LAPAR & HAUS..." % p_name
	elif GameState.is_hungry:
		speech_label.text = "%s: PERUTKU LAPAR..." % p_name
	elif GameState.is_thirsty:
		speech_label.text = "%s: TENGGOROKAN HAUS..." % p_name
	else:
		speech_label.text = "%s: KONDISI PRIMA" % p_name

	if notebook_modal.visible:
		_render_notebook_page()

func _show_toast(msg: String) -> void:
	toast_banner.visible = true
	toast_label.text = msg
	if toast_tween != null and toast_tween.is_valid():
		toast_tween.kill()
	toast_banner.modulate = Color(1, 1, 1, 1)
	toast_tween = create_tween()
	toast_tween.tween_interval(2.8)
	toast_tween.tween_property(toast_banner, "modulate:a", 0.0, 0.4)
	toast_tween.tween_callback(func(): toast_banner.visible = false)

# --- KLIK LANGSUNG MAKANAN / MINUMAN / P3K DI LEMARI (POIN 5 & A3) ---
func _on_btn_click_soup_pressed() -> void:
	GameState.eat_food_from_shelf()

func _on_btn_click_water_pressed() -> void:
	GameState.drink_water_from_shelf()

func _on_btn_click_medkit_pressed() -> void:
	GameState.use_medkit_from_shelf()

func _on_btn_click_radio_pressed() -> void:
	GameState.use_radio_on_table()

# =====================================================================
# 4. INTERAKSI PINTU KAMAR 404 (MAKSIMAL 1X SEHARI - POIN 5 & 6)
# =====================================================================
func _on_btn_click_door_pressed() -> void:
	if GameState.door_used_today:
		_show_toast("🔒 Pintu sudah digunakan hari ini! Gunakan Radio, Makan/Minum di lemari, atau klik Tempat Tidur.")
		_shake_camera()
		return
	_update_weapon_toggle_button()
	door_action_modal.visible = true

func _update_weapon_toggle_button() -> void:
	if not GameState.inventory["weapon"]:
		btn_toggle_weapon.text = "🔧 Opsi Senjata: [TIDAK PUNYA SENJATA]"
		btn_toggle_weapon.disabled = true
	else:
		btn_toggle_weapon.disabled = false
		if GameState.use_weapon_on_loot:
			btn_toggle_weapon.text = "🔧 Opsi Senjata: [✓ BAWA SENJATA PIPA BESI SAAT KELUAR]"
		else:
			btn_toggle_weapon.text = "🔧 Opsi Senjata: [   TANPA SENJATA (TANGAN KOSONG)]"

func _on_btn_toggle_weapon_pressed() -> void:
	GameState.use_weapon_on_loot = not GameState.use_weapon_on_loot
	_update_weapon_toggle_button()

func _on_btn_door_loot_pressed() -> void:
	door_action_modal.visible = false
	var res := GameState.perform_corridor_loot(GameState.use_weapon_on_loot)
	_show_toast("🎒 " + str(res.get("desc", "")))
	GameState.notebook_page = 0
	_render_notebook_page()
	notebook_modal.visible = true

func _on_btn_room_401_pressed() -> void:
	_handle_neighbor_room_visit("401")

func _on_btn_room_402_pressed() -> void:
	_handle_neighbor_room_visit("402")

func _on_btn_room_403_pressed() -> void:
	_handle_neighbor_room_visit("403")

func _on_btn_room_405_pressed() -> void:
	_handle_neighbor_room_visit("405")

func _handle_neighbor_room_visit(room_no: String) -> void:
	door_action_modal.visible = false
	var res := GameState.visit_neighbor_room(room_no, GameState.use_weapon_on_loot)
	if res.get("open_vn", false):
		vn_from_sleep = false
		_open_vn_dialogue(res["vn_data"])
	else:
		_show_toast(str(res.get("desc", "")))
		GameState.notebook_page = 0
		_render_notebook_page()
		notebook_modal.visible = true

func _on_btn_door_reinforce_pressed() -> void:
	door_action_modal.visible = false
	GameState.reinforce_door_today()

func _on_btn_close_door_modal_pressed() -> void:
	door_action_modal.visible = false

# =====================================================================
# 5. BUKU CATATAN 60 SECONDS! NON-TRANSPARAN (POIN 1 - GAMBAR 1)
# =====================================================================
func _on_btn_open_journal_pressed() -> void:
	_render_notebook_page()
	notebook_modal.visible = true

func _on_btn_close_journal_pressed() -> void:
	notebook_modal.visible = false

func _on_btn_prev_page_pressed() -> void:
	GameState.notebook_page = maxi(0, GameState.notebook_page - 1)
	_render_notebook_page()

func _on_btn_next_page_pressed() -> void:
	if GameState.notebook_page < 3:
		GameState.notebook_page += 1
		_render_notebook_page()
	else:
		notebook_modal.visible = false

func _on_btn_tab_1_pressed() -> void:
	GameState.notebook_page = 0
	_render_notebook_page()

func _on_btn_tab_2_pressed() -> void:
	GameState.notebook_page = 1
	_render_notebook_page()

func _on_btn_tab_3_pressed() -> void:
	GameState.notebook_page = 2
	_render_notebook_page()

func _on_btn_tab_4_pressed() -> void:
	GameState.notebook_page = 3
	_render_notebook_page()

func _render_notebook_page() -> void:
	var page := GameState.notebook_page
	book_bottom_icons.text = "🍲 Sup: %d   |   💧 Air: %d   |   ➕ P3K: %d   |   📻 Radio: %d/3" % [
		GameState.inventory["food"],
		GameState.inventory["water"],
		GameState.inventory["medkit"],
		GameState.inventory["radio_parts"]
	]

	if page == 0:
		book_day_header.text = "DAY %d" % GameState.day
		book_page_body.text = "[b]Catatan Penyintas: %s[/b]\n\n%s\n\n[b]Status Terakhir:[/b]\n%s" % [
			GameState.player_name,
			GameState.morning_diary_text,
			GameState.last_action_note
		]
	elif page == 1:
		book_day_header.text = "LOGISTIK"
		book_page_body.text = "[b]Stok Lemari Kamar 404:[/b]\n• Kaleng Sup: %d kaleng\n• Botol Air Bersih: %d botol\n• Kotak P3K Medis: %d kotak\n• Senjata Pipa Besi: %s\n\n[b]Kondisi Tubuh %s:[/b]\n• Kesehatan (HP): %d%%\n• Kewarasan: %d%%\n• Tingkat Kenyang: %d%%\n• Tingkat Hidrasi: %d%%\n\n[i]Tip: Klik langsung kaleng/botol di lemari kamar untuk makan & minum![/i]" % [
			GameState.inventory["food"],
			GameState.inventory["water"],
			GameState.inventory["medkit"],
			("Tersedia" if GameState.inventory["weapon"] else "Rusak/Hilang"),
			GameState.player_name,
			GameState.health,
			GameState.sanity,
			GameState.hunger,
			GameState.thirst
		]
	elif page == 2:
		book_day_header.text = "LANTAI 4"
		book_page_body.text = "[b]Peta Kamar Tetangga (Lantai 4):[/b]\n• [b]Kamar 401:[/b] %s\n• [b]Kamar 402 (Siska):[/b] %s\n• [b]Kamar 403:[/b] %s\n• [b]Kamar 405 (Karantina):[/b] %s\n\n[b]Aturan Pintu 404:[/b]\nPintu hanya dapat dibuka [b]1 kali sehari[/b]. Setelah kamu kembali ke dalam kamar, kunci pintu dikaitkan rapat dan kamu hanya bisa beraktivitas di dalam kamar atau tidur." % [
			("Sudah Diperiksa" if GameState.visited_rooms.has("401") else "Belum Diperiksa"),
			("Sudah Dikunjungi" if GameState.visited_rooms.has("402") else "Terdengar Suara Penghuni"),
			("Sudah Diperiksa" if GameState.visited_rooms.has("403") else "Rawan Penjarah"),
			("Sudah Dikunjungi" if GameState.visited_rooms.has("405") else "Zona Petugas Hazmat")
		]
	else:
		book_day_header.text = "EVAKUASI"
		book_page_body.text = "[b]Target Penyelamatan Diri:[/b]\n1. Bertahan hidup hingga [b]DAY 10[/b] saat helikopter menyisir atap gedung.\n2. ATAU kumpulkan [b]3/3 Komponen Radio[/b] (Saat ini: %d/3) dan nyalakan Radio di meja untuk memanggil evakuasi lebih cepat!\n\n[b]Ketahanan Barikade Pintu:[/b] %d%%" % [
			GameState.inventory["radio_parts"],
			GameState.barricade
		]

# =====================================================================
# 6. KLIK TEMPAT TIDUR -> EVENT MALAM & INTERAKSI BUKA/TUTUP (POIN 7 & 8)
# =====================================================================
func _on_btn_click_bed_pressed() -> void:
	# Cek apakah sudah mencapai kondisi Tamat sebelum/saat tidur
	if GameState.health <= 0:
		_trigger_game_over("Luka dan kelelahan membuatmu tak sadarkan diri di Kamar 404.")
		return

	current_night_event = GameState.prepare_sleep_night_event()
	sleep_title_label.text = "🌙 " + str(current_night_event.get("title", "MALAM HARI DI KAMAR 404"))
	sleep_desc_label.text = str(current_night_event.get("knock_desc", ""))

	btn_knock_peek.disabled = false
	if current_night_event.get("type", "") == "knock_vn":
		btn_knock_open.text = "🚪 BUKA PINTU & AJAK BICARA TAMU"
	else:
		btn_knock_open.text = "📩 AMBIL PESAN DI BAWAH PINTU"

	sleep_event_modal.visible = true

func _on_btn_knock_peek_pressed() -> void:
	var hint: String = str(current_night_event.get("peephole_hint", "Koridor tampak remang-remang."))
	sleep_desc_label.text = str(current_night_event.get("knock_desc", "")) + "\n\n[color=#facc15][b]👁️ " + hint + "[/b][/color]"
	btn_knock_peek.disabled = true

func _on_btn_knock_open_pressed() -> void:
	sleep_event_modal.visible = false
	if current_night_event.get("type", "") == "knock_vn":
		vn_from_sleep = true
		_open_vn_dialogue(current_night_event["vn_data"])
	else:
		# Event surat di bawah pintu
		GameState.sanity = clampi(GameState.sanity + 10, 0, 100)
		GameState.inventory["food"] += 1
		_finish_night_and_wake_up("Kamu mengambil surat darurat dan +1 Kaleng Sup yang ditinggalkan kurir di depan pintu (+10% Kewarasan).")

func _on_btn_knock_keep_closed_pressed() -> void:
	sleep_event_modal.visible = false
	var closed_msg: String = str(current_night_event.get("closed_outcome", "Kamu tetap menutup pintu rapat-rapat sepanjang malam."))
	if current_night_event.get("vn_data", {}).get("npc_id", "") == "bandit":
		GameState.barricade = clampi(GameState.barricade - 15, 0, 100)
	_finish_night_and_wake_up(closed_msg)

# =====================================================================
# 7. LAYAR OBROLAN VISUAL NOVEL (PERSIS SEPERTI GAMBAR 3 - POIN 8)
# =====================================================================
func _open_vn_dialogue(vn_data: Dictionary) -> void:
	vn_dialogue_layer.visible = true
	vn_outcome_pending = false
	current_vn_context = str(vn_data.get("context", "night_hazmat"))

	var npc_id: String = str(vn_data.get("npc_id", "hazmat"))
	if npc_textures.has(npc_id):
		vn_visitor_sprite.texture = npc_textures[npc_id]

	vn_speaker_name.text = str(vn_data.get("speaker", "Tamu Misterius"))
	vn_dialogue_text.text = "\"" + str(vn_data.get("greeting", "...")) + "\""

	btn_vn_choice_1.visible = true
	btn_vn_choice_2.visible = true
	btn_vn_choice_3.visible = true
	btn_vn_choice_1.text = "▸ " + str(vn_data.get("choice_1", "Opsi 1"))
	btn_vn_choice_2.text = "▸ " + str(vn_data.get("choice_2", "Opsi 2"))
	btn_vn_choice_3.text = "▸ " + str(vn_data.get("choice_3", "Opsi 3"))

func _on_btn_vn_choice_1_pressed() -> void:
	_handle_vn_choice(1)

func _on_btn_vn_choice_2_pressed() -> void:
	_handle_vn_choice(2)

func _on_btn_vn_choice_3_pressed() -> void:
	_handle_vn_choice(3)

func _handle_vn_choice(choice_idx: int) -> void:
	if vn_outcome_pending:
		# Klik selesai membaca respons VN
		vn_dialogue_layer.visible = false
		if vn_from_sleep:
			_finish_night_and_wake_up(GameState.last_action_note)
		else:
			_show_toast(GameState.last_action_note)
		return

	var outcome_text := GameState.resolve_vn_choice(current_vn_context, choice_idx)
	vn_outcome_pending = true
	vn_dialogue_text.text = "[color=#fde047]" + outcome_text + "[/color]"
	btn_vn_choice_1.text = "▸ [LANJUTKAN / TUTUP PINTU]"
	btn_vn_choice_2.visible = false
	btn_vn_choice_3.visible = false

func _finish_night_and_wake_up(night_summary: String) -> void:
	# Cek menang / kalah
	if GameState.health <= 0:
		_trigger_game_over("Kamu tidak berhasil bertahan melewati malam di Kamar 404. (" + night_summary + ")")
		return
	if GameState.inventory["radio_parts"] >= 3 and GameState.radio_used_today:
		_trigger_victory("🚁 EVAKUASI RADIO BERHASIL! Helikopter penyelamat menjemput %s dari atap Lantai 4!" % GameState.player_name)
		return
	if GameState.day >= 10:
		_trigger_victory("🏆 SELAMAT SAMPAI DAY 10! Tim Penyelamat Nasional membuka kunci gedung dan mengevakuasi %s!" % GameState.player_name)
		return

	GameState.advance_to_next_morning(night_summary)
	GameState.notebook_page = 0
	_render_notebook_page()
	notebook_modal.visible = true
	_show_toast("☀️ Bangun di DAY %d! Cek Buku Catatan & makan/minum di lemari." % GameState.day)

func _trigger_game_over(reason: String) -> void:
	GameState.morning_diary_text = "[b]💀 GAME OVER — TEWAS DI KAMAR 404[/b]\n\n" + reason + "\n\nKlik tombol MENU di kanan atas untuk memulai permainan baru."
	GameState.notebook_page = 0
	_render_notebook_page()
	notebook_modal.visible = true

func _trigger_victory(msg: String) -> void:
	GameState.morning_diary_text = "[b]🎉 BERHASIL SELAMAT DARI KAMAR 404![/b]\n\n" + msg + "\n\nKlik tombol MENU di kanan atas untuk bermain lagi."
	GameState.notebook_page = 0
	_render_notebook_page()
	notebook_modal.visible = true

func _shake_camera() -> void:
	var orig := position
	var tw := create_tween()
	tw.tween_property(self, "position", orig + Vector2(-10, 4), 0.05)
	tw.tween_property(self, "position", orig + Vector2(10, -4), 0.05)
	tw.tween_property(self, "position", orig, 0.05)
