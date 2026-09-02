extends Node

var shop_open := false
var money: int = 120

# Shared shop prices so other systems (autosell) can reference them
@export var seed_prices := [6, 8, 10, 7, 12, 9,  5, 10, 9, 14, 7, 6, 8, 18, 16, 11]
@export var fruit_prices := [8, 12, 14, 10, 18, 14, 7, 15, 12, 18, 10, 9, 11, 26, 22, 16]

signal shop_opened
signal shop_closed
signal shop_refreshed
signal money_changed(new_amount: int)

func open_shop():
	shop_open = true
	emit_signal("shop_opened")

func close_shop():
	shop_open = false
	emit_signal("shop_closed")

func refresh_shop():
	emit_signal("shop_refreshed")

func can_afford(price: int) -> bool:
	return money >= price

func try_spend(price: int) -> bool:
	if money < price:
		return false
	money -= price
	emit_signal("money_changed", money)
	return true

func add_money(amount: int):
	money += amount
	emit_signal("money_changed", money)

func get_seed_price(seed_id: int) -> int:
	if seed_id >= 0 and seed_id < seed_prices.size():
		return int(seed_prices[seed_id])
	return 1

func get_plant_price(plant_id: int) -> int:
	if plant_id >= 0 and plant_id < fruit_prices.size():
		return int(fruit_prices[plant_id])
	return 1

func set_money(amount: int):
	money = max(0, amount)
	emit_signal("money_changed", money)
