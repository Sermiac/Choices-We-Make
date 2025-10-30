extends Node

var time = 0
var no_money = 0
var next_cost = "data"


func _ready():
	Globals.reset_data()
	$label_money.text = str(Globals.money)
	$label_A_level.text = str(Globals.lust_level)
	$label_B_level.text = str(Globals.breed_level)
	
	update_costs()


func _process(delta):
	if no_money == 1:
		time += 1 * delta
		if time >= 2:
			time = 0
			no_money = 0
			$label_no_money.text = str("")

func _on_lust_pressed():
	try_upgrade("lust")
	$label_A_level.text = str(Globals.lust_level)
	

func _on_breed_pressed():
	try_upgrade("breed")
	$label_B_level.text = str(Globals.breed_level)

func _on_continue_pressed():
	Globals.upgrade()
	Globals.save_on_file()
	get_tree().change_scene_to_file("res://Scenes/game.tscn")
	
func try_upgrade(stat_name: String) -> void:
	var level = Globals.get(stat_name + "_level")
	var costs = Globals.upgrade_costs.get(stat_name, [])
	
	
	if level >= costs.size():
		update_text("Max level!")
		return
	
	var cost = costs[level]
	if Globals.money >= cost:
		print("Upgrading " + stat_name + " for " + str(cost) + "!")
		update_text("Upgraded for: " + str(cost))
		Globals.money -= cost
		Globals.set(stat_name + "_level", level + 1)
		$label_money.text = str(Globals.money)
		level = Globals.get(stat_name + "_level")
		costs = Globals.upgrade_costs.get(stat_name, [])
		if level >= costs.size():
			update_text("Max level!")
			if stat_name == "lust":
				$label_A_required.text = str("MAX!!")
			elif stat_name == "breed":
				$label_B_required.text = str("MAX!!")
			return
		cost = costs[level]
		next_cost = cost
		if stat_name == "lust":
			$label_A_required.text = str(next_cost)
		elif stat_name == "breed":
			$label_B_required.text = str(next_cost)
		
	else:
		print_no_money()

	
func print_no_money():
	$label_no_money.text = str("Not enough money")
	no_money = 1

func update_text(data_name):
	$label_no_money.text = str(data_name)
	no_money = 1
	
func update_costs():
	if Globals.get("lust_level") < Globals.upgrade_costs.get("lust", ["lust_level"]).size():
		var lust_next_cost = Globals.upgrade_costs.get("lust", ["lust_level"])[Globals.get("lust_level")]
		$label_A_required.text = str(lust_next_cost)
	if Globals.get("lust_level") >= Globals.upgrade_costs.get("lust", ["lust_level"]).size():
		$label_A_required.text = str("MAX!!")
	if Globals.get("breed_level") < Globals.upgrade_costs.get("breed", ["breed_level"]).size():
		var breed_next_cost = Globals.upgrade_costs.get("breed", ["breed_level"])[Globals.get("breed_level")]
		$label_B_required.text = str(breed_next_cost)
	if Globals.get("breed_level") >= Globals.upgrade_costs.get("breed", ["breed_level"]).size():
		$label_B_required.text = str("MAX!!")
