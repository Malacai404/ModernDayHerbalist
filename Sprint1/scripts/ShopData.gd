extends Node

var shop_open := false
var money: int = 120

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

func set_money(amount: int):
	money = max(0, amount)
	emit_signal("money_changed", money)
