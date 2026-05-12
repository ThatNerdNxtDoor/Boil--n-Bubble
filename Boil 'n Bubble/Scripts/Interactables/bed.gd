extends StaticInteractable

func interaction(caller):
	SignalBus.sleeping.emit()
